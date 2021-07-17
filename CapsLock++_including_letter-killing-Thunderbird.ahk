#SingleInstance force
#Persistent
#InstallKeybdHook
#InstallMouseHook

; CapsLock++_including_letter-killing-Thunderbird.ahk
; old name: thunderbird-letter-key-munging.ahk
;
; originally, just disabled  unmodified letters for Thunderbird Windows,  reducing errors
; Encountered using Dragon speech recognition,
;
; then added lowercase lock
;
; then added display and disable for other modifier keys, like CapsLock and LWin, etc.
;
; (since I've been having trouble with some of these keys getting locked)
;
; TBD: make more generic
;
; TBD: make a GUI -  set/clear keys from the GUI
;
; TBD:  scanned the entire keyboard looking for keys that are locked down -  and clear them?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;tbd: wish:  want transient kill letter mode [speech]

;; My kill_letters mode in Thunderbird: it greatly removes or
;; reduces speech recognition errors, that typically arise when Dragon
;; misrecognizes a command, and attempts to and ordinary text to things
;; like the Thunderbird main window.  Which can produce disasters,
;; because Thunderbird binds commands not just to modified control and
;; all keys, but also to just about every ordinary letter it can, in
;; Windows when you are not actually writing into a text box

;; But occasionally I have to turn
;; off, in order to be able to search for messages.  And then I forget
;; to turn it on.occasionally leading to bad things, when accidental
;; dictation is interpreted as commands by Thunderbird.

;;Therefore, I would like a transient kill_letter mode. E.g. turn it
;;on when I say "Puff search" in Thunderbird's main window. And turn
;;it off when I do something like press enter (although I note that
;;it's actually incremental search, at least enter is a good ending
;;point). could actually turn it off whenever I move the mouse or
;;click or -any control key except those that I might use to edit. for
;;that matter, could use a timeout

;;  For the moment, I just need to remember to turn letter kill back on.

;;  And I try to use window title context specific enabling and disabling.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

SetTitleMatchMode,2

lowercase_shift_state := 0
kill_letters := 1 ;; disable letters by default (only in Thunderbird main window)


;; transient message parameters

;; Transient_Message msgbox max lifetime
message_timeout := 5 ;; seconds
message_timeout_very_long := 999999999 ;; seconds

;; g4cs_unobtrusive_message - tooltips
;; but NOT One of my earlier transient_tooltip  libraries
;; instead, new approach - has a delay,  but also  responds to events
;; TBD: make this into a library class
global ttoff_Delay
ttoff_Delay := 10000		; overall max timeout
ttoff_Step := 250		; polling interval, check if mouse or keyboard have moved
ttoff_Min := 2000		; minimum display time - eg to skip UP efent if key tapped but not hedld




CapsLock_key_bindings_help := ""
CapsLock_key_bindings_help .= ""   . "(disabled)	= CapsLock"
CapsLock_key_bindings_help .= "`n" . "CLEAR	= ^  control \t  unsticks most keyboard locks"
CapsLock_key_bindings_help .= "`n" . "legacy	= +  shift"
CapsLock_key_bindings_help .= "`n" . "LOWER	= ^+ control \t lowercase lock"
CapsLock_key_bindings_help .= "`n" . "KILL	= ^! alt shift \t  kill unmodified  ordinary keys"
CapsLock_key_bindings_help .= "`n" . "DISPLAY	= ^!+  control alt plus"
CapsLock_key_bindings_help .= "`n" . "================================="
CapsLock_key_bindings_help .= "`n" . "plain CapsLock DISABLED"
CapsLock_key_bindings_help .= "`n" . "C:	 ^	CLEAR keyboard locks (mostly)"
CapsLock_key_bindings_help .= "`n" . "S:	 +	LEGACY CAPSLOCK toggle"
CapsLock_key_bindings_help .= "`n" . "A:	 !	(not defined)"
CapsLock_key_bindings_help .= "`n" . "CS:	 ^+	LOWERCASE toggle"
CapsLock_key_bindings_help .= "`n" . "CA:	 ^!	KILL letters toggle"
CapsLock_key_bindings_help .= "`n" . "AS:	 !+	(not defined)"
CapsLock_key_bindings_help .= "`n" . "CAS:	 ^!+	DISPLAY (verbose)"
CapsLock_key_bindings_help .= "`n"


g4cs_Verbose_Display_Letter_Kill_and_Lowercase_and_Other_Modifier_States("starting script")
Gui_for_Command_String_setup_for_Thunderbird_Letter_Key_Munging()



Verbose_Message_for_Letter_Munging(msg_context:="")
{
	global lowercase_shift_state  ; TBD: rename lowercase_lock
	global kill_letters
	global message_timeout

	msg := ""
	msg .= "This Script:`t" . A_ScriptName . "`n"
	if( msg_context == "" )
	{
		msg .= "This hotkey:`t" . A_ThisHotKey . "`n"
	}
	else
	{
		msg .= msg_context . "`n"
	}
        msg .= "=================================`n"
	msg .= "LOWERCASE LOCK and LETTER KILL`n"
	msg .= "=================================`n"
	msg .= (lowercase_shift_state?"ON ":"OFF") . "-  lowercase lock`n"
	msg .= (kill_letters?"ON ":"OFF") . "- ignore/kill all unmodified letters`n"
	msg .= "    reduce speech problems in Thunderbird`n"
	msg .= "=================================`n"
	msg .= "AHK KEY BINDINGS`n"
	msg .= "=================================`n"

	global CapsLock_key_bindings_help
	msg .= CapsLock_key_bindings_help

	msg .= "=================================`n"
	msg .= "KNOWBRAINER/DRAGON voice commands`n"
	msg .= "=================================`n"
	msg .= "PUFF lowercase Lock (|on|off)`n"
	msg .= "PUFF kill letters (|on|off)`n"
	msg .= "PUFF keyboard (reset|display)`n"
	msg .= "`n"
	msg .= "=================================`n"
	msg .= "MODIFIER STATE - Logical/Physical`n"
	msg .= "=================================`n"
	msg .= g4cs_LockState_string() . "`n"
	msg .= GetKeyState("LShift")       . "/" . GetKeyState("LShift","P") 	. "  +LShift"	. "`t"
	msg .= GetKeyState("LControl")     . "/" . GetKeyState("LControl","P") 	. "  ^LControl"	. "`t"
	msg .= GetKeyState("LAlt")         . "/" . GetKeyState("LAlt","P") 	. "  !LAlt"	. "`t`t"
	msg .= GetKeyState("LWin")         . "/" . GetKeyState("LWin","P") 	. "  #LWin"	. "`n"

	msg .= GetKeyState("RShift")       . "/" . GetKeyState("RShift","P") 	. "  +RShift"	. "`t"
	msg .= GetKeyState("RControl")     . "/" . GetKeyState("RControl","P") 	. "  ^RControl"	. "`t"
	msg .= GetKeyState("RAlt")         . "/" . GetKeyState("RAlt","P") 	. "  !RAlt"	. "`t`t"
	msg .= GetKeyState("RWin")         . "/" . GetKeyState("RWin","P") 	. "  #RWin"	. "`n"
	;;msg .= "`n"
	msg .= GetKeyState("Volume_Up")        . "/" . GetKeyState("Volume_Up","P") 		. "  Volume_Up"		. "`t"
	msg .= GetKeyState("Media_Next")       . "/" . GetKeyState("Media_Next","P") 	        . "  Media_Next"	. "`t"
	msg .= GetKeyState("Media_Play_Pause") . "/" . GetKeyState("Media_Play_Pause","P") 	. "  Media_Play_Pause"	. "`n"

	msg .= GetKeyState("Volume_Down")      . "/" . GetKeyState("Volume_Down","P") 	        . "  Volume_Down"	. "`t"
	msg .= GetKeyState("Media_Prev")       . "/" . GetKeyState("Media_Prev","P") 	        . "  Media_Prev"	. "`t"
	msg .= GetKeyState("Media_Stop")       . "/" . GetKeyState("Media_Stop","P") 	        . "  Media_Stop"	. "`n"

	return msg
}
g4cs_CapsLock_Unobtrusive(msg:="")
{
	local state
	if( 0 )
	{
		if( GetKeyState("CapsLock","T") == 1 )
		{
			SetCapsLockState, off
		}
		else if( GetKeyState("CapsLock", "P") == 0 )
		{
			SetCapsLockState, on
		}
	}
	;;Send,{Blind}{CapsLock up}
	Send,{Blind}{CapsLock}
	g4cs_unobtrusive_message(msg)  ;; tbd: now must be after action, since uses blocking sleep. tbd: use timer/transient
	;;g4cs_save_unobtrusive_message(msg)  ;; tbd: now must be after action, since uses blocking sleep. tbd: use timer/transient
	;;g4cs_clear_tooltip() ;tbd: transient
}

g4cs_unobtrusive_message(msg:="")
{
	;;msgbox,DEBUG %A_ThisFunc%
	g4cs_save_unobtrusive_message(msg)
	g4cs_unobtrusive_message_saved()
	g4cs_Tooltip_Off_Timer()
	;; ^^ split into composing and saving the message, and displaying it, in case you want to have a blocking action or sleep in between
	;; (in which case you call g4cs_unobtrusive_message_saved() on timer or othr event that is not blocked
}

g4cs_save_unobtrusive_message(msg:="")
{
	local
	;; tbd: now must be after action, since uses blocking sleep. tbd: use timer/transient
	;;msgbox,DEBUG %A_ThisFunc% start msg=%msg%
	if( 1 || A_PriorHotKey != A_ThisHotKey )
	{
		;;msgbox,DEBUG prior %A_PriorHotKey% != this %A_ThisHotKey%
		global CapsLock_key_bindings_help

		global saved_msg

		saved_msg := ""
		if( msg != "" )
		{
			saved_msg .= ""
			. msg
			;;. " " . ( GetKeyState("CapsLock", "T") ? "on" : "off" )
		}
		msg := saved_msg . g4cs_unobtrusive_message_string()

		;;msgbox,DEBUG delete old timer
		SetTimer,g4cs_RemoveToolTip_timer_event,Delete ; clear any existing timeout that would clear the tooltip
		tooltip,%msg%
		;;msgbox,DEBUG tooltip displayed
	}
	else
	{
		;;msgbox,DEBUG prior %A_PriorHotKey% == this %A_ThisHotKey%
	}
	return msg
}


g4cs_unobtrusive_message_string()
{

	local
	global CapsLock_key_bindings_help

	local msg
	msg := ""
	. "`n"
	. "`n"
	. g4cs_LockState_string()
	. "`n"
	. "`n"
	. CapsLock_key_bindings_help

	global ttoff_Delay
	msg .=  "`n"
	. "`n" . "Move mouse/kbd to clear, or times out in " . Round(ttoff_Delay/1000) . "s"

	return msg
}
g4cs_unobtrusive_message_saved()
{
	global saved_msg
	msg := saved_msg . g4cs_unobtrusive_message_string()
	;;msgbox,DEBUG setting g4cs_RemoveToolTip_timer_event
	SetTimer,g4cs_RemoveToolTip_timer_event,Delete ; clear any existing timeout that would clear the tooltip
	tooltip,%msg%
	;;msgbox,DEBUG sett g4cs_RemoveToolTip_timer_event
}

g4cs_LockState_string()
{
	local

	global lowercase_shift_state
	global kill_letters
	;;state := GetKeyState("CapsLock", "T") ? "on" : "off"
	msg := ""
	. "" . GetKeyState("CapsLock","T") . "/" . GetKeyState("CapsLock","P") 	. "  CapsLock"	. "`t"
	. " " . GetKeyState("NumLock","T")  . "/" . GetKeyState("NumLock","P") 	. "  NumLock"	. "`t"
	. "`n" . GetKeyState("ScrollLock","T") "/" . GetKeyState("ScrollLock","P") . "  ScrollLock"	. "`t" ;
	. " " . GetKeyState("Insert","T")      . "/" . GetKeyState("Insert","P")     . "  Insert"	. ""
	. "`n" . lowercase_shift_state . "  lowercase lock "
	. "`t" . kill_letters          . "  kill_letters (in tbird)"

	return msg
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; the Capslock comands that control the filtering are global
;       - but the actual filtering is window specific
;         TBD: might like to make the settings window specific as well

#MaxThreadsPerHotKey,4

g4cs_Tooltip_Off_Timer()
{
	local

	global ttoff_Start
	global ttoff_Delay
	global ttoff_Step

	ttoff_Start := A_TickCount

	SetTimer, g4cs_RemoveToolTip_timer_event,%ttoff_Step% ; TBD:  parameter
}

g4cs_RemoveToolTip_timer_event()
{
	local
	global ttoff_Start
	global ttoff_Delay
	global ttoff_Min

	local delta
	delta := A_TickCount - ttoff_Start

	;;tooltip, DEBUG: remove CHECKING  tooltip time: %A_TickCount%   idle %A_TimeIdlePhysical%      start: %ttoff_Start%    delta %delta%   delay %ttoff_Delay%
	;;msgbox,remove tooltip time: %A_TickCount%   idle %A_TimeIdlePhysical%      start: %ttoff_Start%    delta %delta%   delay %ttoff_Delay%

	;;msgbox,DEBUG %A_ThisFunc%

	if( delta < ttoff_Min )
		return

	;; Repeat until the delay time is  exceeded, or a non-idle event has been observed
	if( delta > ttoff_Delay
		|| A_TimeIdlePhysical + 500 < delta)
	{
		SetTimer,g4cs_RemoveToolTip_timer_event,Delete ; TBD:  parameter
		;; tooltip, DEBUG: remove DONE tooltip time: %A_TickCount%   idle %A_TimeIdlePhysical%      start: %ttoff_Start%    delta %delta%   delay %ttoff_Delay%
		ToolTip
		;;msgbox,DEBUG %A_ThisFunc% - timer cleared
	}
	else
	{
		;;msgbox,DEBUG %A_ThisFunc% - no timer action
	}
	return
}




;;*CapsLock Up::
;;{
;;	g4cs_unobtrusive_message_saved()
;;
;;	g4cs_Tooltip_Off_Timer()
;;	return
;;}

;; vv  0:  no modifiers CapsLock =>  disabled, with message
CapsLock::
{
	if( A_ThisHotKey != A_PriorHotKey )
		g4cs_unobtrusive_message( "plain CapsLock DISABLED")
	return
}

;; vv    1: C: control CapsLock =>  normal / clear locks
^CapsLock::g4cs_Normal_Lock_States()

;; vv    1: S: shift CapsLock =>  legacy CapsLock
+CapsLock::g4cs_CapsLock_Unobtrusive(A_ThisHotKey . " == LEGACY CAPSLOCK toggle")

;; vv    1: A: alt CapsLock =>  disabled
!CapsLock::g4cs_unobtrusive_message( "alt+CapsLock =>  not defined")

;; vv   2: CS: control shift CapsLock =>  lowercase
^+CapsLock::Toggle_Letter_Lowercase()
;; ^^   - Lowercase CapsLock  wants to be easy to type
;;      - but not too easy

;; vv   2: CA: control alt CapsLock ==>  letter kill
^!CapsLock::Toggle_Letter_Kill()
;;      -  letter kill is most confusing
;;      -  was tempted to make it control alt shift CapsLock

;; vv   2:  AS: alt shift CapsLock =>   verbose display
!+CapsLock::g4cs_unobtrusive_message( "alt shift CapsLock => not defined")


;; vv   3: CAS: control alt shift CapsLock =>  letter kill
^+!CapsLock::
{
	g4cs_Verbose_Display_Letter_Kill_and_Lowercase_and_Other_Modifier_States()
	return
}


#MaxThreadsPerHotKey


;========================================================================================

;;; The actual filtering is window specific

;; Kill all unmodified letters

;; I only kill all letters in certain Thunderbird windows
;; because Thunderbird Windows have a whole slew of keyboard shortcuts that don't have modifiers
;; and if I accidentally dictate text or say the wrong command things go really badly. Even a global command

;; TBD: extend this to other apps that have same problem, make dynamic, default by app

;; TBD: Disabling dictation mode in certain apps in Windows might help,
;; but (a) there doesn't seem to be a standard Dragon/KnowBrainer way to do this
;; (b) could kluge with AHK, but it's one of those polling things that I dislike
;;      --- would be better to hook to a window change event
;; (c) this wouldd not help when a command, typically a global command, emits an unmodified letter

SetTitleMatchMode,2 ;; TBD: I really want this To be regex but have not been able to make it work
;;#if kill_letters && WinActive("ahk_exe thunderbird.exe") && !WinActive("Write:") && !WinActive("Insert HTML") && !WinActive("Text Color")

kill_letters_may_be_needed_in_current_context()
{
	local
	SetTitleMatchMode,RegEx
	if( ! WinActive("ahk_exe thunderbird.exe") ) {
		return 0
	}
	if( ! WinActive("Mozilla Thunderbird$") ) {
		return 0
	}

	no_Kill_letters := 0
	|| WinActive("^Write:.* Mozilla Thunderbird$")
	|| WinActive("^Troubleshooting Information - Mozilla Thunderbird$")
	|| WinActive("^Inbox.* Mozilla Thunderbird$")
	|| WinActive("Insert HTML")
	|| WinActive("Text Color")
	|| WinActive("^Add-ons Manager - Mozilla Thunderbird$")

	if( no_Kill_letters ) {
		return 0
	}
	return 1		;default safe
}

#if kill_letters && kill_letters_may_be_needed_in_current_context()
;; kill_letters in main Thunderbird window
;; but not in a Write: composition window, and certain other windows
#include kill-letters.ahk-lib
#if

;;----------------------------------------------------------------------------------------

;; lowercase lock currently only for Thunderbird

;; Although I might like to have it in the OneNote app as well,
;; and in emacs
;; and maybe anywhere

;;#if lowercase_shift_state && WinActive("ahk_exe thunderbird.exe")
#if lowercase_shift_state
#include lowercase-unmodified-letters.ahk-lib
#if



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


g4cs_Verbose_Display_Letter_Kill_and_Lowercase_and_Other_Modifier_States(msg_context := "")
{
	local
	global lowercase_shift_state
	global kill_letters
	global message_timeout
	global message_timeout_very_long

	local timeout


	sleep,500 ; to give the keys a chance to be cleared



	if( msg_context == "starting script" )
		timeout := message_timeout
	else
		timeout := message_timeout_very_long
	;; tbd: perhaps some transient verbosity after special key bindings, like clearing all?
	;; but not all simple keybindings, like CapsLock, or LowerCase Lock

	Transient_Message(Verbose_Message_for_Letter_Munging(msg_context), timeout )

	return
}
g4cs_Disable_Letter_Kill_and_Lowercase_and_Other_Modifier_States()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	lowercase_shift_state := 0
	kill_letters := 0

	SetCapsLockState , Off
	SetNumLockState , Off
	SetScrollLockState , Off

	g4cs_unobtrusive_message( A_ThisHotKey . "Disabled lc + lk")

	return
}
g4cs_Normal_Lock_States()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	SetCapsLockState,Off
	SetCapsLockState,Off
	SetCapsLockState,Off

	lowercase_shift_state := 0
	kill_letters := 1

	SetCapsLockState , Off
	SetNumLockState , Off
	SetScrollLockState , Off

	g4cs_unobtrusive_message( A_ThisHotKey . " reset to NORMAL")

	return
}

Toggle_Letter_Lowercase()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	lowercase_shift_state ^= 1

	g4cs_unobtrusive_message( A_ThisHotKey . "toggle LOWERCASE lock")
	return
}
g4cs_Letter_Lowercase_On()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	lowercase_shift_state := 1

	g4cs_unobtrusive_message( A_ThisHotKey . "Lowercase lock ON")
	return
}
g4cs_Letter_Lowercase_Off()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	lowercase_shift_state := 0

	g4cs_unobtrusive_message( A_ThisHotKey . "Lowercase lock OFF")
	return
}


Toggle_Letter_Kill()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	kill_letters ^= 1

	g4cs_unobtrusive_message( A_ThisHotKey . " KILL LETTERS toggle")
	return
}
g4cs_Letter_Kill_On()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	kill_letters := 1

	g4cs_unobtrusive_message( A_ThisHotKey . "KILL letters ON")
	return
}
g4cs_Letter_Kill_Off()
{
	global lowercase_shift_state
	global kill_letters
	global message_timeout

	kill_letters := 0

	g4cs_unobtrusive_message( A_ThisHotKey . "KILL letters OFF")
	return
}



killed_letter_function()
{
	global message_timeout

	Transient_Message( ""
		. "key pressed: " . A_ThisHotKey . "`n"
		. "letters [a-zA-Z] are being killed`n"
		. "press CapsLock for help"
		, message_timeout	)
	return
}


;;----------------------------------------------------------------------------------------

;; g4cs - Gui For Command String
;;
;; allows speech commands tp invoke functions provided by this package
;; TBD: encapsulate better, as a library gui_for_command_string.ahk-lib

;; DISABLED:   WORK IN PROGRESS:

Gui_for_Command_String_setup_for_Thunderbird_Letter_Key_Munging()
{
	global gui_window_title := "g4cs: keyboard:"

	global g4cs_commands

	;;FAIL?: Hotkey,% "<+<^<#F24",Gui_for_Command_String
	Hotkey,% "^!F24",Gui_for_Command_String
	;;OK: Hotkey,% "F8",Gui_for_Command_String
}


Gui_for_Command_String()
{
	global Command_String = ""
	global gui_window_title

	Gui,New,+AlwaysOnTop,%gui_window_title%
	Gui,Add,Text,,g4fc Thunderbird_Letter_Key_Munging
	Gui,Add,Text,,Command_String:
	Gui,Add,Edit,vCommand_String
	Gui, Add, Button,gGui_for_Command_String_button_pressed Default,Submit AHK command string
	Gui, Show
}

Gui_for_Command_String_button_pressed()
{
	global Command_String
	global g4cs_commands := {}

	;; TBD: Was not able to initialize these globally - why not?
	g4cs_commands["g4cs_Letter_Kill_Off"] := 1
	g4cs_commands["g4cs_Letter_Kill_On"] := 1

	g4cs_commands["g4cs_Letter_Lowercase_Off"] := 1
	g4cs_commands["g4cs_Letter_Lowercase_On"] := 1

	g4cs_commands["g4cs_Verbose_Display_Letter_Kill_and_Lowercase_and_Other_Modifier_States"] := 1
	g4cs_commands["g4cs_Disable_Letter_Kill_and_Lowercase_and_Other_Modifier_States"] := 1



	Gui,Submit
	;;msgbox,Gui_for_Command_String %Command_String%
	; TBD: I have not decided if I will vet everything, or call indirect
	; or be hybrid - check that name has prefix like "gui_cmd_string_callable_*"
	; to prevent arbitrary calls. but still be agile
	if( g4cs_commands[Command_String] == 1 ) {
		%Command_String%()
	}
	else
	{
		msg := "Unrecognized command string " . Command_String . "`n" . "g4cs_commands[]= <" . g4cs_commands[Command_String] . ">" . "`n"

		msg .= "g4cs_commands" . "`n"
		for key, value in g4cs_commands
		{
			msg .= key . "-->" . value . "`n"
		}
		msgbox, %msg%



	}
}


#include transient_tooltip.ahk-lib