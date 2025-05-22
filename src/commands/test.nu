def main [config: string, image: string] {
    let config = open $config
    let cargo_commands = ($config.targets | each {|t| $"cargo build --target ($t)"} | str join " && ")
    docker run $image sh -c $"cargo new /project && cd /project && cargo add ring && ($cargo_commands)"
}
