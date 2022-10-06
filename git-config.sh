#!/bin/bash

# Set global params
# -------------------------------------

git config --global user.name "James MacAdie (server name)"
git config --global user.email "james@macadie.co.uk"

git config --global core.editor "vim"

git config --global color.status "auto"
git config --global color.branch "auto"

git config --global push.default "simple"

git config --global alias.lol "log --graph --decorate"
git config --global alias.lols "log --oneline --graph --decorate"
git config --global alias.logs "log --stat"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.ci "commit"
git config --global alias.st "status"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.df "difftool"
git config --global alias.dfs "difftool --cached"
git config --global alias.dfn "diff --name-only"
git config --global alias.dfus "!f() { git difftool $1:./ -- $2; }; f"
git config --global alias.pom "push origin main"
git config --global alias.pl "pull origin main"

git config --global diff.algorithm histogram
git config --global diff.tool "vimdiff"
git config --global merge.tool "vimdiff"
git config --global difftool.prompt "false"
git config --global difftool.trustExitCode "true"

# Set up SSH connection
# https://help.github.com/articles/generating-ssh-keys/#platform-linux
# -------------------------------------

# Check for existing keys
# ls -la ~/.shh
# If already have a key then can skip generating a new key below

# Generate new SSH key
ssh-keygen -t ed25519 -C "james@macadie.co.uk"

# Add key to agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add key to github account
echo -e "\n"
echo "1) Copy text of following file"
echo -e "\n- - - - - - -"
cat ~/.ssh/id_ed25519.pub
echo -e "- - - - - - -\n"
echo "2) Go to http://github.com
3) Go to Settings > SSH Keys
4) Click Add SSH Key
5) Add a title so can differentiate (preferably this server name)
6) Paste copied key text into Key field
7) Click Add Key"
echo -n "Press any key when done ..."
read -s response
echo -e "\n"

# Test connection
ssh -T git@github.com

# Finally change the repo over to SSH
git remote set-url origin git@github.com:jmacadie/bootstrap-server.git
