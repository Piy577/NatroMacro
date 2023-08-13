#NoEnv
#SingleInstance force
RunWith(32)
runWith(version){	
	if (A_PtrSize=(version=32?4:8))
		Return
	SplitPath,A_AhkPath,,ahkDir
	if (!FileExist(correct := ahkDir "\AutoHotkeyU" version ".exe")){
		MsgBox,0x10,"Error",% "Couldn't find the " version " bit Unicode version of Autohotkey in:`n" correct
		ExitApp
	}
	Run,"%correct%" "%A_ScriptName%",%A_ScriptDir%
	ExitApp
}
;OnMessages
OnMessage(0x4299, "hb_resetTimeout")

global HBTimeout:=nowUnix()
global MacroRunning:=0
global paused:=0
global resetting

SetWorkingDir, ..
while 1 {
	if((nowUnix()-HBTimeout)>60 && paused=0){ ; natro_macro is frozen
		resetting:=1
		FileAppend `[%A_Hour%:%A_Min%:%A_Sec%`] Detected: Macro Freeze`, Re-starting`n, status_log.txt
		FileAppend `[%A_MM%/%A_DD%`]`[%A_Hour%:%A_Min%:%A_Sec%`] Detected: Macro Freeze`, Re-starting`n, debug_log.txt
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows On
		SetTitleMatchMode 2
		WinKill, natro_macro
		sleep, 10000
		run, natro_macro.ahk
		HBTimeout:=nowUnix()
		SendMessage, 0x4299, 0, 0,, natro_macro
		DetectHiddenWindows %Prev_DetectHiddenWindows%
		SetTitleMatchMode %Prev_TitleMatchMode%
		if(MacroRunning) {
			;sleep, 30000
			Send {f1}
		}
		resetting:=0
	}
	sleep, 5000
}
return

hb_resetTimeout(wParam, lParam){
	global HBTimeout, resetting
	;temp:=(nowUnix()-HBTimeout)
	;Msgbox heartbeat received! A_NowUTC=%A_NowUTC% HBTimeout=%HBTimeout% result=%temp%
	HBTimeout:=nowUnix()
	paused:=wParam
	if(resetting=0)
		MacroRunning:=lParam
	;send ACK
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    SendMessage, 0x4299, 0, 0,, natro_macro
    DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%
}
nowUnix(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}
/*
f5::
temp:=(A_NowUTC-HBTimeout)
Msgbox manual: A_NowUTC=%A_NowUTC% HBTimeout=%HBTimeout% result=%temp%
return
*/