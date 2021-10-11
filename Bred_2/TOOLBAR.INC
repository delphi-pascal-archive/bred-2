const
  TBN_FIRST                = 0-700;       { toolbar }
  TBN_LAST                 = 0-720;

  TBSTATE_CHECKED         = $01;
  TBSTATE_PRESSED         = $02;
  TBSTATE_ENABLED         = $04;
  TBSTATE_HIDDEN          = $08;
  TBSTATE_INDETERMINATE   = $10;
  TBSTATE_WRAP            = $20;
  TBSTATE_ELLIPSES        = $40;

  TBSTYLE_BUTTON          = $00;
  TBSTYLE_SEP             = $01;
  TBSTYLE_CHECK           = $02;
  TBSTYLE_GROUP           = $04;
  TBSTYLE_CHECKGROUP      = TBSTYLE_GROUP or TBSTYLE_CHECK;
  TBSTYLE_DROPDOWN        = $08;

  TBSTYLE_TOOLTIPS        = $0100;
  TBSTYLE_WRAPABLE        = $0200;
  TBSTYLE_ALTDRAG         = $0400;
  TBSTYLE_FLAT            = $0800;
  TBSTYLE_LIST            = $1000;
  TBSTYLE_CUSTOMERASE     = $2000;

  TB_ENABLEBUTTON         = WM_USER + 1;
  TB_CHECKBUTTON          = WM_USER + 2;
  TB_PRESSBUTTON          = WM_USER + 3;
  TB_HIDEBUTTON           = WM_USER + 4;
  TB_INDETERMINATE        = WM_USER + 5;
  TB_ISBUTTONENABLED      = WM_USER + 9;
  TB_ISBUTTONCHECKED      = WM_USER + 10;
  TB_ISBUTTONPRESSED      = WM_USER + 11;
  TB_ISBUTTONHIDDEN       = WM_USER + 12;
  TB_ISBUTTONINDETERMINATE = WM_USER + 13;
  TB_SETSTATE             = WM_USER + 17;
  TB_GETSTATE             = WM_USER + 18;
  TB_ADDBITMAP            = WM_USER + 19;

  TB_SAVERESTOREA          = WM_USER + 26;
  TB_ADDSTRINGA            = WM_USER + 28;
  TB_GETBUTTONTEXTA        = WM_USER + 45;
  TBN_GETBUTTONINFOA       = TBN_FIRST-0;

  TB_SAVERESTOREW          = WM_USER + 76;
  TB_ADDSTRINGW            = WM_USER + 77;
  TB_GETBUTTONTEXTW        = WM_USER + 75;
  TBN_GETBUTTONINFOW       = TBN_FIRST-20;

  TB_SAVERESTORE          = TB_SAVERESTOREA;
  TB_ADDSTRING            = TB_ADDSTRINGA;
  TB_GETBUTTONTEXT        = TB_GETBUTTONTEXTA;
  TBN_GETBUTTONINFO       = TBN_GETBUTTONINFOA;

  TB_CUSTOMIZE            = WM_USER + 27;
  TB_GETITEMRECT          = WM_USER + 29;
  TB_BUTTONSTRUCTSIZE     = WM_USER + 30;
  TB_SETBUTTONSIZE        = WM_USER + 31;
  TB_SETBITMAPSIZE        = WM_USER + 32;
  TB_AUTOSIZE             = WM_USER + 33;
  TB_GETTOOLTIPS          = WM_USER + 35;
  TB_SETTOOLTIPS          = WM_USER + 36;
  TB_SETPARENT            = WM_USER + 37;
  TB_SETROWS              = WM_USER + 39;
  TB_GETROWS              = WM_USER + 40;
  TB_SETCMDID             = WM_USER + 42;
  TB_CHANGEBITMAP         = WM_USER + 43;
  TB_GETBITMAP            = WM_USER + 44;
  TB_REPLACEBITMAP        = WM_USER + 46;
  TB_SETINDENT            = WM_USER + 47;
  TB_SETIMAGELIST         = WM_USER + 48;
  TB_GETIMAGELIST         = WM_USER + 49;
  TB_LOADIMAGES           = WM_USER + 50;
  TB_GETRECT              = WM_USER + 51; { wParam is the Cmd instead of index }
  TB_SETHOTIMAGELIST      = WM_USER + 52;
  TB_GETHOTIMAGELIST      = WM_USER + 53;
  TB_SETDISABLEDIMAGELIST = WM_USER + 54;
  TB_GETDISABLEDIMAGELIST = WM_USER + 55;
  TB_SETSTYLE             = WM_USER + 56;
  TB_GETSTYLE             = WM_USER + 57;
  TB_GETBUTTONSIZE        = WM_USER + 58;
  TB_SETBUTTONWIDTH       = WM_USER + 59;
  TB_SETMAXTEXTROWS       = WM_USER + 60;
  TB_GETTEXTROWS          = WM_USER + 61;

  SBT_OWNERDRAW            = $1000;
  SBT_NOBORDERS            = $0100;
  SBT_POPOUT               = $0200;
  SBT_RTLREADING           = $0400;

  CCS_TOP                 = $00000001;
  CCS_NOMOVEY             = $00000002;
  CCS_BOTTOM              = $00000003;
  CCS_NORESIZE            = $00000004;
  CCS_NOPARENTALIGN       = $00000008;
  CCS_ADJUSTABLE          = $00000020;
  CCS_NODIVIDER           = $00000040;
  CCS_VERT                = $00000080;
  CCS_LEFT                = (CCS_VERT or CCS_TOP);
  CCS_RIGHT               = (CCS_VERT or CCS_BOTTOM);
  CCS_NOMOVEX             = (CCS_VERT or CCS_NOMOVEY);


  TBN_BEGINDRAG           = TBN_FIRST-1;
  TBN_ENDDRAG             = TBN_FIRST-2;
  TBN_BEGINADJUST         = TBN_FIRST-3;
  TBN_ENDADJUST           = TBN_FIRST-4;
  TBN_RESET               = TBN_FIRST-5;
  TBN_QUERYINSERT         = TBN_FIRST-6;
  TBN_QUERYDELETE         = TBN_FIRST-7;
  TBN_TOOLBARCHANGE       = TBN_FIRST-8;
  TBN_CUSTHELP            = TBN_FIRST-9;
  TBN_DROPDOWN            = TBN_FIRST-10;
  TBN_CLOSEUP             = TBN_FIRST-11;

  TB_ADDBUTTONS           = WM_USER + 20;
  TB_INSERTBUTTON         = WM_USER + 21;
  TB_DELETEBUTTON         = WM_USER + 22;
  TB_GETBUTTON            = WM_USER + 23;
  TB_BUTTONCOUNT          = WM_USER + 24;
  TB_COMMANDTOINDEX       = WM_USER + 25;

  UDM_SETRANGE            = WM_USER+101;
  UDM_GETRANGE            = WM_USER+102;
  UDM_SETPOS              = WM_USER+103;
  UDM_GETPOS              = WM_USER+104;

  UDS_WRAP                = $0001;
  UDS_SETBUDDYINT         = $0002;
  UDS_ALIGNRIGHT          = $0004;
  UDS_ALIGNLEFT           = $0008;
  UDS_AUTOBUDDY           = $0010;
  UDS_ARROWKEYS           = $0020;
  UDS_HORZ                = $0040;
  UDS_NOTHOUSANDS         = $0080;


  numb=17;
{  HKEY_CURRENT_USER = DWORD($80000001);
  CW_USEDEFAULT = DWORD($80000000);}
type
  PTBButton = ^TTBButton;
  TTBButton = packed record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..2] of Byte;
    dwData: Longint;
    iString: Integer;
  end;
 PTBSaveParamsA = ^TTBSaveParamsA;
 TTBSaveParamsA = packed record
    hkr: THandle;
    pszSubKey: PAnsiChar;
    pszValueName: PAnsiChar;
 end;

  PToolTipText = ^TToolTipTextA;
  TToolTipTextA = packed record
    hdr: TNMHDR;
    lpszText: PAnsiChar;
    szText: array[0..79] of AnsiChar;
    hinst: THandle;
    uFlags: UINT;
  end;

  PTBNOTIFY = ^TTBNOTIFY;
  TTBNOTIFY = packed record
    hdr: TNMHDR;
    iItem:integer;
    TBBUTTON:TTBButton;
    cchText: integer;
    pszText:PChar;
  end;
  PTBAddBitmap = ^TTBAddBitmap;
  TTBADDBITMAP = packed record
    hInst: THandle;
    nID: UINT;
  end;


