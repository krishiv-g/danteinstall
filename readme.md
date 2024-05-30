
# Setting Up Dante Proxy on Ubuntu 20.04

Dante is a robust, open-source SOCKS proxy solution that offers a gateway for managing and monitoring web traffic, enhancing privacy, and optimizing security.

## Prerequisites

- Non-root user with sudo privileges
- Domain name or IP address for configuration

## Installation of Dante

1. **Update and Install Dante**:
   ```bash
   sudo apt update
   sudo apt install dante-server
   ```

2. **Verify Installation**:
   ```bash
   systemctl status danted.service
   ```

   Ensure that Dante starts correctly, though it may initially fail due to disabled features.

## Configuring Dante

1. **Edit Configuration File**:
   Remove the existing `/etc/danted.conf` and create a new one:
   ```bash
   sudo rm /etc/danted.conf
   sudo nano /etc/danted.conf
   ```

2. **Sample Configuration**:
   Here's a minimal setup for Dante's configuration:
   ```conf
   logoutput: syslog
   user.privileged: root
   user.unprivileged: nobody

   internal: 0.0.0.0 port=1080
   external: eth0

   socksmethod: username
   clientmethod: none

   client pass {
       from: 0.0.0.0/0 to: 0.0.0.0/0
   }

   socks pass {
       from: 0.0.0.0/0 to: 0.0.0.0/0
   }
   ```

3. **Firewall Configuration**:
   Allow traffic on port 1080:
   ```bash
   sudo ufw allow 1080
   ```

4. **Restart Dante Service**:
   Restart Dante to apply new configurations:
   ```bash
   sudo systemctl restart danted.service
   ```

## Secure Dante

To enhance security, restrict access by IP or set up user authentication:

1. **Create a SOCKS User**:
   ```bash
   sudo useradd -r -s /bin/false proxy-user
   sudo passwd proxy-user
   ```

2. **Restrict Access**:
   Modify `/etc/danted.conf` to allow connections only from specific IPs.

## Conclusion

Dante offers a powerful proxy setup ideal for managing and securing network traffic. Ensure proper security measures and configure according to your network requirements.

For more detailed configuration options and advanced setups, refer to Dante’s official documentation or DigitalOcean community guides.

## Configuring Multiple Dante Instances

For environments requiring Dante to handle traffic on multiple IP addresses, you can automate the setup process using a shell script. This script will configure multiple instances of Dante, each bound to a different IP address found on your server.

### Script Overview

The script performs the following actions:
- Detects all non-local IP addresses available on the server.
- Generates a unique Dante configuration file for each IP address.
- Creates a systemd service file for each Dante instance to allow individual management.
- Starts and enables each Dante SOCKS server instance.

### How to Use the Script

1. **Prepare the Script**:
   - Ensure you have the script `setup_dante_instances.sh` on your server. You can download it from the repository or create it using the content provided.

2. **Make the Script Executable**:
   ```bash
   chmod +x setup_dante_instances.sh
   ```

3. **Run the Script**:
   Execute the script with root privileges:
   ```bash
   sudo ./setup_dante_instances.sh
   ```

4. **Verify Each Instance**:
   Check the status of each Dante instance to ensure they are running correctly:
   ```bash
   systemctl status danted_*.service
   ```

5. **Testing**:
   Use a SOCKS client to connect through the ports configured by the script to verify that each instance is functioning correctly.

This script simplifies the deployment of multiple Dante SOCKS server instances on a server, making it ideal for complex network environments or systems with multiple network interfaces.

## Conclusion

Dante offers a powerful proxy setup ideal for managing and securing network traffic. Ensure proper security measures and configure according to your network requirements. For more detailed configuration options and advanced setups, refer to Dante’s official documentation or community guides such as those available on DigitalOcean.
