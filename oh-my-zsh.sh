#!/usr/bin/env sh
#
# See https://ohmyz.sh/
#

DIR=$(dirname "$0")
. ${DIR}/shared.sh

echo ""
echo "This will download a shell script to install oh-my-zsh from"
echo "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
echo "Proceed with caution and verify that this remote shell script is"
echo "actually oh-my-zsh (especially if you're installing this as root"
continue_prompt "Proceed with installing?"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "source ~/.profile" >> .zshrc