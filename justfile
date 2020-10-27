# Link dotfiles
link:
	nix-shell --command "python -m link_dotfiles"

# Install vscode extensions
vscode:
	cd ./.config/Code/User && ./install-extensions.sh
