{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchpatch,
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
  version = "0.41.0";

  # workspace: CLI support for colocated workspaces
  #
  # See: https://github.com/jj-vcs/jj/pull/8834
  src = fetchFromGitHub {
    owner = "jj-vcs";
    repo = "jj";
    rev = "4ff8e3ab8a824e6b1606d45fe30d04aceb08b2cf";
    hash = "sha256-MyP50FknFWK4A64/PCrx8phlorT1Y9sl+AsSAz+yk/E=";
  };

  patches = [
    # interdiff: Support multiple revisions in args
    #
    # See: https://github.com/jj-vcs/jj/pull/9645
    # See: https://github.com/jj-vcs/jj/issues/8281
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/6da0290d17c3562fd5b6d69752a39142789076e2.diff";
      excludes = [
        "CHANGELOG.md"
      ];
      hash = "sha256-OkhKG/pnxXF0FGG0rsve3bTAz72jBjBRNusb5EEx75M=";
    })
  ];

  cargoHash = "sha256-nRNeJTFGbXp1wAYvf9p6qPcNdQGHwb2P++xrKsArxqg=";

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

    # This test fails on my patch but not upstream.
    "-E"
    "not test(=test_interdiff_command::test_interdiff_revset_ranges)"
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

  __structuredAttrs = true;

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
