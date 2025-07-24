{
  fetchFromGitHub,
  beets,
  chromaprint,
  rbt,
  fetchpatch,
  lib,
}:

lib.warnIf (lib.versionAtLeast beets.version "2.3.2")
  ''
    beets is ${beets.version}, but our override bumps it to an unstable commit
    after 2.3.1. Consider removing the `src` override.
  ''

  (beets.override {
    src = fetchFromGitHub {
      owner = "beetbox";
      repo = "beets";
      # `master` as of 2025-07-20.
      # This is so patches apply cleanly.
      # See: https://github.com/beetbox/beets/commit/0fec858a13854dd16cba5fcd6e698da148f4672d
      rev = "0fec858a13854dd16cba5fcd6e698da148f4672d";
      hash = "sha256-J2DDtXtq4o3lQvSGK4+SBY6JuhjLBRNIQZtiTGaYMDE=";
    };

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

      # These were added after 2.3.1 and aren't reflected in Nixpkgs.
      replace.builtin = true;
      musicbrainz.builtin = true;
    };
  }).overridePythonAttrs
  (prev: {
    patches = (prev.patches or [ ]) ++ [
      # Don't crash if a Discogs release is deleted.
      # See: https://github.com/beetbox/beets/pull/5893
      (fetchpatch {
        url = "https://github.com/beetbox/beets/commit/312cfd9ed3605b276000d35006af9f09acd432fb.patch";
        hash = "sha256-mP8bKY58nVZNgqzEYbH9poCZ4ZCI3SYD5/zcixBd4Xs=";
      })
    ];

    disabledTestPaths =
      lib.subtractLists [
        # Renamed to `test_bpd.py`.
        "test/plugins/test_player.py"
      ] (prev.disabledTestPaths or [ ])
      ++ [
        "test/plugins/test_bpd.py"
      ];

    # No way to configure this?
    # It doesn't like that `beetcamp` is built against the previous
    # `beets` which doesn't include `beetcamp` lol.
    dontUsePythonCatchConflicts = true;
  })
