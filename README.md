# Merged Starknet Packages

This repository is derived from and based on the following Dart packages:

- [`starknet`](https://pub.dev/packages/starknet)
- [`starknet_provider`](https://pub.dev/packages/starknet_provider)

## About

This repository consolidates the functionality of the `starknet` and
`starknet_provider` packages into a single package and adapts the codebase
for use in internal projects.

In addition to merging the packages, this codebase includes modifications
and cleanup to better align with current project requirements.

## Changes Made

Compared to the original upstream packages, this repository includes:

- Merging `starknet` and `starknet_provider` into a single package
- Removal of deprecated and unused code
- Removal of unused or obsolete constants
- Internal refactoring and improvements
- Dependency version adjustments for compatibility

These changes are functional and structural but remain consistent with
the original design and intent of the upstream projects.

## License & Attribution

This project is based on the open-source Dart packages:

- `starknet`
- `starknet_provider`

Both original packages are licensed under the **MIT License**.
Original copyright notices and license texts are preserved:

- `starknet` — see [LICENSE](./licenses/starknet_LICENSE)
- `starknet_provider` — see [LICENSE](./licenses/starknet_provider_LICENSE)

This repository does not introduce a new license and is governed solely by
the original MIT licenses preserved in this repository.