use ./common.nu ALPINE_VERSION

export def run [spec: record] {
    let rw_bind = $spec.rw_bind | transpose name value | each {|it| ["--mount", $"type=bind,src=($it.name),dst=($it.value)"]} | flatten
    let ro_bind = $spec.ro_bind | transpose name value | each {|it| ["--mount", $"type=bind,src=($it.name),dst=($it.value),ro"]} | flatten

    # For macOS compatibility, create a separate volume for the build cache.
    # Otherwise, some files appear to be missing when linking the toolchain.
    # Using a volume should also speed up builds on macOS.
    (docker volume create alpine-rustx-build)

    (docker run --rm -t -i -v alpine-rustx-build:/build ...$rw_bind ...$ro_bind $"alpine:($ALPINE_VERSION)" $spec.command)
}
