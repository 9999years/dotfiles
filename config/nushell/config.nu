$env.LESS_TERMCAP_mb = (ansi red_bold)
$env.LESS_TERMCAP_md = (ansi {fg: "#5fafd7", attr: "bold"})  # light blue
$env.LESS_TERMCAP_me = (ansi reset)
# Black on light yellow. Used for search highlights.
$env.LESS_TERMCAP_so = (ansi {fg: "#000000", bg: "#ffdb4d", attr: "bold"})
$env.LESS_TERMCAP_se = (ansi reset)
$env.LESS_TERMCAP_us = (ansi {fg: "#9eff96", attr: "underline"})
$env.LESS_TERMCAP_ue = (ansi reset)

$env.MANPAGER = "nvim +Man!"
$env.PYTHONSTARTUP = ("~/.pythonrc" | path expand)
$env.RIPGREP_CONFIG_PATH = ("~/.ripgreprc" | path expand)

def --env c. [] { cd .. }
def --env c2 [] { cd ../.. }
def --env c3 [] { cd ../../.. }
def --env c4 [] { cd ../../../.. }
def --env c5 [] { cd ../../../../.. }
