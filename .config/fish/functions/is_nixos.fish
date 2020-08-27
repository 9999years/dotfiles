# Defined in /tmp/fish.3s08lp/is_nixos.fish @ line 2
function is_nixos --description 'true if the current system is NixOS'
  switch (uname -v)
      case "*NixOS*"
          true
  end
  false
end
