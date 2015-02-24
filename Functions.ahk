﻿Run(File)
{ ; Finds and runs a program
	Exts := ["", ".exe", ".ahk", ".bat", ".com", ".jar", ".lnk"]
	Dirs := [A_WorkingDir
	, A_ScriptDir
	, A_ScriptDir "\Programs"
	, A_WinDir
	, A_WinDir "\System32"
	, A_ProgramFiles
	, A_ProgramFiles "\" File]
	
	for each, Dir in Dirs
	{
		for each, Ext in Exts
		{
			FilePath := Dir "\" File . Ext
			if FileExists(FilePath)
			{
				Run, %FilePath%, %FilePath%\..
				return
			}
		}
	}
	return "Program not found"
}

FileExists(File)
{ ; FileExist and is not directory
	return (Attr := FileExist(File)) && !InStr(Attr, "D")
}

Newlines(String="")
{ ; Normalizes newlines
	if (String == "")
		Clipboard := RegexReplace(Clipboard, "\R", "`r`n")
	Else
		return RegexReplace(String, "\R", "`r`n")
}

WhatsMyIP()
{ ; Returns your public IP
	static IP, http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	if IP
		return IP
	http.Open("GET", "http://wtfismyip.com/text"), http.Send()
	IP := Trim(http.ResponseText, " `t`r`n")
	return IP
}

Kill(Script)
{ ; Closes a running script
	HiddenWins := A_DetectHiddenWindows
	TitleMode := A_TitleMatchMode
	Script := CleanEx(Script)
	DetectHiddenWindows, On
	SetTitleMatchMode, RegEx
	WinClose, i).*%Script%.ahk - AutoHotkey.*, , 3
	WinKill, i).*%Script%.ahk - AutoHotkey.*
	DetectHiddenWindows, %HiddenWins%
	SetTitleMatchMode, %TitleMode%
}

CleanEx(Needle)
{ ; Sanitize the RegEx input
	return "\Q" RegExReplace(Needle, "\\E", "\E\\E\Q") "\E"
}

Top()
{ ; Sets the active window AlwaysOnTop
	global AKMhWnd
	WinWaitNotActive, ahk_id %AKMhWnd%
	WinSet, AlwaysOnTop, Toggle, A
}

; Modified by GeekDude from http://goo.gl/0a0iJq
UriEncode(Uri)
{
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	While Code := NumGet(Var, A_Index - 1, "UChar")
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
	|| Code >= 0x61 && Code <= 0x7A) ; a-z
	Res .= Chr(Code)
	Else
		Res .= "%" . SubStr(Code + 0x100, -1)
	SetFormat, IntegerFast, %f%
	Return, Res
}

UriDecode(Uri)
{
	Pos := 1
	While Pos := RegExMatch(Uri, "i)(%[\da-f]{2})+", Code, Pos)
	{
		VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)
		Loop, Parse, Code, `%
			NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, "UTF-8"), All
	}
	Return, Uri
}