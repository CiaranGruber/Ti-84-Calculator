;Scogger-TI Level editor. For Tim. Because COW.
;
;TODO: 
;      figure out exactly which direction codes are for what:
;        Then fix internal representation.
;        Then fix output representation
;Internal format: 0=water 1=pad 2-5=dir 6=pad2 7=rock
;Export format: 
;
;
;
;
;
;
ToolTip,Loading interface...

Gui,Font,s8 Q2,Arial
Gui,Font,s8 Q2,MS sans serif
Gui,Font,s8 Q2,Trebuchet MS

#NoEnv
#SingleInstance force
SendMode Input
SetWorkingDir %A_ScriptDir%
Thread,interrupt,0
#KeyHistory 0
#MaxThreads 255
#MaxMem 4095
#MaxThreadsBuffer On
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#IfWinActive,ahk_class AutoHotkeyGUI
;ListLines Off
;SetBatchLines, -1
Process, Priority, , R
SetTitleMatchMode fast
SetKeyDelay, -1, -1, -1
SetMouseDelay, -1
SetWinDelay, -1
SetControlDelay, -1

 ifnotexist,img
   filecreatedir,img
 FileInstall,img\empty.PNG,img\empty.PNG
 FileInstall,img\pad.PNG,img\pad.PNG
 FileInstall,img\s_down.PNG,img\s_down.PNG
 FileInstall,img\s_left.PNG,img\s_left.PNG
 FileInstall,img\s_right.PNG,img\s_right.PNG
 FileInstall,img\s_up.PNG,img\s_up.PNG
 FileInstall,img\rock.PNG,img\rock.PNG
 FileInstall,img\pad2.PNG,img\pad2.PNG 
 
 Gui,Add,Edit,vLONGEDIT x0 y0 w200 h20 multi,Paste level data
 Gui,Add,Button,vOBJ00 gPARSE_DATA x205 y0 h20 w90,Parse LvData
 Gui,Add,Button,vOBJ01 gEXPORT_DATA x300 y0 h20 w95,All => Clipboard
 Gui,Add,Button,vOBJ02 gLV_TO_CLIPBOARD x300 y25 h18 w95,Lvl => Clipboard
 Gui,Add,Button,vOBJ17 gMENU_EXPORT x300 y45 h18 w95,Save to file
 Gui,Add,Button,vOBJ18 gMENU_IMPORT x300 y65 h18 w95,Load from file
 
 Gui,Add,GroupBox,x300 w95 y90 h88,Shift board
 
 Gui,Add,Button,vOBJ03 x338 y110 w20 h20 gSHIFT_UP,^
 Gui,Add,Button,vOBJ04 x338 y150 w20 h20 gSHIFT_DOWN,v
 Gui,Add,Button,vOBJ05 x358 y130 w20 h20 gSHIFT_RIGHT,>
 Gui,Add,Button,vOBJ06 x318 y130 w20 h20 gSHIFT_LEFT,<

 curlevel:=0
 maxlevel:=0
 curdifficulty:=1
 maxdifficulty:=1
 frogxpos:=0
 frogypos:=0
 frogdirection:=0
 sprite_underneath:=0
 collapse_info:=0
 game_mode=0
 
 xcount:=0
 ycount:=0
 xpos:=10
 ypos:=30
 Loop,8
 { ;outer loop: by row
   Loop,8
   { ;inner loop: output each item in the row
     Gui,Add,Picture,w16 h16 x%xpos% y%ypos% vIMGVAR_%xcount%_%ycount% gIMGCLICK,img\empty.PNG
     IMGARRAY_%xcount%_%ycount%:=0
     IMGLOC_%xcount%_%ycount%_X:=xpos
     IMGLOC_%xcount%_%ycount%_Y:=ypos
     xpos+=17
     xcount++
   }
   Gui,Add,Button,vDR%ycount% w70 x150 h16 y%ypos% gDELROW_%ycount%,DelRow %ycount%
   if (ycount!=0)&&(ycount!=7)
     Gui,Add,Button,vIR%ycount% w70 x225 h16 y%ypos% gINSROW_%ycount%,InsRow %ycount%
   xpos-=(xcount*17)
   xcount:=0
   ypos+=(17+(((ycount=0)||(ycount=6))?(4):(0)))
   ycount++
 }
 
 x=10
 xc=0
 Loop,8
 {
   Gui,Add,Button,vDC%xc% w16 h16 y180 x%x% gDELCOL_%xc%,D
   if (xc!=0)&&(xc!=7)
     Gui,Add,Button,vIC%xc% w16 h16 y200 x%x% gINSCOL_%xc%,I
   x+=17
   xc++
 }

 Gui,Add,Button,vOBJ07 w100 h20 y180 x150 gCLEAR_BOARD,Clear board
 Gui,Add,Button,vOBJ08 w100 h20 y180 x260 gFILL_BOARD,Fill board
 Gui,Add,Button,vOBJ09 w100 h20 y205 x150 gRESET_ALL,Reset all data
 Gui,Add,Button,vOBJ10 w100 h20 y205 x260 gROTATE_BOARD,Rotate board
 
 Gui,Add,Text,w70 x10 y230 h20 vLEVEL_INFO,Lvl 0/0
 Gui,Add,Text,w80 x10 y250 h20 vDIFFICULTY_INFO,Difficulty: N/A
 Gui,Add,Text,w80 x10 y270 h20 vCOLLAPSED_INFO,Empty table
 
 Gui,Add,Button,w50 x100 y230 h20 gPREV_LEVEL,<< LVL
 Gui,Add,Button,w50 x160 y230 h20 gNEXT_LEVEL,LVL >>
 Gui,Add,Button,vOBJ11 w60 x220 y230 h20 gSAVE_LEVEL,Save Lvl
 Gui,Add,Button,vOBJ12 w80 x290 y230 h20 gNEW_LEVEL,Save As Lvl
 Gui,Font,Bold
 Gui,Add,Button,gSCREENFIX x105 w70 y255 h20,ScreenFix
 Gui,Font,Normal
 
 Gui,Add,GroupBox,w100 h100 y250 x180,Move Frog

 Gui,Add,Button,w20 h20     y270 x220 gMF_UP,^
 Gui,Add,Button,w20 h20     y310 x220 gMF_DN,v
 Gui,Add,Button,w20 h20     y290 x200 gMF_LF,<
 Gui,Add,Button,w20 h20     y290 x240 gMF_RT,>

 Gui,Add,GroupBox,w100 h100 y250 x290,Direction
 
 Gui,Add,Button,vOBJ13 w20 h20     y270 x330 gDI_UP,^
 Gui,Add,Button,vOBJ14 w20 h20     y310 x330 gDI_DN,v
 Gui,Add,Button,vOBJ15 w20 h20     y290 x310 gDI_LF,<
 Gui,Add,Button,vOBJ16 w20 h20     y290 x350 gDI_RT,>

 Gui,Add,Text,w70 x10 y290 h20 vFROG_POS,Frog (0`,0)
 Gui,Add,Button,w70 x10 y310 h20 gGOTO_LEVEL,Goto level
 Gui,Add,Edit,w40 Limit3 x85 y310 vJUMP_TO_THIS_LEVEL,%maxlevel%
 Gui,Add,Button,w70 x10 y335 h20 gSTART_GAME vSTART_GAME_TITLE,Game Mode
 Gui,Add,Button,vOBJ99 w70 x85 y335 h20 gRESET_PUZZLE,Restart
 Gui,Add,Text,w380 x10 y360 h20,Push F1 while this window is activated to display hotkey help.
 show_frog()
 
 ifexist,img\dump.txt
 {
   LONGEDIT:=""
   Loop,Read,img\dump.txt
     LONGEDIT.=A_LoopReadLine "`r`n"
   GoSub PARSE_DATA_BREAKIN
 }
 
 Gui,show,h380 w400,Scogger-TI Level Editor
 
 OnExit,CleanupCrew

 Return

SCREENFIX:
 Critical ON
 x=0
 y=0
 Loop,8
 {
   Loop,8
   {
     a:=IMGARRAY_%x%_%y%:=LDAT_%curlevel%_%x%_%y%
     if !a
       a=empty
     else if a=6
       a=pad2
     else if a=7
       a=rock
     else
       a=pad
     GuiControl,,IMGVAR_%x%_%y%,img\%a%.PNG
     x++
   }
   x=0
   y++
 }
 show_frog()
 Critical Off
 Goto RESET_PUZZLE


START_GAME:
 Critical On
 ax:=game_mode
 GuiControl,Enable%ax%,LONGEDIT
 GuiControl,Enable%ax%,OBJ00
 GuiControl,Enable%ax%,OBJ01
 GuiControl,Enable%ax%,OBJ02
 GuiControl,Enable%ax%,OBJ03
 GuiControl,Enable%ax%,OBJ04
 GuiControl,Enable%ax%,OBJ05
 GuiControl,Enable%ax%,OBJ06
 GuiControl,Enable%ax%,OBJ07
 GuiControl,Enable%ax%,OBJ08
 GuiControl,Enable%ax%,OBJ09
 GuiControl,Enable%ax%,OBJ10
 GuiControl,Enable%ax%,OBJ11
 GuiControl,Enable%ax%,OBJ12
 GuiControl,Enable%ax%,OBJ13
 GuiControl,Enable%ax%,OBJ14
 GuiControl,Enable%ax%,OBJ15
 GuiControl,Enable%ax%,OBJ16
 GuiControl,Enable%ax%,OBJ17
 GuiControl,Enable%ax%,OBJ18
 
 v=0
 Loop,8
 {
   if (v!=0)&&(v!=7)
   {
     GuiControl,Enable%ax%,IR%v%
     GuiControl,Enable%ax%,IC%v%
   }
   GuiControl,Enable%ax%,DR%v%
   GuiControl,Enable%ax%,DC%v%
   v++
 }
; GuiControl,Disable%ax%,OBJ99
 if !game_mode
 {
   GuiControl,,START_GAME_TITLE,Edit Mode
   load_level_data(curlevel)
   disp_cur_level()  
 }
 else
 {
   GuiControl,,START_GAME_TITLE,Game Mode
 }
 game_mode:=!game_mode
 Critical Off
 Return

r::
RESET_PUZZLE:
 load_level_data(curlevel)
 disp_cur_level()
 Return
 
 
GOTO_LEVEL:
 Gui,Submit,NoHide
 curlevel:=JUMP_TO_THIS_LEVEL
 load_level_data(curlevel)
 disp_cur_level()
 Return
 
RESET_ALL:
 curlevel=0
 maxlevel=0
 curdifficulty:=1
 maxdifficulty:=1
 frogxpos:=0
 frogypos:=0
 frogdirection:=0
 sprite_underneath:=0
 collapse_info:=0
 Gosub CLEAR_BOARD
 disp_cur_level()
 ifexist,img\dump.txt
   filedelete,img\dump.txt
 Return

CLEAR_BOARD:
 Critical On
 backup_imgarray()
 x=0
 y=0
 Loop,8
 {
   Loop,8
   {
     IMGARRAY_%x%_%y%=0
     x++
   }
   x=0
   y++
 }
 update_against_backup(1)
 Critical Off
 Return

FILL_BOARD:
 Critical On
 backup_imgarray()
 x=0
 y=0
 Loop,8
 {
   Loop,8
   {
     IMGARRAY_%x%_%y%=1
     x++
   }
   x=0
   y++
 }
 update_against_backup(1)
 Critical Off
 Return 

IMGCLICK:
 Critical On
 MouseGetPos,mx,my
 If (!(mx+my))
   Return   ;should never happen, but ah well.
;x1,y1---\    |x1<=xpos<(x1+15)
;  |     |    |y1<=xpos<(y1+15)
;  \---x2,y2  |
;If ((y1<y)&&(y<(y1+15))&&(x1<x)&&(x<(x1+15)))
 SysGet,atmp_titleh,31
 SysGet,atmp_borderh,6
 SysGet,atmp_frameh,8
 
 my -= (atmp_titleh+atmp_borderh+atmp_frameh)
 
 SysGet,atmp_borderx,5
 SysGet,atmp_framew,7
 
 mx -= (atmp_borderx+atmp_framew)
 
 cx:=0
 cy:=0
 
 Loop,8
 {
   Loop,8
   {
     x1:=IMGLOC_%cx%_%cy%_X
     y1:=IMGLOC_%cx%_%cy%_Y
     If (((y1-00)<my)&&(my<(y1+15))&&((x1-03)<mx)&&(mx<(x1+15)))
     {
       if ((IMGARRAY_%cx%_%cy%<2)||(IMGARRAY_%cx%_%cy%>5))
       {
         IMGARRAY_%cx%_%cy%:=!IMGARRAY_%cx%_%cy%
         a=IMGARRAY_%cx%_%cy%
         ;change to rock
         if getKeyState("Shift","P")
           IMGARRAY_%cx%_%cy%:=7,a:="rock"
         ;change to purp lilypad
         else if getKeyState("Control","P")
           IMGARRAY_%cx%_%cy%:=6,a:="pad2"
         else
           IMGARRAY_%cx%_%cy%:=IMGARRAY_%cx%_%cy%,a:=((IMGARRAY_%cx%_%cy%)?("pad"):("empty"))
         GuiControl,,IMGVAR_%cx%_%cy%,img\%a%.PNG
       }
     }
     cx++
   }
   cx=0
   cy++
 }
 Critical Off
 Return
 
PARSE_DATA:
;Assume this format:
;64bytes (8x8 grid), 0=water 1=pad
;.db frogx,frogy,direction,difficulty
 Gui,Submit,NoHide
PARSE_DATA_BREAKIN:
 LONGEDIT:=regexreplace(LONGEDIT,"[^[:ascii:]]")
 ToolTip,Parsing data...
 c:=0
 Loop,Parse,LONGEDIT,`n,`r 
 {
   a:=A_LoopField
   if a=""
     continue
   if substr(a,1,1)="/"
     continue
   
   if substr(a,1,1)="{"
   {
     c++
     x=0
     y=0
     Loop,Parse,a,`,
     {
       b:=RegExReplace(A_LoopField,"i)[^0-9]")
       if A_Index<65
       {
         LDAT_%c%_%x%_%y%:=b
         x++
         if x>7
         {
           x=0
           y++
         }
       }
       if A_Index=65
         LDAT_%c%_FROGX:=b
       if A_Index=66
         LDAT_%c%_FROGY:=b
       if A_Index=67
         LDAT_%c%_FROGDIR:=b
       if A_Index=68
         LDAT_%c%_DIFFICULTY:=b
     }
   }
 }
 maxlevel:=c
 curlevel:=1
 GuiControl,,JUMP_TO_THIS_LEVEL,%maxlevel%
 ToolTip
 load_level_data(curlevel)
 disp_cur_level() 
 Return
 
EXPORT_DATA:
 Critical On
 expo_string:=".db " maxlevel "`n"
 Loop,% maxlevel
   export_level(A_Index)
 Critical Off
 clipboard:=expo_string
 Return
 
SHIFT_UP:
 Critical On
 if frogypos>0
   move_frog(0,-1)
 backup_imgarray()
 x=0
 y=1
 Loop,7
 {
   Loop,8
   {
     yprv:=y-1
     
     if (x=frogxpos)&&(y=frogypos)
       IMGARRAY_%x%_%y%:=sprite_underneath
     IMGARRAY_%x%_%yprv%:=IMGARRAY_%x%_%y%
     if y=7
       IMGARRAY_%x%_%y%=0
     x++
   }
   x=0
   y++
 }
 update_against_backup(1)
 Critical Off
 Return

SHIFT_DOWN:
 Critical On
 if frogypos<7
   move_frog(0,1)
 backup_imgarray()
 x=0
 y=6
 Loop,7
 {
   Loop,8
   {
     ynxt:=y+1
     if (x=frogxpos)&&(y=frogypos)
       IMGARRAY_%x%_%y%:=sprite_underneath
     IMGARRAY_%x%_%ynxt%:=IMGARRAY_%x%_%y%
     if y=0
       IMGARRAY_%x%_%y%=0
     x++
   }
   x=0
   y--
 }

 update_against_backup(1)
 Critical Off
 Return
 
SHIFT_LEFT:
 Critical On
 if frogxpos>0
   move_frog(-1,0)
 backup_imgarray()
 x=1
 y=0
 Loop,7
 {
   Loop,8
   {
     xprv:=x-1
     
     if (x=frogxpos)&&(y=frogypos)
       IMGARRAY_%x%_%y%:=sprite_underneath
     IMGARRAY_%xprv%_%y%:=IMGARRAY_%x%_%y%
     if x=7
       IMGARRAY_%x%_%y%=0
     y++
   }
   y=0
   x++
 }

 update_against_backup(1)
 Critical Off
 Return

SHIFT_RIGHT:
 Critical On
 if frogxpos<7
   move_frog(1,0)
 backup_imgarray()
 x=6
 y=0
 Loop,7
 {
   Loop,8
   {
     xnxt:=x+1
     if (x=frogxpos)&&(y=frogypos)
       IMGARRAY_%x%_%y%:=sprite_underneath
     IMGARRAY_%xnxt%_%y%:=IMGARRAY_%x%_%y%
     if x=0
       IMGARRAY_%x%_%y%=0
     y++
   }
   y=0
   x--
 }
 update_against_backup(1)
 Critical Off
 Return

q::
PREV_LEVEL:
 if !maxlevel
   return
 curlevel:=((curlevel<2)?(1):(curlevel-1))
 load_level_data(curlevel)
 disp_cur_level()
 Return
e::
NEXT_LEVEL:
 if (curlevel="")||(maxlevel="")
   curlevel:=maxlevel:=0
 curlevel:=((curlevel>=maxlevel)?(maxlevel):(curlevel+1))
 load_level_data(curlevel)
 disp_cur_level()
 Return
SAVE_LEVEL:
 if (curlevel="")||(maxlevel="")
   curlevel:=maxlevel:=0
 if maxlevel=0
   Goto NEW_LEVEL
 save_level_data(curlevel)
 disp_cur_level()
 Return
NEW_LEVEL:
 if (curlevel="")||(maxlevel="")
   curlevel:=maxlevel:=0
 maxlevel++
 curlevel:=maxlevel
 Goto SAVE_LEVEL
 
LV_TO_CLIPBOARD:
 Critical On
 expo_string:=""
 export_level(curlevel)
 Critical Off
 clipboard:=expo_string
 Return
 
;uses expo_string global variable to output data
export_level(level)
{
  Global
  Local a,b,c,x,y
  c:=level
  a:=LDAT_%c%_FROGDIR
  if a=0
    d=DIR0
  if a=1
    d=DIR1
  if a=2
    d=DIR2
  if a=3
    d=DIR3
  expo_string.="Level" c ":`r`n"
  expo_string.=".db " LDAT_%c%_FROGX "," LDAT_%c%_FROGY-1 "," d "," LDAT_%c%_DIFFICULTY "`r`n"
  x:=0
  y:=1
  Loop,6
  {
    tstr:=".db "
    Loop,8
    {
      b:=LDAT_%c%_%x%_%y%
      if b=1
        b=0
      else if b=6
        b=7
      else if b=7
        b=8
      else
        b=6
;      if (x=LDAT_%c%_FROGX)&&(y=LDAT_%c%_FROGY)
;        b:=d
      tstr.= b ","
      x++
    }
    expo_string.=tstr "`r`n"
    x=0
    y++
  }
  Return  
}
w::
up::
MF_UP:
 move_frog(0,-1)
 Return
s::
down::
MF_DN:
 move_frog(0,1)
 Return
a::
left::
MF_LF:
 move_frog(-1,0)
 Return
d::
right::
MF_RT:
 move_frog(1,0)
 Return
 

DI_UP:
 frogdirection=0
 show_frog()
 Return

DI_DN:
 frogdirection=1
 show_frog()
 Return

DI_LF:
 frogdirection=2
 show_frog()
 Return

DI_RT:
 frogdirection=3
 show_frog()
 Return
 

 
DELROW_0:
 delete_row(0)
 Return
DELROW_1:
 delete_row(1)
 Return
DELROW_2:
 delete_row(2)
 Return
DELROW_3:
 delete_row(3)
 Return
DELROW_4:
 delete_row(4)
 Return
DELROW_5:
 delete_row(5)
 Return
DELROW_6:
 delete_row(6)
 Return
DELROW_7:
 delete_row(7)
 Return

delete_row(rownum)
{ ;Collapse towards center. Split this routine into two parts.
  Global
  Local a,b,c,x,y
  Critical On
  backup_imgarray()
  
  if rownum>3
  { 
    y=4
    x=0
    Loop,4
    {
      yprv:=y-1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (rownum<y)
          IMGARRAY_%x%_%yprv%:=IMGARRAY_%x%_%y%
        if y=7
          IMGARRAY_%x%_%y%:=0
        x++
      }
      x=0
      y++
    }
  } else {
    y=3
    x=0
    Loop,4
    {
      ynxt:=y+1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (rownum>y)
          IMGARRAY_%x%_%ynxt%:=IMGARRAY_%x%_%y%
        if y=0
          IMGARRAY_%x%_%y%:=0
        x++
      }
      x=0
      y--
    }
  }

  update_against_backup(1)
  Critical Off
  Return
}

ROTATE_BOARD:
  Critical On
  backup_imgarray()
  dir:=frogdirection
  if dir=0
    dirpr=2
  if dir=1
    dirpr=3
  if dir=2
    dirpr=0
  if dir=3
    dirpr=1
  frogdirection:=dirpr
  move_frog(frogypos,frogxpos,1)
  
  x1=0
  x2=0
  y1=0
  y2=0
  Loop,8
  {
    Loop,8
    {
      if (x1=frogxpos)&&(y1=frogypos)
        IMGARRAY_%x1%_%y1%:=sprite_underneath
      TMPSWAP_%x2%_%y2%:=IMGARRAY_%x1%_%y1%
      x1++
      y2++
    }
    x1=0
    y2=0
    y1++
    x2++
  }
  x=0
  y=0
  Loop,8
  {
    Loop,8
    {
      IMGARRAY_%x%_%y%:=TMPSWAP_%x%_%y%
      x++
    }
    x=0
    y++
  }

  
  update_against_backup(1)
  Critical Off
  Return





INSROW_0:
 insert_row(0)
 Return
INSROW_1:
 insert_row(1)
 Return
INSROW_2:
 insert_row(2)
 Return
INSROW_3:
 insert_row(3)
 Return
INSROW_4:
 insert_row(4)
 Return
INSROW_5:
 insert_row(5)
 Return
INSROW_6:
 insert_row(6)
 Return
INSROW_7:
 insert_row(7)
 Return

insert_row(rownum)
{
  Global
  Local a,b,c,x,y
  Critical On
  backup_imgarray()
  if (rownum>3)
  {
    y=6
    x=0
    Loop,3
    {
      ynxt:=y+1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (rownum<=y)
          IMGARRAY_%x%_%ynxt%:=IMGARRAY_%x%_%y%
        if (y=rownum)
          IMGARRAY_%x%_%y%:=0        
        x++
      }
      x=0
      y--
    }
  } else {
    y=1
    x=0
    Loop,3
    {
      yprv:=y-1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (rownum>=y)
          IMGARRAY_%x%_%yprv%:=IMGARRAY_%x%_%y%
        if (y=rownum)
          IMGARRAY_%x%_%y%:=0        
        x++
      }
      x=0
      y++
    }
  }
  update_against_backup(1)
  Critical Off
  Return
}

DELCOL_0:
 delete_col(0)
 Return
DELCOL_1:
 delete_col(1)
 Return
DELCOL_2:
 delete_col(2)
 Return
DELCOL_3:
 delete_col(3)
 Return
DELCOL_4:
 delete_col(4)
 Return
DELCOL_5:
 delete_col(5)
 Return
DELCOL_6:
 delete_col(6)
 Return
DELCOL_7:
 delete_col(7)
 Return
delete_col(colnum)
{
  Global
  Local a,b,c,x,y
  Critical On
  backup_imgarray()
  
  if colnum>3
  { 
    x=4
    y=0
    Loop,4
    {
      xprv:=x-1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (colnum<x)
          IMGARRAY_%xprv%_%y%:=IMGARRAY_%x%_%y%
        if x=7
          IMGARRAY_%x%_%y%:=0
        y++
      }
      y=0
      x++
    }
  } else {
    x=3
    y=0
    Loop,4
    {
      xnxt:=x+1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (colnum>x)
          IMGARRAY_%xnxt%_%y%:=IMGARRAY_%x%_%y%
        if x=0
          IMGARRAY_%x%_%y%:=0
        y++
      }
      y=0
      x--
    }
  }

  update_against_backup(1)
  Critical Off
  
  Return

}


INSCOL_1:
 insert_col(1)
 Return
INSCOL_2:
 insert_col(2)
 Return
INSCOL_3:
 insert_col(3)
 Return
INSCOL_4:
 insert_col(4)
 Return
INSCOL_5:
 insert_col(5)
 Return
INSCOL_6:
 insert_col(6)
 Return

insert_col(colnum)
{
  Global
  Local a,b,c,x,y
   Critical On
  backup_imgarray()
  if (colnum>3)
  {
    x=6
    y=0
    Loop,3
    {
      xnxt:=x+1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (colnum<=x)
          IMGARRAY_%xnxt%_%y%:=IMGARRAY_%x%_%y%
        if (x=colnum)
          IMGARRAY_%x%_%y%:=0        
        y++
      }
      y=0
      x--
    }
  } else {
    x=1
    y=0
    Loop,3
    {
      xprv:=x-1
      Loop,8
      {
        if (x=frogxpos)&&(y=frogypos)
          IMGARRAY_%x%_%y%:=sprite_underneath
        if (colnum>=x)
          IMGARRAY_%xprv%_%y%:=IMGARRAY_%x%_%y%
        if (x=colnum)
          IMGARRAY_%x%_%y%:=0        
        y++
      }
      y=0
      x++
    }
  }
  update_against_backup(1)
  Critical Off
 
  Return
}


move_frog(dx,dy,absol=0)
{
  Global
  Local a,b,c,x,y,ix,iy,ix1,ix2,iy1,iy2
  
  if (!game_mode)
  {
    if (dx=1)&&(frogxpos>6)
      Return
    if (dx=-1)&&(frogxpos<1)
      Return
    if (dy=1)&&(frogypos>5)
      Return
    if (dy=-1)&&(frogypos<2)
      Return
    x:=frogxpos
    y:=frogypos
    a:=IMGARRAY_%x%_%y%:=sprite_underneath
    ix:=IMGLOC_%x%_%y%_X
    iy:=IMGLOC_%x%_%y%_Y
    if a=0
      a=empty
    else if a=6
      a=pad2
    else if a=7
      a=rock
    else
      a=pad
    GuiControl,,IMGVAR_%x%_%y%,img\%a%.PNG
    frogxpos:=x+dx
    frogypos:=y+dy
    if (absol)
    {
      frogxpos:=dx
      frogypos:=dy
    }
    show_frog()
  } else {
    ;game mode stuffs here.
    ;dir,dx,dy. Invalid moves: 0,*,1 1,*,-1 2,1,* 3,-1,*
    dir:=frogdirection
    if ((dir=0)&&(dy=1))||((dir=1)&&(dy=-1))||((dir=2)&&(dx=1))||((dir=3)&&(dx=-1))
      Return  ;disallow movement if any of these invalid moves happen
    x:=frogxpos
    y:=frogypos
    c=0  ;errorlevel for this loop
    Loop,8
    {
      x+=dx
      y+=dy
      if ((x=-1)||(y=-1)||(x=8)||(y=8))
      {
        c=1
        break
      }
      if ((IMGARRAY_%x%_%y%=1)||(IMGARRAY_%x%_%y%>5))
      {
        c=0
        break
      }
    }
    if (c)
      Return  ;don't allow movement that takes you past the edge of the screen
      
    a:=sprite_underneath
;    ToolTip,PPOS: %a%
    if a=7
      a:="rock",IMGARRAY_%frogxpos%_%frogypos%:=7
    else if a=6
      a:="pad",IMGARRAY_%frogxpos%_%frogypos%:=1
    else
      a:="empty",IMGARRAY_%frogxpos%_%frogypos%:=0
    GuiControl,,IMGVAR_%frogxpos%_%frogypos%,img\%a%.PNG
    frogxpos:=x
    frogypos:=y
    if dy=1
      frogdirection=1
    if dy=-1
      frogdirection=0
    if dx=1
      frogdirection=3
    if dx=-1
      frogdirection=2
    show_frog()
  }
  Return
}

show_frog()
{
  Global
  Local a,b,c,x,y,ix,iy
  x:=frogxpos
  y:=frogypos

  if ((IMGARRAY_%x%_%y%<2)||(IMGARRAY_%x%_%y%>5))
    sprite_underneath:=IMGARRAY_%x%_%y%
  ;
  IMGARRAY_%x%_%y%:=frogdirection+2
  ix:=IMGLOC_%x%_%y%_X
  iy:=IMGLOC_%x%_%y%_Y
  if frogdirection=0
    a=s_up.PNG
  if frogdirection=1
    a=s_down.PNG
  if frogdirection=2
    a=s_left.PNG
  if frogdirection=3
    a=s_right.PNG
  GuiControl,,IMGVAR_%x%_%y%,img\%a%
  GuiControl,,FROG_POS,Frog (%x%`,%y%)
  Return
}


load_level_data(clev)
{
  Global
  Local a,b,c,x,y,ix,iy
  if clev=0
    Return
  frogxpos:=LDAT_%clev%_FROGX
  if frogxpos=""
    frogxpos=0
  frogypos:=LDAT_%clev%_FROGY
  if frogypos=""
    frogypos=0
  curdifficulty:=LDAT_%clev%_DIFFICULTY
  if curdifficulty=""
    curdifficulty=1
  frogdirection:=LDAT_%clev%_FROGDIR
  if frogdirection=""
    frogdirection=0
    
  backup_imgarray()
  
  x:=0
  y:=0
  Loop,8
  {
    Loop,8
    {
      IMGARRAY_%x%_%y%:=LDAT_%clev%_%x%_%y%
      x++
    }
    x=0
    y++
  }
  update_against_backup(1)
  Return
}

save_level_data(clev)
{
  Global
  Local a,b,c,x,y,ix,iy
  LDAT_%clev%_FROGX:=frogxpos
  LDAT_%clev%_FROGY:=frogypos
  LDAT_%clev%_DIFFICULTY:=curdifficulty
  LDAT_%clev%_FROGDIR:=frogdirection
  
  x:=0
  y:=0
  Loop,8
  {
    Loop,8
    {
      if (frogxpos=x)&&(frogypos=y)
        LDAT_%clev%_%x%_%y%:=sprite_underneath
      else
        LDAT_%clev%_%x%_%y%:=IMGARRAY_%x%_%y%
      x++
    }
    x=0
    y++
  }
  Return
}


disp_cur_level()
{
  Global
  Local a,b,c
  GuiControl,,LEVEL_INFO,Lvl %curlevel%/%maxlevel%
  
  if curdifficulty=""
    a=N/A
  else
    a:=curdifficulty
  GuiControl,,DIFFICULTY_INFO,Difficulty: %a%
  if !collapse_info
    a=No board info
  if collapse_info=1
    a=Auto-collapsed
  if collapse_info=2
    a=Not collapsed
  GuiControl,,COLLAPSED_INFO,%a%
  Return
}

backup_imgarray()
{
  Global
  Local a,b,c,x,y
  x=0
  y=0
  Loop,8
  {
    Loop,8
    {
      if (IMGARRAY_%x%_%y%="")
        IMGARRAY_%x%_%y%:=0
      if (x=frogxpos)&&(y=frogypos)
        IMGBAK_%x%_%y%:=sprite_underneath
      else
        IMGBAK_%x%_%y%:=IMGARRAY_%x%_%y%
      x++
    }
    x=0
    y++
  }
  Return
}

update_against_backup(sf=0)
{
  Global
  Local a,b,c,x,y
  x=0
  y=0
  Loop,8
  {
    Loop,8
    {
      if (IMGARRAY_%x%_%y%="")
        IMGARRAY_%x%_%y%:=0
      ;
      b:=IMGBAK_%x%_%y%
      a:=IMGARRAY_%x%_%y%
      if a=0
        a=empty
      else if a=6
        a=pad2
      else if a=7
        a=rock
      else
        a=pad
      if (b!=IMGARRAY_%x%_%y%)
        GuiControl,,IMGVAR_%x%_%y%,img\%a%.PNG      
      x++
    }
    x=0
    y++
  }
  if sf=1
    show_frog()
  Return
}

MENU_EXPORT:
 y_about:="Editor crafted by Rodger 'Iambian' Weisman, with love and cherries."
 FileSelectFile,outfilename,S24,%A_ScriptDir%\LevelSet.sls,Save Level Set As...,Scogger-TI Level Set (*.sls)
 if (ErrorLevel)
   Return
 dump_to_file(outfilename)
 Return
MENU_IMPORT:
 FileSelectFile,infilename,,%A_ScriptDir%,Load Level Set From...,Scogger-TI Level Set (*.sls)
 if (ErrorLevel)
   Return
 ifexist,%infilename%
 {
   LONGEDIT:=""
   Loop,Read,%infilename%
     LONGEDIT.=A_LoopReadLine "`r`n"
   GoSub PARSE_DATA_BREAKIN
 }
 Return

dump_to_file(dumpfile:="img\dump.txt")
{
  Global
  Local a,b,c,d,x,y,outdat
  ifexist,%dumpfile%
    filedelete,%dumpfile%
  outdat:=""
  Loop,% maxlevel
  { 
    c:=A_Index
    x=0
    y=0
    outdat.="{"
    Loop,8
    {
      Loop,8
      {
        outdat.= LDAT_%c%_%x%_%y% ","
        x++
      }
      x=0
      y++
    }
    outdat.= LDAT_%c%_FROGX ","
    outdat.= LDAT_%c%_FROGY ","
    outdat.= LDAT_%c%_FROGDIR ","
    outdat.= LDAT_%c%_DIFFICULTY "}`r`n"
  }
  fileappend,%outdat%,%dumpfile%
}

F1::
 SetTimer,F1Cleared,2000
 ToolTip,%A_Space%F1 = Show this help`n W/A/S/D = Move frog`n Q/E = Prev/next level`n R = Reset level`n Pause/Break = Reload app`n Esc = Exit app`n`nClick=Toggle rock/pad`nShift+Click: Add rock`nCtrl+Click: Add 2-hit pad
 Return
F1Cleared:
 SetTimer,F1Cleared,Off
 ToolTip
 Return

GuiClose:
GuiEscape:
 ExitApp

CleanupCrew:
 if maxlevel!=0
   dump_to_file()
 ExitApp

#IfWinActive
Pause::
 Reload
 Return
