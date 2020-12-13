#!/usr/bin/env bash
# Install / Remove Mongodb on Fedora32
# NOTE:
# From: https://fedoramagazine.org/how-to-get-mongodb-server-on-fedora/
# It’s been more than a year when the upstream MongoDB decided to change the license of the Server code. The previous license was GNU Affero General Public License v3 (AGPLv3). However, upstream wrote a new license designed to make companies running MongoDB as a service contribute back to the community. The new license is called Server Side Public License (SSPLv1) and more about this step and its rationale can be found at MongoDB SSPL FAQ.
#
# Fedora has always included only free (as in “freedom”) software. When SSPL was released, Fedora determined that it is not a free software license in this meaning. All versions of MongoDB released before the license change date (October 2018) could be potentially kept in Fedora, but never updating the packages in the future would bring security issues. Hence the Fedora community decided to remove the MongoDB server entirely, starting Fedora 30.

function install(){
  # Create Repo
  cat << EOF > /etc/yum.repos.d/mongodb.repo
[mongodb-upstream]
name=MongoDB Upstream Repository
baseurl=https://repo.mongodb.org/yum/redhat/8Server/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOF

  # Install meta-package
  echo 'Installing MongoDB...'
  sudo dnf -y install mongodb-org

  # Start server
  echo 'Starting and enabling Mongod'
  systemctl enable --now mongod
}

function uninstall(){
  # Stop server
  echo 'Stopping Mongod'
  systemctl disable --now mongod

  # Remove meta-package
  echo 'Removing MongoDB...'
  sudo dnf -y remove mongodb-org

  # Remove repo
  echo 'Removing mongodb.repo'
  rm /etc/yum.repos.d/mongodb.repo
  }

# Check Root
if [ ${UID} -ne 0 ];then
  echo "Please run as root."
  exit 1
fi

# Entrypoint Install/Uninstall/Usage
arg=$1
case $arg in
install)
  Message="Preparing to install MongoDB."
  install
  ;;
uninstall)
  Message="Preparing to uninstall MongoDB."
  uninstall
  ;;
*)
  Message="Usage: install_mongodb [install | uninstall]"
  echo ${Message}
  exit 1
  ;;
esac
