$baseGPPath = Join-Path $env:windir "\system32\GroupPolicy"
$machinePolicyPath = Join-Path $baseGPPath "\Machine\Registry.pol"
$userPolicyPath = Join-Path $baseGPPath "\User\Registry.pol"

If(Test-Path $machinePolicyPath) {
	Get-Content $machinePolicyPath | Export-Clixml "machine-gp.xml"
}
If(Test-Path $userPolicyPath) {
	Get-Content $userPolicyPath    | Export-Clixml "user-gp.xml"
}
