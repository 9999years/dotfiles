{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  gitMinimal,
  hatchling,
  httpx,
  jevkit-runtime,
  pathspec,
  pytestCheckHook,
  unidiff,
}:

buildPythonPackage (finalAttrs: {
  pname = "jev-grep";
  version = "0.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "keltokhy";
    repo = "jgrep";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BB6nBTVqpILRJ6JX5on16FV8oIJAKO4h3Lv+ilKkahQ=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    httpx
    jevkit-runtime
    pathspec
    unidiff
  ];

  # Skipping the `code` extra (`tree-sitter{,-c,-go}`), which only adds `--functions`
  # support for Go and C. Python `--functions` uses `ast` and needs no extra.
  #
  # Tests for the Go and C paths `importorskip` the grammars, so they skip cleanly.

  # Nixpkgs ships unidiff 1.x; jgrep pins `<0.8` but only uses `PatchSet` and
  # `UnidiffParseError`, which are unchanged. The test suite exercises this.
  pythonRelaxDeps = [
    "unidiff"
  ];

  nativeCheckInputs = [
    gitMinimal # `jgrep review` shells out to `git`.
    pytestCheckHook
  ];

  pythonImportsCheck = [ "jgrep" ];

  meta = {
    description = "grep by meaning: filter lines with a plain-English description";
    homepage = "https://github.com/keltokhy/jgrep";
    changelog = "https://github.com/keltokhy/jgrep/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "jgrep";
  };
})
