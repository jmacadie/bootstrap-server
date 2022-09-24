#!/bin/bash

sudo apt-get install ruby-full gcc build-essential

sudo gem install bundler
sudo gem install puma
sudo gem install sinatra

# Create the folder and file that puma-manager will read from
sudo mkdir /etc/puma
sudo touch /etc/puma/puma.conf

# Set up systemd puma startup script
sudo tee /usr/local/bin/puma-manager.sh > /dev/null <<'EOF'
#!/bin/bash

PUMA_CONF="/etc/puma/puma.conf"

for i in `cat $PUMA_CONF`; do
  app=`echo $i | cut -d , -f 1`
  logger -t "puma-manager" "Starting $app"
  cd $app
  exec bundle exec puma -e production --config puma.rb
done
EOF

# Set up systemd service to call script
sudo tee /etc/systemd/system/puma-manager.service > /dev/null <<'EOF'
[Unit]
After=network.target

[Service]
ExecStart=/usr/local/bin/puma-manager.sh

[Install]
WantedBy=default.target
EOF

# Set permissions
sudo chmod 744 /usr/local/bin/puma-manager.sh
sudo chmod 664 /etc/systemd/system/puma-manager.service

# Reload systemd
sudo systemctl daemon-reload
sudo systemctl enable puma-manager.service

