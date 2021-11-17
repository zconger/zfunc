#!/usr/bin/env zsh

# Here's a bunch of BASH functions I'd like to always have handy

# Report the public IP address of an EC2 instance given it's Name as an argument
function z-ec2-ip {
  aws ec2 describe-instances --filters "Name=tag:Name,Values=${1}" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
}

# SSH to a StackHawk EC2 instance by name as user ubuntu and with the shhawk1.pem key
function z-sshawk {
  ssh -i ~/.ssh/sshawk1.pem ubuntu@$(z-ec2-ip "${1}")
}

function z-dns-flush {
  dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}

function z-g-pull {
  git checkout master ; git pull
  git checkout sandbox ; git pull
  git checkout develop ; git pull
}

# z-pr <base-branch>
function z-pr {
  base="${1}"
  if [[ -z "${base}" ]] ; then
    return 1
  else
    gh pr create --base "${base}" --web
  fi
}

function z-upgrade {
  if [[ -z "${ZFUNC}" ]]; then
    ZFUNC="${HOME}/bin/zfunc.sh"
  fi

  if ! curl --header "Authorization: token ${GITHUB_PAT}" \
     --header "Accept: application/vnd.github.v3.raw" \
     --location https://api.github.com/repos/zconger/zfunc/contents/zfunc.sh \
     --output "${ZFUNC}";
  then
    echo "Failed to download zfunc.sh" >&2
    return 1
  fi

  chmod 755 "${ZFUNC}"
  . "${ZFUNC}"
}

function z-brew-switch {
  #! /usr/bin/env bash
  set -ex
  pkg=$1
  version=$2
  brew unlink "$pkg"
  (
    pushd "$(brew --prefix)/opt"
    rm -f "$pkg"
    ln -s "../Cellar/$pkg/$version" "$pkg"
  )
  brew link "$pkg"
}

function z-pod-destroy {
  if [[ -z $2 ]]; then
    >&2 echo "Usage: $0 <PODNAME> <NAMESPACE>"
    return 1
  fi
  podname=$1
  namespace=$2
  kubectl delete pod "${podname}" --grace-period=0 --force --namespace "${namespace}"
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

