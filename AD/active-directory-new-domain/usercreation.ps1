#Adds KDS Root Key with no delay. Use only with testing, will cause issue with more than one DC.
Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))

#Createa OU for Worker VMs and AD Group for Container Hosts

New-ADOrganizationalUnit "WorkerVMs"
New-ADGroup -GroupCategory Security -DisplayName "Container Hosts" -Name containerhosts -GroupScope Universal
$containerhosts = Get-ADGroup containerhosts

New-ADUser -Name User1 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User1@win.local
$user1 = Get-ADUser User1
New-ADUser -Name User2 -PasswordNeverExpires $true -AccountPassword ("Password123!" | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true -UserPrincipalName User2@win.local
$user2 = Get-ADUser User2

#frontend GMSA
New-ADServiceAccount -Name APP1 -DNSHostName app1.win.local -ServicePrincipalNames http/app1 -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local" -KerberosEncryptionType RC4, AES128, AES256

Set-ADServiceAccount -Identity app1 -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity app1 -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local','HTTP/vsvm.win.local'}
Set-ADServiceAccount -identity app1 -replace @{userAccountControl=16781312}

#backend GMSA
New-ADServiceAccount -Name APP2 -DNSHostName app2.win.local -ServicePrincipalNames http/app2 -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local", "containerhosts" -KerberosEncryptionType RC4, AES128, AES256

$impersonation = Get-ADServiceAccount -Identity app1
Set-ADServiceAccount -Identity app2 -PrincipalsAllowedToDelegateToAccount $impersonation
Set-ADServiceAccount -identity app2 -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local', 'HTTP/vsvm.win.local'}
Set-ADServiceAccount -identity app2 -replace @{userAccountControl=16781312}

#Other Possible AD Additions
$usergroup = New-ADGroup -GroupCategory Security -DisplayName "Web Users" -Name WebUsers -GroupScope Universal
$usergroup | Add-ADGroupMember -Members (Get-ADServiceAccount -Identity APP1,APP2)

$g | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)






