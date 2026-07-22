# Contributing to statim

Thank you for your interest in contributing to statim. We are genuinely
grateful for every contribution; your time and ideas make this project
better and directly help us as maintainers.

## Code of Conduct

By participating in this project, you agree to follow the rules in
[CODE_OF_CONDUCT.md](https://s7-stats.github.io/statim/dev/CODE_OF_CONDUCT.md).

## Ways to Contribute

- Report bugs and suggest features using GitHub issues.
- Improve documentation and examples.
- Submit pull requests for fixes and enhancements.

## Development Setup

1.  Clone the repository.
2.  Install development dependencies in R:

``` r

install.packages(c("devtools", "roxygen2", "testthat"))
```

3.  Load the package for development:

``` r

devtools::load_all()
```

## Tooling

This project enforces code style via two tools:

- [Air](https://posit-dev.github.io/air/) for code formatting
- [lintr](https://lintr.r-lib.org/) for static analysis

For installation, see the [Air CLI
guide](https://posit-dev.github.io/air/cli.html). Verify with
`air --version`. For editor integration, see the [editor
guides](https://posit-dev.github.io/air/editors.html).

The project root contains an `air.toml` — your editor will pick it up
automatically.

## Style Rules

- Use `=` for assignment, not `<-`.
- 4-space indentation (enforced by `air.toml`).

## Pull Request Guidelines

- Keep pull requests focused and small when possible.

- Add or update tests when behavior changes.

- Update documentation for user-facing changes.

- Format the project before submitting:

  ``` bash
  air format .
  ```

- Check for linting issues:

  ``` r

  lintr::lint_package()
  ```

- Run checks:

  ``` r

  devtools::check()
  ```

Both `air format .` and
[`lintr::lint_package()`](https://lintr.r-lib.org/reference/lint.html)
must produce no errors. Every pull request runs automated checks via CI
— unformatted code or linting violations will fail the build.

## Questions

If you are unsure how to approach a change, open an issue to discuss it
first.
