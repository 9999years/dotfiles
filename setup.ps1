<#
.PARAMETER Name
The name of a file in this directory, like ".gitconfig" or ".minttyrc"
#>
[CmdletBinding()]
Param(
	[Parameter(
		ValueFromPipeline=$True
	)]
	[String[]]$Names=(".gitconfig",
		".gitignore_global",
		".gitattributes_global",
		".latexmkrc",
		".minttyrc",
		"pip.conf",
		"_curlrc",
		"youtube-dl.conf",
		"AppData/Roaming/ConEmu.xml"),
	[ValidateSet("Force", "Quit", "Skip", "Ask")]
	[String]$Overwrite="Ask"
)

Begin {
	"Linking files"

	function PromptForChoice {
		[CmdletBinding()]
		Param(
			[String]$Message,
			[String]$Question,
			[String[]]$Choices=("&Yes", "&No"),
			[Int]$DefaultChoice=1
		)

		$choiceList = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
		$Choices | %{
			$choiceList.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList $_))
		}

		return $Host.UI.PromptForChoice($Message, $Question, $choiceList, $DefaultChoice)
	}

	$choice = Switch($Overwrite) {
		"Force" { 0 }
		"Quit"  { 1 }
		"Skip"  { 2 }
		Default { -1 }
	}
}

Process {
	ForEach($Name in $Names) {
		$From = Join-Path $env:USERPROFILE $Name
		$To = Join-Path $PSScriptRoot $Name
		"Linking from $From to $To" | Write-Verbose

		$skip = $False

		If(Test-Path $From) {
			# file already exists
			If($Overwrite -eq "Ask") {
				# ask the user
				$choice = PromptForChoice `
					-Message "$From already exists" `
					-Question "Write anyways?" `
					-Choices ("&Force", "&Quit", "&Skip") `
					-DefaultChoice 1
			}

			Switch($choice) {
				0 { Remove-Item $From -Force }
				# quit; magic number means "file already exists"
				1 { Throw [System.IO.IOException]::new(
					"$From already exists!", 0x80070050) }
				Default {
					"Skipping"
					# Continue keyword doesnt work here
					# for. Reasons
					$skip = $True
				}
			}
		}

		If($skip) {
			Continue
		}

		#mklink
		New-Item -Path $From -Value $To -ItemType SymbolicLink | `
		%{ $_.Name }
	}
}

End {
	"To restore local group policy run './gp/restore.ps1'; this will overwrite all current group policy! Use https://github.com/dlwyatt/PolicyFileEditor/blob/master/Commands.ps1 instead?"
}
