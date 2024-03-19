# SCForceOption

This powershell script is designed to retrieve the status of the "SCForceOption" Registry Key Value for a list of windows machines provided in a csv file.
It reads the information from the registry and reports back the current status of the key value.

# Arguments

( -i ) provides the current status information, then exports this to SCForceSummary.csv
( -e ) enables scforceoption on all computers in the input file hostname.csv
( -d ) disables scforceoption on all computers in the input file hostname.csv

# Formatting the input file
The input file "hostname.csv" must only include a list of computer names, without any headers or additional information. 
It is essential to ensure that the file is properly formatted as a “CSV” to avoid errors during the query process.

# Running the script

The script has a feature that automatically detects the folder it is being run from. However, if you plan to execute it outside of that folder, you need to modify the $scriptroot variable to reflect the folder location where the script is stored. Additionally, certain versions of Windows may have a different Registry Path, and this path can be customized by editing the $RegPath variable in the script.

# Information Gathered

**Enabled**  means that SCForceOption is enabled on the target machine
**Disabled** means that SCForceOption is disabled on the target machine
**Not Found** means that the Registry Variable or Registry Path was not found on the target machine
**Error** means that there was an issue finding this target machine
