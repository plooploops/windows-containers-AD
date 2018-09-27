
#Get current A Records
Get-DnsServerResourceRecord -ComputerName adVM -ZoneName win.local -RRType A

#Create New A Record
Add-DnsServerResourceRecordA -Name "frontend" -ZoneName win.local -AllowUpdateAny -IPv4Address 10.0.0.15

#Modify Existing A Record
$new = Get-DnsServerResourceRecord -ComputerName adVM -ZoneName win.local -Name frontend
$old = Get-DnsServerResourceRecord -ComputerName adVM -ZoneName win.local -Name frontend
$new.RecordData.IPv4Address = [System.Net.IPAddress]::parse('10.0.0.16')
Set-DnsServerResourceRecord -NewInputObject $new -OldInputObject $old -ZoneName win.local -ComputerName adVM

#Remove Existing A Record

Get-DnsServerResourceRecord -ComputerName adVM -ZoneName win.local -Name frontend | Remove-DNSServerResourceRecord –ZoneName win.local –ComputerName adVM -Force

