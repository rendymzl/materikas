[Setup]
AppId=M4T2R1K45-0000-0000-0014-W4RD4N4
AppVersion=1.5.3+12
AppName=Materikas
AppPublisher=
AppPublisherURL=
AppSupportURL=
AppUpdatesURL=
DefaultDirName={autopf64}\materikas
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=materikas-1.5.3+12-windows-setup
Compression=lzma
SolidCompression=yes
SetupIconFile=
WizardStyle=modern
PrivilegesRequired=none
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]

Name: "english"; MessagesFile: "compiler:Default.isl"




















































[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,Materikas}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "materikas-1.5.3+12-windows-setup_exe\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "materikas-1.5.3+12-windows-setup_exe\PrintImage.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "materikas-1.5.3+12-windows-setup_exe\assets\template_tambah_barang_materikas.xlsx"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Materikas"; Filename: "{app}\materikas.exe"
Name: "{autodesktop}\Materikas"; Filename: "{app}\materikas.exe"; Tasks: desktopicon
Name: "{userstartup}\Materikas"; Filename: "{app}\materikas.exe"; WorkingDir: "{app}"; Tasks: launchAtStartup

[Run]
Filename: "{app}\materikas.exe"; Description: "{cm:LaunchProgram,Materikas}"; Flags:  nowait postinstall skipifsilent
