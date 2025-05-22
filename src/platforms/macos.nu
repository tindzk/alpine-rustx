export const SDK_VERSION = "13.3";

export def build [] {
    cd /toolchains/
    let path = $"MacOSX($SDK_VERSION).sdk"

    if not ($path | path exists) {
        curl -L https://github.com/roblabla/MacOSX-SDKs/releases/download/($SDK_VERSION)/($path).tar.xz | tar xJ
    }
}
