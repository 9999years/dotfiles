{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  fetchpatch,
}:
buildDotnetModule {
  pname = "slsk-batchdl";
  version = "2.4.7";

  src = fetchFromGitHub {
    owner = "fiso64";
    repo = "slsk-batchdl";
    rev = "v2.4.7";
    hash = "sha256-P7V7YJUA1bkfp13Glb1Q+NJ7iTya/xgO1TM88z1Nddc=";
  };

  patches = [
    # Debug-log search results.
    #
    # See: https://github.com/fiso64/slsk-batchdl/pull/116
    (fetchpatch {
      url = "https://github.com/fiso64/slsk-batchdl/commit/1b45215afcf51853d790051e2584e61b2fe63056.patch";
      hash = "sha256-UMS4yHCd4SDSBilrhdpVwaiBNcv7yBxHR+m8zmrUZEc=";
    })

    # Ignore underscores in integer/double parameters
    #
    # Allows e.g. `max-stale-time = 600_000`.
    #
    # See: https://github.com/fiso64/slsk-batchdl/pull/119
    (fetchpatch {
      url = "https://github.com/fiso64/slsk-batchdl/commit/3e7aab7205752b1236b0d0ee179cc84013871ab2.patch";
      hash = "sha256-TO80jHGnyLIITnBU/FPn41YqyOObBzcpt4+4ukyPDkY=";
    })

    # Log download completion, e.g. `Completed 13/41 downloads = 31.70%`.
    #
    # See: https://github.com/fiso64/slsk-batchdl/pull/118
    (fetchpatch {
      url = "https://github.com/fiso64/slsk-batchdl/commit/2c43baacaebed0c2f3d7bdf938f2d00dfea5cb47.patch";
      hash = "sha256-VRCSTE4xfZQbwGKo50bhizyg8Tq8WXQCCZBXsmW9QTc=";
    })

    # Add `spotify-albums` input type.
    #
    # See: https://github.com/fiso64/slsk-batchdl/pull/124
    (fetchpatch {
      url = "https://github.com/fiso64/slsk-batchdl/commit/7ca39ba3963b58e09a38438f43f114bfef99a039.patch";
      hash = "sha256-9NTnGyCRMAl5sc8+K6cK8l96MwuyXHJv7jsrBzEWmdE=";
    })
  ];

  postPatch = ''
    # .NET 6 is EOL, .NET 8 works fine modulo the trimming flag.
    # See: https://github.com/fiso64/slsk-batchdl/issues/112
    sed \
        --in-place \
        --expression "s|<TargetFramework>net6\.0</TargetFramework>|<TargetFramework>net8\.0</TargetFramework>|g" \
        slsk-batchdl/slsk-batchdl.csproj \
        slsk-batchdl.Tests/slsk-batchdl.Tests.csproj \
  '';

  projectFile = "slsk-batchdl/slsk-batchdl.csproj";

  # Tests fail to build.
  # See: https://github.com/fiso64/slsk-batchdl/issues/111
  # testProjectFile = "slsk-batchdl.Tests/slsk-batchdl.Tests.csproj";

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;
  executables = [ "sldl" ];

  dotnetFlags = [
    "--property:PublishSingleFile=true"
    # Note: This breaks Spotify authentication!
    # See: https://github.com/fiso64/slsk-batchdl/issues/112
    # "--property:PublishTrimmed=true"
  ];

  selfContainedBuild = true;
}
