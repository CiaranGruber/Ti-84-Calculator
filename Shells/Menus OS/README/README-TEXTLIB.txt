


                                   CE TextLib
				   Dr. D'nar
                                 8 August 2015



====== Usage ===================================================================

    CE TextLib is a library for the TI-84 Plus CE that primarily provides text-
related functions.  It also has a version for the TI-84 Plus C SE.  Some
functions work best with MathPrint disabled.

    TextLib takes as its input a list in Ans, containing commands.  Any output
is also provided via Ans.  The first element in the input list must be a
command, followed by any additional required argument(s).  Additional commands
can follow each argument.  However, if multiple commands have output, only the
last output will be returned.

    For example, to turn off the run indicator:
:{1}
:Asm(prgmTEXTLIB)
Similarly, to turn off the run indicator and enable inverse text:
:{1,13}
:Asm(prgmTEXTLIB)
Arguments follow the command number, so to move to the right side of the top
line of text, do this:
:{15,1,26}
:Asm(prgmTEXTLIB)
You can chain commands with arguments, too.  For example, this will set inverse
text, move the cursor to the right side of the top line of text, display some
kind of up arrow, and return the version number:
:{13,15,1,26,19,243,10}
:Asm(prgmTEXTLIB)
:Disp Ans
You cannot, however, chain an output to an input in one command.  For example,
you cannot, in a single command, use GetCursor, Or8, and SetCursor in sequence
to set one or more cursor bits; the three would have to be run as
:{31}:Asm(prgmTEXTLIB)
:{36,Ans,32+64}:Asm(prgmTEXTLIB)
:{41,Ans}:Asm(prgmTEXTLIB)

    Invalid or incorrect commands may variously throw an error or cause the
library to stop processing the current command list.


====== Commands ================================================================
Number	Command name & Description
------	--------------------------
0	xyzzy
	Nothing happens.
1	RunIndicOff
	Turns the run indicator off.
2	CursorOff
	Turns the blinking cursor off.
3	InverseTextOff
	Unsets inverse text.
4	DisableColor
	Disables color text.
5	GetCursorPos
	Returns the current cursor location, in the format {row,column}
6	GetFgColor
	Returns the current foreground color, if set.  This does NOT read the
	color from the cursor location, but instead the color from the last
	SetFgColor/SetColors.
7	GetBgColor
	Returns the current background color, if set.  This does NOT read the
	color from the cursor location, but instead the color from the last
	SetBgColor/SetColors.
8	ReadBuffer
	Reads a character from the homescreen ASCII buffer, at the current
	cursor location.
9	ReadBufferInc
	Reads a character from the homescreen ASCII buffer, at the current
	cursor location, and advances the cursor.
10	GetVersion
	Returns the version number of the library.  Subsequent commands are
	ignored.
11	RunIndicOn
	Turns the run indicator on.
12	CursorOn
	Turns on the blinking cursor.
13	InverseTextOn
	Sets inverse text.
14	EnableColor
	Enables color text mode.
15	SetCursorPos
	Sets the cursor position, input is in {row,column format}, e.g.
	{15,1,26} moves to the right side of the top row.
16	SetFgColor
	Sets the foreground color, e.g. {16,BLUE}
17	SetBgColor
	Sets the background color
18	PutMap
	Displays a character using a raw ASCII code.  For example, {18,26}
	displays an ampersand.  The cursor is not advanced.
19	PutC
	Displays a character using a raw ASCII code.  For example, {18,26}
	displays an ampersand.  The cursor is advanced.
20	GetHwType
	Returns 4 for the TI-84 Plus C SE, 5 for the TI-84 Plus CE.  
	Subsequent commands are ignored.
21	ToggleRunIndic
	Toggles the run indicator.
22	ToggleCursor
	Toggles the cursor, BUT IF THE CURSOR IS ON, DOES NOT ERASE THE CURSOR
23	ToggleInverseText
	Toggles inverse text.
24	ToggleColor
	Toggles color-enabled mode.
25	NumToStr
	Converts a floating-point number to string, ex. {25,3.14} returns "3.14"
	Subsequent commands are ignored.
	For some reason, this returns a longer string on eZ80 models (possibly
	a bug from porting to the eZ80?).
26	GetQuote
	Returns the " character.  Subsequent commands are ignored.
27	GetStore
	Returns the -> character.  Subsequent commands are ignored.
28	GetToken
	Returns an arbitrary token, e.g. {29,95} returns "prgm", while
	{29,239,14} returns "isClockOn"; this will read a second argument if the
	first is the start of a two-byte token.  Subsequent commands are
	ignored.
29	GetTokenByte
	Returns 1 or 2 entry list, containing the byte code(s) of a token in a
	string, ex. {29,3,5} returns the byte(s) of the 5th token in Str3.
	Returns {257} for string not found, {258} for string too short,
	{259} for archived string (TI-84 Plus C SE only; CE supports it).
30	GetColors
	Returns {fgColor,bgColor}.  This does NOT read the color from the cursor
	location, but instead the color from the last SetFgColor/SetColors.
31	GetCursor
	Returns the current cursor flags.
	Bit 2 (4) = textInsMode, bit 3 (8) = shift2nd, bit 4 (16) = shiftAlpha,
	bit 5 (32) = shiftLwrAlph, bit 6 (64) = shiftALock,
	bit 7 (128) = shiftKeepAlph
	{31}:Asm(prgmTEXTLIB):{35,Ans,8}:Asm(prgmTEXTLIB) will return 0 if
	shift2nd is not set and non-zero if set.
32	DisableLowercase
	Disables typing lowercase letters.
33	FillRect
	Fills a given area with a color. Format: {28,row,col,height,width,color}
	Does not set background color.
34	FillRectRepaint
	Like FillRect, but also repaints characters.  ALSO SETS FGCOLOR AND
	BGCOLOR.  Format: {28,row,col,height,width,bgcolor,fgcolor}
	NOTE THE REVERSED FOREGROUND/BACKGROUND ORDER.
35	And8
	Returns 8-bit bitwise AND, ex. {33,15,17} returns 1.
36	Or8
	Returns 8-bit bitwise OR.
37	Xor8
	Returns 8-bit bitwise XOR.
38	Not8
	Returns 8-bit bitwise NOT, ex. {36,15} returns 240.
39	BitTest
	Returns 0 or 1 for a given bit, ex. {37,8,3} returns 1.
	TI-84 Plus C SE: Supports bits 0-15.
	eZ80 models: Supports bits 0-23.
40	SetColors
	Reverse of GetColors.
41	SetCursor
	Sets cursor flags, reverse of GetCursor.
	Note that pressing ON with shift2nd set will . . . turn the calculator
	off.  (This is also implicitly a BREAK like pressing ON normally.  You
	just have to press ON a second time to turn the calculator back on.)
42	EnableLowercase
	Enables typing lowercase letters.


====== Change Log ==============================================================
8 August 2015, v1.12
	Now sets textEraseBelow when using color mode, which fixes a small
	spacing issue.
5 August 2015, v1.11
	Fixed a bug in getting colors due to a typo in an #IFDEF.
4 August 2015, v1.1
	Added a bunch of new functions: NumToStr, GetQuote, GetStore, GetToken, 
	GetTokenByte, GetColors, GetCursor, DisableLowercase, FillRect, 
	FillRectRepaint, And8, Or8, Xor8, Not8, BitTest, SetColors, SetCursor, 
	and EnableLowercase.
	Command 0 is now a no-op.
	Fixed a bug with ReadBuffer/ReadBufferInc on the TI-84 Plus C SE where
	it always returned the first character on a line of text.
1 August 2015, v1.0
	First release.