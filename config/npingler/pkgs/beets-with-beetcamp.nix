{
  beets,
  chromaprint,
  rbt,
  fetchpatch,
  lib,
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

    # These were added after 2.3.1 and aren't reflected in Nixpkgs.
    replace.builtin = true;
    musicbrainz.builtin = true;

    # I added this one :)
    detectmissing.builtin = true;
  };
}).overridePythonAttrs
  (prev: {
    patches = (prev.patches or [ ]) ++ [
      # NB: Dropped a patch to make logging levels/format configurable here
      # because it was too hard to rebase.
      #
      # See: https://github.com/beetbox/beets/pull/5897

      # spotify: Don't crash if a network request fails
      #
      # See: https://github.com/beetbox/beets/pull/5910
      (fetchpatch {
        url = "https://github.com/beetbox/beets/commit/bf927a5d36d47791f5a0162622c3683aa0600060.patch";
        hash = "sha256-kNoY4QpaKwfqDGLE2KFqkCi7dqzfpEAj5LqTvAYABtw=";
      })

      # detectmissing: init
      #
      # See: https://github.com/beetbox/beets/pull/5912
      (fetchpatch {
        url = "https://github.com/beetbox/beets/commit/288d5e7dc701aff39ea98dfeefce2a1fbf384842.patch";
        hash = "sha256-m6578KqQZoTMsLlOTgKOYQoRW0XQ96Gy2JmI7Ufal5g=";
      })

      # fish: complete files in more places
      #
      # See: https://github.com/beetbox/beets/pull/5927
      (fetchpatch {
        url = "https://github.com/beetbox/beets/commit/f0b535488996136f648c91cbc7eed7d810d377cf.patch";
        hash = "sha256-UNc51I6UH7L+w4Y5S9vV0logmRroCMFqpXn9NxVV1iM=";
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
