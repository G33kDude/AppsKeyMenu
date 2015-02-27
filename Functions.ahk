Run(File)
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

UriEncode(Uri, RE="[0-9A-Za-z]") {
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
	While Code := NumGet(Var, A_Index - 1, "UChar")
		Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
	Return, Res
}

UriDecode(Uri) {
	Pos := 1
	While Pos := RegExMatch(Uri, "i)(%[\da-f]{2})+", Code, Pos)
	{
		VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)
		Loop, Parse, Code, `%
			NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
		Decoded := StrGet(&Var, "UTF-8")
		Uri := SubStr(Uri, 1, Pos-1) . Decoded . SubStr(Uri, Pos+StrLen(Code)+1)
		Pos += StrLen(Decoded)+1
	}
	Return, Uri
}

Base64_Encode(In, Encoding="UTF-8")
{
	VarSetCapacity(Bin, StrPut(In, Encoding))
	InLen := StrPut(In, &Bin, Encoding) - 1
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &Bin
	, "UInt", InLen, "UInt", 0x40000001, "Ptr", 0, "UInt*", OutLen)
	VarSetCapacity(Out, OutLen * (1+A_IsUnicode))
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &Bin
	, "UInt", InLen, "UInt", 0x40000001, "Str", Out, "UInt*", OutLen)
	return Out
}

Base64_Decode(In, Encoding="UTF-8")
{
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In
	, "UInt", StrLen(In), "UInt", 0x1, "Ptr", 0
	, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	VarSetCapacity(Out, OutLen)
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In
	, "UInt", StrLen(In), "UInt", 0x1, "Str", Out
	, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	return StrGet(&Out, OutLen, "UTF-8")
}