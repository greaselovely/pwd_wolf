import os
import sys
from time import sleep
import requests
import pyperclip as pc


def clear():
    os.system("cls" if os.name == "nt" else "clear")

####
# Get password from password wolf, and copy chosen password to clipboard 
# README.md: API call for x number of passwords to generate, then displays a menu to select one to copy to clipboard.
#
# Change to 'on' or 'off' to enable or disable each:
upper = 'on'
lower = 'on'
numbers = 'on'
special = 'on'
#phonetic = 'off'  # unused via API, which sucks but whatevs
#
# Length of the password
length=16
# characters to exclude:
exclude="@!<>|[]\{\}\\/?&^,`)("
# number of passwords to generate:
repeat=9
maximum=20
#
#lpath = os.path.expanduser('~\\Desktop\\projects\\certs')
#cert = os.path.join(lpath, 'fullchain.cer')
#
####

clear()

# Ask the user how many passwords they want.  
try:
    nop = int(input("\tHow many passwords? [9]: "))
except ValueError:
    nop = 9

# if the user enters 0 or nothing, then use the int value above
# otherwise assign the number of passwords given by the user to $repeat
if not (nop < 0 or nop == '' or nop > maximum):
    repeat = nop
elif nop > maximum:
    print(f"\tThat's too many, using our default value of {repeat}")
    sleep(3)

# Use the following URL to accept all defaults:
# $url1 = "https://passwordwolf.com/api/"
#
# This uses the variables above:
URL = f"https://passwordwolf.com/api/?length={length}&numbers={numbers}&upper={upper}&lower={lower}&special={special}&exclude={exclude}&repeat={repeat}"

#r = requests.get(URL, verify=cert)
r = requests.get(URL)

passwords = r.json()

clear()

pwd_dict = {}
print()
for i, p in enumerate(passwords):
    pwd_dict[i+1] = p['password']
    print(f"\t{i+1}. {p['password']}")

print('\n')

# If there's only 1 password generated, then copy to the clipboard and exit.
if nop == 1:
    pc.copy(pwd_dict.get(1))
    print('\tPassword Copied\n')
    sys.exit()
# Otherwise choose which password you want from the list.
else:
    try:
        ans = int(input("\tSelect Password to Copy: "))
    except ValueError:
        ans = 0

# If you enter anything else other than what is available, you get a smartass reply and you get to start over.
if ans <= 0 or ans > max(pwd_dict.keys()) or ans == '':
    print("\tHilarious...\n\n")
else:
    pc.copy(pwd_dict.get(ans))
    print(f"\tPassword #{ans} Copied\n\n")
