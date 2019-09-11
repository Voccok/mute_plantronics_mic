#include <Array.au3>
#include <GuiToolBar.au3>

TraySetIcon("_Sys-Mute_Plantronics.ico")

HotKeySet( "^!m", "toggle_mute_microphone")
HotKeySet( "^+!m", "terminate")
AutoItSetOption("SendKeyDelay", 10)

;toggle_mute_microphone()
WinWaitActive("Normally this text would be the window title that we wait for to appear. This time we dont want that and we wait forever.")

Func toggle_mute_microphone ()

   Global $hSysTray_Handle

   ; save mouse position and active window
   $pos = MouseGetPos()
   $active_window = WinGetHandle("")

   $sSearchtext='Plantronics Voyager 8200 Series' ; searches from the beginning of the string
   $iButton=Get_SysTray_IconText($sSearchtext)
   if $iButton > -1 Then
	  _GUICtrlToolbar_ClickButton($hSysTray_Handle, $iButton, "right", True, 1)
	  Send("{up}{up}{enter}")

	  ; return where we left off
	  MouseMove($pos[0], $pos[1], 1);
	  WinActivate($active_window)
   EndIf

   Send("{CTRLUP}")
   Send("{SHIFTUP}")

EndFunc



Func Get_SysTray_IconText($sSearch)
   For $i = 1 To 99
      ; Find systray handles
      $hSysTray_Handle = ControlGetHandle('[Class:Shell_TrayWnd]', '', '[Class:ToolbarWindow32;Instance:' & $i & ']')
      If @error Then
         ;MsgBox(16, "Error", "System tray not found")
         ExitLoop
      EndIf

      ; Get systray item count
      Local $iSysTray_ButCount = _GUICtrlToolbar_ButtonCount($hSysTray_Handle)
      If $iSysTray_ButCount = 0 Then
         ;MsgBox(16, "Error", "No items found in system tray")
         ContinueLoop
      EndIf

      Local $aSysTray_ButtonText[$iSysTray_ButCount]

      ; Look for wanted tooltip
      For $iSysTray_ButtonNumber = 0 To $iSysTray_ButCount - 1
		 $target_string = _GUICtrlToolbar_GetButtonText($hSysTray_Handle, $iSysTray_ButtonNumber)

         If $sSearch =  StringMid($target_string, 1, StringLen($sSearch)) Then
			$parts = StringSplit($target_string, @CRLF)
			If $parts[0] = 3 Then
			   ConsoleWrite("Mute off, was '" & $parts[2] & "'" & @CRLF)
			Else
			   ConsoleWrite("Muted" & @CRLF)
			EndIf
			Return SetError(0, $i, $iSysTray_ButtonNumber)
         EndIf
      Next
   Next

   ConsoleWrite(@CRLF & "Did not find any system tray program starting with '" & $sSearch & "'")
   Return SetError(1, -1, -1)

EndFunc   ;==>Get_SysTray_IconText



Func terminate()
   MsgBox("", "terminate", "Stopping plantronics muter. Thank you!", 5)
   Exit
EndFunc



; Works on all headsets, but is quite slow (1.1s)
Func toggle_mute_microphone_old ()
   ConsoleWrite("Toggling mute...")
   ShellExecute("rundll32.exe", 'shell32.dll,Control_RunDLL mmsys.cpl,,recording') 
   WinWaitActive("Sound")
   Send("{down}{down}{down}+{F10}P^{tab}^{tab}{tab}{space}{esc}{esc}")
EndFunc