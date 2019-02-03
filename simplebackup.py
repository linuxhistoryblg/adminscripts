#!/usr/bin/env python3

from subprocess import run
from os import environ
from sys import exit
from datetime import datetime

def main():
    #Get user's home Directory
    home = environ['HOME'] + '/Documents'
    #Set gpguser, most likely the owner of $home
    gpguser = environ['USER']

    #Temporary backup location
    temp_dir = '/tmp'
    #Get time
    now = datetime.now()
    time_str = str(now.day) + '_' + str(now.month) + '_' + str(now.year)
    now_str = str(now.hour) + ':' + str(now.minute) + ':' + str(now.second)
    #Full Path Filename of backup
    backname = temp_dir + '/' + time_str + '_' + environ['USER'] + '_' + 'Documents.tgz'
    cryptout = backname + '.pgp'

    #Create Archive
    print("Creating Archive.")
    backup_job = run(['tar', '-czf', backname, home])

    #Check for successful archive creation
    if backup_job.returncode != 0:
        print('A filesystem error has occurred, exiting')
        exit(1)
    else:
        print('Archive completed successfully.')

    #Encrypt with pgp
    print(f'Encrypting {backname} as {backname}.pgp')
    crypt = run(['gpg', '-r', gpguser, '-o', cryptout, '-e', backname])
    if crypt.returncode == 0:
        print(f'{backname} encrypted successfully.')
    else:
        print(f'could not encrypt {backname}, exiting')
        exit(1)

    ##Backup to gdrive with rclone
    run_args = ['rclone', 'copy', cryptout, 'gdrive:backup']
    print('Backing up to google drive.')
    print(f'Started at {now_str}')
    cloud_backup_job = run(run_args)

    ##Get time after upload
    now = datetime.now()
    now_str = str(now.hour) + ':' + str(now.minute) + ':' + str(now.second)
    print('Upload was successful.')
    print(f'Finished at {now_str}')
    exit(0)



if __name__ == "__main__":
    main()





