
net localgroup administrators /add win.local\workeradmin
net localgroup "Remote Desktop Users" /add win.local\workeradmin
net localgroup "Remote Desktop Users" /add win.local\winadmin

Enable-WindowsOptionalFeature -FeatureName ActiveDirectory-Powershell -online -all
Start-BitsTransfer https://raw.githubusercontent.com/Microsoft/Virtualization-Documentation/live/windows-server-container-tools/ServiceAccounts/CredentialSpec.psm1

#Needs to use AD Account not Local

Add-ADGroupMember -Identity "CN=containerhosts,CN=users,DC=win,DC=local" -Members "CN=worker1,OU=WorkerVMs,DC=win,DC=local"

Get-ADServiceAccount -Identity app1 
Install-ADServiceAccount -Identity app1

Get-ADServiceAccount -Identity app2
Install-ADServiceAccount -Identity app2

Import-Module .\CredentialSpec.psm1
new-item -itemtype directory -path C:\ProgramData\Docker\CredentialSpecs

New-CredentialSpec -Name app1 -AccountName app1 
New-CredentialSpec -Name app2 -AccountName app2 