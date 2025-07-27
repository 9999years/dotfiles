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
        url = "https://github.com/beetbox/beets/commit/5a4066ada03d6a28891a9346d0ab85654fc32c4e.patch";
        hash = "sha256-czftG20yE7FtWY5yBGQfpMGNCxftDxgoTPHyvG72fgM=";
      })

      # chroma: set a default timeout of 10 seconds
      #
      # See: https://github.com/beetbox/beets/pull/5898
      (fetchpatch {
        url = "https://github.com/beetbox/beets/commit/8ce0ad71d7bf10f50f17c2966f9e439cafae73d0.patch";
        hash = "sha256-spdvev2eYeUInf8m5VplrbAS7g5LzJrlOcHV6KHj7lU=";
      })

      # logging: make levels/format configurable
      #
      # See: https://github.com/beetbox/beets/pull/5897
      (fetchpatch {
        # logging: use module names as logger names
        url = "https://github.com/beetbox/beets/commit/2fc940852213a6572f87fd5be47e80562d7bb09a.patch";
        hash = "sha256-yT9gRv98z6GCJTnlWHjtBUPjFViRpuOD0b8v7Cc11sU=";
      })
      (fetchpatch {
        # logging: use beets logger in more places
        url = "https://github.com/beetbox/beets/commit/a2963fa0c16be13ea4865cf0235c661d3c365d89.patch";
        hash = "sha256-J6tMuZUXMr/RQTgt33Q0bqiRTymxRDlzIsA8IEhQVBk=";
      })
      (fetchpatch {
        # logging: make log levels/format configurable
        url = "https://github.com/beetbox/beets/commit/7e93ce71c93c7abef4e9e98889a37741d0cb8dca.patch";
        hash = "sha256-n3X8WoujIt7sN8NuRwKp49lJi5APr9+GL5vlX24OwcQ=";
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
