{
  beets,
  chromaprint,
  rbt,
}:

(beets.override {
  pluginOverrides = {
    # See: https://github.com/NixOS/nixpkgs/pull/428173
    chroma = {
      wrapperBins = [
        chromaprint
      ];
    };

    beetcamp = {
      enable = true;
      propagatedBuildInputs = [ rbt.beetcamp ];
    };
  };
}).overridePythonAttrs
  {
    # No way to configure this?
    # It doesn't like that `beetcamp` is built against the previous
    # `beets` which doesn't include `beetcamp` lol.
    dontUsePythonCatchConflicts = true;
  }
