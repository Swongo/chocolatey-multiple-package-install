$AddNewLine = "`n"

function ExitScript($ExitReason) {
    Write-Host $ExitReason;
    cmd /c pause 
    exit;
}

function ExitIfNotAdministrator {
    $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent());
    if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        ExitScript "Run as administrator" 
    }
}

function IsChocolateyInstalled {
    try {
        choco
        return $true;
    }
    catch {
        return $false;
    }
}

function ChocolateyInstallMenu {
    $Install = New-Object System.Management.Automation.Host.ChoiceDescription "&Install", "Install chocolatey";
    $Script = New-Object System.Management.Automation.Host.ChoiceDescription "&Script", "Show chocolatey install script";
    $Url = New-Object System.Management.Automation.Host.ChoiceDescription "&Url", "Show url for chocolatey install script";
    $Exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", "Exit script";
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Install, $Script, $Url, $Exit);

    $ScriptUrl = "https://chocolatey.org/install.ps1";
    $ChocoInstallScript = (New-Object System.Net.WebClient).DownloadString($ScriptUrl);
    $ChocolateyInstalled = $false;

    $AddNewLine;
    Do {
        $Decision = $Host.UI.PromptForChoice("Chocolatey install menu", "Type a command", $Options, 1);
        switch ($Decision) {
            0 {
                Invoke-Expression $ChocoInstallScript;
                $ChocolateyInstalled = $true;
            }
            1 {
                $AddNewLine;
                Write-Host $ChocoInstallScript -ForegroundColor green;
            }
            2 {
                $AddNewLine;
                Write-Host $ScriptUrl;
                $AddNewLine;
            }
            3 {
                exit;
            }
            default {
               exit;
            }
        } 
    } Until ($ChocolateyInstalled -eq $true)

    RunScript;
}

function PackageInstallMenu {
    $File = "Packages.txt";
    $AddNewLine;
    Write-Warning "Remember to check virus scan results for each package on https://chocolatey.org/ before blindly installing.";

    if (!(Test-Path .\$File)) {
        ExitScript "No file with name $File was found. Please create file in same location as script location and add one package name on each line.";
    }
    elseif (!(Get-Content -Path .\$File)) {
        ExitScript "$File does not contain any packages. Please add one package name on each line.";
    }
    else {
        PrepareInstall $File;
    }
}

function PrepareInstall($File) {
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Install all packages without prompting";
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Install all packages with prompting";
    $Exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", "Exit script";
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No, $Exit);
    $Decision = $Host.UI.PromptForChoice("Ready to install all packages", "Confirm all prompts?", $Options, 1);

    switch ($Decision) {
        0 {
            InstallPackages $file $true;
        }
        1 {
            InstallPackages $file $false;
        }
        2 {
            exit;
        }
        Default {
            exit;
        }
    }
}
function InstallPackages($file, $acceptAllPrompts) {
    $PackagesToInstall = Get-Content -Path .\$file;
    $FailedToInstallPackages = New-Object System.Collections.Generic.List[System.Object];

    foreach ($line in $PackagesToInstall) {
        if ($acceptAllPrompts -eq $true) {
            try {
                choco install $line -y;
            }
            catch {
                $FailedToInstallPackages.Add($line);
            }
        }
        else {
            try {
                choco install $line;
            }
            catch {
                $FailedToInstallPackages.Add($line);
            }
        }
    }

    if ($FailedToInstallPackages.Count -gt 0) {
        $AddNewLine;
        foreach ($FailedPackage in $FailedToInstallPackages) {
            Write-Host "Failed to Install: $FailedPackage" -ForegroundColor Red;
        }
        $AddNewLine;

        if ($FailedToInstallPackages.Count -lt $PackagesToInstall.Length) {
            $TotalInstalled = $PackagesToInstall.Length - $FailedToInstallPackages.Count;
            ExitScript "$($TotalInstalled)/$($PackagesToInstall.Length) packages installed.";
        }
        elseif ($FailedToInstallPackages.Count -eq $PackagesToInstall.Length) {
            ExitScript "All packages failed to install.";
        }
    }
    else {
        ExitScript "All packages installed.";
    }
}

function RunScript { 
    ExitIfNotAdministrator;

    if (IsChocolateyInstalled -eq $true) {
        PackageInstallMenu;
    }
    else {
        ChocolateyInstallMenu;
    }

    exit;
}

RunScript;