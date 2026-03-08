{
  lib,
  fetchPypi,
  buildPythonPackage,
  hatchling,
  httpx,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jevkit-runtime";
  version = "0.3.1";
  pyproject = true;

  src = fetchPypi {
    pname = "jevkit_runtime";
    inherit (finalAttrs) version;
    hash = "sha256-W2zBWqtUuWReohjxPCUngFhlhUiZr9l7qZHNA9ljR58=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    httpx
  ];

  optional-dependencies = {
    http2 = [
      httpx.optional-dependencies.http2
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [ "jevkit_runtime" ];

  meta = {
    description = "Shared transport, configuration, caching, and accounting for JevKit tools";
    homepage = "https://github.com/keltokhy/jevkit-core";
    changelog = "https://github.com/keltokhy/jevkit-core/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
  };
})
