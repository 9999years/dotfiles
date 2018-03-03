<#
.PARAMETER Name
The name of a file in this directory, like ".gitconfig" or ".minttyrc"
#>
function LinkFile {
	[CmdletBinding()]
	Param(
		[Parameter(
			ValueFromPipeline=$True
		)]
		[String] $Name,
		[Switch] $Force,
		[Switch] $Ask
	)

	Process {
		$From = Join-Path $env:USERPROFILE $Name
		$To = Resolve-Path $Name
		"Linking from $From to $To" | Write-Verbose

		If(Test-Path $From) {
			$resp = ""
			If(!$Force -and $Ask) {
				"$From already exists!"
				While($resp -notmatch "[yn]") {
					$resp = Read-Host "Write anyways? (y/n)"
				}
			}
			# file already exists
			If($Force -or ($resp -match "y")) {
				Remove-Item $From -Force
			} Else {
				# magic number means "file already exists"
				Throw [System.IO.IOException]::new(
					"$From already exists!",
					0x80070050)
			}
		}

		#mklink
		New-Item -Path $From -Value $To -ItemType SymbolicLink | `
		%{ $_.Name }
	}
}

(".gitconfig",
".gitignore",
".gitignore_global",
".latexmkrc",
".minttyrc",
"_curlrc",
"AppData/Roaming/ConEmu.xml") | LinkFile -Ask
