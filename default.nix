{ pkgs ? import <nixpkgs> { }, dev ? true }:
let
  inherit (pkgs) stdenv lib ctags jq pipenv;
  inherit (pkgs.gitAndTools) git;
  inherit (lib) inNixShell;
  py = pkgs.python38.withPackages (pypkgs:
    with pypkgs;
    ((lib.optional (inNixShell && dev) [
      black
      autopep8
      yapf
      jedi
      flake8
      bandit
      mypy
      pep8
      pydocstyle
      pylama
      pylint
      isort
      python-ctags3
      pytest
      hypothesis
      rope
      ptpython
      poetry
      conda
    ])
    # --- actual deps
      ++ [ humanize setuptools ]));

in stdenv.mkDerivation {
  pname = "dotfiles";
  version = "0.0.0";
  src = builtins.path {
    name = "dotfiles";
    path = ./.;
  };
  buildInputs = [ py ];

  nativeBuildInputs = lib.optional (dev && inNixShell) [ ctags pipenv ];

  shellHook = let pbin = name: builtins.toJSON "${py}/bin/${name}";
  in lib.optionalString (dev && inNixShell) ''
    gitRoot=$(git rev-parse --show-toplevel)
    if [[ -z "$gitRoot" ]]; then
      echo "Couldn't find Git repo root"
      return 1
    fi

    if [[ ! -e "$gitRoot/.vim/coc-settings.json" ]]; then
      mkdir "$gitRoot/.vim"
      echo "{}" > "$gitRoot/.vim/coc-settings.json"
    fi

    settingsPaths=$(mktemp)
    cat << EOF > "$settingsPaths"
    {
      "python.formatting.autopep8Path": ${pbin "autopep8"},
      "python.formatting.blackPath": ${pbin "black"},
      "python.formatting.yapfPath": ${pbin "yapf"},
      "python.linting.flake8Path": ${pbin "flake8"},
      "python.linting.banditPath": ${pbin "bandit"},
      "python.linting.mypyPath": ${pbin "mypy"},
      "python.linting.pep8Path": ${pbin "pep8"},
      "python.linting.pydocstylePath": ${pbin "pydocstyle"},
      "python.linting.pylamaPath": ${pbin "pylama"},
      "python.linting.pylintPath": ${pbin "pylint"},
      "python.poetryPath": ${pbin "poetry"},
      "python.condaPath": ${pbin "conda"},
      "python.pipenvPath": ${builtins.toJSON "${pipenv}/bin/pipenv"},
      "python.sortImports.path": ${pbin "isort"},
      "python.workspaceSymbols.ctagsPath": ${
        builtins.toJSON "${ctags}/bin/ctags"
      },
      "python.pythonPath": ${pbin "python"}
    }
    EOF

    newSettings=$(mktemp)
    jq --slurp '.[0] * .[1]' \
      "$gitRoot/.vim/coc-settings.json" \
      "$settingsPaths" \
      > "$newSettings"
    mv "$newSettings" "$gitRoot/.vim/coc-settings.json"
    unset tmp
  '';
}
