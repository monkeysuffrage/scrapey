[Setup]
AppName=Farts Scraper
AppVersion=1.0
DefaultDirName={localappdata}\Farts Scraper
DefaultGroupName=Farts Scraper

[Files]
Source: "config\*"; DestDir: "{app}\config"; 

[Icons]
Name: "{group}\Farts Scraper"; Filename: "{app}\farts.exe"