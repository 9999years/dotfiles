{
  python3,
  fetchpatch,
  beets-with-beetcamp,
}:

python3.pkgs.callPackage (
  {
    toPythonApplication,
    beets,
    beetcamp,
    beets-copyartifacts3,
  }:

  (toPythonApplication (
    beets.override {
      # Needed until we have https://github.com/NixOS/nixpkgs/pull/477084
      # Ughhhhh.
      beets = beets-with-beetcamp;

      pluginOverrides = {
        beetcamp = {
          enable = true;
          propagatedBuildInputs = [ beetcamp ];
        };

        copyartifacts = {
          enable = true;
          propagatedBuildInputs = [ beets-copyartifacts3 ];
        };

        # I added this one :)
        #
        # Can't put this in `pluginOverrides`.
        # See: https://github.com/NixOS/nixpkgs/pull/471166
        detectmissing = {
          builtin = true;
        };
      };

      extraPatches = [
        # NB: Dropped a patch to make logging levels/format configurable here
        # because it was too hard to rebase.
        #
        # See: https://github.com/beetbox/beets/pull/5897

        # detectmissing: init
        #
        # See: https://github.com/beetbox/beets/pull/5912
        (fetchpatch {
          url = "https://github.com/beetbox/beets/commit/288d5e7dc701aff39ea98dfeefce2a1fbf384842.patch";
          hash = "sha256-m6578KqQZoTMsLlOTgKOYQoRW0XQ96Gy2JmI7Ufal5g=";
        })
      ];
    }
  )).overridePythonAttrs
    (prev: {
      # lol lmao
      # See: https://github.com/NixOS/nixpkgs/pull/471166
      doCheck = false;
    })
) { }
