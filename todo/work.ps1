$sources = "C:\sources"
$language = "en-US"

$aclGroup = New-Object System.Security.Principal.NTAccount("BUILTIN\Administrators")
#$aclRules = New-Object Security.AccessControl.FileSystemAccessRule($aclGroup, "FullControl", "ContainerInherit,ObjectInherit", "InheritOnly", "Allow")
#                                                                #    $(Value):(F)                                              /T             /grant

Remove-Item -Force -Recurse -Confirm:$false "$sources\PerfLogs"
& attrib.exe '+s' '+h' "$sources\inetpub"

# Optimize OptionalFeatures
$wofRemovals = (
    "WorkFolders-Client",
    "WindowsMediaPlayer",
    "SmbDirect",
    "Microsoft-RemoteDesktopConnection",
    "MSRDC-Infrastructure"
)
foreach ($feature in $wofRemovals) {
    Disable-WindowsOptionalFeature -Path:$sources -FeatureName:$feature -Remove
}

# Optimize Windows Capabilities
$capRemovals = (
    "App.StepsRecorder~~~~0.0.1.0",
    "Browser.InternetExplorer~~~~0.0.11.0",
    "Language.Handwriting~~~$language~0.0.1.0",
    "Language.Speech~~~$language~0.0.1.0",
    "Language.TextToSpeech~~~$language~0.0.1.0",
    "MathRecognizer~~~~0.0.1.0",
    "Media.WindowsMediaPlayer~~~~0.0.12.0",
    "Microsoft.Windows.Notepad.System~~~~0.0.1.0",
    "Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0",
    "Microsoft.Windows.Ethernet.Client.Intel.E1i68x64~~~~0.0.1.0",
    "Microsoft.Windows.Ethernet.Client.Intel.E2f68~~~~0.0.1.0",
    "Microsoft.Windows.Ethernet.Client.Realtek.Rtcx21x64~~~~0.0.1.0",
    "Microsoft.Windows.Ethernet.Client.Vmware.Vmxnet3~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Broadcom.Bcmpciedhd63~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Broadcom.Bcmwl63al~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Broadcom.Bcmwl63a~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwbw02~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwew00~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwew01~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwlv64~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwns64~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwsw00~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwtw02~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwtw04~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwtw06~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwtw08~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Intel.Netwtw10~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Marvel.Mrvlpcie8897~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Qualcomm.Athw8x~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Qualcomm.Athwnx~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Qualcomm.Qcamain10x64~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Ralink.Netr28x~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Realtek.Rtl8192se~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane01~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane13~~~~0.0.1.0",
    "Microsoft.Windows.Wifi.Client.Realtek.Rtwlane~~~~0.0.1.0"
)
foreach ($cap in $capRemovals) {
    Remove-WindowsCapability -Path:$sources -Name:$cap
}

function Remove-PrivilegedFile {
    param (
        [string]
        $Path
    )

    # $AclObject = Get-Acl -Path $Path
    # $AclObject.SetOwner($aclGroup)
    # $AclObject.AddAccessRule($aclRules)
    # Set-Acl -Path $Path -AclObject $AclObject
    & takeown.exe '/f' $Path | Out-Null
    & icacls.exe $Path '/grant' "$($aclGroup):(F)" '/T' '/C' | Out-Null

    Remove-Item -Force -Confirm:$false -Path:$Path
}

function Remove-PrivilegedDirectory {
    param (
        [string]
        $Path
    )

    # $AclObject = Get-Acl -Path $Path
    # $AclObject.SetOwner($aclGroup)
    # $AclObject.AddAccessRule($aclRules)
    # Set-Acl -Path $Path -AclObject $AclObject
    & takeown.exe '/r' '/f' $Path | Out-Null
    & icacls.exe $Path '/grant' "$($aclGroup):(F)" '/T' '/C' | Out-Null

    Remove-Item -Force -Recurse -Confirm:$false -Path:$Path
}

# Remove Deprecated programs
Remove-PrivilegedDirectory -Path:"$sources\Program Files\Internet Explorer"
Remove-PrivilegedDirectory -Path:"$sources\Program Files (x86)\Internet Explorer"
Remove-PrivilegedDirectory -Path:"$sources\Program Files\Windows Mail"
Remove-PrivilegedDirectory -Path:"$sources\Program Files (x86)\Windows Mail"
Remove-PrivilegedDirectory -Path:"$sources\Program Files\Windows Photo Viewer"
Remove-PrivilegedDirectory -Path:"$sources\Program Files (x86)\Windows Photo Viewer"

# Remove Microsoft Edge entirely
Remove-PrivilegedDirectory -Path:"$sources\Program Files (x86)\Microsoft"

# Remove OneDrive
Remove-PrivilegedDirectory -Path:"$sources\Windows\System32\OneDrive.ico"
Remove-PrivilegedDirectory -Path:"$sources\Windows\System32\OneDriveSetup.exe"
