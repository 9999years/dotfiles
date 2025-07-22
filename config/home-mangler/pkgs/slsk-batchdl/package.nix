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
    # See: https://github.com/fiso64/slsk-batchdl/pull/116
    (fetchpatch {
      url = "https://github.com/fiso64/slsk-batchdl/commit/d3c18200d3a25baad9538e753c3d6517091c7a02.patch";
      hash = "sha256-h+kU3OxOD+SLh5RbuJjIT73SYhQZJ9pF2H9iTKCS9mk=";
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
