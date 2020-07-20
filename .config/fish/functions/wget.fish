function wget --wraps wget --description 'downloads files'
    if command -v wget >/dev/null
        command wget $argv
    else
        echo "wget not available; using `curl -OL` instead."
        curl -OL $argv
    end
end
