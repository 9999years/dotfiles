{
  python3,
  fetchpatch,
  beets-with-beetcamp,
}:

(python3.pkgs.toPythonApplication (
  python3.pkgs.beets.override {
    # Needed until we have https://github.com/NixOS/nixpkgs/pull/477084
    # Ughhhhh.
    beets = beets-with-beetcamp;

    pluginOverrides = {
      beetcamp = {
        enable = true;
        propagatedBuildInputs = [ python3.pkgs.beetcamp ];
      };

      copyartifacts = {
        enable = true;
        propagatedBuildInputs = [ python3.pkgs.beets-copyartifacts3 ];
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
  }
)).overridePythonAttrs
  (prev: {
    # lol lmao
    # See: https://github.com/NixOS/nixpkgs/pull/471166
    doCheck = false;
  })
