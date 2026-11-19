; Compile only from the complete, verified Flutter release directory.
#ifndef AppVersion
  #error AppVersion is required
#endif
#ifndef BuildNumber
  #error BuildNumber is required
#endif
#ifndef BundleDir
  #error BundleDir is required
#endif
#ifndef OutputDirectory
  #error OutputDirectory is required
#endif

[Setup]
AppId={{FA12D6E6-D46B-4F05-A7DF-884DD12D725A}
AppName=Dukto2
AppVersion={#AppVersion}
VersionInfoVersion={#AppVersion}.{#BuildNumber}
AppPublisher=赵真灵(lvjing2)
AppPublisherURL=https://github.com/lvjing2
AppSupportURL=https://github.com/lvjing2/dukto2/issues
AppUpdatesURL=https://github.com/lvjing2/dukto2/releases
DefaultDirName={localappdata}\Programs\Dukto2
DefaultGroupName=Dukto2
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDirectory}
OutputBaseFilename=Dukto2-{#AppVersion}-build.{#BuildNumber}-windows-x64-setup
SetupIconFile={#SourcePath}..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Dukto2.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
CloseApplications=yes
RestartApplications=no
Uninstallable=yes
; Only files installed below {app} are removed. Never delete user settings,
; identity, history or received files from AppData/Downloads on uninstall.

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BundleDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Dukto2"; Filename: "{app}\Dukto2.exe"
Name: "{autodesktop}\Dukto2"; Filename: "{app}\Dukto2.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Dukto2.exe"; Description: "{cm:LaunchProgram,Dukto2}"; Flags: nowait postinstall skipifsilent unchecked
