#!/bin/bash

# Directory where the .conf files are located
DIR="/etc/pve/nodes/$(hostname)/qemu-server"

# Variable to store the total sum of cores
TOTAL_CORES=0

# Loop to find all .conf files in the directory
for file in "$DIR"/*.conf; do
    # Check if the file does NOT contain the line "template:"
    if ! grep -q "template:" "$file"; then
        # If it doesn't, extract the value after "cores: " and add it to the total
        CORES=$(grep -oP '(?<=cores: )\d+' "$file")
        if [ -n "$CORES" ]; then
            TOTAL_CORES=$((TOTAL_CORES + CORES))
        fi
    fi
done

# Display the total sum of cores
echo "Total cores used in VMs (QEMU): $TOTAL_CORES"