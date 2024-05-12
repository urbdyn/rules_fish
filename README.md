# Rules Fish

This repository provides rules for building [Fish shell](https://fishshell.com/) scripts with
[Bazel](https://bazel.build/).

Work in this repo is currently in progress. Everything is experimental and subject to change.
A number of issues need resolved before this project is suitable for an `0.0.1` release,
including documentation and features beyond a simple `fish_binary` rule. See the GitHub
issues for more information.

To run an interactive demo of Fish shell being built from source and executing in the
bazel execroot, run `bazel run --noincompatible_sandbox_hermetic_tmp //:interactive`
from the `tests/e2e/bzlmod` directory.

> NOTE: Only a Linux x86_64 toolchain is provided today and executing on other platforms
  is a no-op.

You can also build Fish directly and run the binary file from the `bzlmod` directory:

```sh
bazel build --noincompatible_sandbox_hermetic_tmp @fish_toolchains//fish:fish
bazel-bin/external/rules_fish~override~fish_shell~fish_toolchains/fish/fish/bin/fish --private
```
