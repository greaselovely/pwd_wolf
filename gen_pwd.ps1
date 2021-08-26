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
$len=16
# characters to exclude:
$exclude='"@!<>|[]{}\/?&"'
# number of passwords to generate:
$repeat=10
#
#
# Use the following URL to accept all defaults:
# $url1 = "https://passwordwolf.com/api/"
#
# This uses the 
$url1 = "https://passwordwolf.com/api/?length=$len&numbers=$numbers&upper=$upper&lower=$lower&special=$special&exclude=$exclude&repeat=$repeat"
#
#
####

$response = Invoke-WebRequest -Uri $url1 -UseBasicParsing
$passwords = $response | ConvertFrom-Json

clear

Write-Host

$menu = @{}
$i=1
foreach ($password in $passwords.password) {
	Write-Host " $i. $($password)"
	$menu.Add($i,($password))
	$i++
}
Write-Host

[int]$ans = Read-Host '  Select Password to Copy '
$selection = $menu.Item($ans)

if ($ans -ge $i -Or $ans -eq '') {
	Write-Host "  Hilarious..."
	Write-Host
}
else {
	Set-Clipboard -Value $selection
	Write-Host "  Password Copied"
	Write-Host
}
