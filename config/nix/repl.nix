info: final: attrs:
let
  # Equivalent to nixpkgs `lib.optionalAttrs`.
  optionalAttrs = predicate: attrs: if predicate then attrs else { };

  # If `attrs.${oldName}.${info.currentSystem}` exists, alias `${newName}` to
  # it.
  collapseRenamed =
    oldName: newName:
    optionalAttrs (attrs ? ${oldName} && attrs.${oldName} ? ${info.currentSystem}) {
      ${newName} = attrs.${oldName}.${info.currentSystem};
    };

  # Alias `attrs.${oldName}.${info.currentSystem} to `${newName}`.
  collapse = name: collapseRenamed name name;
in
# Preserve the original bindings as `original`.
(optionalAttrs (!attrs ? original) {
  original = attrs;
})
// (collapseRenamed "packages" "pkgs")
// (collapseRenamed "legacyPackages" "pkgs")
// collapse "checks"
// collapse "devShells"
