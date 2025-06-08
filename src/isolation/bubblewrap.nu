use ./common.nu ALPINE_VERSION

export def run [spec: record] {
    if not ("rootfs" | path exists) {
        mkdir rootfs

        let major_alpine_version = ($ALPINE_VERSION | split row '.' | take 2 | str join ".")

        let host_arch = (uname | get machine)
        wget -O - $"https://dl-cdn.alpinelinux.org/alpine/v($major_alpine_version)/releases/($host_arch)/alpine-minirootfs-($ALPINE_VERSION)-($host_arch).tar.gz" | tar -xz -C rootfs
    }

    let rw_bind = $spec.rw_bind | transpose name value | each {|it| ["--bind", $it.name, $it.value]} | flatten
    let ro_bind = $spec.ro_bind | transpose name value | each {|it| ["--ro-bind", $it.name, $it.value]} | flatten

    (bwrap
        --bind rootfs /
        ...$rw_bind
        ...$ro_bind
        --proc /proc
        --dev /dev
        --uid 0
        --gid 0
        --unshare-pid
        --clearenv
        $spec.command
    )
}
