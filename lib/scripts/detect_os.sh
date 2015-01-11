#!/bin/bash

#Refer to https://github.com/puppetlabs/facter/blob/master/lib/facter/operatingsystem/linux.rb if additional
#operating systems need to be supported or more specific information about the operating system is required.

if [[ $(lsb_release -is 2>/dev/null) == "Ubuntu" ]]; then
  echo "Ubuntu"
  exit 0
else
  if [[ -e "/etc/redhat-release" ]]; then
    echo "$(cat /etc/redhat-release | cut -d " " -f1)"
    exit 0
  fi
fi

exit 1