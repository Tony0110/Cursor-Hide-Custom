#Persistent
; This script hides the mouse cursor after 3 seconds of inactivity.
; It also attempts to address issues with the cursor remaining visible in some games.

CoordMode, Mouse, Screen  ; Use screen coordinates for mouse positions
MouseGetPos, ix, iy       ; Get initial mouse position

SystemCursor("Init")      ; Initialize system cursor functions

SetTimer, CheckIdle, 1000   ; Run the CheckIdle subroutine every 250 milliseconds (4 times per second)
return

CheckIdle:
    MouseGetPos, cx, cy      ; Get current mouse position
    TimeIdle := A_TimeIdlePhysical // 1000  ; Get idle time in seconds

    if (TimeIdle >= 3) ; Check if mouse has been idle for 3 seconds or more
    {
        MouseGetPos, ix, iy  ; Update last mouse position (not strictly necessary here, but good practice)
        SystemCursor("Off")   ; Hide the cursor
    }
    else if (cx != ix or cy != iy) ; Check if mouse has moved since last check
    {
        SystemCursor("On")    ; Show the cursor
    }
return

OnExit, ShowCursor  ; Ensure the cursor is made visible when the script exits.
return

ShowCursor:
    SystemCursor("On")   ; Make sure the cursor is visible before exiting
    ExitApp             ; Terminate the script

SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
    static AndMask, XorMask, $, h_cursor  ; Declare static variables (persist values between function calls)
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors IDs
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors handles
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors

    if (OnOff = "Init" or OnOff = "I" or $ = "")       ; Initialization block (runs only once at the beginning)
    {
        $ = h                                          ; Set default cursor type to 'h' (handle)
        VarSetCapacity( h_cursor,4444, 1 )           ; Reserve memory for cursor handle
        VarSetCapacity( AndMask, 32*4, 0xFF )          ; Create AND mask for blank cursor (opaque)
        VarSetCapacity( XorMask, 32*4, 0 )             ; Create XOR mask for blank cursor (transparent)

        ; List of system cursor IDs (standard cursors)
        system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
        StringSplit c, system_cursors, `,  ; Split the list into individual cursor IDs

        Loop %c0% ; Loop through each system cursor ID
        {
            ; Load the standard system cursor
            h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
            ; Copy the handle to save the default cursor
            h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
            ; Create a blank cursor
            b%A_Index% := DllCall("CreateCursor","uint",0, "int",0, "int",0
                , "int",32, "int",32, "uint",&AndMask, "uint",&XorMask )
        }
    }
    ; Determine whether to use blank or default cursors
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ = b  ; Use blank cursors if turning off, toggling, or if currently using default and requested to toggle/turn off
    else
        $ = h  ; Otherwise, use the saved default cursors (turning on or initializing)

    Loop %c0% ; Loop through each system cursor ID again
    {
        ; Copy the appropriate cursor (blank or default)
        h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
        ; Set the system cursor to the chosen cursor (blank or default)
        DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
    }
}