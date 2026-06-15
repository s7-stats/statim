#' Extract the hypothesized scalar value from a null claim
#'
#' Rearranges the hypothesis by moving all `param_obj` terms to the left
#' and all scalar terms to the right. Returns the resulting scalar and the
#' (possibly flipped) operator.
#'
#' Only handles linear combinations of parameters.
#'
#' @param claim A `null_claim` object.
#'
#' @return A list with fields `scalar` and `op`.
#'
#' @export
claim_scalar_diff = function(claim) {
    assert_linear(claim@lhs, "claim_scalar_diff")
    assert_linear(claim@rhs, "claim_scalar_diff")

    lhs_terms = collect_terms(claim@lhs, sign = 1L)
    rhs_terms = collect_terms(claim@rhs, sign = -1L)
    all_terms = c(lhs_terms, rhs_terms)

    param_terms = Filter(function(t) t$kind == "param", all_terms)
    scalar_terms = Filter(function(t) t$kind == "scalar", all_terms)

    if (length(param_terms) == 0L) {
        cli::cli_abort(c(
            "No population parameter found in hypothesis.",
            "i" = "At least one side must contain a parameter like {.fn MU}, {.fn PI}, etc."
        ))
    }

    scalar_val = -Reduce("+", lapply(scalar_terms, `[[`, "value"), 0)

    op = claim@op
    lhs_has_only_scalars = !any(vapply(lhs_terms, function(t) t$kind == "param", logical(1)))
    if (lhs_has_only_scalars && length(lhs_terms) > 0L) {
        op = unname(FLIP_OP[op])
    }

    list(scalar = scalar_val, op = op)
}

#' Extract contrast coefficients from a null claim
#'
#' Decomposes the hypothesis into a named numeric vector of coefficients,
#' one per `param_obj` term, plus the hypothesized scalar value and operator.
#'
#' @param claim A `null_claim` object.
#'
#' @return A list with fields `coefs`, `scalar`, and `op`.
#'
#' @export
claim_contrast_coefs = function(claim) {
    assert_linear(claim@lhs, "claim_contrast_coefs")
    assert_linear(claim@rhs, "claim_contrast_coefs")

    lhs_terms = collect_terms(claim@lhs, sign = 1L)
    rhs_terms = collect_terms(claim@rhs, sign = -1L)
    all_terms = c(lhs_terms, rhs_terms)

    param_terms = Filter(function(t) t$kind == "param", all_terms)
    scalar_terms = Filter(function(t) t$kind == "scalar", all_terms)

    if (length(param_terms) == 0L) {
        cli::cli_abort(c(
            "No population parameter found in hypothesis.",
            "i" = "At least one side must contain a parameter like {.fn MU}, {.fn PI}, etc."
        ))
    }

    nms = vapply(param_terms, function(t) extract_param_name(t$node), character(1))
    raw_coefs = vapply(param_terms, `[[`, numeric(1), "coef")
    names(raw_coefs) = nms

    unique_nms = unique(nms)
    coefs = vapply(unique_nms, function(nm) sum(raw_coefs[nms == nm]), numeric(1))
    names(coefs) = unique_nms

    zero_terms = names(coefs[coefs == 0])
    if (length(zero_terms) > 0L) {
        cli::cli_warn(c(
            "Zero-coefficient term{?s} in contrast: {.val {zero_terms}}.",
            "i" = "Duplicate parameters with opposite signs cancelled out.",
            "i" = "Verify the hypothesis is written as intended."
        ))
    }

    scalar_val = -Reduce("+", lapply(scalar_terms, `[[`, "value"), 0)

    op = claim@op
    lhs_has_only_scalars = !any(vapply(lhs_terms, function(t) t$kind == "param", logical(1)))
    if (lhs_has_only_scalars && length(lhs_terms) > 0L) {
        op = unname(FLIP_OP[op])
    }

    list(coefs = coefs, scalar = scalar_val, op = op)
}

#' Build a `.contrasts`-shaped list from a `%=%` chain
#'
#' Extracts coefficients from a `%=%`-chained claim, e.g.
#' `MU(a) %=% (2 * MU(b)) %=% MU(c)`. Each operand becomes its own column
#' (`h01`, `h02`, ...). The matrix carries `"ops"` and `"scalars"`
#' attributes, and is returned inside a list named by the model's grouping
#' variable — the exact shape `.contrasts` resolvers return.
#'
#' @param claim A `null_claim` object with `op == "%=%"`.
#' @param processed The processed model output (`.proc` / `lazy@processed`),
#'   used to look up the grouping variable name.
#' @param operand_resolver A function `function(node)` that turns a single
#'   `%=%` operand into a `claim_contrast_coefs()`-shaped list (`coefs`,
#'   `scalar`, `op`). Defaults to [peq_operand_as_param()], which treats the
#'   operand as a single parameter equated to zero — the current behavior
#'   for `MU(a) %=% (2 * MU(b)) %=% MU(c)`. Supply a different resolver to
#'   support other `%=%` notations (e.g. operands that are themselves linear
#'   combinations, `mu1 - mu2 = mu2 + mu3 = ...`).
#'
#' @return A named list with one element: a numeric matrix with `"ops"` and
#'   `"scalars"` attributes.
#'
#' @export
claim_peq_coefs = function(claim, processed, operand_resolver = peq_operand_as_param) {
    if (claim@op != "%=%") {
        cli::cli_abort("{.arg claim} must have op {.code %=%}.")
    }

    claim_nms = sprintf("h0%d", seq_along(claim@lhs))
    resolved = lapply(claim@lhs, operand_resolver)

    param_nms = unique(unlist(lapply(resolved, function(r) names(r$coefs))))

    grp_name = names(processed$group_data)[[1]]
    all_lvls = unique(as.character(processed$group_data[[grp_name]]))
    row_order = c(param_nms, setdiff(all_lvls, param_nms))

    mat = matrix(
        0,
        nrow = length(row_order),
        ncol = length(claim_nms),
        dimnames = list(row_order, claim_nms)
    )

    for (j in seq_along(resolved)) {
        coef = resolved[[j]]$coefs
        mat[names(coef), j] = coef
    }

    attr(mat, "ops") = vapply(resolved, `[[`, character(1), "op")
    attr(mat, "scalars") = vapply(resolved, `[[`, numeric(1), "scalar")

    rlang::set_names(list(mat), grp_name)
}

#' Default `%=%` operand resolver: a single parameter equated to zero
#'
#' Treats a `%=%` operand (e.g. `MU(a)` or `2 * MU(b)`) as `<operand> == 0`
#' and extracts its coefficient via [claim_contrast_coefs()]. This is the
#' default `operand_resolver` for [claim_peq_coefs()], matching
#' `MU(a) %=% (2 * MU(b)) %=% MU(c)`-style chains.
#'
#' Default `%=%` operand resolver: a single parameter equated to zero
#'
#' Treats a `%=%` operand (e.g. `MU(a)` or `2 * MU(b)`) as `<operand> == 0`
#' and extracts its coefficient via [claim_contrast_coefs()]. This is the
#' default `operand_resolver` for [claim_peq_coefs()], matching
#' `MU(a) %=% (2 * MU(b)) %=% MU(c)`-style chains.
#'
#' @param node A single `%=%` operand node (a `param_obj` or `arith_node`).
#'
#' @return A `claim_contrast_coefs()`-shaped list (`coefs`, `scalar`, `op`).
#'
#' @keywords internal
peq_operand_as_param = function(node) {
    single = null_claim(lhs = node, rhs = 0, op = "==", alt_op = "!=", expr = node)
    claim_contrast_coefs(single)
}

#' Build a `.contrasts`-shaped list from a `list_h0()` block
#'
#' Extracts each named claim's contrast coefficients via
#' [claim_contrast_coefs()] and assembles them into a single matrix, one
#' column per named hypothesis, with each claim's own operator and scalar.
#' Rows are ordered by `.base_null` if present, otherwise by first
#' appearance. The matrix carries `"ops"` and `"scalars"` attributes, and is
#' returned inside a list named by the model's grouping variable — the exact
#' shape `.contrasts` resolvers return.
#'
#' @param claim A `list_h0_claims` object, as returned inside [state_null()]
#'   when using [list_h0()].
#' @param processed The processed model output (`.proc` / `lazy@processed`),
#'   used to look up the grouping variable name.
#'
#' @return A named list with one element: a numeric matrix with `"ops"` and
#'   `"scalars"` attributes.
#'
#' @export
claim_list_h0_coefs = function(claim, processed) {
    if (!S7::S7_inherits(claim, list_h0_claims)) {
        cli::cli_abort("{.arg claim} must be a {.cls list_h0_claims} object.")
    }

    claim_nms = names(claim@claims)
    resolved = lapply(claim@claims, claim_contrast_coefs)

    base_names = if (!is.null(claim@base_claim)) {
        base_nodes = if (claim@base_claim@op == "%=%") {
            claim@base_claim@lhs
        } else {
            unlist(
                lapply(list(claim@base_claim@lhs, claim@base_claim@rhs), param_nodes_from_node),
                recursive = FALSE
            )
        }
        vapply(base_nodes, extract_param_name, character(1))
    } else {
        NULL
    }

    all_param_nms = unique(unlist(lapply(resolved, function(r) names(r$coefs))))
    row_nms = if (!is.null(base_names)) {
        c(base_names, setdiff(all_param_nms, base_names))
    } else {
        all_param_nms
    }

    grp_name = names(processed$group_data)[[1]]
    all_lvls = unique(as.character(processed$group_data[[grp_name]]))
    row_order = c(row_nms, setdiff(all_lvls, row_nms))

    mat = matrix(
        0,
        nrow = length(row_order),
        ncol = length(claim_nms),
        dimnames = list(row_order, claim_nms)
    )

    for (j in seq_along(resolved)) {
        coef = resolved[[j]]$coefs
        mat[names(coef), j] = coef
    }

    attr(mat, "ops") = vapply(resolved, `[[`, character(1), "op")
    attr(mat, "scalars") = vapply(resolved, `[[`, numeric(1), "scalar")

    rlang::set_names(list(mat), grp_name)
}

#' Package resolved claim arguments for injection
#'
#' Used inside a `claim_translator` to declare argument names and values
#' merged into the impl's call. Names must match the formals of the impl's
#' `fn`.
#'
#' @param ... Named arguments to inject.
#'
#' @return A named list with class `"claim_args"`.
#'
#' @keywords internal
#' @noRd
claim_args = function(...) {
    args = list(...)
    if (length(args) == 0L || is.null(names(args)) || any(!nzchar(names(args)))) {
        cli::cli_abort("All arguments to {.fn claim_args} must be named.")
    }
    structure(args, class = "claim_args")
}

contains_param = function(node) {
    if (S7::S7_inherits(node, param_obj)) return(TRUE)
    if (inherits(node, "arith_node")) {
        return(any(vapply(node$operands, contains_param, logical(1))))
    }
    FALSE
}

assert_linear = function(node, call_nm) {
    if (!inherits(node, "arith_node")) return(invisible(NULL))

    op = node$op
    ops = node$operands

    if (op == "*") {
        if (contains_param(ops[[1]]) && contains_param(ops[[2]])) {
            cli::cli_abort(c(
                "Non-linear hypothesis detected: parameter multiplied by parameter.",
                "i" = "{.fn {call_nm}} only handles linear combinations of parameters.",
                "x" = "Found: {.code {deparse(node$expr)}}."
            ))
        }
    }

    if (op == "/") {
        if (contains_param(ops[[2]])) {
            cli::cli_abort(c(
                "Non-linear hypothesis detected: parameter in denominator.",
                "i" = "{.fn {call_nm}} only handles linear combinations of parameters.",
                "x" = "Found: {.code {deparse(node$expr)}}."
            ))
        }
    }

    if (op == "^") {
        if (contains_param(ops[[1]])) {
            cli::cli_abort(c(
                "Non-linear hypothesis detected: parameter raised to a power.",
                "i" = "{.fn {call_nm}} only handles linear combinations of parameters.",
                "x" = "Found: {.code {deparse(node$expr)}}."
            ))
        }
    }

    lapply(ops, assert_linear, call_nm = call_nm)
    invisible(NULL)
}

collect_terms = function(node, sign = 1L, coef = 1) {
    if (is.numeric(node)) {
        return(list(list(kind = "scalar", value = sign * coef * node, node = node)))
    }

    if (S7::S7_inherits(node, param_obj)) {
        return(list(list(kind = "param", coef = sign * coef, node = node)))
    }

    if (inherits(node, "arith_node")) {
        op = node$op
        ops = node$operands

        if (op == "+") {
            return(c(
                collect_terms(ops[[1]], sign, coef),
                collect_terms(ops[[2]], sign, coef)
            ))
        }

        if (op == "-") {
            if (length(ops) == 1L) return(collect_terms(ops[[1]], -sign, coef))
            return(c(
                collect_terms(ops[[1]], sign, coef),
                collect_terms(ops[[2]], -sign, coef)
            ))
        }

        if (op == "*") {
            if (is.numeric(ops[[1]])) return(collect_terms(ops[[2]], sign, coef * ops[[1]]))
            return(collect_terms(ops[[1]], sign, coef * ops[[2]]))
        }

        if (op == "/") {
            return(collect_terms(ops[[1]], sign, coef / ops[[2]]))
        }
    }

    cli::cli_abort(
        "Cannot reduce term to a linear combination: {.code {deparse(node$expr %||% node)}}."
    )
}

extract_param_name = function(node) {
    if (!S7::S7_inherits(node, param_obj)) {
        cli::cli_abort("Expected a param_obj node.")
    }

    if (S7::S7_inherits(node, RHO)) {
        return(paste0(rlang::as_label(node@x), "~", rlang::as_label(node@y)))
    }

    given = node@given

    if (!is.null(given)) {
        given_expr = rlang::quo_get_expr(given)
        if (rlang::is_call(given_expr, "==") && length(given_expr) == 3L) {
            return(as.character(given_expr[[3]]))
        }
        return(deparse(given_expr))
    }

    rlang::as_label(node@x)
}
