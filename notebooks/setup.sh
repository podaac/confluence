#!/bin/bash

# Script to create and set up jupyter lab.
#
# Usage: ./setup.sh /path/to/virtual/environment/parent/directory/jupyter

env_dir=$1

# Step 1) Set up a virtual environment

python3 -m venv ${env_dir}

# Step 2) Install requirements into virtual environment

${env_dir}/bin/pip install -r requirements.txt
