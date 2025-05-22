use ./common.nu ALPINE_VERSION

export def run [spec: record] {
    let rw_bind = $spec.rw_bind | transpose name value | each {|it| ["--mount", $"type=bind,src=($it.name),dst=($it.value)"]} | flatten
    let ro_bind = $spec.ro_bind | transpose name value | each {|it| ["--mount", $"type=bind,src=($it.name),dst=($it.value),ro"]} | flatten

    (docker run --rm -t -i ...$rw_bind ...$ro_bind $"alpine:($ALPINE_VERSION)" $spec.command)
}
