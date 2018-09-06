#Adds KDS Root Key with no delay. Use only with testing, will cause issue with more than one DC.
Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))

#Create a OU for Worker VMs and AD Group for Container Hosts

New-ADOrganizationalUnit "WorkerVMs"
New-ADGroup -GroupCategory Security -DisplayName "Container Hosts" -Name containerhosts -GroupScope Universal
$containerhosts = Get-ADGroup containerhosts

New-ADOrganizationalUnit "Member Servers"


# Create some sample regular users if needed for future testing

New-ADUser -Name User1 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User1@win.local
$user1 = Get-ADUser User1
New-ADUser -Name User2 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User2@win.local
$user2 = Get-ADUser User2
New-ADUser -Name User3 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User3@win.local
$user3 = Get-ADUser User3







