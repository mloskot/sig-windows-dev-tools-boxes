# Sets SSH private key files with strict permissions to let Vagrant use keys
# and help avoid password prompts on every vagrant ssh command.
Get-ChildItem -Recurse -File -Filter private_key | ForEach-Object {
    New-Variable -Name keyFile -Value $_
    if (-not (Test-Path -Path $keyFile -PathType Leaf)) {
        Write-Error "Cannot find $keyFile"
    }
    Write-Host "Setting SSH keys permissions for $keyFile"
    icacls $keyFile /c /t /Inheritance:d
    icacls $keyFile /c /t /Grant ${env:UserName}:F
    takeown /F $keyFile
    icacls $keyFile /c /t /Grant:r ${env:UserName}:F
    icacls $keyFile /c /t /Remove:g Administrator 'Authenticated Users' BUILTIN\Administrators BUILTIN Everyone System Users
    icacls $keyFile
    Remove-Variable -Name keyFile
}
