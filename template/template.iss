[Setup]
AppName=Template Scraper
AppVersion=1.0
DefaultDirName={localappdata}\Template Scraper
DefaultGroupName=Template Scraper
// ChangesAssociations=yes

[Files]
Source: "config\*"; DestDir: "{app}\config"; 
Source: "src\*"; DestDir: "{app}\src"; 
Source: "icon.ico"; DestDir: "{app}"; 

[Icons]
Name: "{group}\Template Scraper"; Filename: "{app}\template.exe"
// Name: "{group}\Edit Config"; Filename: "{win}\notepad.exe"; Parameters: "{app}\config\config.yml"; Comment: "Config"; WorkingDir: "{app}\config"
// Name: "{group}\View Output File"; Filename: "{app}\output.csv"; WorkingDir: "{app}"
Name: "{group}\Uninstall Template Scraper"; Filename: "{uninstallexe}"

[Registry]
// Root: HKCR; Subkey: SystemFileAssociations\.csv\shell\Template Scraper; ValueType: string; Flags: uninsdeletekey deletekey; ValueName: Icon; ValueData: """{app}\icon.ico"""
// Root: HKCR; Subkey: SystemFileAssociations\.csv\shell\Template Scraper\command; ValueType: string; ValueData: """{app}\template.exe"" ""%1"""; Flags: uninsdeletekey deletekey

[Run]
//Filename: schtasks.exe; Parameters:" /CREATE /TN ""Scheduled Template"" /TR ""{app}\template.exe"" /SC DAILY /ST 02:30"
