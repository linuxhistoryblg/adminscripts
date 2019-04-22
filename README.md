# adminscripts
A repository of system administration scripts

# simplebackup.py
Python3 script that compresses a user's home directory, encrypts the file with gpg, and then uploads it to google drive. 
Requires the user first install and configure rclone for use with google drive https://rclone.org/drive/ and have a valid gpg key.

# fwreload
This simple bash script uses dialog to display the output of 'firewall-cmd --reload && firewall-cmd --list-all'.
Requires: dialog
