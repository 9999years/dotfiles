info: final: attrs: let
  optionalAttrs = predicate: attrs:
    if predicate
    then attrs
    else {};

  collapseRenamed = oldName: newName:
    optionalAttrs (builtins.hasAttr oldName attrs
      && builtins.hasAttr info.currentSystem attrs.${oldName})
    {
      ${newName} = attrs.${oldName}.${info.currentSystem};
    };

  collapse = name: collapseRenamed name name;

  collapseAll = builtins.foldl' (prev: name: prev // collapse name) {} (builtins.attrNames attrs);
in
  (optionalAttrs (! attrs ? original)
    {
      original = attrs;
    })
  // (collapseRenamed "legacyPackages" "pkgs")
  // (collapseRenamed "packages" "pkgs")
  // collapseAll
