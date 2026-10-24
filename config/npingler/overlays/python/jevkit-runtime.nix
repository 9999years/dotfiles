{
  lib,
  fetchPypi,
  buildPythonPackage,
  hatchling,
  httpx,
  pillow,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jevkit-runtime";
  version = "0.4.3";
  pyproject = true;

  src = fetchPypi {
    pname = "jevkit_runtime";
    inherit (finalAttrs) version;
    hash = "sha256-ChRSkg+r6ch6SCiMgnzpMXuOS0Vm+QKAsXqWdY2w3oA=";
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
    images = [ pillow ];
  };

  nativeCheckInputs = [
    pillow
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
