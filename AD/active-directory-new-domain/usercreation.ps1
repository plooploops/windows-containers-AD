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

#MSMQSend gMSA - Receiver on Worker 2
New-ADServiceAccount -Name MSMQSend -DNSHostName MSMQSend.win.local -ServicePrincipalNames http/MSMQSend -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local" -KerberosEncryptionType RC4, AES128, AES256
Set-ADServiceAccount -Identity MSMQSend -replace @{ServicePrincipalName='host/MSMQSend','MQQB/MSMQSend','RPC/MSMQSend','TCP/MSMQSend','UDP/MSMQSend'}
Set-ADServiceAccount -Identity MSMQSend -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity MSMQSend -replace @{'msDS-AllowedToDelegateTo'='host/worker2.win.local','LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local','HTTP/vsvm.win.local', 'RPC/worker1.win.local', 'RPC/worker2.win.local'}
Set-ADServiceAccount -identity MSMQSend -replace @{userAccountControl=16781312}
SetSPN -l win\MSMQSend$

#MSMQReceiver gMSA - Receiver on Worker 1
New-ADServiceAccount -Name MSMQReceiver -DNSHostName MSMQReceiver.win.local -ServicePrincipalNames http/MSMQReceiver -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local" -KerberosEncryptionType RC4, AES128, AES256
Set-ADServiceAccount -Identity MSMQReceiver -replace @{ServicePrincipalName='host/MSMQReceiver','MQQB/MSMQReceiver','RPC/MSMQReceiver','TCP/MSMQReceiver','UDP/MSMQReceiver'}
Set-ADServiceAccount -Identity MSMQReceiver -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity MSMQReceiver -replace @{'msDS-AllowedToDelegateTo'='host/worker1.win.local','LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local','HTTP/vsvm.win.local', 'RPC/worker1.win.local', 'RPC/worker2.win.local'}
Set-ADServiceAccount -identity MSMQReceiver -replace @{userAccountControl=16781312}
SetSPN -l win\MSMQReceiver$

#frontend GMSA
New-ADServiceAccount -Name APP1 -DNSHostName app1.win.local -ServicePrincipalNames http/app1 -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local" -KerberosEncryptionType RC4, AES128, AES256

Set-ADServiceAccount -Identity app1 -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity app1 -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local','HTTP/vsvm.win.local'}
Set-ADServiceAccount -identity app1 -replace @{userAccountControl=16781312}
#confirm SPN
SetSPN -l win\app1$

#backend GMSA
New-ADServiceAccount -Name APP2 -DNSHostName app2.win.local -ServicePrincipalNames http/app2 -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=containerhosts,CN=users,DC=win,DC=local", "containerhosts" -KerberosEncryptionType RC4, AES128, AES256

$impersonation = Get-ADServiceAccount -Identity app1
Set-ADServiceAccount -Identity app2 -PrincipalsAllowedToDelegateToAccount $impersonation
Set-ADServiceAccount -identity app2 -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/worker1.win.local','HTTP/worker2.win.local', 'HTTP/vsvm.win.local'}
Set-ADServiceAccount -identity app2 -replace @{userAccountControl=16781312}
#confirm SPN
SetSPN -l win\app2$

#Other Possible AD Additions
$usergroup = New-ADGroup -GroupCategory Security -DisplayName "Web Users" -Name WebUsers -GroupScope Universal
$usergroup | Add-ADGroupMember -Members (Get-ADServiceAccount -Identity APP1,APP2)

$g | Add-ADGroupMember -Members (Get-ADComputer -Identity worker1)






