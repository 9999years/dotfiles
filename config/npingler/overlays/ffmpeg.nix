final: prev: {
  # Don't even get me started.
  #
  # See: https://github.com/NixOS/nixpkgs/issues/511265
  ffmpeg-full = null;
  ffmpeg = null;

  keyfinder-cli = null;
  aacgain = null;
  chromaprint = null;

  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (pyFinal: pyPrev: {
      pyacoustid = null;
    })
  ];
}
