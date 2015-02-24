#NoEnv
SetBatchLines, -1
Menu, Tray, Icon, AKM.ico

; #Include Functions.ahk

; Initialize GUI
ScrollBack := [], Arrow := 0
Gui, AKM:New, hWndAKMhWnd
Gui, Margin, 5, 5
Gui, Font, s8, Microsoft Sans Serif
Gui, Add, Edit, x5 y5 w120 h21 r1 vQuery +HwndQueryHwnd ; Main edit
Gui, Add, Button, x129 y4 w52 h23 Default gSubmit, Submit ; Main submit
Gui, Font, s6, Webdings
Gui, Add, Button, x184 y4 w18 h23 gArrow vArrow, 6 ; History arrow
Gui, Font, s8, Microsoft Sans Serif
Gui, Add, ListBox, x5 y31 w120 r10 gHistBox vHistBox, %History% ; History scrollback
Gui, +ToolWindow +E0x40000 ; Taskbar Button
Gui, Show, h31 w206 Hide, AKMenu
return

AppsKey::
ShowMenu:
Gui, AKM:Default

; Populate scrollback
HistBox :=
for each, Entry in ScrollBack
	HistBox .= "|" Entry
GuiControl,, HistBox, % HistBox ? HistBox : "|"

GuiControl, Focus, Query
SendMessage, 0x00B1, 0, -1,, ahk_id %QueryHwnd% ;EM_SETSEL
Gui, Show
return

Arrow:
if (Arrow := !Arrow)
{
	GuiControl,, Arrow, 5
	Gui, Show, AutoSize
	Gui, Show, w206
}
else
{
	GuiControl,, Arrow, 6
	Gui, Show, w206 h31
}
return

Submit:
Gui, Submit
if (Query != ScrollBack[1])
	ScrollBack.Insert(1, Query)
RegExMatch(Query, "s)^\s*([^\s]+)(?:\s+(.+?))?\s*$", Match)

Result := ""
if IsFunc(Match1)
	Result := Match2 ? %Match1%(Match2) : %Match1%()
else
	Result := "Unknown Command"

if (Result != "")
{
	ScrollBack.Insert(1, Result)
	GuiControl,, Query, %Result%
	GoSub, ShowMenu
}
return

HistBox:
if (A_GuiEvent == "DoubleClick")
	GuiControl,, Query, % ScrollBack[A_EventInfo]
return

AKMGuiEscape:
AKMGuiClose:
Gui, Hide
return

Reload()
{
	Reload
	return
}

Exit()
{
	ExitApp
	return
}

Clear()
{
	global ScrollBack
	ScrollBack := []
}