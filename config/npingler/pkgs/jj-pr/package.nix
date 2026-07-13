{
  lib,
  gh,
  jujutsu,
  makeBinaryWrapper,
  runCommand,
  writers,
}:

let
  unwrapped = writers.writePython3Bin "jj-pr" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./jj-pr.py);
in
runCommand "jj-pr"
  {
    nativeBuildInputs = [ makeBinaryWrapper ];
    meta = {
      description = "Create pull requests with jj";
      mainProgram = "jj-pr";
    };
  }
  ''
    makeWrapper ${unwrapped}/bin/jj-pr $out/bin/jj-pr \
      --prefix PATH : ${
        lib.makeBinPath [
          gh
          jujutsu
        ]
      }
  ''
