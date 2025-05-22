#!/usr/bin/env nu

use targets.nu
use platforms/linux.nu
use platforms/windows.nu
use platforms/macos.nu

let config = open /build/config.nuon

'nameserver 8.8.8.8' | save -f /etc/resolv.conf

$env.PATH = ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"]

let all_targets = (targets parse $config.targets)

for target in $all_targets.linux {
    print $"Building ($target)..."
    linux build $target
}

for target in $all_targets.windows {
    print $"Building ($target)..."
    windows build $target
}

if ($all_targets.macos | is-not-empty) {
    print "Building macOS..."
    macos build
}
