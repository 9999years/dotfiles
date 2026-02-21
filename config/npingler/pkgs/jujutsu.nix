{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  gitMinimal,
  gnupg,
  openssh,
  buildPackages,
  nix-update-script,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jujutsu";
  version = "0.38.0";

  # workspace: CLI support for colocated workspaces
  #
  # See: https://github.com/jj-vcs/jj/pull/8834
  src = fetchFromGitHub {
    owner = "jj-vcs";
    repo = "jj";
    rev = "bb6b0653646ab4d404defb94e2bf8daa9f95b1cb";
    hash = "sha256-+qbab8M7cmToJezVpJo4E/4EKssxiYLoaL26NuBWUms=";
  };

  cargoHash = "sha256-s8VxVQJAdG84D8nNt3XYNgAyyNosy1cvxpZbLkn8roc=";

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = [
    gitMinimal
    gnupg
    openssh
  ];

  cargoBuildFlags = [
    # Don’t install the `gen-protos` build tool.
    "--bin"
    "jj"
  ];

  useNextest = true;

  cargoTestFlags = [
    # Don’t build the `gen-protos` build tool when running tests.
    "-p"
    "jj-lib"
    "-p"
    "jj-cli"
  ];

  env = {
    # Disable vendored libraries.
    ZSTD_SYS_USE_PKG_CONFIG = "1";
    LIBGIT2_NO_VENDOR = "1";
    LIBSSH2_SYS_USE_PKG_CONFIG = "1";
  };

  postInstall =
    let
      jj = "${stdenv.hostPlatform.emulator buildPackages} $out/bin/jj";
    in
    lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) ''
      mkdir -p $out/share/man
      ${jj} util install-man-pages $out/share/man/

      installShellCompletion --cmd jj \
        --bash <(COMPLETE=bash ${jj}) \
        --fish <(COMPLETE=fish ${jj}) \
        --zsh <(COMPLETE=zsh ${jj})
    '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/jj";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Git-compatible DVCS that is both simple and powerful";
    homepage = "https://github.com/jj-vcs/jj";
    changelog = "https://github.com/jj-vcs/jj/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      _0x4A6F
      thoughtpolice
      emily
      bbigras
    ];
    mainProgram = "jj";
  };
})
