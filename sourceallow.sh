#!/bin/bash

ALLOWABLES="/mme/allowables.list"

# Check if the file exists
if [ ! -f "$ALLOWABLES" ]; then
    echo "Error: $ALLOWABLES file not found!"
    exit 1
fi

# Function to check if a string is an IP
is_ip() {
    [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# Process each line in the file
while IFS= read -r entry; do
    # Skip empty lines
    [ -z "$entry" ] && continue

    # If the entry is an IP, update UFW directly
    if is_ip "$entry"; then
        echo "Allowing $entry from allowables.list"
        ufw allow in from "$entry" comment "$entry"
        ufw allow out to "$entry" comment "$entry"
    else
        # Perform DNS lookup
        ips=$(dig +short "$entry")

        # For each IP, update the UFW
        for ip in $ips; do
            # Make sure it's a valid IP (avoiding CNAME or other types of records)
            if is_ip "$ip"; then
                echo "Allowing $ip for domain $entry"
                ufw allow in from "$ip" comment "$entry"
                ufw allow out to "$ip" comment "$entry"
            fi
        done
    fi
done < "$ALLOWABLES"

echo "Firewall rules updated based on the entries in $ALLOWABLES"
