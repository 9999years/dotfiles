{
  lib,
  fetchPypi,
  setuptools,
  wheel,
  beets,
  buildPythonPackage,
}:

buildPythonPackage (finalAttrs: {
  pname = "beets-copyartifacts3";
  version = "0.1.6";
  pyproject = true;

  src = fetchPypi {
    pname = "beets_copyartifacts3";
    inherit (finalAttrs) version;
    hash = "sha256-Z3I2DHaM0BgPUAttY7LTq+eXFFDeYIIgbbyVUERQ1zM=";
  };

  build-system = [
    setuptools
    wheel
  ];

  nativeBuildInputs = [
    beets
  ];

  meta = {
    description = "Beets plugin to copy non-music files to import path";
    homepage = "https://pypi.org/project/beets-copyartifacts3/";
    license = lib.licenses.mit;
    mainProgram = "beets-copyartifacts3";
  };
})
