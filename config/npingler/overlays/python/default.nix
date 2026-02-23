final: prev: {
  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (pyFinal: pyPrev: {
      # keep-sorted start
      beets-copyartifacts3 = pyFinal.callPackage ./beets-copyartifacts3.nix { };
      # keep-sorted end

      gst-python = pyPrev.gst-python.overrideAttrs (prev: {
        # Tests are flaky and timeout.
        #
        # Also, `gst-python` is built with Meson, so we can't set `doCheck =
        # false` here.
        installCheckPhase = "";
      });

      kaleido = pyPrev.kaleido.overridePythonAttrs (prev: {
        # Oh, who even gives a shit anymore.
        #
        # See: https://github.com/NixOS/nixpkgs/pull/454818
        postInstall = "";
        buildInputs = [ ];
      });
    })
  ];
}
