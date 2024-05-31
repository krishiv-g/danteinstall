#!/bin/bash

# Update and upgrade the system unattended
echo "Updating and upgrading the system..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install Dante server
echo "Installing Dante server..."
apt-get install -y dante-server

# Directory for Dante configurations and systemd service files
CONFIG_DIR="/home/ubuntu/dante-config-files"
LOG_DIR="/var/log/dante"
OUTPUT_FILE="/home/ubuntu/danted_ips_ports.txt"

# Ensure the directories exist
mkdir -p $CONFIG_DIR
mkdir -p $LOG_DIR

# Base port number (incremented for each IP)
base_port=1080

# Get all available IPv4 addresses, excluding local and Docker ones
IP_ADDRESSES=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v -e '^127' -e '^172')

# Initialize the output file
echo "IP and Ports from Dante configuration files:" > "$OUTPUT_FILE"

# Loop over each IP address
for ip in $IP_ADDRESSES; do
    # Configuration and service names
    conf_name="danted_$ip.conf"
    service_name="danted_$ip.service"

    # Replace dots in IP to use in filenames
    filename_ip=$(echo $ip | tr '.' '_')

    # Create Dante config file for this IP
    cat <<EOF >"$CONFIG_DIR/danted_$filename_ip.conf"
logoutput: $LOG_DIR/danted_$filename_ip.log

internal: $ip port = $base_port
external: $ip

clientmethod: none
socksmethod: username none

user.privileged: root
user.unprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    command: bind connect udpassociate
    log: connect disconnect error
}
EOF

    # Create systemd service file for this instance
    cat <<EOF >"/etc/systemd/system/danted_$filename_ip.service"
[Unit]
Description=Dante SOCKS Server for IP $ip
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/danted -f $CONFIG_DIR/danted_$filename_ip.conf
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start the service
    systemctl enable danted_$filename_ip.service
    systemctl start danted_$filename_ip.service

    # Increment the base port for the next service
    ((base_port++))
done

# Extract IP and port information from Dante configuration files
for file in $CONFIG_DIR/danted_*.conf; do
    if [[ -f $file ]]; then
        # Check for internal and external lines and extract IP and port
        while read -r line; do
            if [[ $line =~ ^internal:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\ port\ =\ ([0-9]+) ]]; then
                ip="${BASH_REMATCH[1]}"
                port="${BASH_REMATCH[2]}"
                echo "internal: $ip port = $port" >> "$OUTPUT_FILE"
            elif [[ $line =~ ^external:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
                ip="${BASH_REMATCH[1]}"
                echo "external: $ip" >> "$OUTPUT_FILE"
            fi
        done < "$file"
    fi
done

echo "Dante SOCKS server instances have been configured and started for each IP."
echo "IP and port information has been saved to $OUTPUT_FILE."
