# Chocolatey multiple package install

This script uses Chocolatey (https://chocolatey.org/) a package manager for windows to install multiple packages from a "Packages.txt" file.<br />If you don't have Chocolatey installed you will be prompted to install it in order to proceed with the package installation.

## Disclaimer
This script uses the free and unlicensed version of chocolatey which does not contain contain runtime malware protection / virus scanning from the command line. Therefore Remember to check virus scan results for each package on https://chocolatey.org/ before blindly installing the package.

## Usage

1) Create or add packages line by line in a "Packages.txt" file in the same location as this script
    - if Packages.txt is empty or does not exists the script will throw an exception 
2) Run script with powershell.exe as admin: 
    - `.\ChocolateyMultiplePackageInstall.ps1`

### Chocolatey intall menu
This menu will only be shown if you don't have Chocolatey installed.<br />
It has 4 options: Install, Script, Url, Exit. 
- "Script" prints the full script in the console 
- "Url" shows the link to the chocolatey install script

### Package install menu
When Chocolatey is installed this menu will be shown.<br />
It has 3 options: Yes, No and Exit
- "Yes" install all packages without prompting
- "No" install all packages with prompting