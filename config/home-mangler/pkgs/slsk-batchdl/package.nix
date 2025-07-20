{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
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

  postPatch = ''
    sed \
        --in-place \
        --expression "s|<TargetFramework>net6\.0</TargetFramework>|<TargetFramework>net8\.0</TargetFramework>|g" \
        slsk-batchdl/slsk-batchdl.csproj \
        slsk-batchdl.Tests/slsk-batchdl.Tests.csproj \
  '';

  projectFile = "slsk-batchdl/slsk-batchdl.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;
  executables = [ "sldl" ];

  dotnetFlags = [
    "--property:PublishSingleFile=true"
    # Note: This breaks Spotify authentication!
    # "--property:PublishTrimmed=true"
  ];

  selfContainedBuild = true;
}
