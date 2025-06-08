# alpine-rustx
[![CI](https://github.com/tindzk/alpine-rustx/actions/workflows/build.yaml/badge.svg)](https://github.com/tindzk/alpine-rustx/actions/workflows/build.yaml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

alpine-rustx generates lightweight, Alpine-based Docker images for cross-compiling Rust projects to Linux, macOS and Windows across multiple architectures. The environments are pre-configured for the selected targets, eliminating the usual hassle of setting up toolchains.

## Features
- Cross-compile to Linux, Windows and macOS from a single Docker image
- Images are customisable using a simple [NUON](https://www.nushell.sh/book/loading_data.html#nuon) configuration file
- Toolchain builds are cached across configuration changes for fast iterations
- Configuration metadata is embedded in the Docker image for auditing purposes
- Supports two isolation backends: Bubblewrap, Docker
- Tiny Nushell code base (< 500 LOC), designed with modularity in mind

## Example
A self-contained build environment can be defined using a simple configuration file such as:

```nuon
{
    rust_version: "1.86.0"
    alpine_version: "3.21"
    targets: [
        "aarch64-unknown-linux-musl"
        "x86_64-pc-windows-gnu"
        "aarch64-apple-darwin"
    ]
}
```

The generated Docker image allows you to compile your Rust project for any of the targets using `cargo build --target <target>`, without needing to set up Cargo to use the correct compiler or linker for each platform.

## Requirements
- Docker
- [Bubblewrap](https://github.com/containers/bubblewrap) (optional, Linux only)
- A minimum of 15 GB free disk space is recommended

## Installation
Clone the repository:
```shell
git clone https://github.com/tindzk/alpine-rustx.git
cd alpine-rustx
```

Or download the archive:
```shell
wget https://github.com/tindzk/alpine-rustx/archive/refs/heads/main.zip
unzip main.zip
cd alpine-rustx-main
```

Set up the environment:
```shell
export RUSTX_PATH=$(pwd)
export PATH=$RUSTX_PATH:$PATH
```

## Usage
Create a new project and copy the sample configuration:

```shell
mkdir sample-project && cd sample-project
cp $RUSTX_PATH/config.nuon.sample rustx.nuon
```

Edit `rustx.nuon` to match your requirements. Please note that Linux targets currently support only the `musl` variant.

Build all toolchains and generate the `Dockerfile`:

```shell
rustx build rustx.nuon
```

> [!NOTE]
> This automatically fetches the correct Nu version on first run.

Finally, build the Docker image:

```shell
docker build --tag myproject:latest -f build/Dockerfile .
```

## Testing
Validate that the image works correctly by building the [Ring](https://docs.rs/crate/ring/latest) cryptography library which depends on system libraries:

```shell
rustx test rustx.nuon myproject:latest
```

## Comparison
An alternative worth considering is [cross](https://github.com/cross-rs/cross). While alpine-rustx was designed to produce custom Docker images for CI environments, cross is a more general-purpose cross-compilation tool. In addition to building, it can run tests via emulation and its Linux targets support both musl and glibc.

## Credits
alpine-rustx relies on these projects:
- [musl-cross-make](https://github.com/richfelker/musl-cross-make/)
- [mingw-w64-build](https://github.com/Zeranoe/mingw-w64-build)

## Licence
Licenced under the [Apache Licence v2.0](https://www.apache.org/licenses/LICENSE-2.0).
