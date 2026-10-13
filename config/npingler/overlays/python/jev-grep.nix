{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchPypi,
  gitMinimal,
  hatchling,
  httpx,
  jevkit-runtime,
  pathspec,
  pytestCheckHook,
  unidiff,
}:

let
  # unidiff 1.x ignores differing `---` paths after a `diff --git` header,
  # bypassing jgrep's malformed-path handling.
  unidiff_0_7 = unidiff.overridePythonAttrs (
    finalAttrs: _: {
      version = "0.7.5";
      src = fetchPypi {
        pname = "unidiff";
        inherit (finalAttrs) version;
        hash = "sha256-Ll8BYgUiSJRrnwlwpA6eEkI2v4bIK3CCEUOm/B3qJXQ=";
      };
    }
  );
in
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
    unidiff_0_7
  ];

  # Skipping the `code` extra (`tree-sitter{,-c,-go}`), which only adds `--functions`
  # support for Go and C. Python `--functions` uses `ast` and needs no extra.
  #
  # Tests for the Go and C paths `importorskip` the grammars, so they skip cleanly.

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
