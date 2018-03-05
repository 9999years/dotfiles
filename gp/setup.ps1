"Getting RSAT = Remote Server Administration Tools incl. GPMC"
choco install rsat

"Enabling RSATClient-Features-GP"
$enable = Enable-WindowsOptionalFeature -FeatureName 'RSATClient-Features-GP' -Online

"Result:"
$enable

If($enable.RestartNeeded) {
	"Restart needed! Exiting."
	Return
}
