<#
.PARAMETER Name
The name of a file in this directory, like ".gitconfig" or ".minttyrc"
#>
[CmdletBinding(SupportsShouldProcess = $True)]
Param(
	[Parameter(
		ValueFromPipeline=$True
	)]
	[String[]]$Names=(".gitconfig",
		".gitignore_global",
		".gitattributes_global",
		".latexmkrc",
		".minttyrc",
		".pip.conf",
		".curlrc",
		".youtube-dl.conf",
		".pythonrc",
		".ptpython/config.py",
		"AppData/Roaming/ConEmu.xml",
		".config/alacritty/alacritty.yml"),
	[Switch]$Force
)

Begin {
	if ($ConfirmPreference -eq 'Low') {
		$YesToAll = $False
	} else {
		$YesToAll = $True
	}
	if ($Force) {
		$YesToAll = $True
	}
	$NoToAll = $False
}

Process {
	ForEach($Name in $Names) {
		$From = Join-Path $env:USERPROFILE $Name
		$To = Join-Path $PSScriptRoot $Name
		"Linking from $From to $To" | Write-Verbose

		If(Test-Path $From) {
			# file already exists

			If($PSCmdlet.ShouldContinue("Overwrite $From with a link to $To?",
					"Confirm overwrite", [ref]$YesToAll, [ref]$NoToAll)) {
				Remove-Item $From -Confirm:$False
				New-Item -Path $From -Value $To -ItemType SymbolicLink -Confirm:$False |
					Out-Null
			}
		} Else {
			New-Item -Path $From -Value $To -ItemType SymbolicLink -Confirm:$False |
				Out-Null
		}
		$Name
	}
}
