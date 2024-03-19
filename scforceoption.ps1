#This is the name of the csv that contains the device names to be read
$csvname = "hostname.csv" 

#auto detect location of script 
$scriptroot = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$csvPath = "$($scriptroot)\$($csvname)"

#Registry path for scforceoption
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system" 
$RegKey = "SCForceOption"
$disableValue = "0"
$enableValue = "1"

function Check-SCForceOption {

		try {
		
			$RegValue = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
				param($RegPath, $RegKey)
				if (Test-Path $RegPath) {
					$Value = Get-ItemProperty -Path $RegPath -Name $RegKey -ErrorAction Stop
					return $Value.$RegKey
				} else {
					return "Not Found"
				}
			} -ArgumentList $RegPath, $RegKey
		} catch {
			return "Error"
		}
		
		return $RegValue		
}

Function Get-SCForceSummary {	

	$SCForceSummary = @()
	$csvComputers = Import-Csv -Path $csvPath -Header List -ErrorAction Stop | Select-Object -ExpandProperty List
	
		foreach ($ComputerName in $csvComputers) {
			$SCForceOptionValue = Check-SCForceOption -Computer $ComputerName	
			if ($SCForceOptionValue -eq $enableValue) {
				$ReportedValue =  "Enabled"
			} elseif ($SCForceOptionValue -eq $disableValue) {
				$ReportedValue =  "Disabled"
			} elseif ($SCForceOptionValue -eq "Not Found") {
				$ReportedValue =  "Not Found"
			} else {
				$ReportedValue =  "Error"
				$SCForceOptionValue = "Error"
			}
			$SCForceSummary += [PSCustomObject]@{
							Computer = $ComputerName
							RegKey = $RegKey
							Status = $ReportedValue
						} 
		}	
	return $SCForceSummary
}	

if ($args -eq "-d"){


$SCForceSummary = Get-SCForceSummary
$Computers = $SCForceSummary | where-object { ($_.Status -eq "Enabled") } | Select-Object -ExpandProperty Computer

		foreach ($computerName in $Computers){
		Invoke-Command -ComputerName $computerName -ScriptBlock {
			Set-ItemProperty -Path $using:RegPath -Name $using:RegKey -Value $using:disableValue
		}
}


} Elseif ($args -eq "-e"){

$SCForceSummary = Get-SCForceSummary
$Computers = $SCForceSummary | where-object { ($_.Status -eq "Disabled") } | Select-Object -ExpandProperty Computer

		foreach ($computerName in $Computers){
		Invoke-Command -ComputerName $computerName -ScriptBlock {
			Set-ItemProperty -Path $using:RegPath -Name $using:RegKey -Value $using:enableValue
		}
}

}Elseif ($args -eq "-i"){

$output = Get-SCForceSummary 
$output
$output | Export-CSV -path "$($Scriptroot)\SCForceOptionSummary.csv" -NoTypeInformation

}Else {

Write-host "Expecting Argument `n-d (Disable)`n-e (Enable) `n-i (Current Status Information)"
}
