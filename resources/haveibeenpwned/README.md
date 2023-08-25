# Check Password Against HaveIBeenPwned.com Website
This Powershell script is a simple example of using the k-anonymity method detailed in Troy's blog [troyhunt.com](https://www.troyhunt.com/understanding-have-i-been-pwneds-use-of-sha-1-and-k-anonymity/) to check a password if it shows up in the HaveIBeenPwned.com database. The password and its full SHA1 hash are **never** sent to HaveIBeenPwned.com. The password is stored in a secure string on your local machine. This script sends a few prefix characters of your password hash as a query to HaveIBeenPwned.com where it pulls matching suffix results to your local machine to do any comparisons. 

The script will ask two questions:
 - An initial prompt to start
 - To enter your password (stored in a secure string)

 The example script run below I entered a password called "password" to search the HaveIBeenPwned.com database.

 ```
 This script will securely check if your password has been deteced in the HaveIBeenPwned.com (HIBP) database.
Sensative data is never sent to HIBP or leaves your local machine.
Okay to continue?
Enter 'y' for YES or 'n' for NO: y

Enter your password to check for compromise
Enter Password: ********

Processing password hash

Searching HaveIBeenPwned.com database

Processing query results

WARNING: Password found in HIBP database and is compromised. Do NOT use this password
Number of times this password has been seen by HIBP: 9636205
 ```
