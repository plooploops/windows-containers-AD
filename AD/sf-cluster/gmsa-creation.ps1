$group = New-ADGroup -GroupCategory Security -DisplayName "Container Hosts" -Name containerhosts -GroupScope Universal 
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity host)

$group | Add-ADGroupMember -Members (Get-ADComputer -Identity conhost000000)
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity conhost000001)
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity conhost000002)
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity conhost000003)
$group | Add-ADGroupMember -Members (Get-ADComputer -Identity conhost000004)

# FOR IIS Scenarios ONLY #	
#frontend GMSA
New-ADServiceAccount -Name FRONTEND -DNSHostName frontend.win.local -ServicePrincipalNames http/frontend -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "containerhosts" -KerberosEncryptionType RC4, AES128, AES256
Set-ADServiceAccount -Identity frontend -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','containerhosts'
Set-ADServiceAccount -identity frontend -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/backend.win.local','HTTP/conhost000000.win.local','HTTP/conhost000001.win.local','HTTP/conhost000002.win.local','HTTP/conhost000003.win.local','HTTP/conhost000004.win.local'}
Set-ADServiceAccount -identity frontend -replace @{userAccountControl=16781312}
#confirm SPN
SetSPN -l win\frontend$
#backend GMSA
New-ADServiceAccount -Name BACKEND -DNSHostName backend.win.local -ServicePrincipalNames http/backend -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "containerhosts" -KerberosEncryptionType RC4, AES128, AES256
$impersonation = Get-ADServiceAccount -Identity frontend
Set-ADServiceAccount -Identity backend -PrincipalsAllowedToDelegateToAccount $impersonation
Set-ADServiceAccount -identity backend -replace @{'msDS-AllowedToDelegateTo'='LDAP/adVM.win.local','HTTP/conhost000000.win.local','HTTP/conhost000001.win.local','HTTP/conhost000002.win.local','HTTP/conhost000003.win.local','HTTP/conhost000004.win.local'}
Set-ADServiceAccount -identity backend -replace @{userAccountControl=16781312}
#confirm SPN
SetSPN -l win\backend$

#get frontend settings
get-adserviceaccount -identity frontend -properties 'PrincipalsAllowedToDelegateToAccount','PrincipalsAllowedToRetrieveManagedPassword','kerberosEncryptionType','ServicePrincipalName','msDS-AllowedToDelegateTo','userAccountControl','PrincipalsAllowedToDelegateToAccount'

#get backend settings
get-adserviceaccount -identity backend -properties 'PrincipalsAllowedToDelegateToAccount','PrincipalsAllowedToRetrieveManagedPassword','kerberosEncryptionType','ServicePrincipalName','msDS-AllowedToDelegateTo','userAccountControl','PrincipalsAllowedToDelegateToAccount'