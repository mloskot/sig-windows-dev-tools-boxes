$ErrorActionPreference = 'Stop'
if ($args[0] -notmatch 'test_') {
    throw "Directory $args[0] is not test"
}
Write-Output "Running $($args[0])"
Push-Location $args[0]
$log = (Join-Path -Path (Get-Location) -ChildPath ("run-{0}.log" -f (Get-Date).ToString('yyyyMMddTHHmmss')))
0..9 | ForEach-Object {
    $s = (Get-Date)
    Write-Output ('######### Test vagrant up #{0} at {1}' -f $_, (Get-Date -Date $s -Format o))
    vagrant up
    Write-Output ('######### Done vagrant up #{0} in {1:N5} minutes' -f $_, ((Get-Date) - $s).TotalMinutes)
    vagrant destroy --force
    Remove-Item -Recurse .\.vagrant -Force -ErrorAction SilentlyContinue
} | Tee-Object -FilePath $log
Write-Host '-----------------------------------------'
Get-Content $log | Select-String -Pattern 'Done'  | Tee-Object -FilePath $log -Append
Write-Host "Output saved in $log"
Pop-Location
