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