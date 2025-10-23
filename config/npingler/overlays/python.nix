final: prev: {
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (pyFinal: pyPrev: {
      musicbrainzngs =
        final.lib.warnIf (final.lib.versionAtLeast pyPrev.musicbrainzngs.version "0.7.2")
          ''
            musicbrainzngs is ${pyPrev.musicbrainzngs.version}, but our override bumps it to an unstable commit
            after 0.7.1. Consider removing the `src` override.
          ''
          pyPrev.musicbrainzngs.overridePythonAttrs
          (prev: {

            src = final.fetchFromGitHub {
              owner = "alastair";
              repo = "python-musicbrainzngs";
              rev = "1638c6271e0beb9560243c2123d354461ec9f842";
              hash = "sha256-1p7thMnaE5vqMfE2i7fIlXwOtVSR1nN/sz/DJyDd/Jk=";
            };

            patches = (prev.patches or [ ]) ++ [
              # Timeout API calls after 10 seconds.
              #
              # See: https://github.com/alastair/python-musicbrainzngs/pull/295
              (final.fetchpatch {
                url = "https://github.com/alastair/python-musicbrainzngs/commit/588e01061973ce0e7d16c1b85eecafe10cc1c22a.patch";
                hash = "sha256-exwIF60vucYZecy1UgDapIxficJoEhos34lCCg6rcZI=";
              })

              # logging: use module names for loggers
              #
              # See: https://github.com/alastair/python-musicbrainzngs/pull/297
              (final.fetchpatch {
                url = "https://github.com/alastair/python-musicbrainzngs/commit/f768c3db1cf8a93922d6d381be4091a5eec112bf.patch";
                hash = "sha256-lHHhMziETXZHFlZD/1uZvSbpfGzTEf7DE4KKQfxs6tk=";
              })
            ];
          });

      gst-python = pyPrev.gst-python.overrideAttrs (prev: {
        # Tests are flaky and timeout.
        #
        # Also, `gst-python` is built with Meson, so we can't set `doCheck =
        # false` here.
        installCheckPhase = "";
      });
    })
  ];
}
