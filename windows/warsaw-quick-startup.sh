#!/bin/bash
# To disable warsaw on startup use: sudo systemctl disable warsaw.service

sudo systemctl start warsaw.service
sleep 10m
sudo systemctl stop warsaw.service
ps aux | grep warsaw | awk '{print "sudo kill -9 "$2}' | sh
