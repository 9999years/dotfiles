# Defined in /tmp/fish.mYhPSB/fish_greeting.fish @ line 2
function fish_greeting
    function d
        echo "$argv" | base64 -d
    end

    function n
        random choice (
            echo ZHJvbmUAZHJvbmUAZHJvbmUAcmVxdWkAcmVxdWkAcmVxdWkAcmVxdWllbmlpAG15IGxvdmUAc3dlZXRoZWFydABiYWJ5AHNsdXQAcGV0AGthdABjdXRpZQBmdWNrdG95AGJlYXV0aWZ1bA== \
            | base64 -d \
            | string split0
        )
    end

    if test -z "$IN_NIX_SHELL"
        switch (date +%H)
            case 00 01  # midnight-2am
                echo -sn (set_color --bold yellow) (d VGltZSBmb3IgYmVkLCAK)(n)(d ISDwn5uMIPCfmLQg8J+YmiAgCg==)
            case 02 03 # 2am-4am
                echo -sn (set_color --bold red) (d R28gdG8gc2xlZXAgaW1tZWRpYXRlbHksIHJlcXVpZW5paSEg8J+bkSDwn5KkIPCfmKAgIAo=)
            case 04 05 06  # 4am-7am
                echo -s (set_color --bold brred)(d R28gdG8gc2xlZXAgCg==) \
                    (set_color --underline)(d cmlnaHQgbm93Cg==)(set_color normal) \
                    (set_color --bold brred) \
                    (d IGFuZCByZXBvcnQgeW91ciBub24tY29tcGxpYW5jZSB0byB5b3VyIGFkbWluaXN0cmF0b3IuIPCfmqgg8J+bkSAgCg==)
                echo (d RW50ZXIgeW91ciBwYXNzd29yZCB0byBhY2NlcHQgeW91ciBjYWdlOgo=)
                eval (echo c3VkbyBkcm9uZXBsYXkgbG9jayAkVVNFUgo= | base64 -d)
            case 13 14 15 16 17  # 1pm-5pm
                echo -sn (set_color --bold green) (d R29vZCBhZnRlcm5vb24sIAo=)(n)(d ISDwn4yeIPCfpJYgIAo=)
            case 18 19  # 6pm-7pm
                echo -sn (set_color --bold magenta) (d R29vZCBldmVuaW5nLCAK)(n)(d ISDwn4yHIPCfpbAgIAo=)
            case 20 21 22  # 8pm-10pm
                echo -sn (set_color --bold blue) (d RmVlbGluZyBzbGVlcHksIAo=)(n)(d PyDwn5i0IPCfkpYgIAo=)
            case 23 24  # 11pm-midnight
                echo -sn (set_color --bold blue) (d R28gYnJ1c2ggeW91ciB0ZWV0aCwgCg==)(n)(d ISDwn6qlIOKdpAo=)
            case '*' # nominally 7am-noon
                echo -sn (set_color --bold cyan) (d R29vZCBtb3JuaW5nLCAK)(n)(d ISDwn4yEIEkgbG92ZSB5b3UhIPCfkpUgCg==)
        end
        echo -s (set_color normal)
        if command -vq puppy
            set_color magenta
            and puppy
            and set_color normal
        end
    else
        echo -s -n (set_color --bold blue) "🐟  " (set_color normal)
    end
end
