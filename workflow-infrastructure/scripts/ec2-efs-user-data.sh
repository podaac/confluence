#!/bin/bash

# EFS Utils
yum install -y amazon-efs-utils

# Logs
EFS_DIRECTORY="/mnt/logs"
mkdir -p $${EFS_DIRECTORY}
echo "${logs}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# Validation
EFS_DIRECTORY="/mnt/validation"
mkdir -p $${EFS_DIRECTORY}
echo "${validation}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# Offline
EFS_DIRECTORY="/mnt/offline"
mkdir -p $${EFS_DIRECTORY}
echo "${offline}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# Output
EFS_DIRECTORY="/mnt/output"
mkdir -p $${EFS_DIRECTORY}
echo "${output}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# Diagnostics
EFS_DIRECTORY="/mnt/diagnostics"
mkdir -p $${EFS_DIRECTORY}
echo "${diagnostics}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# MOI
EFS_DIRECTORY="/mnt/moi"
mkdir -p $${EFS_DIRECTORY}
echo "${moi}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# Input
EFS_DIRECTORY="/mnt/input"
mkdir -p $${EFS_DIRECTORY}
echo "${input}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# FLPE
EFS_DIRECTORY="/mnt/flpe"
mkdir -p $${EFS_DIRECTORY}
echo "${flpe}:/ $${EFS_DIRECTORY} efs tls,_netdev" >> /etc/fstab
chown -R ec2-user $${EFS_DIRECTORY}

# Mount
mount -a -t efs defaults

# Create necessary directories
mkdir -p /mnt/diagnostics/postdiagnostics/basin
mkdir -p /mnt/diagnostics/postdiagnostics/reach
mkdir -p /mnt/diagnostics/prediagnostics

mkdir -p /mnt/flpe/geobam
mkdir -p /mnt/flpe/hivdi
mkdir -p /mnt/flpe/metroman
mkdir -p /mnt/flpe/momma
mkdir -p /mnt/flpe/sad
mkdir -p /mnt/flpe/sic4dvar

mkdir -p /mnt/input/gage
mkdir -p /mnt/input/sos
mkdir -p /mnt/input/sword
mkdir -p /mnt/input/swot/creation_logs


mkdir -p /mnt/logs/sic4dvar

mkdir -p /mnt/output/sos

mkdir -p /mnt/validation/figs

chown -R ec2-user /mnt/*
