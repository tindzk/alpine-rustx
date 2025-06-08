#!/usr/bin/env nu
use targets.nu
use platforms/macos.nu

export def generate [config: record] {
    let docker_image = $"rust:($config.rust_version)-alpine($config.alpine_version)"

    mut $base_env = {}
    mut $apk_deps = ["musl-dev"]

    let all_targets = (targets parse $config.targets)

    if (($all_targets.linux | is-not-empty) or ($all_targets.windows | is-not-empty)) {
        $base_env.PATH = "/toolchains/bin:$PATH"
    }

    for target in $all_targets.linux {
        let prefix = $target | str replace "-unknown" ""

        let target_env = $target | str replace -a "-" "_"

        $base_env = $base_env | insert $"CC_($target_env)" $"($prefix)-gcc"
        $base_env = $base_env | insert $"CARGO_TARGET_($target_env | str upcase)_LINKER" $"($prefix)-ld"
    }

    for target in $all_targets.windows {
        let target_env = $target | str replace -a "-" "_"
        let arch = $target | split row "-" | first

        # Unlike Linux, use gcc instead of ld as it links the standard Windows libraries and startup files
        $base_env = $base_env | insert $"CARGO_TARGET_($target_env | str upcase)_LINKER" $"($arch)-w64-mingw32-gcc"

        $base_env.LIBRARY_PATH = $"/toolchains/($arch)-w64-mingw32/lib/"
    }

    for target in $all_targets.macos {
        let target_env = $target | str replace -a "-" "_"
        $base_env = $base_env | insert $"CC_($target_env)" "clang"
        $base_env = $base_env | insert $"CARGO_TARGET_($target_env | str upcase)_LINKER" "rust-lld"
    }

    if ($all_targets.macos | is-not-empty) {
        # iconv and CoreFoundation are needed from macOS SDK
        $base_env.SDKROOT = $"/toolchains/MacOSX($macos.SDK_VERSION).sdk/"
    }

    let macos_commands = if ($all_targets.macos | is-not-empty) {
        mut host_arch = (uname | get machine)
        if $host_arch == "arm64" {
            # Needed if host system is macOS
            $host_arch = "aarch64"
        }

        let rust_objcopy = $"/usr/local/rustup/toolchains/($config.rust_version)-($host_arch)-unknown-linux-musl/lib/rustlib/($host_arch)-unknown-linux-musl/bin/rust-objcopy"

        $apk_deps = [...$apk_deps, "clang", "llvm"]

        # Workaround for: https://github.com/rust-lang/rust/issues/138943
        [$"RUN rm ($rust_objcopy) && ln -s /usr/bin/llvm-objcopy ($rust_objcopy)"]
    } else {
        []
    }

    let component_command = if ($config.components | is-empty) { [] } else { [$"RUN rustup component add ($config.components | str join ' ')"] }

    let nextest_command = if (not $config.nextest) { [] } else { ["RUN wget -O - https://get.nexte.st/latest/linux-musl | tar zxf - -C /usr/local/cargo/bin"] }

    let target_command = $"RUN rustup target add ($all_targets.linux | append $all_targets.macos | append $all_targets.windows | str join ' ')"

    let custom_commands = ($config.commands | each { |c| $"RUN ($c)" })

    let meta = ($config | transpose name value | each {|c| $"LABEL config.($c.name)=\"($c.value | into string | str replace -a '"' '\"')\""})

    return [
        $"FROM ($docker_image)",
        $"RUN apk add --no-cache ($apk_deps | str join ' ')",
        ...$component_command,
        ...$nextest_command,
        "COPY toolchains/ /toolchains/",
        ...($base_env | items {|key, value| echo $'ENV ($key)=($value)' }),
        ...$macos_commands,
        $target_command,
        ...$custom_commands,
        'LABEL generator="alpine-rustx"',
        ...$meta
    ] | str join "\n"
}
