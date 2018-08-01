cls
$RGName = "windows-container-ad";
$VMName = "myvs2017vm";
$VMUsername = "test";
$DeployLocation = "West US"
$ChocoPackages = "linqpad;sysinternals;agentransack;beyondcompare;fiddler4;visualstudiocode;imageresizerapp;gimp;";
#$ARMTemplate = "C:\@SourceControl\GitHub\ARMChocolatey\azuredeploy.json"
$ARMTemplate = "C:\Users\angee\source\repos\win-container-ad\AD\visual-studio-dev-vm-chocolatey\azuredeploy.json"

# 1. Login
#Login-AzureRmAccount

#2. Create a resource group
#New-AzureRmResourceGroup -Name $RGName -Location $DeployLocation -Force

#3. Create resources within RG
$sw = [system.diagnostics.stopwatch]::startNew()
New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile $ARMTemplate -deployLocation $DeployLocation -vmName $VMName -vmAdminUserName $VMUsername -vmIPPublicDnsName $VMName -chocoPackages $ChocoPackages -Mode Complete -Force 
$sw | Format-List -Property *

#4. Get the RDP file
Get-AzureRmRemoteDesktopFile -ResourceGroupName $RGName -Name $VMName -Launch -Verbose -Debug

