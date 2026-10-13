{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  jujutsu,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jj-hunk";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "laulauland";
    repo = "jj-hunk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Pe0rLEUMXmq+8eUMmjuu5KvFJ/aN53bTQ6/1rE2YcT0=";
  };

  cargoHash = "sha256-tO4oGY92AieYb1SY3ylWSkOlcIKadbZLKOY6nTzXo48=";

  nativeBuildInputs = [ makeBinaryWrapper ];
  nativeCheckInputs = [ jujutsu ];
  cargoTestFlags = [ "--workspace" ];

  postFixup = ''
    wrapProgram $out/bin/jj-hunk \
      --suffix PATH : ${lib.makeBinPath [ jujutsu ]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/jj-hunk --help
    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Non-interactive hunk selection for Jujutsu";
    homepage = "https://github.com/laulauland/jj-hunk";
    changelog = "https://github.com/laulauland/jj-hunk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "jj-hunk";
    platforms = lib.platforms.unix;
  };
})
