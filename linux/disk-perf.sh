#!/bin/bash

# Check if directories are provided as arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory1> <directory2> ..."
    exit 1
fi

# Check for required dependencies
if ! command -v fio &> /dev/null || ! command -v jq &> /dev/null; then
    echo "Error: This script requires both fio and jq to be installed."
    echo "Install them using:"
    echo "  sudo apt-get install fio jq"
    exit 1
fi

# Test execution function
run_test() {
    local dir=$1
    local test_type=$2
    local rw_type=$3
    local bs=$4

    echo -e "\n=== Running $test_type test in $dir ==="

    # Execute FIO and capture output
    output=$(fio --name=test \
        --directory="$dir" \
        --rw=$rw_type \
        --bs=$bs \
        --size=1G \
        --numjobs=1 \
        --time_based \
        --runtime=30s \
        --ioengine=libaio \
        --direct=1 \
        --group_reporting \
        --filename=testfile \
        --output-format=json 2>&1)

    # Extract metrics using jq
    bw=$(echo "$output" | jq '.jobs[0].read.bw + .jobs[0].write.bw' | awk '{printf "%.2f MiB/s", $1/1024}')
    iops=$(echo "$output" | jq '.jobs[0].read.iops + .jobs[0].write.iops' | awk '{printf "%.0f", $1}')
    clat=$(echo "$output" | jq '.jobs[0].read.clat_ns.mean + .jobs[0].write.clat_ns.mean' | awk '{printf "%.2f µs", ($1/1000)}')

    # Display results
    echo "Throughput (BW): $bw"
    echo "IOPS: $iops"
    echo "Average latency (clat): $clat"
}

# Process all provided directories
for dir in "$@"; do
    # Verify directory existence
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist, skipping..."
        continue
    fi

    echo -e "\n===== TESTING DIRECTORY: $dir ====="

    # Sequential tests
    run_test "$dir" "Sequential Read" "read" "1M"
    run_test "$dir" "Sequential Write" "write" "1M"

    # Random tests
    run_test "$dir" "Random Read" "randread" "4k"
    run_test "$dir" "Random Write" "randwrite" "4k"

    # Cleanup test file
    rm -f "$dir/testfile"
    echo "Cleaned up test file in $dir"
done