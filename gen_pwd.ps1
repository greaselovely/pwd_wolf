#!/usr/bin/env pwsh
####
# Get password from password wolf, and copy chosen password to clipboard 
# README.md: API call for x number of passwords to generate, then displays a menu to select one to copy to clipboard.
#
# Change to 'on' or 'off' to enable or disable each:
$upper='on'
$lower='on'
$numbers='on'
$special='on'
#
# Length of the password
$length=16
# characters to exclude:
$exclude='"@!<>|[]{}\/?&^,`)("'
# number of passwords to generate:
$repeat=9
$maximum=20
#
#
####

clear

Write-Host
# Ask the user how many passwords they want.  
[int]$nop = Read-Host '  How many passwords? [9]: '

# if the user enters 0 or nothing, then use the int value above
# otherwise assign the number of passwords given by the user to $repeat
if (!($nop -le 0 -Or $nop -eq '' -Or $nop -gt $maximum)) {
	$repeat = $nop
}
elseif ($nop -gt $maximum) {
	echo "  That's too many, using our default value of $repeat"
	Start-Sleep -Seconds 3
}

# Use the following URL to accept all defaults:
# $URL = "https://passwordwolf.com/api/"
#
# This uses the variables above:
$URL = "https://passwordwolf.com/api/?length=$length&numbers=$numbers&upper=$upper&lower=$lower&special=$special&exclude=$exclude&repeat=$repeat"
#
$passwords = Invoke-RestMethod -Uri $URL -UseBasicParsing

clear

Write-Host

# Create an empty hash table.
$menu = @{}
$i=1
# and create the menu list and display them.
foreach ($password in $passwords.password) {
	Write-Host " $i. $($password)"
	$menu.Add($i,($password))
	$i++
}

Write-Host

# If there's only 1 password generated, then copy to the clipboard and exit.
if ($nop -eq 1) {
	$selection = $menu.Item(1)
	Set-Clipboard -Value $selection
	Write-Host "  Password Copied"
	Write-Host
	exit
}
# Otherwise choose which password you want from the list.
else {
	[int]$ans = Read-Host '  Select Password to Copy '
	$selection = $menu.Item($ans)
}

# If you enter anything else other than what is available, you get a smartass reply and you get to start over.
if ($ans -le 0 -Or $ans -ge $i -Or $ans -eq '') {
	Write-Host "  Hilarious..."
	Write-Host
}
# otherwise we'll place the selected password string in the clipboard for you to use.
else {
	Set-Clipboard -Value $selection
	Write-Host "  Password #$ans Copied"
	Write-Host
}
