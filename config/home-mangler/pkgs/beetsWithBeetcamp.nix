{
  beets,
  rbt,
}:

(beets.override {
  pluginOverrides = {
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
