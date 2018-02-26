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
		[Switch] $Force
	)

	Process {
		$From = Join-Path $env:USERPROFILE $Name
		$To = Resolve-Path $Name
		"Linking from $From to $To" | Write-Verbose

		If(Test-Path $From) {
			# file already exists
			If($Force) {
				Remove-Item $From -Force
			} Else {
				# magic number means "file already exists"
				Throw [System.IO.IOException]::new(
					"$From already exists!",
					0x80070050)
			}
		}

		#mklink
		New-Item -Path $From -Value $To -ItemType SymbolicLink
	}
}

(".gitconfig",
".gitignore",
".gitignore_global",
".latexmkrc",
".minttyrc",
"_curlrc") | LinkFile
