export def normalise [config: record] {
    return ($config
        | default [] components
        | default false nextest
        | default [] commands
        | default "bubblewrap" isolation
    )
}
