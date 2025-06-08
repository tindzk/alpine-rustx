use ../dockerfile.nu
use ../isolation/bubblewrap.nu
use ../isolation/docker.nu
use ../config.nu

def main [config_path: string] {
    let root_path = ($env.FILE_PWD | path join "../../")

    mut host_arch = (uname | get machine)
    if $host_arch == "arm64" {
        # Needed if host system is macOS
        $host_arch = "aarch64"
    }

    let nu_version = (open ($root_path | path join ".nu_version") | str trim)
    let cfg = config normalise (open $config_path)

    mkdir build
    mkdir toolchains

    mut spec = {
        rw_bind: {
            $"(pwd)/toolchains": "/toolchains"
        }
        ro_bind: {
            $"(pwd)/build/nu-($nu_version)-($host_arch)-unknown-linux-musl/nu": "/bin/nu",
            ($config_path | path expand): "/build/config.nuon",
            ($root_path | path join "src"): "/src"
        }
        command: "/src/build.nu"
    }

    if $cfg.isolation == "bubblewrap" {
        $spec.rw_bind = $spec.rw_bind | insert $"(pwd)/build" "/build"
        bubblewrap run $spec
    } else if $cfg.isolation == "docker" {
        docker run $spec
    } else {
        error "Invalid isolation mode"
    }

    dockerfile generate $cfg | save -f build/Dockerfile
    print "Generated build/Dockerfile"

    "build/\nrootfs/" | save -f build/Dockerfile.dockerignore
    print "Generated build/Dockerfile.dockerignore"
}
