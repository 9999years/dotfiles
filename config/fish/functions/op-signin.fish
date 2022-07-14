function op-signin
    set -gx OP_SESSION_my (op signin my --raw)
end
