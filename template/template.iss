[Setup]
AppName=Template Scraper
AppVersion=1.0
DefaultDirName={localappdata}\Template Scraper
DefaultGroupName=Template Scraper

[Files]
Source: "config\*"; DestDir: "{app}\config"; 
Source: "src\*"; DestDir: "{app}\src"; 

[Icons]
Name: "{group}\Template Scraper"; Filename: "{app}\template.exe"