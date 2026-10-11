{
  python3,
  fetchpatch,
}:

python3.pkgs.callPackage (
  {
    toPythonApplication,
    beets,
    beetcamp,
  }:

  toPythonApplication (
    beets.override {
      # Required, not just preference: `extraPatches` drops a new file into
      # `beetsplug/`, and the `preCheck` sanity check diffs that directory
      # against `passthru.plugins.builtins`, which `pluginOverrides` can't add
      # to. So the check always fails while we're carrying the patch below.
      #
      # (`pluginOverrides.<name>.builtin` looks like it should do this, but
      # nothing in nixpkgs ever reads that field.)
      doCheck = false;

      extraPatches = [
        # `missingfiles`, which I wrote.
        #
        # See: https://github.com/beetbox/beets/pull/5912
        #
        # The PR is closed for now -- the maintainers would rather this became
        # a `beet remove` flag -- so this is rebased onto upstream `master` on
        # my own fork.
        (fetchpatch {
          url = "https://github.com/9999years/beets/commit/dc76296689bd1d8bd478490ff4d437d586b5381b.patch";

          # Take only the plugin itself. The commit also touches
          # `docs/changelog.rst` and `docs/plugins/index.rst`, which upstream
          # rewrites constantly, so keeping those hunks means the patch stops
          # applying every other release.
          includes = [ "beetsplug/missingfiles.py" ];

          hash = "sha256-Duqw3aowMV88wRPSOE4tEm2F4kNfVYi+ROgCroWTRko=";
        })
      ];

      # NB: `missingfiles` deliberately has no `pluginOverrides` entry. The
      # patch puts it in `beetsplug/`, which the wheel picks up wholesale, and
      # it has no dependencies of its own to propagate.
      pluginOverrides = {
        beetcamp = {
          enable = true;
          propagatedBuildInputs = [ beetcamp ];
        };
      };
    }
  )
) { }
