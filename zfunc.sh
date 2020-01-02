#!/usr/bin/env bash

# Here's a bunch of BASH functions I'd like to always have handy

function zf_ec2_pub_ip {
  aws ec2 describe-instances --filters "Name=tag:Name,Values=${1}" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
}

### Main script
# Check to see if zfunc.sh was executed with an argument, and if so, try running it as a function
if [[ -n $1 ]]; then
  if declare -f "$1" > /dev/null; then
    # call arguments
    "$@"
  else
    echo "ERROR: '$1' is not a biodome function"
    exit 1
  fi
fi
