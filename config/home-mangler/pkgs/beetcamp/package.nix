{
  fetchFromGitHub,
  python3Packages,
  beets,
  lib,
}:

let
  version = "0.22.0";
in

python3Packages.buildPythonApplication {
  pname = "beetcamp";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "snejus";
    repo = "beetcamp";
    tag = "0.22.0";
    hash = "sha256-5tcQtvYmXT213mZnzKz2kwE5K22rro++lRF65PjC5X0=";
  };

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = [
    beets
    python3Packages.pycountry
    python3Packages.httpx
    python3Packages.packaging
  ];

  # Needs unpackaged `rich-tables`.
  doCheck = false;

  meta = {
    description = "Music tagger and library organizer";
    homepage = "https://beets.io";
    license = lib.licenses.gpl2;
    mainProgram = "beetcamp";
  };
}
