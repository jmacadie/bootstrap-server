#!/bin/bash
#https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-22-04-quickstart

sudo apt-get install postgresql postgresql-contrib libpq-dev

# Create role for current user (replace X), need a DB with the same name
sudo -u postgres createuser -s $USER
sudo -u postgres createdb $USER

# Actually going to stick with peer authentication as default
# Will add app specific passwrd access in the create app scripts
## https://unix.stackexchange.com/a/389706 - for expl on find usage
#
## Change postgres local login from peer to identity file
#sudo find /etc/postgresql -type f -name "pg_hba.conf" \
#          -exec /bin/bash \
#            -c 'sed -rin "s/^(local[[:space:]]*all[[:space:]]*all[[:space:]]*)peer/\1ident map=main/g" $1' bash {} \;
#
## Add current user to identity
#sudo find /etc/postgresql -type f -name "pg_ident.conf" \
#          -exec /bin/bash \
#            -c 'echo "  main          $1                   $1" >>$2' bash $USER {} \;
## Restart postgres so identity changes take effect
#sudo service postgresql restart
