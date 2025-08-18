{
  writeShellApplication,
  npins,
}:

writeShellApplication {
  name = "npins-init";
  runtimeInputs = [
    npins
  ];
  text = builtins.readFile ./npins-init.sh;
}
