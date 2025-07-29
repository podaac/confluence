#!/bin/bash

# Script to run juptyer lab
#
# Usage: ./run.sh /path/to/virtual/environment/parent/directory/jupyter

env_dir=$1

source ${env_dir}/bin/activate

jupyter lab
