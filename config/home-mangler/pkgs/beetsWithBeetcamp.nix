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
        url = "https://github.com/beetbox/beets/commit/0b0ce86074b90ff61778d0272f4b417628748b8c.patch";
        hash = "sha256-1jwaytNRVpHuGqwGlYk0GbwU57jrrWXPxvJmSYm2qws=";
      })

      # logging: add new TRACE level
      # See: https://github.com/beetbox/beets/pull/5895
      (fetchpatch {
        url = "https://github.com/beetbox/beets/commit/d985391bcd07b30889ce87643f501395975f8e14.patch";
        hash = "sha256-jFg+JxdqzG7u/0BvpcZPN+2s5K2czjGCHN+UcSB9zo0=";
      })

      # logging: set root logger level/handler
      #
      # See: https://github.com/beetbox/beets/pull/5897
      (fetchpatch {
        url = "https://github.com/beetbox/beets/commit/2cb2f09d2352288175442f55a7fb08c0a3631002.patch";
        hash = "sha256-EvudJ2lL91FWbRF5Qs6NaNEA9Tz8g92xtyGCN7Vw3bw=";
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
