const MUSL_CROSS_MAKE_COMMIT = "6f3701d08137496d5aac479e3a3977b5ae993c1f"

export def build [target: string] {
    let musl_target = $target | str replace "-unknown" ""
    let toolchain_path = $"/toolchains/($musl_target)"

    if not ($toolchain_path | path exists) {
        cd /build

        let path = $"musl-cross-make-($MUSL_CROSS_MAKE_COMMIT)"

        if not ($path | path exists) {
            wget -O - $"https://github.com/richfelker/musl-cross-make/archive/($MUSL_CROSS_MAKE_COMMIT).zip" | unzip -
        }

        cd $path

        apk add musl-dev g++ make patch

        # unzip does not set executable flag
        chmod +x cowpatch.sh

        echo [$"TARGET = ($musl_target)", "OUTPUT = /toolchains/"] | str join "\n" | save -f config.mak
        make
        make install
    }
}
