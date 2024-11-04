#!/bin/bash

# Function to conver to GB
convert_to_gb() {
    local size=$1
    local unit=${size: -1}
    local number=${size%?}
    
    case $unit in
        G)
            echo "$number"
            ;;
        M)
            echo "scale=2; $number / 1024" | bc
            ;;
        K)
            echo "scale=2; $number / 1024 / 1024" | bc
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Search for all rows with disk definition and sum by storage
cat /etc/pve/nodes/*/qemu-server/* | grep -E "scsi[0-9]:|virtio[0-9]:|ide[0-9]:|efidisk[0-9]:|tpmstate[0-9]:" | grep -v "media=cdrom" | 
while read line; do
    if [[ $line =~ size=([0-9]+[GMK]) ]]; then
        size=${BASH_REMATCH[1]}
        storage=$(echo $line | cut -d: -f2 | cut -d, -f1)
        echo "$storage $(convert_to_gb $size)"
    fi
done | awk '
{
    storage[$1] += $2
}
END {
    for (s in storage) {
        printf "Storage %s: %.2f GB\n", s, storage[s]
    }
}'
