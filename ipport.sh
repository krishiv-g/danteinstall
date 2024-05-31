#!/bin/bash

# Output file
output_file="danted_ips_ports.txt"

# Initialize the output file
echo "IP and Ports from Dante configuration files:" > "$output_file"

# Loop through all relevant files in /etc/danted*
for file in /etc/danted*; do
    if [[ -f $file ]]; then
        # Check for internal and external lines and extract IP and port
        while read -r line; do
            if [[ $line =~ ^internal:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\ port\ =\ ([0-9]+) ]]; then
                ip="${BASH_REMATCH[1]}"
                port="${BASH_REMATCH[2]}"
                echo "internal: $ip port = $port" >> "$output_file"
            elif [[ $line =~ ^external:\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
                ip="${BASH_REMATCH[1]}"
                echo "external: $ip" >> "$output_file"
            fi
        done < "$file"
    fi
done

echo "Done. Check the file $output_file for the results."
