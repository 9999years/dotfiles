{
  lib,
  stdenvNoCC,
  fetchzip,
  makeWrapper,
  nodejs,
  git,
  jujutsu,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "skepsis";
  version = "0.4.0";

  # Upstream publishes a self-contained CLI and frontend bundle.
  src = fetchzip {
    url = "https://registry.npmjs.org/@oxide/skepsis/-/skepsis-${finalAttrs.version}.tgz";
    hash = "sha256-/XSCS6Wsr9kAx3/z/eVZbvoiFTUTUCqIiutKk/BZzUE=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/skepsis
    cp -r dist package.json $out/lib/skepsis/
    makeWrapper ${lib.getExe nodejs} $out/bin/skepsis \
      --add-flags "$out/lib/skepsis/dist/cli.js" \
      --suffix PATH : ${
        lib.makeBinPath [
          jujutsu
          git
        ]
      }
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/skepsis --help
    test -f $out/lib/skepsis/dist/web/index.html
    runHook postInstallCheck
  '';

  meta = {
    description = "Local browser-based code review for jj and Git";
    homepage = "https://github.com/oxidecomputer/skepsis";
    license = lib.licenses.mpl20;
    mainProgram = "skepsis";
    platforms = lib.platforms.unix;
  };
})
