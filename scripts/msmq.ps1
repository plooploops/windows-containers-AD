#MSMQrec GMSA on worker1

New-ADServiceAccount -Name MSMQrec -DNSHostName MSMQrec.demo.local -ServicePrincipalNames http/MSMQrec -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=container hosts,CN=users,DC=demo,DC=local" -KerberosEncryptionType RC4, AES128, AES256

Set-ADServiceAccount -Identity MSMQrec -TrustedForDelegation $true
Set-ADServiceAccount -Identity MSMQrec -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','container hosts'
Set-ADServiceAccount -identity MSMQrec -replace @{'msDS-AllowedToDelegateTo'='LDAP/CSE-MSMQ-DC.demo.local','HTTP/CSE-MSMQ-02.demo.local','HTTP/CSE-MSMQ-01.demo.local','HTTP/CSE-MSMQ-DEV.demo.local'}
Set-ADServiceAccount -identity MSMQrec -replace @{userAccountControl=16781312}

#MSMQsend GMSA on worker2

New-ADServiceAccount -Name MSMQsend -DNSHostName MSMQsend.demo.local -ServicePrincipalNames http/MSMQsend -PrincipalsAllowedToRetrieveManagedPassword "Domain Controllers", "domain admins", "CN=container hosts,CN=users,DC=demo,DC=local" -KerberosEncryptionType RC4, AES128, AES256

Set-ADServiceAccount -Identity MSMQsend -TrustedForDelegation $true
Set-ADServiceAccount -Identity MSMQsend -PrincipalsAllowedToRetrieveManagedPassword 'domain admins','domain controllers','container hosts'
Set-ADServiceAccount -identity MSMQsend -replace @{'msDS-AllowedToDelegateTo'='LDAP/CSE-MSMQ-DC.demo.local','HTTP/CSE-MSMQ-02.demo.local','HTTP/CSE-MSMQ-01.demo.local','HTTP/CSE-MSMQ-DEV.demo.local'}
Set-ADServiceAccount -identity MSMQsend -replace @{userAccountControl=16781312}
