{ lib, python38, ctags, pipenv, init_coc_python ? null }:
let
  inherit (lib) inNixShell optionalString;
  pypkgs = python38.pkgs;

in pypkgs.buildPythonApplication {
  pname = "dotfiles";
  version = "0.0.0";
  srcs = if inNixShell then [ ] else [ ./pyproject.toml ./link_dotfiles ];
  unpackCmd = ''
    cp --recursive "$curSrc" "$(stripHash "$curSrc")"
  '';

  format = "flit";

  checkInputs = [ ctags pipenv ] ++ (with pypkgs; [
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
  ]);

  doCheck = true;

  propagatedBuildInputs = with pypkgs; [ humanize setuptools ];

  shellHook = optionalString (init_coc_python != null)
    "${init_coc_python}/bin/init_coc_python.py";
}
