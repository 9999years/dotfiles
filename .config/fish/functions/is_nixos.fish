function is_nixos --description 'true if the current system is NixOS'
  switch (uname -v)
      case "*NixOS*"
          true
  end
  false
end

