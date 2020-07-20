# Defined in /var/folders/dm/2kd_hgp51qx5v41_4ct5c8tw001d24/T//fish.VUUeyk/is_linkedin.fish @ line 2
function is_linkedin
    switch (hostname)
        case "*.linkedin.biz"
            true
        case "*"
            false
    end
end
