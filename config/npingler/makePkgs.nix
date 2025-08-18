{
  lib,
  callPackage,
  newScope,
}:
lib.packagesFromDirectoryRecursive {
  inherit callPackage newScope;
  directory = ./pkgs;
}
