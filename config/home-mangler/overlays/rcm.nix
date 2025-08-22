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

      # Print when a new file is linked or copied
      #
      # See: https://github.com/thoughtbot/rcm/pull/310
      (final.fetchpatch {
        url = "https://github.com/thoughtbot/rcm/commit/ba9498541203f27a6a6ccef6fa19c232219b6111.patch";
        hash = "sha256-Y2znU3vn+V5ToSkG4TxlVHBWYk4YWkmQS/sq5knLLjA=";
      })
    ];
  });
}
