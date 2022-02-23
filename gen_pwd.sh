#!/bin/bash

# Supporting bash version 4.x only.

if ! which jq > /dev/null
    then
        clear
        echo -e "\n\n\tRequires jq to be installed\n\n"
        exit 0
fi

if ! which xclip > /dev/null
    then
        clear
        echo -e "\n\n\tRequires xclip to be installed\n\n"
        exit 0
fi

####
# Get password from password wolf, and copy chosen password to clipboard
# README.md: API call for x number of passwords to generate, then displays a menu to select one to copy to clipboard.
#
# Change to 'on' or 'off' to enable or disable each:
upper='on'
lower='on'
numbers='on'
special='on'
#phonetic='off'  # unused via API, which sucks but whatevs
#
# Length of the password
length=16
# characters to exclude, separate with a '\' to make literal:
exclude="\@\!\<\>\|\[\]\{\}\\\/\?\&\^\,\`\)\("
# number of passwords to generate:
repeat=9
maximum=20
#
#
####

# URL encode the special characters so curl doesn't puke:
exclude=$(echo -n "$exclude" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-)

clear

# Ask the user how many passwords they want.
printf >&2 "\n\n\tHow many passwords? [9]: "
IFS= read -r nop

# if the user enters 0 or nothing, then use the int value above
# otherwise assign the number of passwords given by the user to {repeat}
if ! ( [[ "$nop" -le 0 ]] || [[ "$nop" -eq '' ]] || [[ "$nop" -gt "$maximum" ]] )
    then
        repeat=$nop
elif [[ "$nop" -gt "$maximum" ]]
    then
        echo -e "\n\tThat's too many, using our default value of $repeat"
        sleep 3
fi

clear
echo

# Use the following URL to accept all defaults:
# URL="https://passwordwolf.com/api/"
#
# This uses the variables above:
URL="https://passwordwolf.com/api/?length=$length&numbers=$numbers&upper=$upper&lower=$lower&special=$special&exclude=$exclude&repeat=$repeat"

passwords=$(curl -sk --connect-timeout 19.01 "$URL" | jq '.[].password')

# declare the array before we populate it:
declare -A pwd_dict
# using i for starting key value and increment it in the for loop
i=1
for p in $(echo $passwords | sed s/\"//g)
    do
        # populate the array:
        pwd_dict[$i]=$p
        # display each pwd:
        echo -e "\t$i. $p"
        # increment i (index #)
        i=$(($i+1))
done

# If there's only 1 password generated, then copy to the clipboard and exit.
if [[ "$nop" -eq 1 ]]
    then
        # Copy to clipboard
        echo ${pwd_dict[1]} | xclip -sel clip
        echo -e "\n\tPassword Copied\n\n"
        exit 0
# Otherwise choose which password you want from the list.
    else
        printf >&2 "\n\n\tSelect a Password to Copy: "
        IFS= read -r ans
fi

# Get length of the passwords array / dict:
pwdlen=$(echo ${#pwd_dict[@]})

# If you enter anything else other than what is available, you get a smartass reply and you get to start over.
# I could have evaluated >> $ans -gt $nop <<, but this is a cool way to get the length of the array, the more you know...
if [[ "$ans" -le 0 ]] || [[ "$ans" -gt "$pwdlen" ]] || [[ "$ans" == "" ]]
    then
        echo -e "\tHilarious...\n\n"
    else
        # Copy to clipboard:
        echo ${pwd_dict[$ans]} | xclip -sel clip
        echo -e "\tPassword #$ans Copied\n\n"
fi

