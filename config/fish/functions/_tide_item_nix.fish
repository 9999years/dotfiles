function _tide_item_nix
    set -q tide_nix_icon; or set -l tide_nix_icon '❄'
    set -q IN_NIX_SHELL && _tide_print_item nix $tide_nix_icon
end
