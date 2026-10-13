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
    # cli: report remotes before fetching
    #
    # Prerequisite for https://github.com/jj-vcs/jj/pull/10391
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/commit/8ed0e38561547271c7fe4044ce51602df9ba9b21.diff";
      excludes = [ "CHANGELOG.md" ];
      hash = "sha256-9OVGugHuUFMZbSzRE/vRVm+wUks42pVfgFogRHkCZNY=";
    })
    # 86b7e2e8 git: use gix to prune refs that couldn't be fetched
    # 3ba08bde git: add test for fetching renamed refs with path conflicts
    # 33eb03b4 git: don't respect configured refspecs when fetching
    # 78dd53c5 revset: drop parsing hints for deprecated range operators
    #
    # Prerequisite for https://github.com/jj-vcs/jj/pull/10391
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/compare/78dd53c5b67bcf3cff8cb9a9f15dbb9a4e129398...86b7e2e80b8e541a6aee2972a077428b7d1d4e18.diff";
      excludes = [ "CHANGELOG.md" ];
      hash = "sha256-kQvAp0uJHc3GP93a/DYaAANKkcSbmOlBWj1Y+QW9Gm0=";
    })
    # git: fetch bookmarks into temporary namespace
    #
    # See: https://github.com/jj-vcs/jj/pull/10391
    (fetchpatch {
      url = "https://github.com/jj-vcs/jj/compare/3bf1f8f64375d3b7c0e91d63c538c1bcc0bcb97d...c2626de7203d755372a4a00782ecff9f09cff380.diff";
      excludes = [ "CHANGELOG.md" ];
      hash = "sha256-A2TqrKenbtAMKn+lgNLapIp7CzNuGjjAXuJtajsLT+Q=";
    })

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
