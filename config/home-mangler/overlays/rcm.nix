final: prev: {
  rcm = prev.rcm.overrideAttrs (prevDrv: {
    patches = (prevDrv.patches or [ ]) ++ [
      # rcup: Fix shell quoting in `is_linked`
      #
      # See: https://github.com/thoughtbot/rcm/pull/309
      (final.fetchpatch {
        url = "https://github.com/thoughtbot/rcm/commit/20e8d6016087439af728ebb6b096f442152fd07b.patch";
        hash = "sha256-Jc7c63jEAwndzQ8OotOwtOvj4Rg2tj74FIxLE6AFfYE=";
      })
    ];
  });
}
