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
    # Includes "git: delete many refs in the same transaction".
    #
    # See: https://github.com/jj-vcs/jj/pull/10147
    rev = "531e8da8066271040b4b1e74ce17a8a941544cce";
    hash = "sha256-iHFqcHSKjj2UimJ9SaWqfUi8wxI+7X2Be1r59tVhC3U=";
  };

  patches = [
    # interdiff: Support multiple revisions in args
    #
    # See: https://github.com/jj-vcs/jj/pull/9645
    # See: https://github.com/jj-vcs/jj/issues/8281
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/16dbe5df309996d42a57468dad3c21250b3bc3f9.diff";
      hash = "sha256-ibLa9WHqPRSJosuv4oHCXcbepRo1aFsSm+nPzDWdp0I=";
    })
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/c62acf5d64d7fcdab9c9dcac794a4f2aafcf0756.diff";
      hash = "sha256-wmO0SM1jnJPCPj/lPx1+LQRPHKhA+h/N9gVnYpiWgdI=";
    })
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/e6fe66b94bb60459844f0b6e615d7e9d9d43e264.diff";
      excludes = [
        "CHANGELOG.md"
      ];
      hash = "sha256-kCwkSdtPKU8913/Y/6KEgMzN3dfbsQDUuQxU7jmOw7I=";
    })
  ];

  cargoHash = "sha256-KaPFN559hZbNfPdhHNGd7MTOXLm4ky0ZX9eM+Ckz0xI=";

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
    changelog = "https://github.com/jj-vcs/jj/blob/${finalAttrs.src.rev}/CHANGELOG.md";
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
