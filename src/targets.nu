export def parse [targets: list<string>] {
    let native = $"(uname | get machine)-unknown-linux-musl"

    let linux = $targets | filter {|target| ($target | str contains "-linux-") and $target != $native}
    let windows = $targets | filter {|target| ($target | str contains "-windows-")}
    let macos = $targets | filter {|target| ($target | str contains "-apple-darwin")}

    return {
        "native": $native
        "linux": $linux
        "windows": $windows
        "macos": $macos
    }
}
