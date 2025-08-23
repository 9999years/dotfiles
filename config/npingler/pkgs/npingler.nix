{
  lib,
  stdenv,
  buildPackages,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
}:

let
  emulatorAvailable = stdenv.hostPlatform.emulatorAvailable buildPackages;
  emulator = stdenv.hostPlatform.emulator buildPackages;
in
rustPlatform.buildRustPackage {
  pname = "npingler";
  version = "unstable-2025-08-25";

  src = fetchFromGitHub {
    owner = "9999years";
    repo = "npingler";
    rev = "1bee770d581940341378dca023e0bf03b2ef4cdc";
    hash = "sha256-eVHGRkJYrLtbsvmy1RZNjy9b0y4gUA124EW5R03dRVI=";
  };

  cargoHash = "sha256-j54mF1w6e6tmiiRRvKyN2bupeeAIrzWXqD6FM9yYAHM=";

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString emulatorAvailable ''
    installShellCompletion --cmd npingler \
      --bash <(${emulator} $out/bin/npingler util generate-completions bash) \
      --fish <(${emulator} $out/bin/npingler util generate-completions fish) \
      --zsh  <(${emulator} $out/bin/npingler util generate-completions zsh)
  '';

  meta = {
    description = "Nix profile manager for use with npins";
    homepage = "https://github.com/9999years/npingler";
    license = lib.licenses.mit;
    maintainers = [
      lib.maintainers._9999years
    ];
    mainProgram = "npingler";
  };

  passthru.updateScript = nix-update-script { };
}
