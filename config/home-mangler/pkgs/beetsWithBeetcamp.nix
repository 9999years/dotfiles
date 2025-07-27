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
        url = "https://github.com/beetbox/beets/commit/28616a77b52e6763e9485491053d227441c77efe.patch";
        hash = "sha256-v7Ica6/HCHWNTzYmhG0wzk02W0DVZ1WyRPsaXuhCpDo=";
      })
      (fetchpatch {
        # logging: make log levels/format configurable
        url = "https://github.com/beetbox/beets/commit/c530b1e575d2b74f327cd3717b440a2f354f37b2.patch";
        hash = "sha256-7OFEQ6Oy1vzskutHdsh52+NRG5N2WXjc666i1Fn7HlU=";
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
