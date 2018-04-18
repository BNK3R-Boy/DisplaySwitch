#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent

SetKeyDelay, 30, 30

RegRead, location, HKEY_CURRENT_USER\SOFTWARE\MPC-HC64\MPC-HC, ExePath
rr:=ErrorLevel
If rr
{
  RegRead, location, HKEY_CURRENT_USER\SOFTWARE\MPC-HC\MPC-HC, ExePath
  rr:=ErrorLevel
}

Icon_single:="DisplaySwitch.single.ico"
Icon_dual:="DisplaySwitch.dual.ico"
Icon_sleep:="DisplaySwitch.sleep.ico"
Icon_exit:="DisplaySwitch.exit.ico"


Menu, Tray, NoStandard
Menu, Tray, Add , 2nd Display on/off, DisplaySwitch
Menu, Tray, Add , Displays off, PowerSwitch
Menu, Tray, Icon, Displays off, %A_WorkingDir%\%Icon_sleep%,1
Menu, Tray, Tip, DisplaySwitch

vurlr:=1
If !rr
{
  SetTimer, CheckClipboard, On
  Menu, Tray, Add
  Menu, Tray, Add , Video URL Redirector, VURLR
  Menu, Tray, Check, Video URL Redirector
}
Else
{
  SetTimer, CheckClipboard, Off
}

Menu, Tray, Add
Menu, Tray, Add , Exit, Exi
Menu, Tray, Icon, Exit, %A_WorkingDir%\%Icon_exit%,1
Menu, Tray, Default, 2nd Display on/off

SysGet, Mon, MonitorCount
If (Mon == 1)
{
  Menu, Tray, Icon, %A_WorkingDir%\%Icon_dual%,1,1
  Menu, Tray, Icon, 2nd Display on/off, %A_WorkingDir%\%Icon_dual%,1
}
Else
{
  Menu, Tray, Icon, %A_WorkingDir%\%Icon_single%,1,1
  Menu, Tray, Icon, 2nd Display on/off, %A_WorkingDir%\%Icon_single%,1
}

Return

VURLR:
  If !vurlr
  {
    vurlr:=1
    SetTimer, CheckClipboard, On
    Menu, Tray, ToggleCheck, Video URL Redirector
  }
  Else
  {
    vurlr:=0
    SetTimer, CheckClipboard, Off
    Menu, Tray, ToggleCheck, Video URL Redirector
  }
Return

DisplaySwitch:
  SysGet, Mon, MonitorCount
  BlockInput, on
  MouseGetPos, ox, oy

  If (Mon == 1) {
    DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, A_WorkingDir . "\2.png", UInt, 1)
    RunWait C:\Windows\System32\DisplaySwitch.exe /extend
  }
  Else {
    DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, A_WorkingDir . "\1.png", UInt, 1)
    RunWait C:\Windows\System32\DisplaySwitch.exe /internal
  }

  sleep, 1500

  SysGet, cMon, MonitorCount
  If (cMon == 1) {
    Menu, Tray, Icon, %A_WorkingDir%\%Icon_dual%,1,1
    Menu, Tray, Icon, 2nd Display on/off, %A_WorkingDir%\%Icon_dual%,1
  }
  Else {
    Menu, Tray, Icon, %A_WorkingDir%\%Icon_single%,1,1
    Menu, Tray, Icon, 2nd Display on/off, %A_WorkingDir%\%Icon_single%,1
  }
  MouseMove, ox, oy, 0
  BlockInput, off
Return

PowerSwitch:
  BlockInput, on
  SendMessage, 0x112, 0xF170, 2,, Program Manager
  sleep, 1500
  BlockInput, off
Return

Rel:
  Reload
Return

Exi:
  ExitApp
Return

CheckClipboard:
  cb:=clipboard
  If (InStr(cb,"http://") OR InStr(cb,"https://")) AND (InStr(cb,".mp4") OR InStr(cb,".avi") OR InStr(cb,".mkv") OR InStr(cb,".flv"))
  {
    IF (cb != old)
    {
      IfWinExist, ahk_exe mpc-hc64.exe
        Run, mpc-hc64.exe %clipboard% /add, %location%, Max
      Else
        Run, mpc-hc64.exe %clipboard% /fullscreen, %location%, Max
    }
    old:=cb
  }
Return