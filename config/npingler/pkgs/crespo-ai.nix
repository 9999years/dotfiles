{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  deno,
  cacert,
  makeWrapper,
  gh,
  python3,
}:

let
  version = "unstable-2026-09-14";
  src = fetchFromGitHub {
    owner = "david-crespo";
    repo = "llm-cli";
    rev = "7a35765a7cbedb14893b7e66cc6062c3de53d691";
    hash = "sha256-AtG+S0HIpUqtH81tPpZ4TxW1kKt4On6Jz9mDo9L5hag=";
  };

  # Drops the `x-typescript-types` headers from the vendor manifest, so that
  # `deno` doesn't go looking for the type definitions we delete below.
  dropTypeHeaders = ''
    import json

    path = "vendor/manifest.json"

    with open(path) as file:
        manifest = json.load(file)

    for module in manifest["modules"].values():
        module.get("headers", {}).pop("x-typescript-types", None)

    with open(path, "w") as file:
        json.dump(manifest, file, indent=2)
  '';

  deps = stdenvNoCC.mkDerivation {
    pname = "crespo-ai-deps";
    inherit version src;
    nativeBuildInputs = [
      deno
      python3
    ];
    env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      export DENO_DIR=$TMPDIR/deno-cache
      deno cache --vendor --frozen main.ts
      # This is a local installation cache, not part of the dependencies.
      rm node_modules/.deno/.setup-cache.bin

      # `esm.sh` advertises type definitions with an `x-typescript-types`
      # response header, and `deno.lock` records no hashes for them. Some of
      # them are synthesized by `esm.sh` rather than copied from the npm
      # tarball, so their contents follow whatever version of `esm.sh` is
      # deployed and our `outputHash` drifts out from under us. Nothing needs
      # them at runtime -- `deno run` doesn't typecheck -- so throw them away
      # and keep this derivation pinned to content `deno.lock` can verify.
      find vendor/esm.sh -name '*.d.ts' -delete
      python3 -c ${lib.escapeShellArg dropTypeHeaders}
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r vendor node_modules $out/
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-NutFmAY/sLZ2HKtw/yX9MJmjRVGzk+kD+ui/LuT0VRc=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "crespo-ai";
  inherit version src;
  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/crespo-ai
    cp -r . $out/lib/crespo-ai/
    cp -r ${deps}/{vendor,node_modules} $out/lib/crespo-ai/
    makeWrapper ${lib.getExe deno} $out/bin/ai \
      --add-flags "run --cached-only --frozen --vendor --node-modules-dir=manual" \
      --add-flags "--config $out/lib/crespo-ai/deno.jsonc" \
      --add-flags "--allow-env --allow-read --allow-write --allow-net --allow-run=gh,osascript" \
      --add-flags "$out/lib/crespo-ai/main.ts" \
      --suffix PATH : ${lib.makeBinPath [ gh ]}
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export DENO_DIR=$TMPDIR/empty-deno-cache
    $out/bin/ai --help
    $out/bin/ai models
    runHook postInstallCheck
  '';

  meta = {
    description = "David Crespo's CLI for chatting with LLM APIs";
    homepage = "https://github.com/david-crespo/llm-cli";
    license = lib.licenses.mit;
    mainProgram = "ai";
    platforms = lib.platforms.unix;
  };
}
