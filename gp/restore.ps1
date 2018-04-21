$baseGPPath = Join-Path $env:windir "\system32\GroupPolicy"
$machinePolicyPath = Join-Path $baseGPPath "\Machine\Registry.pol"
$userPolicyPath = Join-Path $baseGPPath "\User\Registry.pol"

If(Test-Path $machinePolicyPath) {
	Export-Clixml "machine-gp.xml" > $machinePolicyPath
}
If(Test-Path $userPolicyPath) {
	Export-Clixml "user-gp.xml" > $userPolicyPath
}
