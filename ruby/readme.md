Scripts in this folder should get you up and running with Ruby + Puma + Nginx + Postgres

Run in the following order:
1) ruby-setup.sh - to install ruby & puma and setup puma to restart on reboot
2) nginx-setup.sh - to insall nginx, if not already insalled
3) postgres-setup.sh - to install postgres, if not already installed

Finally you can use create-new-app.sh to set up a shell app, which runs it's own puma server
wipe-app.sh cleans up what create-new-app.sh created
