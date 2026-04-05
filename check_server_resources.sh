#!/bin/bash

echo "========================================="
echo "  Server Resource Check"
echo "========================================="
echo ""

echo "--- Memory Usage (free -h) ---"
free -h
echo ""

echo "--- Disk Usage (df -h) ---"
df -h
echo ""

echo "========================================="
echo "  Check Complete"
echo "========================================="
