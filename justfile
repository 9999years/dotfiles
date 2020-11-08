# Link dotfiles
link:
	@nix-build --arg doCheck false --out-link .link_dotfiles_built
	@./.link_dotfiles_built/bin/link_dotfiles --dotfiles ./dotfiles.json

# Install vscode extensions
vscode:
	cd ./.config/Code/User && ./install-extensions.sh
