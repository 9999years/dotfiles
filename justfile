# Link dotfiles
link:
	nix-shell --command "python -m _python.dotfiles"

# Install vscode extensions
vscode:
	cd ./.config/Code/User && ./install-extensions.sh
