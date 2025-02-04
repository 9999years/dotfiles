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

  # Get `attrs.${name}` or `null` if it doesn't exist.
  getAttrOrNull = name: attrs: if attrs ? ${name} then attrs.${name} else null;

  # Get all input lists from `drv`.
  # This does not include implicit inputs.
  getInputs =
    drv:
    builtins.filter (drv: drv != null) (
      builtins.concatLists [
        (getAttrOrNull "buildInputs" drv)
        (getAttrOrNull "nativeBuildInputs" drv)
        (getAttrOrNull "propagatedBuildInputs" drv)
        (getAttrOrNull "propagatedNativeBuildInputs" drv)
      ]
    );

  # Get the input named `name` from the input lists of `drv`.
  getNamedInput =
    name: drv:
    let
      allInputs = builtins.filter (
        input: getAttrOrNull "name" input == name || getAttrOrNull "pname" input == name
      ) (getInputs drv);
      length = builtins.length allInputs;
    in
    if length == 0 then
      builtins.throw "No input found named ${name} from ${builtins.toString drv}"
    else if length > 1 then
      builtins.trace "Multiple (${length}}) inputs found named ${name} from ${builtins.toString drv}" (
        builtins.elemAt allInputs 0
      )
    else
      builtins.elemAt allInputs 0;
in
# Preserve the original bindings as `original`.
(optionalAttrs (!attrs ? original) {
  original = attrs;
})
// {
  inherit getInputs getNamedInput;
}
// (collapseRenamed "packages" "pkgs")
// (collapseRenamed "legacyPackages" "pkgs")
// collapse "checks"
// collapse "devShells"
