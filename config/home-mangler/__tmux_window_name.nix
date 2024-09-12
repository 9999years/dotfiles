{
  writeShellApplication,
  coreutils,
  git,
}:

writeShellApplication {
  name = "__tmux_window_name";
  runtimeInputs = [
    coreutils
    git
  ];
  text = builtins.readFile ./__tmux_window_name.sh;
}
