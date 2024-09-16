#!/bin/bash

# srsUE initialization script

# Start dbus and avahi-daemon services (if needed)
service dbus start && service avahi-daemon start

# Ensure COMPONENT_NAME is set to 'ue'
if [[ -z "$COMPONENT_NAME" ]]; then
    echo "Error: COMPONENT_NAME environment variable not set"
    exit 1
elif [[ "$COMPONENT_NAME" != "ue" ]]; then
    echo "Error: Invalid COMPONENT_NAME. Must be 'ue'"
    exit 1
fi

# Set default configuration directory
CONFIG_DIR=/etc/srsran

# Create configuration directory
mkdir -p $CONFIG_DIR

# Copy bladerf_ue.conf into the configuration directory
cp /mnt/srsue/bladerf_ue.conf $CONFIG_DIR/ue.conf

# Replace placeholders with actual values
sed -i 's|UE1_IMSI|'$UE1_IMSI'|g' $CONFIG_DIR/ue.conf
sed -i 's|UE1_KI|'$UE1_KI'|g' $CONFIG_DIR/ue.conf
sed -i 's|UE1_OP|'$UE1_OP'|g' $CONFIG_DIR/ue.conf

# Replace BLADERF_SERIAL_NUMBER if BLADERF_SERIAL is set
if [[ -n "$BLADERF_SERIAL" ]]; then
    sed -i 's|serial=BLADERF_SERIAL_NUMBER|serial='$BLADERF_SERIAL'|g' $CONFIG_DIR/ue.conf
else
    # Remove the device_args line if no serial number is provided
    sed -i '/device_args = serial=BLADERF_SERIAL_NUMBER/d' $CONFIG_DIR/ue.conf
fi

# Start srsUE
echo "Starting srsUE with configuration in $CONFIG_DIR/ue.conf"
/usr/local/bin/srsue $CONFIG_DIR/ue.conf
