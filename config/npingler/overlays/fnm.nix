final: prev: {
  fnm = prev.fnm.overrideAttrs (drv: {
    nativeBuildInputs = (drv.nativeBuildInputs or [ ]) ++ [ final.pkg-config ];
    buildInputs = (drv.buildInputs or [ ]) ++ [ final.zstd ];
  });
}
