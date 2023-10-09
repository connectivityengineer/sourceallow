#!/bin/bash

### a quick dirty script by Connectivity Engineer 
### script to allow our  iptv sources
### source ulrs must be in the file /mme/allowables.list
#### or change the location below to fit your file location

ALLOWABLES="/mme/allowables.list"
#!/bin/bash

ALLOWABLES="/mme/allowables.list"

# Check if the file exists
if [ ! -f "$ALLOWABLES" ]; then
    echo "Error: $ALLOWABLES file not found!"
    exit 1
fi

# Process each line in the file
while IFS= read -r domain; do
    # Skip empty lines
    [ -z "$domain" ] && continue

    # Perform DNS lookup
    ips=$(dig +short "$domain")

    # For each IP, update the UFW
    for ip in $ips; do
        # Make sure it's a valid IP (avoiding CNAME or other types of records)
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "Allowing $ip for domain $domain"
            ufw allow in from "$ip" comment "$domain"
            ufw allow out to "$ip" comment "$domain"
        fi
    done
done < "$ALLOWABLES"

echo "Firewall rules updated based on the domains in $ALLOWABLES"
