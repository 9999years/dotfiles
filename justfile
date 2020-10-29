# Link dotfiles
link:
	nix-shell --arg dev false --command "python -m link_dotfiles"

# Install vscode extensions
vscode:
	cd ./.config/Code/User && ./install-extensions.sh
