#! /bin/bash

if command -v fish > /dev/null \
    && [[ "$HOSTNAME" == "alia.cs.brandeis.edu" \
          || "$HOSTNAME" == "paul.cs.brandeis.edu" ]]
then
    echo -e "\033[92mElevating shell to root\033[0m"
    echo -e "\033[91mYou are on \033[1m$HOSTNAME\033[21m\033[22m, do not fuck up.\033[0m"
    exec sudo bash -c "source ~/ssh-agent-data && fish"
fi
