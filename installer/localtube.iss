; Instalador do LocalTube para Windows (Inno Setup 6).
; Gere antes o executável: flutter build windows --release
; Depois compile este script no Inno Setup Compiler (ou: iscc installer\localtube.iss).

#define AppName "LocalTube"
#define AppVersion "1.0.0"
#define BuildDir "..\build\windows\x64\runner\Release"

[Setup]
AppId={{6C1C4E5B-5A57-4C1B-9B7B-5C0D3B1A7E21}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppName}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayIcon={app}\LocalTube.exe
OutputDir=..\build\installer
OutputBaseFilename=LocalTube-Setup-{#AppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequiredOverridesAllowed=dialog
WizardStyle=modern

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\LocalTube.exe"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\LocalTube.exe"; Tasks: desktopicon

[Registry]
; Adiciona o LocalTube ao menu "Abrir com" dos formatos de vídeo.
Root: HKA; Subkey: "Software\Classes\Applications\LocalTube.exe\shell\open\command"; ValueType: string; ValueData: """{app}\LocalTube.exe"" ""%1"""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\LocalTube.exe"; ValueType: string; ValueName: "FriendlyAppName"; ValueData: "LocalTube"
Root: HKA; Subkey: "Software\Classes\.mp4\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\.mkv\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\.avi\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\.mov\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\.webm\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\.wmv\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\.flv\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\.m4v\OpenWithList\LocalTube.exe"; Flags: uninsdeletekey

[Run]
Filename: "{app}\LocalTube.exe"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
