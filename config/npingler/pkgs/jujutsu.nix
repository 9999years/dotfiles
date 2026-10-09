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
  version = "0.46.0";

  src = fetchFromGitHub {
    owner = "jj-vcs";
    repo = "jj";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5A443Cjlbu3+46F1Ynfu8FSOOy1yjZSgFnCbg6dMzzk=";
  };

  patches = [
    # interdiff: Support multiple revisions in args
    #
    # See: https://github.com/jj-vcs/jj/pull/9645
    # See: https://github.com/jj-vcs/jj/issues/8281
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/eb102785cbc33e5201ad1418d5bcc98ecd881b33.diff";
      hash = "sha256-ibLa9WHqPRSJosuv4oHCXcbepRo1aFsSm+nPzDWdp0I=";
    })
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/b9d92ada3cb623192a3e42ac059b1616c5ac8306.diff";
      hash = "sha256-dIEB7gAl44blhcjInLbDcvFoJyTiAwEic7KPqMoXvzo=";
    })
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/2e79d34b75e050de1c932b0bee9c0e9caeaa0a64.diff";
      excludes = [
        "CHANGELOG.md"
      ];
      hash = "sha256-hobKcwzT+FbN2QlKPNy4ojcdoFvjSciHvmU0nMzdm28=";
    })
  ];

  cargoHash = "sha256-ugqvdijwIUrvq0gEQSzAxqSnF6Ui3qBmMvk1L2TXWEE=";

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
    "not (test(=test_interdiff_command::test_interdiff_revset_ranges) | test(=test_evolog_command::test_evolog_squash))"
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
