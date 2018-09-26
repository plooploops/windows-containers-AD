$path = 'C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64\';
try
{
    c:\rtools_setup_x64.exe /install /quiet;
    while(!(Test-Path $path)){ Start-Sleep -Seconds 2 };
}
catch
{
    Write-Host $_.Exception.Message
}
if (Test-Path $path){ cd "$path"; .\msvsmon.exe /nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs; cd C:\ };

