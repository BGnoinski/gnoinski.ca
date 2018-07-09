#!/bin/bash

# based off https://docs.docker.com/install/linux/docker-ce/ubuntu/

cat <<EOF

*********DISCLAIMER********
This script removes, updates, and installs packages on your system.
It's possible that your system breaks if you run this. 
Ensure you are comfortable running this script if it's your primary system.

Even after the above warning,
Did you go through the script and still wish to run this script? [y/n]
EOF

read agreeinstall

if [[ $agreeinstall != 'y' ]]; then
  exit
fi



# If you're going through like you should be
# delete everything between this line

function i_warned_you {
  percentage="70% 80% 90% 100%"
  sleep_time=4

  user_interrupt(){
          echo -e "\nKeyboard Interrupt detected."
          echo -e "Speeding up encryption.\n"
          if [[ sleep_time -gt 1 ]]; then
            ((sleep_time-=1))
          fi
  }
  trap user_interrupt SIGINT
  trap user_interrupt SIGTSTP

  echo -e "\n\n\nYou should have gone through the script, but since you didn't"
  echo -e "Who likes bitcoins?\n"
  sleep 1

  for percent in $percentage; do
    echo -e "Your drive has been $percent encrypted\n\n"
    sleep $sleep_time
  done
  trap - SIGINT
  trap - SIGTSTP

  cat <<HOPEYOULEARNED

Your system has ** NOT BEEN CHANGED ** in any way.
I just wanted to drive home the severity of running random internet scripts.

HOPEYOULEARNED

  echo -e "Do you wish to continue with the script? [y/n]"
  read continue
  if [[ $continue == 'y' ]]; then
    echo "You're hopeless, go read the damn script."
    exit
  fi
exit
}

i_warned_you
# and this line. I would never actually do the above.

sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

cat <<EOF
Output above this line should include a pub line that ends in "0EBF CD88"

EOF

echo "Does output look correct? [y/n]"
read correctoutput
if [[ $correctoutput != 'y' ]]; then
  cat <<EOF 
If output is not correct, please visit Dockers install page
If output was correct but you entered something other than 'y' re-run script.
EOF
  exit
fi

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce
