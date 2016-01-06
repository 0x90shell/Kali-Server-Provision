1. Copy folder to desired machine or share drive.

2. To create a user, add public keys to pubkeys folder. Username will be whatever prefixes ".pub" in keyfiles. 

3. Run ./provision.sh from within a Kali 2 instance. This will probably run on most modern Linux builds, but I've only tested on Kali 2.

Notes:

1. Random 20char passwords will be generated for all accounts. Users will be able to access through SSH only with key. Once user logs in they will have to view password.txt in their home folder to get the random password to execute sudo commands. They will need to reset to password with passwd command. All auto-generated accounts will have sudo access.

2. "Root" and "user" account are randomly set, but they are not recoverable. "User" is used to run certain tasks as non-privileged by the "root" account. Sudo access for users should negate the need for root password. Run "sudo -i" to initiate root shell.

3. Hostname is not changed. Change if needed.