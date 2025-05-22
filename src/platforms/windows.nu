export def build [target: string] {
    let arch = $target | split row "-" | first
    let toolchain_path = $"/toolchains/($arch)-w64-mingw32"

    if not ($toolchain_path | path exists) {
        cd /build/

        if not ("mingw-w64-build" | path exists) {
            wget https://raw.githubusercontent.com/Zeranoe/mingw-w64-build/refs/heads/master/mingw-w64-build
            chmod +x mingw-w64-build
        }

        apk add musl-dev bash g++ flex bison git make m4 curl texinfo

        ./mingw-w64-build --keep-artifacts -r /build/mingw/ -p /toolchains/ $arch

        # See https://git.lix.systems/lix-project/lix/commit/486d1a143720158e7e17abae151b23bd7575fe01#diff-01eed9ba871e09edf30e72cfb33eb833b447582a
        ar r $"($toolchain_path)/lib/libgcc_eh.a"
    }
}
