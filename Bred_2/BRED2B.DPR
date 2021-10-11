program Bred2b;

uses //System, SysInit,
  Windows,
  Messages,
  RichEdit,
  CommDlg,
  ShellAPI;

{$R EDITOR.RES}

type
 PIID = PGUID;
 TIID = TGUID;

 PMemRec=^TMemRec;
 TMemRec = packed record
  Position,MemSize:integer;
  case integer of
  0:(Handle:THandle;);
  1:(MemStream:PChar;);
 end;
 MenuAcc = packed record
  m:byte;
  c:Char;
  ID:UINT;
  end;
 TTextRangeA = packed record
  chrg: TCharRange;
  lpstrText: PChar;
 end;

 PMemRecEx=^TMemRecEx;
 TMemRecEx= packed record
  Handle:THandle;
  index:integer;
  Tr:TTextRangeA;
  Type_:byte;
  UndoType:byte;
  Next:PMemRecEx;
 end;
 str32=array[0..32]of char;
 str255 = array[0..260] of Char;

 const
  WinName:PChar = 'BRED2';
  Lib = 'riched32.dll';
  comctl ='comctl32.dll';
  ole32='ole32.dll';
  DefaultFileName:PChar = 'NoName';
  ReadError = $0001;
  WriteError = $0002;
  NoError = $0000;
  max_str = 260;


q1:PChar=#$46#$61#$63#$65#$20#$AA#$E0#$A8#$A2#$AE#$A9#$3F#13#10+
#218#196#196#196#196#196#196#191#13#10+
#179' \  / '#179#13#10+
#179' O  O '#179#13#10+
#179'  ..  '#179#13#10+
#179'  '#196#196'  '#179#13#10+
#192#196#196#196#196#196#196#217#0;

  BredKey = 'Software\Klug\Bred2c';//В реестре
  MRU='LIST';

  cp_n=4;
  cp_1:array[0..cp_n] of integer= (1, -1, 3, 7, 5); {to OEM}
  cp_2:array[0..cp_n] of integer= (0, -1, 2, 6, 4); {to Origin}


  s1_:array[0..cp_n]of PChar=('ANSI (1251)','OEM (866)','KOI8 R','ISO',
   'MAC');
  s2_:array[0..2]of PChar=('SizeW','SizeD','SizeK');
  s3_:array[0..2]of PChar=('EffW','EffD','EffK');
  s4_:array[0..2]of PChar=('SetW','SetD','SetK');
  s5_:array[0..2]of PChar=('FontW','FontD','FontK');
  charSets:array[0..2]of integer=(RUSSIAN_CHARSET, OEM_CHARSET, DEFAULT_CHARSET);

  Enableds: array[Boolean] of UINT = (MF_BYCOMMAND or MF_GRAYED,
                                      MF_BYCOMMAND or MF_ENABLED);

  Code:packed array[0..8,128..255]of char =
(
#192#193#194#195#196#197#198#199#200#201#202#203#204#205#206#207#208#209#210#211#212#213#214#215#216#217#218#219#220#221#222#223+
#224#225#226#227#228#229#230#231#232#233#234#235#236#237#238#239#045#045#045#166#043#166#166#172#172#166#166#172#045#045#045#172+
#076#043#084#043#045#043#166#166#076#227#166#084#166#061#043#166#166#084#084#076#076#045#227#043#043#045#045#045#045#166#166#045+
#240#241#242#243#244#245#246#247#248#249#250#251#252#253#254#255+
#168#184#170#186#175#191#161#162#176#149#183#118#185#164#166#160,{ansi}

#063#063#039#063#034#058#197#216#063#037#063#060#063#063#063#063#063#039#039#034#034#007#045#045#063#084#063#062#063#063#063#063+
#255#246#247#063#253#063#179#021#240#099#242#060#191#045#082#244#248#043#073#105#063#231#020#250#241#252#243#062#063#063#063#245+
#128#129#130#131#132#133#134#135#136#137#138#139#140#141#142#143#144#145#146#147#148#149#150#151#152#153#154#155#156#157#158#159+
#160#161#162#163#164#165#166#167#168#169#170#171#172#173#174#175+
#224#225#226#227#228#229#230#231#232#233#234#235#236#237#238#239,

#225#226#247#231#228#229#246#250#233#234#235#236#237#238#239#240+
#242#243#244#245#230#232#227#254#251#253#255#249#248#252#224#241+
#193#194#215#199#196#197#214#218#201#202#203#204#205#206#207#208+
#144#145#146#129#135#178#180#167#166#181#161#168#174#173#172#131+
#132#137#136#134#128#138#175#176#171#165#187#184#177#160#190#253+
#186#182#183#170#169#162#164#189#188#133#130#141#140#142#143#139+
#210#211#212#213#198#200#195#222#219#221#223#217#216#220#192#209+
#179#163#069#101#073#105#089#121#156#149#158#150#078#191#148#154,{oem to koi8}

#196#179#218#191#192#217#195#180#194#193#197#223#220#219#221#222+
#176#177#178#179#254#249#251#205#060#062#255#179#248#248#250#058+
#205#186#213#241#214#201#184#183#187#212#211#200#190#189#188#198+
#199#204#181#240#182#185#209#210#203#207#208#202#216#215#206#253+
#238#160#161#230#164#165#228#163#229#168#169#170#171#172#173#174+
#175#239#224#225#226#227#166#162#236#235#167#232#237#233#231#234+
#158#128#129#150#132#133#148#131#149#136#137#138#139#140#141#142+
#143#159#144#145#146#147#134#130#156#155#135#152#157#153#151#154,{koi8 to oem}

#128#129#130#131#132#133#134#135#136#137#138#139#140#141#142#143+
#144#145#146#147#148#149#150#151#152#153#154#155#156#157#158#159+
#255#240#162#163#164#165#166#167#168#169#170#171#172#173#174#175+
#128#129#130#131#132#133#134#135#136#137#138#139#140#141#142#143+
#144#145#146#147#148#149#150#151#152#153#154#155#156#157#158#159+
#160#161#162#163#164#165#166#167#168#169#170#171#172#173#174#175+
#224#225#226#227#228#229#230#231#232#233#234#235#236#237#238#239+
#252#241#242#243#244#245#246#247#248#249#250#251#252#253#254#255,

#128#129#130#131#132#133#134#135#136#137#138#139#140#141#142#143+
#144#145#146#147#148#149#150#151#152#153#154#155#156#157#158#159+
#160#161#162#163#164#165#166#167#168#169#170#171#172#173#174#175+
#176#177#178#179#180#181#182#183#184#185#186#187#188#189#190#191+
#192#193#194#195#196#197#198#000#000#201#255#203#204#205#206#207+
#000#000#210#211#212#213#214#215#216#217#218#219#252#240#241#239+
#160#161#162#163#164#165#166#167#168#169#170#171#172#173#174#175+
#224#225#226#227#228#229#230#231#232#233#234#235#236#237#238#255,{mac}

#176#177#178#179#180#181#182#183#184#185#186#187#188#189#190#191+
#192#193#194#195#196#197#198#199#200#201#202#203#204#205#206#207+
#208#209#210#211#212#213#214#215#216#217#218#219#220#221#222#223+
#176#177#178#179#180#181#182#183#184#185#186#187#188#189#190#191+
#192#193#194#195#196#197#198#199#200#201#202#203#204#205#206#207+
#208#209#210#211#212#213#214#215#216#217#218#219#220#221#222#223+
#224#225#226#227#228#229#230#231#232#233#234#235#236#237#238#239+
#161#241#242#243#244#245#246#247#248#249#250#251#240#253#254#160,{iso}

#128#129#130#131#132#133#134#135#136#137#138#139#140#141#142#143+
#144#145#146#147#148#149#150#151#152#153#154#155#156#157#158#159+
#255#240#162#163#164#165#166#167#168#169#170#171#172#173#174#175+
#128#129#130#131#132#133#134#135#136#137#138#139#140#141#142#143+
#144#145#146#147#148#149#150#151#152#153#154#155#156#157#158#159+
#160#161#162#163#164#165#166#167#168#169#170#171#172#173#174#175+
#224#225#226#227#228#229#230#231#232#233#234#235#236#237#238#239+
#252#241#242#243#244#245#246#247#248#249#250#251#252#253#254#255,

#065#066#086#071#068#069#090#090#073#089#075#076#077#078#079#080#082#083#084#085#070#072#067#067#083#083#039#073#039#069#073#073+
#097#098#118#103#100#101#122#122#105#121#107#108#109#110#111#112#176#177#178#179#180#181#182#183#184#185#186#187#188#189#190#191+
#192#193#194#195#196#197#198#199#200#201#202#203#204#205#206#207#208#209#210#211#212#213#214#215#216#217#218#219#220#221#222#223+
                                                                                                                                 #114#115#116#117#102#104#099#099#115#115#039#121#039#101#105#105+
#069#101#242#243#244#245#246#247#248#249#250#251#252#253#254#255{oem to translit}

);

var
 MyFont:hFont;
 MainWindow:hWnd;
 RTF:hWnd=0;
 Stat:hWnd=0;
 Tool:hWnd=0;
 hRTFLib:THandle=0;
 FSrcPos: integer;
 lpfnOldRTFProc:longint;
 OpenFN: TOpenFileName;
 FldRect:TRect;
 ToolBmp, MenuBmp, MenuBmp2:hBitmap;
 MainMenu:hMenu;
 IcoSm, HTMLIcoSm:hIcon;
 PopMenu:array[0..7] of hMenu;
 Repl,RpAll:boolean;
 maxtextlen :DWORD;
 hAccl: hAccel;
 OldCr:TCharRange;
 WWrap:Integer;
 PUndo:PMemRecEx=nil;
 NoUndo, NoModify:boolean;
 Instance: Longint;
 hDevMode_:THandle = 0;
 hDevNames_:THandle= 0;
 F_O_I:integer     = 1;
 TextD:byte=0;
 FindText_,ReplText_:str32;
 FBegin:boolean=false;
 FUp:boolean=false;
 WWord:boolean=false;
 MCase:boolean=false;
 Head:boolean=false;
 Prompt:boolean=true;
 ins:boolean;
 autosave,curautosave,BIGbutton:boolean;
 HackFileName, PathName: array[0..max_str]of char;
 NonClientMetrics: TNonClientMetrics;

const
  {$I IDM.pas}
  {$I ToolBar.inc}
var
 TCommand:packed array[1..7] of byte=
  (id_new,id_odos,id_save,id_cut,id_copy,id_paste,id_undo);
 SzMenu:array[1..bmps,0..31] of char;
 Accels:array[0..bmps] of MenuAcc;
 Accnt:byte=0;


 rc_,rcPage_:TRect;
 maxc,CharPos,NextPos,ipage,Zoom:integer;
 pdc:hDC;
 tpp:TPOINT=(x:0;y:0);
 ZoomIn, ZoomOut:hCursor;
 HeadP:boolean;
 Set_, FHeight, Effects:integer;
 Font_:str32;
 too,sta:boolean;
 cp_m:integer=-1;
// htm:boolean=true;

 TBS:TTBSaveParamsA=(hkr:HKEY_CURRENT_USER;
         pszSubKey:BredKey;
         pszValueName:'TBS');

//Единственный способ перехватить Drag'n'Drop текста в richedit:
const
  RECO_PASTE   = $00000000; // paste from clipboard
  RECO_DROP   = $00000001; // drop
  RECO_COPY   = $00000002; // copy to the clipboard
  RECO_CUT   = $00000003; // cut to the clipboard
  RECO_DRAG   = $00000004; // drag
//  IID_IUnknown: TIID = '{00000000-0000-0000-C000-000000000046}';
//  IID_IRichEditOleCallback: TIID = '{00020D03-0000-0000-C000-000000000046}';

type
  IUnknown    = ^PIUnknownMT;
  PIUnknownMT = ^TIUnknownMT;
  TIUnknownMT = packed record  { IUnknown method table }
    QueryInterface: function (const Self: IUnknown;
      const IID: TIID; var Obj: Pointer): HResult; stdcall;
    AddRef:         function (const Self: IUnknown): Integer; stdcall;
    Release:        function (const Self: IUnknown): Integer; stdcall;
  end;


  IRichEditOleCallback    = ^PIRichEditOleCallbackMT;
  PIRichEditOleCallbackMT = ^TIRichEditOleCallbackMT;
  TIRichEditOleCallbackMT = packed record  {IRichEditOleCallback method table }
    case Integer of
      0: (
        { IUnknown methods }
        QueryInterface: function (const Self: IRichEditOleCallback;
          const IID: TIID; var Obj: Pointer): HResult; stdcall;
        AddRef:         function (const Self: IRichEditOleCallback): Integer; stdcall;
        Release:        function (const Self: IRichEditOleCallback): Integer; stdcall;
        { IRichEditOleCallback methods }
    GetNewStorage: function (const Self: IRichEditOleCallback; out stg: pointer): HRESULT; stdcall;
    GetInPlaceContext:function (const Self: IRichEditOleCallback; out Frame: pointer;
         out Doc: pointer; var FrameInfo: Pointer):
HRESULT; stdcall;
    ShowContainerUI:function (const Self: IRichEditOleCallback; fShow: BOOL): HRESULT; stdcall;
    QueryInsertObject:function (const Self: IRichEditOleCallback; const clsid: TGUID; stg: pointer; cp: longint):
HRESULT; stdcall;
    DeleteObject:function (const Self: IRichEditOleCallback; oleobj: pointer): HRESULT; stdcall;
    QueryAcceptData:function (const Self: IRichEditOleCallback; dataobj: pointer; var cfFormat: word;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
    ContextSensitiveHelp:function (const Self: IRichEditOleCallback; fEnterMode: BOOL): HRESULT; stdcall;
    GetClipboardData:function (const Self: IRichEditOleCallback; const chrg: TCharRange; reco: DWORD;
         out dataobj: pointer): HRESULT; stdcall;
    GetDragDropEffect:function (const Self: IRichEditOleCallback; fDrag: BOOL; grfKeyState: DWORD;
         var dwEffect: DWORD): HRESULT; stdcall;
    GetContextMenu:function (const Self: IRichEditOleCallback; seltype: Word; oleobj: pointer;
         const chrg: TCharRange; var menu: HMENU): HRESULT; stdcall;);
      1: (IUnknownMT: TIUnknownMT);
  end;
  PRichEditOleCallback = ^TRichEditOleCallback;
  TRichEditOleCallback = PIRichEditOleCallbackMT;

var
//  m_cRef:longint=1;
  RichEditOleCallback:TRichEditOleCallback;
  RichEditOleCallbackMT:TIRichEditOleCallbackMT;

//function IsEqualIID(const iid1, iid2: TIID): Boolean; stdcall;  external ole32 name 'IsEqualGUID';

function TIRichEditOleCallback_QueryInterface(const Self: IUnknown; const IID: TIID;
  var Obj: Pointer): HResult; stdcall;
begin
  if @Obj = nil then begin
    Result := E_POINTER;
    Exit
  end;

  // Assume failure.
  Obj := nil;
  Result := E_NOINTERFACE;
{
  // Check for supported interfaces.
  if IsEqualIID(IID, IID_IUnknown) or
     IsEqualIID(IID, IID_IRichEditOleCallback) then begin
    // Return the requested interface and AddRef.
    Obj := Self;
    IUnknown(Obj)^^.AddRef(Obj);
    Result := S_OK
  end}
end;

function TIRichEditOleCallback_AddRef(const Self: IUnknown): Integer; stdcall;
begin
//  inc(m_cRef);
  Result :=2;// m_cRef;
end;

function TIRichEditOleCallback_Release(const Self: IUnknown): Integer; stdcall;
begin
//  dec(m_cRef);
  Result :=1;// m_cRef;
end;


function TIRichEditOleCallback_GetNewStorage(const Self: IRichEditOleCallback;
 out stg: pointer): HRESULT; stdcall;
begin
// stg:=nil;
 result:=E_NOTIMPL;
end;

function TIRichEditOleCallback_GetInPlaceContext(const Self: IRichEditOleCallback; out Frame: pointer;
         out Doc: pointer; var FrameInfo: pointer):
HRESULT; stdcall;
begin
 result:=E_NOTIMPL;
end;

function TIRichEditOleCallback_ShowContainerUI(const Self: IRichEditOleCallback; fShow: BOOL): HRESULT; stdcall;
begin
 result:=E_NOTIMPL;
end;

function TIRichEditOleCallback_QueryInsertObject(const Self: IRichEditOleCallback; const clsid: TGUID; stg: pointer; cp: longint):
HRESULT; stdcall;
begin
 result:=S_OK;
end;

function TIRichEditOleCallback_DeleteObject(const Self: IRichEditOleCallback; oleobj: pointer): HRESULT; stdcall;
begin
 result:=S_OK;
end;
{
function TIRichEditOleCallback_QueryAcceptData(const Self: IRichEditOleCallback; dataobj: pointer; var cfFormat: word;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
 }
function TIRichEditOleCallback_ContextSensitiveHelp(const Self: IRichEditOleCallback; fEnterMode: BOOL): HRESULT; stdcall;
begin
 result:=E_NOTIMPL;
end;

function TIRichEditOleCallback_GetClipboardData(const Self: IRichEditOleCallback; const chrg: TCharRange; reco: DWORD;
         out dataobj: pointer): HRESULT; stdcall;
begin
 if @dataobj = nil then
 begin
    Result := E_POINTER;
    Exit
 end;
 dataobj:=nil;
 result:=E_NOTIMPL;
end;

function TIRichEditOleCallback_GetDragDropEffect(const Self: IRichEditOleCallback; fDrag: BOOL; grfKeyState: DWORD;
         var dwEffect: DWORD): HRESULT; stdcall;
begin
 result:=E_NOTIMPL;
end;

function TIRichEditOleCallback_GetContextMenu(const Self: IRichEditOleCallback; seltype: Word; oleobj: pointer;
         const chrg: TCharRange; var menu: HMENU): HRESULT; stdcall;
begin
 menu:=0;
 result:=E_NOTIMPL;
end;



procedure InitCommonControls; external comctl name 'InitCommonControls';
function CreateStatusWindow(Style: Longint; lpszText: PAnsiChar;
  hwndParent: HWND; wID: UINT): HWND;stdcall; external comctl name 'CreateStatusWindowA';
function CreateUpDownControl(dwStyle: Longint; X, Y, CX, CY: Integer;
  hParent: HWND;  nID: Integer; hInst: THandle; hBuddy: HWND;
  nUpper, nLower, nPos: Integer): HWND; stdcall;external comctl name 'CreateUpDownControl';

procedure code_upd;
begin
 if stat<>0 then
 begin
  SendMessage(Stat, WM_USER+1, 2, longint(s1_[TextD]));
 end;
end;

procedure kbl_upd;
var
 buf:array[0..9]of char;
begin
 if Stat=0 then exit;
 GetKeyboardLayoutName(buf);
 if lstrcmp(buf,'00000409')=0 then lstrcpy(buf,'EN')
                                 else
  if lstrcmp(buf,'00000419')=0 then lstrcpy(buf,'RU');
 SendMessage(Stat, WM_USER+1, 1 or SBT_POPOUT, longint(@buf[0]));
end;

procedure ins_upd;
const
 s__:array[boolean]of Pchar=('Insert','Overwrite');
begin
 if Stat<>0 then SendMessage(Stat, WM_USER+1, 3, longint(s__[ins]));
end;

procedure UpdateCaretPos;
var
  Cr:TCharRange;
  buf:array[0..40]of char;
begin
  if Stat=0 then exit;
  SendMessage(RTF, EM_EXGETSEL, 0, longint(@Cr));
  if (Cr.cpMin<>OldCr.cpMin)or(Cr.cpMax<>OldCr.cpMax) then
  begin
   OldCr:=Cr;
   Cr.cpMax := SendMessage(RTF, EM_EXLINEFROMCHAR, 0,
    Cr.cpMin);
   Cr.cpMin := Cr.cpMin - SendMessage(RTF, EM_LINEINDEX, Cr.cpMax, 0);
   Inc(Cr.cpMin);
   Inc(Cr.cpMax);
   wvsprintf(buf,'%4u:%u',@Cr);
   SendMessage(Stat, WM_USER+1, 0, longint(@buf[0]));
  end;
end;

function GetProfileInt_(const ValueName:PChar;const DefV:integer):integer;
var
 DataSize,DataType:integer;
 phk:hkey;
begin
 DataSize := Sizeof(integer);
 DataType := REG_DWORD;
 RegOpenKey(HKEY_CURRENT_USER, BredKey, phk);
 if RegQueryValueEx(phk, ValueName, nil,  @DataType, @result, @DataSize)<> ERROR_SUCCESS
  then result:=DefV;
 RegCloseKey(phk);
end;

procedure GetProfileString_(const ValueName:PChar;R:PChar;len:integer);
var
 DataType:integer;
 phk:hkey;
begin
 RegOpenKey(HKEY_CURRENT_USER, BredKey, phk);
 DataType := REG_SZ;
 if RegQueryValueEx(phk, ValueName, nil,  @DataType, PByte(R), @len)<> ERROR_SUCCESS then
  lstrcpy(R,'');
 RegCloseKey(phk);
end;

procedure WriteProfileString_(const ValueName:PChar;const R:PChar);
var
 DataSize,DataType:integer;
 phk:hkey;
begin
 RegCreateKey(HKEY_CURRENT_USER,
  BredKey, phk);
 DataType := REG_SZ;
 DataSize:=lstrlen(R)+1;
 RegSetValueEx(phk, ValueName, 0,  DataType, R, DataSize);
 RegCloseKey(phk);
end;

procedure WriteProfileInt_(const ValueName:PChar;const R:integer);
var
 DataSize,DataType:integer;
 phk:hkey;
begin
 RegCreateKey(HKEY_CURRENT_USER,
  BredKey, phk);
 DataType := REG_DWORD;
 DataSize:=sizeof(integer);
 RegSetValueEx(phk, ValueName, 0,  DataType, @R, DataSize);
 RegCloseKey(phk);
end;

procedure SetFont_;
var
 mmm:integer;
 FormatA: TCharFormat;
 kl:hkl;
begin
 mmm:=SendMessage(RTF, EM_GETMODIFY, 0, 0);
 SendMessage(RTF, EM_SETSEL, 0, -1);
 with FormatA do
 begin
  cbSize := SizeOf(TCharFormat);
  dwMask:= integer(CFM_FACE or CFM_CHARSET or CFM_SIZE or CFM_BOLD
     or CFM_COLOR or CFM_ITALIC);
  yOffset:=0;
  crTextColor:=GetProfileInt_('Cl',COLOR_WINDOWTEXT);
  yHeight:=GetProfileInt_(s2_[TextD], 0);
  bCharSet:=GetProfileInt_(s4_[TextD], charsets[TextD]);
  dwEffects:=GetProfileInt_(s3_[TextD], 0);
  GetProfileString_(s5_[TextD], @szFaceName[0], SizeOf(szFaceName));
  if szFaceName[0]=#0 then
        bPitchAndFamily:= FF_MODERN else bPitchAndFamily:=DEFAULT_PITCH;
 end;
 kl:=GetKeyboardLayout(0);
 SendMessage(RTF, EM_SETCHARFORMAT,
        SCF_ALL or SCF_SELECTION, LPARAM(@FormatA));
 SendMessage(RTF, EM_SETCHARFORMAT,
        0, LPARAM(@FormatA));
 ActivateKeyboardLayout(kl,0);
 SendMessage(RTF, EM_EMPTYUNDOBUFFER, 0, 0);
 SendMessage(RTF, EM_SETMODIFY, mmm, 0);
 CheckMenuRadioItem(MainMenu,id_ANSI, id_KOI8R, id_ANSI+TextD,
         MF_BYCOMMAND or MF_CHECKED);
 code_upd;
end;

procedure SetFont;
var
 cr:TCharRange;
 j,k:integer;
begin
 SendMessage(RTF, WM_SETREDRAW, 0, 0);
 j:=SendMessage(RTF, EM_GETFIRSTVISIBLELINE, 0, 0);
 SendMessage(RTF, EM_EXGETSEL, 0, longint(@CR));
 SetFont_;
 SendMessage(RTF, EM_EXSETSEL, 0, longint(@CR));
 k:=SendMessage(RTF, EM_GETFIRSTVISIBLELINE, 0, 0);
 if k>j then
   SendMessage(RTF, EM_LineScroll, 0, j-k);
 SendMessage(RTF, WM_SETREDRAW, 1, 0);
 InvalidateRect(RTF, nil, false);
end;

procedure IOError;
var
 TextT:array[0..255] of Char;
 r:Cardinal;
begin
   r:=GetLastError();
   if r=0 then r:=10;
   FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    nil,
    r,
    0, // Default language
    TextT,
    255,
    nil
   );
  MessageBox(MainWindow, TextT, WinName, MB_OK or MB_ICONINFORMATION);
end;

function SaveCallback2(dwCookie: Longint; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
begin
  pcb:=cb;
  if cb>0 then
  begin
   Move(pbBuff^,PMemRec(dwCookie)^.MemStream[PMemRec(dwCookie)^.MemSize], cb);
   inc(PMemRec(dwCookie)^.MemSize,cb);
  end;
  Result := NoError;
end;

procedure GetRTFText(m:PMemRec);
var
 ES: TEditStream;
begin
 es.dwCookie:=longint(m);
 es.dwError:= 0;
 es.pfnCallback:= @SaveCallback2;
 SendMessage(RTF, EM_STREAMOUT, SF_TEXT, Longint(@ES));
end;

function OpenCallback2(dwCookie: Longint; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
begin
  if cb>PMemRec(dwCookie)^.MemSize-PMemRec(dwCookie)^.Position
   then pcb:=PMemRec(dwCookie)^.MemSize-PMemRec(dwCookie)^.Position
    else pcb:=cb;
  if pcb>0 then
  begin
   Move(PMemRec(dwCookie)^.MemStream[PMemRec(dwCookie)^.Position], pbBuff^, pcb);
   inc(PMemRec(dwCookie)^.Position,pcb);
  end;
  Result := NoError;
end;

procedure SetRTFText(m:PMemRec;const ss:integer);
var
 ES: TEditStream;
begin
 es.dwCookie:=longint(m);
 es.dwError:= 0;
 es.pfnCallback:= @OpenCallback2;
 m.Position:=0;
 SendMessage(RTF, EM_STREAMIN, ss, Longint(@ES));
end;
//Многоуровневый откат
procedure MakeUndoEmpty;
var
 p1:PMemRecEx;
begin
  while PUndo<>nil do
     begin
      p1:=pUndo;
      pUndo:=pUndo^.next;
      if p1^.Handle<>0 then
      begin
       GlobalFree(p1^.Handle);
      end;
      GlobalFree(longint(p1));
     end;
end;

procedure MakeBackUp(t:byte;LEN:integer);
var
 p1:PMemRecEx;
 t1:TMemRec;
 i:integer;
 cr:TCharRange;
 buf:array[0..4]of char;
label
 AssHole, Penis;
begin
//  htm:=true;
  if NoUndo then exit;
  i:=SendMessage(RTF,WM_GETTEXTLENGTH, 0, 0);
//  if i>$4ffff then exit;
  SendMessage(RTF, EM_EXGETSEL, 0, longint(@CR));
{0 - typing, 1 - enter, 2 - del, 3 - backspace, 5 - ^BS,
 4 - cut(delete),paste(replace), 6 - all, 7 - ^del, 8 -typing(overwrite)}
//  oldt:=t;
  if cr.cpMin<>cr.cpMax then
   if (t<4)or(t=8) then t:=4;
  case t of
   0,1:
   begin
    if (pUndo=nil)or(pUndo.UndoType<>t)or
     (pUndo.tr.chrg.cpMax+LEN<>Cr.cpMin) then
    begin
     p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
     if p1=nil then goto Penis;
     p1.UndoType:=t;
     p1.tr.chrg.cpMin:=Cr.cpMin;
     p1^.next:=pUndo;
     pUndo:=p1;
    end;
    pUndo.tr.chrg.cpMax:=Cr.cpMin;
   end;
   2:if Cr.cpMin<i then
   begin
    p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
    if p1=nil then goto Penis;
    p1.UndoType:=t;
    p1.tr.chrg.cpMin:=Cr.cpMin;
    p1.tr.chrg.cpMax:=Cr.cpMin+2;
    p1^.next:=pUndo;
    pUndo:=p1;
    with pUndo^ do
    begin
     tr.lpstrText:=buf;
     SendMessage(RTF, EM_GETTEXTRANGE, 0, longint(@tr));
     index:=byte(buf[0])+byte(buf[1])shl 8;
    end;
   end;
   3:if Cr.cpMin>0 then
   begin
    p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
    if p1=nil then goto Penis;
    p1.UndoType:=t;
    if Cr.cpMin=1 then p1.tr.chrg.cpMin:=0 else p1.tr.chrg.cpMin:=Cr.cpMin-2;
    p1.tr.chrg.cpMax:=Cr.cpMax;
    p1^.next:=pUndo;
    pUndo:=p1;
    with pUndo^ do
    begin
     tr.lpstrText:=buf;
     SendMessage(RTF, EM_GETTEXTRANGE, 0, longint(@tr));
     index:=byte(buf[0])+byte(buf[1]) shl 8;
    end;
   end;
   4:
    begin
     p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
     if p1=nil then goto Penis;
     if cr.cpMax-cr.cpMin>0 then
     begin
      p1^.Handle:= GlobalAlloc(GPTR,cr.cpMax-cr.cpMin+2);
      if p1^.Handle=0 then
      begin
       GlobalFree(longint(p1));
       goto Penis;
      end;
      p1^.tr.lpstrText:=PChar(p1^.Handle);
      p1.UndoType:=t;
      p1^.tr.chrg.cpMin:=Cr.cpMin;
      p1^.tr.chrg.cpMax:=Cr.cpMin+LEN;
      SendMessage(RTF, em_getseltext, 0, longint(p1^.tr.lpstrText));
      p1^.next:=pUndo;
      pUndo:=p1;
     end
                            else
     begin
       p1.UndoType:=t;
       p1^.tr.chrg.cpMin:=Cr.cpMin;
       p1^.tr.chrg.cpMax:=Cr.cpMin+LEN;
       p1^.tr.lpstrText:=nil;
       p1^.next:=pUndo;
       pUndo:=p1;
     end
    end;
   5:if Cr.cpMin<i then
    begin
     p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
     if p1=nil then  goto Penis;
     p1.tr.chrg.cpMin:=Cr.cpMin;
     p1.tr.chrg.cpMax:=SendMessage(RTF, EM_FINDWORDBREAK, WB_MOVEWORDRIGHT, Cr.cpMin);
     goto AssHole;
    end;
   6:
    begin
     if pUndo<>nil then if pUndo.undotype=6 then exit;
     p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
     if p1=nil then  goto Penis;
     if i>0 then
     begin
      p1^.Handle:= GlobalAlloc(GPTR,i+2);
      if p1^.Handle=0 then
      begin
       GlobalFree(longint(p1));
        goto Penis;
      end;
      p1^.tr.lpstrText:=PChar(p1^.Handle);
      p1^.tr.chrg:=Cr;
      t1.MemStream:=p1^.tr.lpstrText;
      t1.MemSize:=0;
      GetRTFText(@t1);
      p1^.index:=t1.MemSize;
     end;
     p1.UndoType:=t;
     p1.Type_:=TextD;
     p1^.next:=pUndo;
     pUndo:=p1;
    end;
   7:if Cr.cpMin>0 then
    begin
     p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
     if p1=nil then  goto Penis;
     p1.tr.chrg.cpMin:=SendMessage(RTF, EM_FINDWORDBREAK, WB_MOVEWORDLEFT, Cr.cpMin);
     p1.tr.chrg.cpMax:=Cr.cpMin;
AssHole:
     p1.Handle:= GlobalAlloc(GPTR,p1.tr.chrg.cpMax-p1.tr.chrg.cpMin+1);
     if p1.Handle=0 then
     begin
      GlobalFree(longint(p1));
       goto Penis;
     end;
     p1.tr.lpstrText:=PChar(p1^.Handle);
     p1.UndoType:=4;
     SendMessage(RTF, EM_GETTEXTRANGE, 0, longint(@p1.tr));
     SendMessage(RTF, EM_EXSETSEL, 0, Longint(@p1.tr.chrg));
     SendMessage(RTF, WM_Clear, 0, 0);
     p1.tr.chrg.cpMax:=p1.tr.chrg.cpMin;
     p1.next:=pUndo;
     pUndo:=p1;
    end;
   8:
   begin
    p1:=PMemRecEx(GlobalAlloc(GPTR,sizeof(TMemRecEx)));
    if p1=nil then  goto Penis;
    p1.UndoType:=t;
    p1.tr.chrg.cpMin:=Cr.cpMin;
    p1.tr.chrg.cpMax:=Cr.cpMin+1;
    with p1^ do
    begin
     tr.lpstrText:=buf;
     SendMessage(RTF, EM_GETTEXTRANGE, 0, longint(@tr));
     index:=byte(buf[0]);
     if index=13 then index:=0;
    end;
    p1^.next:=pUndo;
    pUndo:=p1;
   end;
  end;
  exit;
Penis:IOERROR;
end;

procedure DoUndo;
var
 p1:PMemRecEx;
 t1:TMemRec;
 Selection: TCharRange;
 buf:array[0..4]of char;
begin
 if pUndo<>nil then
 case pUndo^.UndoType of
 0,1:
 begin
  if pUndo.tr.chrg.cpMax>=pUndo.tr.chrg.cpMin then
  begin
   Selection.cpMin:=pUndo.tr.chrg.cpMax;
   dec(pUndo.tr.chrg.cpMax, 1+pUndo^.UndoType);
   Selection.cpMax:=Selection.cpMin+1+pUndo^.UndoType;
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@Selection));
   SendMessage(RTF, WM_Clear, 0, 0);
  end;
  if pUndo.tr.chrg.cpMax<pUndo.tr.chrg.cpMin then
  begin
   p1:=pUndo;
   pUndo:=pUndo^.next;
   GlobalFree(longint(p1));
  end;
 end;
 2:
 begin
   Selection.cpMin:=pUndo.tr.chrg.cpMin;
   Selection.cpMax:=Selection.cpMin;
   if pUndo^.index=13+10 shl 8 then
   begin
    buf[0]:=#13;
    buf[1]:=#10;
    buf[2]:=#0;
   end
   else
   begin
    buf[0]:=chr(lobyte(pUndo^.index));
    buf[1]:=#0;
   end;
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@Selection));
   SendMessage(RTF, EM_REPLACESEL, 0, longint(@buf[0]));
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@Selection));
   p1:=pUndo;
   pUndo:=pUndo^.next;
   GlobalFree(longint(p1));
 end;
 3:
 begin
   if pUndo^.index=13+10 shl 8 then
   begin
    Selection.cpMin:=pUndo.tr.chrg.cpMax-2;
    buf[0]:=#13;
    buf[1]:=#10;
    buf[2]:=#0;
   end
   else
   begin
    Selection.cpMin:=pUndo.tr.chrg.cpMax-1;
    buf[0]:=chr(hibyte(pUndo^.index));
    buf[1]:=#0;
   end;
   Selection.cpMax:=Selection.cpMin;
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@Selection));
   SendMessage(RTF, EM_REPLACESEL, 0, longint(@buf[0]));
   p1:=pUndo;
   pUndo:=pUndo^.next;
   GlobalFree(longint(p1));
 end;
 4:
  begin
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@pUndo.tr.chrg));
   SendMessage(RTF, EM_REPLACESEL, 0, longint(pUndo.tr.lpstrText));
   p1:=pUndo;
   pUndo:=pUndo^.next;
   GlobalFree(p1^.Handle);
   GlobalFree(longint(p1));
  end;
 5:
  begin
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@pUndo.tr.chrg));
   SendMessage(RTF, EM_REPLACESEL, 0, longint(pUndo.tr.lpstrText));
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@pUndo.tr.chrg));
   p1:=pUndo;
   pUndo:=pUndo^.next;
   GlobalFree(p1^.Handle);
   GlobalFree(longint(p1));
  end;
 6:
  begin
   t1.MemStream:=pUndo^.tr.lpstrText;
   t1.MemSize:=pUndo^.index;
   SetRTFText(@t1,SF_TEXT);
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@pUndo.tr.chrg));
   if pUndo^.Type_<>TextD then
   begin
    TextD:=pUndo^.Type_;
    SetFont;
   end;
   p1:=pUndo;
   pUndo:=pUndo^.next;
   GlobalFree(p1^.Handle);
   GlobalFree(longint(p1));
  end;
 8:
 begin
   buf[0]:=chr(lobyte(pUndo^.index));
   buf[1]:=#0;
   SendMessage(RTF, EM_EXSETSEL, 0, Longint(@pUndo.tr.chrg));
   SendMessage(RTF, EM_REPLACESEL, 0, longint(@buf[0]));
   p1:=pUndo;
   pUndo:=pUndo^.next;
   GlobalFree(longint(p1));
 end;
 end;
end;

function TIRichEditOleCallback_QueryAcceptData(const Self: IRichEditOleCallback; dataobj: pointer; var cfFormat: word;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
begin
 if (reco=RECO_DROP) then
 begin
  cfFormat:=CF_TEXT;
  MakeBackUp(6,0);//Куча дерьма ради этой строчки
 end;
 result:=S_OK;
end;


procedure StatInit;
const
 ai:array[0..3] of integer=(88,166,276,-1);
begin
 Stat:=CreateStatusWindow(WS_CHILD or WS_VISIBLE or WS_BORDER,
                                       nil,
                                       MainWindow,
                                       1);
 SendMessage(Stat, WM_USER+4, 4, longint(@ai));
 code_upd;
 kbl_upd;
end;

procedure StatDown;
begin
 DestroyWindow(Stat);
 Stat:=0;
end;

procedure LoadToolBmp(const flag:boolean;var bmp:hBitmap);
var
 i:integer;
 FileName: array[0..max_str]of char;
const
 t:array[boolean]of PChar=('toolbar2.bmp','largebar.bmp');
begin
 if Bmp<>0 then DeleteObject(Bmp);
 i:=GetModuleFileName(Instance, FileName, SizeOf(FileName))-1;
 while (i>0) and(fileName[i-1]<>'\')do dec(i);
 lstrcpy(@FileName[i],t[flag]);
 Bmp:=LoadImage(0, FileName, IMAGE_BITMAP, 0, 0,
  LR_LOADFROMFILE or LR_LOADMAP3DCOLORS);
end;

procedure ToolInit;
var
 TBA:TTBADDBITMAP;
 TBB:TTBButton;
 i:integer;
begin
 Tool:=CreateWindowEx(0,
                      'ToolbarWindow32',
                      nil,
                      WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS
                        or TBSTYLE_FLAT or CCS_TOP or CCS_ADJUSTABLE,
                      0,
                      0,
                      0,
                      0,
                      MainWindow,
                      0,
                      Instance,
                      nil);
 SendMessage(Tool, TB_BUTTONSTRUCTSIZE, sizeof(TTBBUTTON), 0);
 TBA.hInst:=THandle(-1);
 TBA.nID:=ord(BIGbutton);
 SendMessage(Tool, TB_ADDBITMAP, 15, longint(@TBA));

 LoadToolBmp(BIGbutton, ToolBmp);

 TBA.hInst:=0;
 TBA.nID:=ToolBmp;
 SendMessage(Tool, TB_ADDBITMAP, 5, longint(@TBA));

 SendMessage(Tool, TB_SAVERESTORE, 0, longint(@TBS));
 if SendMessage(Tool, TB_BUTTONCOUNT, 0, 0)=0 then
 begin
        with TBB do
         begin
          fsState:=TBSTATE_ENABLED;
          dwData:=0;
          bReserved[1]:=0;
          bReserved[2]:=0;
          iString:=0;
         end;
        for i:=1 to 7 do
        begin
         with TBB do
         begin
          idCommand:=TCommand[i];
          iBitmap:=idCommand-1;
          fsStyle:=TBSTYLE_BUTTON;
         end;
         SendMessage(Tool, tb_addbuttons, 1, lParam(@TBB));
         if i mod 3=0 then
         begin
          with TBB do
          begin
           iBitmap:=0;
           idCommand:=0;
           fsStyle:=TBSTYLE_SEP;
          end;
          SendMessage(Tool, tb_addbuttons, 1, lParam(@TBB));
         end;
        end;
 end;
end;

procedure ToolDown;
begin
 DestroyWindow(Tool);
 Tool:=0;
end;

function RTFProc(Window: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint;  stdcall; forward;


procedure RTFEDIT_ReCreate;
begin
    RTF:= CreateWindowEx(
                        WS_EX_ACCEPTFILES or
                        WS_EX_STATICEDGE,
//Не включать!             or ES_EX_NOCALLOLEINIT,
                        RICHEDIT_CLASS10A,
                        nil,
                        WS_CHILD or //Не включать! WS_CLIPSIBLINGS or
                        WS_VISIBLE or
                        ES_MULTILINE or
                        WS_VSCROLL or
                        ES_AUTOVSCROLL or
                        ES_NOOLEDRAGDROP or
                        ES_SELECTIONBAR or
                        WWrap,
                        0, 64,
                        128, 128,
                        MainWindow,
                        0,
                        Instance,
                        nil );
     if RTF<>0 then
     begin
      lpfnOldRTFProc:=SetWindowLong(RTF,GWL_WNDPROC,longint(@RTFProc));
      SetFocus(RTF);
      SendMessage(RTF, EM_EXLIMITTEXT, 0, maxtextlen);//Самое главное
      SendMessage(RTF, EM_SETBKGNDCOLOR, 0, GetProfileInt_('Bk',GetSysColor(COLOR_WINDOW)));
      SetFont;
      ins:=false;
      ins_upd;
      OldCr.cpMin:=-1;
      UpdateCaretPos;
      SendMessage(RTF, EM_SETOLECALLBACK, 0,
          longint(@RichEditOleCallback));
     end;
end;

procedure RTFEDIT_Shutdown;
begin
    if hDevNames_<>0 then
    begin
     GlobalFree(hDevNames_);
    end;
    if hDevMode_<>0 then
    begin
     GlobalFree(hDevMode_);
    end;
    if hRTFLib<>0 then
    begin
     if RTF<>0 then
     begin
      DestroyWindow(RTF);
      RTF:=0;
     end;
     FreeLibrary(hRTFLib);
    end;
   MakeUndoEmpty;
end;

procedure HexChr(buf:PChar;var result_:str32);
var
 i,y_,z_:integer;
begin
        i:=0;
        while (Buf^>#0)and(i<32) do
        begin
         y_:=0;
         for z_:= 0 to 1 do
         begin
          case Buf^ of
          '0'..'9': y_:=y_ shl 4 + byte(Buf^)-48;
          'A'..'F': y_:=y_ shl 4 + byte(Buf^)-byte('A')+10;
          'a'..'f': y_:=y_ shl 4 + byte(Buf^)-byte('a')+10;
          end;
          inc(buf);
         end;
         result_[i]:=Chr(y_);
         inc(i);
        end;
        result_[i]:=#0;
end;

function FindWord(Dialog: HWnd; Message, WParam: Longint;
   LParam: Longint): Longint; stdcall;
var
 g,buf:array[0..32]of char;
 i,j:integer;
 b__:boolean;
 cr:TTextRangeA;
 s:array[0..1] of char;
label
 AssHole;
begin
  s[1]:=#0;
  FindWord := 1;
  case Message of
    wm_InitDialog:
    begin
     SendDlgItemMessage(Dialog,102,bm_setCheck,ord(WWord),0);
     SendDlgItemMessage(Dialog,103,bm_setCheck,ord(MCase),0);
     SendDlgItemMessage(Dialog,104,bm_setCheck,ord(FBegin),0);
     SendDlgItemMessage(Dialog,105,bm_setCheck,ord(FUp),0);
     if Repl then
     begin
      SendDlgItemMessage(Dialog,111,bm_setCheck,ord(Prompt),0);
      SetWindowText(Dialog,'Replace...');
     end
     else
     begin
      ShowWindow(GetDlgItem(Dialog,112),sw_Hide);
      ShowWindow(GetDlgItem(Dialog,111),sw_Hide);
      ShowWindow(GetDlgItem(Dialog,110),sw_Hide);
      ShowWindow(GetDlgItem(Dialog,109),sw_Hide);
      ShowWindow(GetDlgItem(Dialog,6),sw_Hide);
      SetWindowText(Dialog,'Find...');
     end;
     for i:=9 downto 0 do
     begin
      s[0]:=chr(i+48);
      GetProfileString_(s,g,sizeof(g));
      if g[0]>#0 then
       SendDlgItemMessage(Dialog,101,cb_InsertString,0,Longint(@g[0]));
     end;
     for i:=0 to 9 do
     begin
      s[0]:=chr(i+48);
      if GetPrivateProfileString('SearchText',s,'',g,sizeof(g),'Wincmd.INI')>0 then
       SendDlgItemMessage(Dialog,101,cb_AddString,0,Longint(@g[0]));
     end;
     SendMessage(RTF, EM_EXGETSEL, 0, longint(@Cr.chrg));
     Cr.chrg.cpMax:=SendMessage(RTF, EM_FINDWORDBREAK, WB_MOVEWORDRIGHT, Cr.chrg.cpMin);
     Cr.chrg.cpMin:=SendMessage(RTF, EM_FINDWORDBREAK, WB_MOVEWORDLEFT, Cr.chrg.cpMax);
     if Cr.chrg.cpMax-Cr.chrg.cpMin>32 then Cr.chrg.cpMax:=Cr.chrg.cpMin+32;
     Cr.lpstrText:=g;
     SendMessage(RTF, EM_GETTEXTRANGE, 0, longint(@CR));
     i:=0;
     j:=0;
     while (i<32)and(g[i]<>#0)do
     begin
           if g[i]>' ' then
           begin
            buf[j]:=g[i];
            inc(j);
           end;
           inc(i);
     end;
     if j=0 then exit;
     buf[j]:=#0;
     case TextD of
     1:for i:=0 to j-1 do
        if buf[i]>=#128 then buf[i]:=Code[0, byte(buf[i])];
     2:for i:=0 to j-1 do
        if buf[i]>=#128 then
        begin
         buf[i]:=Code[3, byte(buf[i])];
         if buf[i]>=#128 then buf[i]:=Code[0, byte(buf[i])];
        end;
      end;
     SendDlgItemMessage(Dialog,101,cb_insertString,0,Longint(@buf[0]));
     SendDlgItemMessage(Dialog,101,CB_SETCURSEL,0,0);
     Exit;
    end;
    wm_Command:
     case LoWord(WParam) of
     id_Ok,id_Yes:
     begin
      b__:=IsWindowEnabled(GetDlgItem(Dialog,101));
      if ((GetWindowTextLength(GetDlgItem(Dialog,101))>0)
       and b__) or ((GetWindowTextLength(GetDlgItem(Dialog,107))>0)
       and not b__)then
      begin
       RpAll:=LoWord(WParam)=id_Yes;
       WWord:=SendDlgItemMessage(Dialog,102,bm_getCheck,0,0)=1;
       MCase:=SendDlgItemMessage(Dialog,103,bm_getCheck,0,0)=1;
       FBegin:=SendDlgItemMessage(Dialog,104,bm_getCheck,0,0)=1;
       FUp:=SendDlgItemMessage(Dialog,105,bm_getCheck,0,0)=1;
       if Repl then Prompt:=SendDlgItemMessage(Dialog,111,bm_getCheck,0,0)=1;
       if b__ then
       begin
        if Repl then
        begin
         GetWindowText(GetDlgItem(Dialog,109),buf,sizeof(buf));
         lstrcpy(ReplText_,buf);
        end;
        GetWindowText(GetDlgItem(Dialog,101),buf,sizeof(buf));
        lstrcpy(FindText_,buf);
       end
         else
       begin
        if Repl then
        begin
         GetWindowText(GetDlgItem(Dialog,110),buf,sizeof(buf));
         HexChr(buf,ReplText_);
        end;
        GetWindowText(GetDlgItem(Dialog,107),buf,sizeof(buf));
        HexChr(buf,FindText_);
       end;
       EndDialog(Dialog, 1);
       if b__ then
       begin
        case TextD of
         1:
         begin
          for i:=0 to lstrlen(FindText_)-1 do
            if FindText_[i]>=#128 then FindText_[i]:=Code[1, byte(FindText_[i])];
          if Repl then
           for i:=0 to lstrlen(ReplText_)-1 do
            if ReplText_[i]>=#128 then ReplText_[i]:=Code[1, byte(ReplText_[i])];
         end;
         2:
         begin
          for i:=0 to lstrlen(FindText_)-1 do
            if FindText_[i]>=#128 then
            begin
             FindText_[i]:=Code[1, byte(FindText_[i])];
             if FindText_[i]>=#128 then FindText_[i]:=Code[2, byte(FindText_[i])];
            end;
          if Repl then
          for i:=0 to lstrlen(ReplText_)-1 do
            if ReplText_[i]>=#128 then
            begin
             ReplText_[i]:=Code[1, byte(ReplText_[i])];
             if ReplText_[i]>=#128 then ReplText_[i]:=Code[2, byte(ReplText_[i])];
            end;
         end;
        end;
        i:=0;
        while i<10 do
        begin
         s[0]:=chr(i+48);
         GetProfileString_(s,g,sizeof(g));
         if g[0]=#0 then goto AssHole;
         if lstrcmp(g,Buf)=0 then goto AssHole;
         inc(i);
        end;
        i:=9;
AssHole:for i:=Pred(i) downto 0 do
        begin
         s[0]:=chr(i+48);
         GetProfileString_(s,g,sizeof(g));
         inc(s[0]);
         WriteProfileString_(s,g);
        end;
        WriteProfileString_('0',Buf);
       end;
      end;
      Exit;
      end;
      id_Cancel:
      begin
        EndDialog(Dialog, 2);
        Exit;
      end;
      108:
      begin
       b__:=SendMessage(lparam,bm_getCheck,0,0)=0;
       EnableWindow(GetDlgItem(Dialog,101),b__);
       EnableWindow(GetDlgItem(Dialog,107),not b__);
       if Repl then
       begin
        EnableWindow(GetDlgItem(Dialog,109),b__);
        EnableWindow(GetDlgItem(Dialog,110),not b__);
       end;
       if b__ then SetFocus(GetDlgItem(Dialog,101))
              else SetFocus(GetDlgItem(Dialog,107));
      end;
      end;
  end;
  FindWord := 0;
end;

function Rep(Dialog: HWnd; Message, WParam: Longint;
   LParam: Longint): Longint; stdcall;
begin
  SendMessage(RTF, EM_HIDESELECTION, 0, 0);
  case Message of
    wm_Command:
    begin
     EndDialog(Dialog, loWord(wParam));
    end;
  end;
  Result := 0;
end;

function SearchAgain: boolean;
var
  fnd,i,j,k:integer;
  Find:TFindText;
Label
 Ass;
Procedure Next;
begin
      SendMessage(RTF, EM_REPLACESEL, 1, Longint(@ReplText_[0]));
      if not FUp then inc(FSrcPos,lstrlen(ReplText_));
end;
begin
 result := false;
 i:=lstrlen(FindText_);
 if i=0 then exit;
 Find.lpstrText := FindText_;
 if WWord then Fnd := FT_WHOLEWORD else Fnd:=0;
 if MCase then Fnd := Fnd or FT_MATCHCASE;
 SendMessage(RTF, EM_EXGETSEL, 0, longint(@Find.chrg));
 if FUp then
 begin
 if FSrcPos>Find.chrg.cpMin
           then FSrcPos:=Find.chrg.cpMin;
  Find.chrg.cpMax:=FSrcPos;
  Find.chrg.cpMin:=0;
  k:=SendMessage(RTF, EM_FINDTEXT, Fnd, LongInt(@Find));
  FSrcPos:=-1;
  while k>=0 do
  begin
   repeat
    FSrcPos:=k;
    j:=Find.chrg.cpMin;
    Find.chrg.cpMin:=(Find.chrg.cpMax+FSrcPos) div 2;
    k:=SendMessage(RTF, EM_FINDTEXT, Fnd, LongInt(@Find));
   until (k<0)or(Find.chrg.cpMax-Find.chrg.cpMin<=i);
   Find.chrg.cpMax:=Find.chrg.cpMin+i;
   Find.chrg.cpMin:=FSrcPos+1;
   k:=SendMessage(RTF, EM_FINDTEXT, Fnd, LongInt(@Find));
   Find.chrg.cpMin:=j;
  end;
 end
      else
 begin
  if (FSrcPos<Find.chrg.cpMin)and not FBegin
           then FSrcPos:=Find.chrg.cpMin
           else
   Find.chrg.cpMin:=FSrcPos;
  Find.chrg.cpMax := SendMessage(RTF,WM_GETTEXTLENGTH, 0, 0);
//  if Repl then dec(Find.chrg.cpMax,i);
  FSrcPos:=SendMessage(RTF, EM_FINDTEXT, Fnd, LongInt(@Find));
 end;
 if FSrcPos>= 0 then
 begin
   Find.chrg.cpMin:=FSrcPos;
   Find.chrg.cpMax:=FSrcPos+i;
   SendMessage(RTF, EM_EXSETSEL, 0, longint(@Find.chrg));
   if Repl then
   begin
    if Prompt then
    begin
    Case DialogBoxParam(Instance, PChar(3), MainWindow, @rep, 0) of
     id_Yes:
     begin
      Prompt:= false;
      RpAll:= true;
      Next
     end;
     id_Ok:Next;
     id_No:RpAll:= false;
     id_Cancel:goto Ass;
    end; {case}
    end
              else
     Next;
   end else
Ass:if not FUp  then inc(FSrcPos,i);
   result := true;
  end
end;

procedure FindClick;
var
 Cr:TCharRange;
Label
 Ass;
begin
 if DialogBoxParam(Instance, PChar(1), MainWindow, @FindWord,0)=1 then
 begin
  if FBegin then
  begin
   if FUp then FSrcPos:=SendMessage(RTF, WM_GETTEXTLENGTH, 0, 0) else
   FSrcPos:=0
  end
            else
  begin
   SendMessage(RTF, EM_EXGETSEL,0,longint(@Cr));
   FSrcPos:=Cr.cpMin;
  end;
  if Repl then makebackup(6,0);
  Ass:
  if  SearchAgain then
   if Repl and RpAll then goto Ass;
 end;
end;

procedure SetCaption;
var
 st: array[0..max_str+9]of char;
 m__:THandle;
 FIND_DATA:TWIN32FINDDATA;
begin
 lstrcpy(@st[1],PathName);
 if lstrcmp(DefaultFileName,PathName)<>0 then
 begin
  m__:=FindFirstFile(PathName, FIND_DATA);//Похоже, единственный способ 
  if m__<>INVALID_HANDLE_VALUE then //получить длинное имя
  begin
   Windows.FindClose(m__);
   lstrcpy(@st[1],FIND_DATA.cFileName);
  end;
 end;
 st[0]:='[';
 lstrcat(st,']-BRED2');
 SetWindowText(MainWindow, st);
end;

function OpenCallback(dwCookie: Longint; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
begin
  pcb:= _lread(dwCookie, pbBuff, cb);
  if pcb=-1 then
  begin
   pcb:=0;
   Result := ReadError;
  end else Result := NoError;
end;

procedure Menu0(const SFileName:PChar;const restore:boolean);
var
 s_,i,j,n:integer;
 s:array[0..3] of char;
 List:array[0..10]of char;
 AFileName,FileName: array[0..max_str]of char;
label
 Ass;
begin
 s[0]:=SFileName[0];
 s[1]:=':';
 s[2]:='\';
 s[3]:=#0;
 if GetDriveType(s)=DRIVE_FIXED then
 begin
  for s_:=0 to lstrlen(SFileName)-1 do if SFileName[s_]='$' then exit;
  GetShortPathName(SFileName,AFileName,max_str);
  GetProfileString_(MRU,List,SizeOf(List));
  s:=#0#70#0#0;
  n:=-1;
  s_:=0;
  while s_<=9 do
  begin
   s[0]:=chr(s_+48);
   FileName[0]:=#0;
   j:=0;
   while j<lstrlen(List) do
   begin
    if List[j]=s[0] then
    begin
     GetProfileString_(s,FileName,SizeOf(FileName));
     break
    end;
    inc(j);
   end;
   if FileName[0]=#0 then
   begin
    if n<0 then n:=s_;
   end
      else
   begin
    GetShortPathName(FileName,FileName,max_str);
    if lstrcmpi(FileName,AFileName)=0 then
    begin
     if restore then
     begin
      s[2]:='C';
      i:=GetProfileInt_(s,-1);
      if i>=0 then SendMessage(RTF,EM_SETSEL, i, i);
     end;
     if j=0 then exit;
     FileName[0]:=List[j];
     lstrcpy(@FileName[1],List);
     lstrcpy(@FileName[j+1],@List[j+1]);
     goto ass;
    end;
   end;
   inc(s_);
  end;
  if n<0 then FileName[0]:=List[9] else
   FileName[0]:=chr(n+48);
  FileName[1]:='F';
  FileName[2]:='C';
  FileName[3]:=#0;
  WriteProfileInt_(FileName, 0);
  FileName[2]:=#0;
  WriteProfileString_(FileName, SFileName);

  lstrcpy(@FileName[1],List);
  j:=1;
  while j<lstrlen(List) do
   begin
    if List[j]=FileName[0] then
    begin
     lstrcpy(@FileName[j+1],@List[j+1]);
     break
    end;
    inc(j);
   end;
  FileName[10]:=#0;
Ass:
  WriteProfileString_(MRU,FileName);
  for i:=909 downto 900 do
  begin
   ModifyMenu(MainMenu, i, MF_BYCOMMAND or MF_STRING, i, '');
   ModifyMenu(MainMenu, i, MF_BYCOMMAND or MF_OWNERDRAW, i, nil);
  end;
 end;
end;

function Open(const AFileName: pChar):boolean;
var
 hFile,s_,d,w,k,Handle:integer;
 ES: TEditStream;
 st,p:PChar;
label
 Asshole, Hole, BlackHole;
const
  WinSymbols:PChar=#242#243#251#252#254#255#0;
  DosSymbols:PChar=#128#133#136#142#147#160#165#168#170#176#177#178#180#186#191#0;
begin
 result:=false;
 Handle:= GlobalAlloc(GPTR, $fff);
 if Handle=0 then exit;
 st:=PChar(Handle);
 hFile:=_lOpen(AFileName, OF_READ);
 if hFile=-1 then  goto BlackHole;
 if GetFileSize(hFile,nil)>maxtextlen then
 begin
  _lclose(hFile);
Hole:IOError;{???}
BlackHole:GlobalFree(Handle);
  exit;
 end;
 es.dwCookie:= hFile;
 es.dwError:= 0;
 es.pfnCallback:= @OpenCallback;

 SendMessage(RTF, EM_STREAMIN, SF_TEXT, Longint(@ES));

 _lclose(hFile);
 if es.dwError<>0 then goto Hole;

 MakeUndoEmpty;
 SendMessage(RTF, EM_SETMODIFY, 0, 0);
 lstrcpy(PathName, AFileName);
 result:=true;

 Menu0(PathName,true);
 SetCaption;

 {FontDetect}//На самом деле _не должен_ срабатывать всегда!
 d:=0;
 w:=0;
 k:=0;
 for s_:=0 to SendMessage(RTF,WM_GETTEXT, $ffd, longint(@st[0]))-1 do
 begin
  P:=WinSymbols;
  while p[0]<>#0 do
  begin
   if p[0]=st[s_] then
   begin
    inc(w);
    goto AssHole;
   end;
   inc(p);
  end;
  P:=DosSymbols;
  while p[0]<>#0 do
  begin
   if p[0]=st[s_] then
   begin
    inc(d);
    goto AssHole;
   end;
   inc(p);
  end;
AssHole:
  if (st[s_]<'a')and (st[s_+1]>='а')and (st[s_+1]<='я')and (st[s_+2]>='А')and (st[s_+2]<='Я')
   then inc(k);
 end;
 s_:=0;
 if d>w then s_:=1 else if k>0 then s_:=2;
 if TextD<>s_ then
 begin
  TextD:=s_;
  SetFont;
 end;
 {FontDetect}
 GlobalFree(Handle);
end;

function SaveCallback(dwCookie: Longint; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
begin
  pcb:= _lwrite(dwCookie, Pointer(pbBuff), cb);
  if pcb<>cb then
  begin
   if pcb=-1 then pcb:=0;
   Result := WriteError;
  end else Result := NoError;
end;

function RTF_Save:boolean;
var
 hFile:THandle;
 attr_:integer;
 ES: TEditStream;
 FIND_DATA:TWIN32FindData;
 ofs:TOFStruct;
 s: array[0..280]of char;
begin
    result:=false;
    HFile:=FindFirstFile(PathName,FIND_DATA);
    if HFile<>INVALID_HANDLE_VALUE then
    begin
     Windows.FindClose(HFile);
     attr_:=FIND_DATA.dwFileAttributes;
     if (attr_ and FILE_ATTRIBUTE_READONLY)>0 then
     begin
      lstrcpy(s, PathName);
      lstrcat(s,': READ ONLY!'#13'Overwrite?');
      if MessageBox(MainWindow, s,WinName,MB_YESNO
       or MB_ICONQUESTION)=IDNO then exit;
      SetFileAttributes(PathName,FILE_ATTRIBUTE_ARCHIVE)
     end;
    end else attr_:=FILE_ATTRIBUTE_ARCHIVE;

    hFile:= OpenFile(PathName,ofs, OF_CREATE or OF_WRITE);
    if hFile=INVALID_HANDLE_VALUE then
    begin
      IOError;
      exit;
    end;

    es.dwCookie:= hFile;   
    es.dwError:= 0;        
    es.pfnCallback:= @SaveCallback; 

    SendMessage(RTF, EM_STREAMOUT, SF_TEXT, Longint(@ES));
    _lclose(hFile);
    SetFileAttributes(PathName,attr_);
    if es.dwError=0 then
     begin
      SendMessage(RTF, EM_SETMODIFY, 0, 0);
      result:=true;
     end
    else
    begin
     IOError;
    end;
end;

procedure TypeChange;
begin
    case OpenFN.nFilterIndex of
    1:OpenFN.lpstrDefExt:='txt';
    2:OpenFN.lpstrDefExt:='';
    3:OpenFN.lpstrDefExt:='htm';
    4:OpenFN.lpstrDefExt:='pas';
    5:OpenFN.lpstrDefExt:='c';
    6:OpenFN.lpstrDefExt:='bat';
    end;
end;

function ExplorerHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  if (Msg = WM_NOTIFY) and (POFNotify(LParam)^.hdr.code = CDN_TYPECHANGE) then
   TypeChange;
end;

procedure OpenDOS;
var
 FileName: array[0..max_str]of char;
begin
  FileName:='';
  with OpenFN do
  begin
    nFilterIndex  := F_O_I;       {Index into Filter String in lpstrFilter}
    flags         := OFN_CREATEPROMPT or OFN_EXPLORER
                      or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_ENABLEHOOK;
    lpstrFile     := FileName;
  end;
  TypeChange;
  if GetOpenFileName(OpenFN) then
  begin
   F_O_I:= OpenFN.nFilterIndex;
   Open(FileName);
  end;
end;

procedure Insert;
var
 FileName: array[0..max_str]of char;
 hFile:THandle;
 ES:TEditStream;
begin
  FileName:='';
  with OpenFN do
  begin
    nFilterIndex  := F_O_I;       {Index into Filter String in lpstrFilter}
    flags         := OFN_CREATEPROMPT or OFN_EXPLORER
                      or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_ENABLEHOOK;
    lpstrFile     := FileName;
  end;
  TypeChange;
  if GetOpenFileName(OpenFN) then
  begin
   F_O_I:= OpenFN.nFilterIndex;
   hFile:=_lOpen(FileName, OF_READ);
   if hFile=THandle(-1) then exit;
   if GetFileSize(hFile,nil)>maxtextlen then
   begin
    _lclose(hFile);
    exit;
   end;
   es.dwCookie:= hFile;
   es.dwError:= 0;
   es.pfnCallback:= @OpenCallback;

   MakeBackUp(6,0);
   SendMessage(RTF, EM_STREAMIN, SF_TEXT or SFF_SELECTION, Longint(@ES));
   _lclose(hFile);
  end;
end;

procedure SAVE_AS;
begin
  with OpenFN do
  begin
    nFilterIndex  := F_O_I;
    flags         :=  OFN_EXPLORER
                      or OFN_PATHMUSTEXIST or OFN_HIDEREADONLY
                      or OFN_OVERWRITEPROMPT or OFN_ENABLEHOOK;
    lpstrFile     := PathName;
  end;
  TypeChange;{???????????????????}
  if GetSaveFileName(OpenFN) then
  begin
   F_O_I:= OpenFN.nFilterIndex;
   if RTF_Save then
   begin
    Menu0(PathName,false);
    MakeUndoEmpty;
   end;
   SetCaption;
  end;
end;

procedure SetWWrap;//Перенос по словам
var
 mmm:integer;
 CharRange: TCharRange;
 m:TMemRec;
 R:TRect;
begin
  m.Handle:= GlobalAlloc(GPTR,
                 SendMessage(RTF,WM_GETTEXTLENGTH, 0, 0)+2);
  if m.Handle=0 then exit;
//  m.MemStream:=PChar(GlobalLock(m.Handle));
  m.MemSize:=0;
  SendMessage(RTF, EM_EXGETSEL, 0, longint(@CharRange));
  mmm:=SendMessage(RTF, EM_GETMODIFY, 0, 0);
  GetRTFText(@m);
  DestroyWindow(RTF);
  RTF:=0;
  if WWrap = 0 then
  begin
   WWrap:=ES_AUTOHSCROLL or WS_HSCROLL;
   CheckMenuItem(MainMenu,id_WordWrap,
         MF_BYCOMMAND or MF_UNCHECKED)
  end
               else
  begin
   WWrap:=0;
   CheckMenuItem(MainMenu,id_WordWrap,
         MF_BYCOMMAND or MF_CHECKED);
  end;
  WriteProfileInt_('WW',WWrap);
  RTFEDIT_ReCreate;
  GetClientRect(MainWindow,r);
  SendMessage(MainWindow, wm_Size,0,MakeLong(r.right,r.bottom));
  SetRTFText(@m, SF_TEXT);
  SendMessage(RTF, EM_EXSETSEL, 0, longint(@CharRange));
  SendMessage(RTF, EM_SETMODIFY, mmm, 0);
  GlobalFree(m.Handle);
end;

function CheckSave:boolean;
var
 st: array[0..280]of char;
 AFileName:array[0..max_str] of char;
 s:array[0..3] of char;
 cr:TCharRange;
 s_:char;
begin
 if lstrcmp(PathName,DefaultFileName)<>0 then
 begin
  GetShortPathName(PathName,AFileName,max_str);
  s:=#0#70#0#0;
  for s_:=#$30 to #$39 do
  begin
   s[0]:=s_;
   GetProfileString_(s,st,SizeOf(st));
   GetShortPathName(st,st,max_str);
   if lstrcmpi(st,AFileName)=0 then
   begin
    s[2]:='C';
    SendMessage(RTF, EM_EXGETSEL, 0, longint(@CR));
    WriteProfileInt_(s, Cr.cpMin);
    break
   end;
  end;
 end;
 result:=true;
 if SendMessage(RTF, EM_GETMODIFY, 0, 0)<>0 then
 begin
  if (not NoModify and (pUndo=nil)) then exit;
  lstrcpy(st,'Save changes to ');
  lstrcat(st,PathName);
  lstrcat(st,'?');
  case MessageBox(MainWindow,st,WinName,MB_YESNOCANCEL
       or MB_ICONQUESTION) of
   IDYES:if lstrcmp(PathName,DefaultFileName)=0 then Save_As
                   else RTF_Save;
   IDNO:;
   IDCANCEL:result:=false;
  end;
 end;
end;

function RTFProc(Window: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint;  stdcall;
var
 Msg:TMsg;
 chr_:array[0..2]of Char;
 FileName: array[0..max_str]of char;
 Tr:TTEXTRANGEA;
 i:integer;
begin
 RTFProc:=0;
 Msg.hWnd:=MainWindow;
 Msg.Message:=Message;
 Msg.wParam:=wParam;

 if TranslateAccelerator(MainWindow, hAccl, Msg)<>0 then
  exit;

 Case Message Of
  wm_Char:
  begin
   case wParam of
    9,32..126,128..255:
    begin
     SendMessage(Window, EM_EXGETSEL, 0, longint(@tr.chrg));
     if tr.chrg.cpMax-tr.chrg.cpMin>2 then
     begin
      i:=tr.chrg.cpMin;
      tr.chrg.cpMin:=tr.chrg.cpMax-2;
      tr.lpstrText:=@chr_[0];
      SendMessage(Window, EM_GETTEXTRANGE, 0, longint(@tr));
      if (chr_[0]=#13)and(chr_[1]=#10) then
      begin
       tr.chrg.cpMax:=tr.chrg.cpMin;
       tr.chrg.cpMin:=i;
       SendMessage(Window, EM_EXSETSEL, 0, longint(@tr.chrg));
      end
     end else if (TextD=1)and(wParam=224)and(tr.chrg.cpMax-tr.chrg.cpMin=0) then
      begin
       if ins then
       begin
        makebackup(8,1);
        inc(tr.chrg.cpMax);
        CallWindowProc(Pointer(lpfnOldRTFProc),Window, EM_EXSETSEL, 0, Longint(@tr.chrg));
       end
         else makebackup(0,1);
       tr.lpstrText:=#160#0;
       CallWindowProc(Pointer(lpfnOldRTFProc),Window, EM_REPLACESEL, 0, longint(tr.lpstrText));
       exit;
      end;
     if ins then makebackup(8,1) else makebackup(0,1);
    end;
   end;
   if TextD>0 then
   begin
    if wParam>127 then
    begin
     wParam:=byte(Code[1, wParam]);
     if TextD=2 then wParam:=byte(Code[2, wParam]);
    end;
   end;
  end;
  wm_keyDown:
  begin
   case wParam of
    VK_CONTROL:
    begin
     if cp_m>=0 then
     begin
//      TextD:=cp_m;
//      SetFont;
      cp_m:=-1;
     end;
    end;
    vk_return:makebackup(1,2);
    vk_delete:if GetKeyState(VK_CONTROL)<0 then
     begin
      if not NoUndo then
      begin
       makebackup(5,0);
       exit
      end
     end
     else
     begin
      SendMessage(Window, EM_EXGETSEL, 0, longint(@tr.chrg));
      if tr.chrg.cpMax-tr.chrg.cpMin>2 then
      begin
       i:=tr.chrg.cpMin;
       tr.chrg.cpMin:=tr.chrg.cpMax-2;
       tr.lpstrText:=@chr_[0];
       SendMessage(Window, EM_GETTEXTRANGE, 0, longint(@tr));
       if chr_[1]=#10 then
       begin
        tr.chrg.cpMax := i - SendMessage(Window, EM_LINEINDEX,  SendMessage(Window, EM_EXLINEFROMCHAR, 0, i), 0);
        if tr.chrg.cpMax<>0 then
        begin
         tr.chrg.cpMax:=tr.chrg.cpMin;
         tr.chrg.cpMin:=i;
         SendMessage(Window, EM_EXSETSEL, 0, longint(@tr.chrg));
        end;
       end;
      end;
      if SendMessage(Window, EM_SELECTIONTYPE, 0, 0)<> SEL_EMPTY then
      begin
       makebackup(4,0);
       SendMessage(Window, WM_CLEAR, 0, 0);
       exit;
      end else makebackup(2,0);
     end;
    vk_back:if GetKeyState(VK_CONTROL)<0 then
     begin
      if not NoUndo then
      begin
       makebackup(7,0);
       exit
      end
     end
     else
     begin
      if SendMessage(Window, EM_SELECTIONTYPE, 0, 0)<> SEL_EMPTY then
      begin
       makebackup(4,0);
       SendMessage(Window, WM_CLEAR, 0, 0);
       exit;
      end else       makebackup(3,0);
     end;
    vk_insert:if GetKeyState(VK_CONTROL)>=0 then
     begin
      ins:=not ins;
      ins_upd;
     end
   end;
  end;
  wm_keyUp:
  begin
   UpdateCaretPos;
  end;
  wm_LButtonDown:PostMessage(MainWindow, wm_user+1,0,0);
  wm_RButtonDown:
   begin
    TrackPopupMenu(PopMenu[1],
    TPM_CENTERALIGN,LoWord(GetMessagePos()),HiWord(GetMessagePos()),
       0, MainWindow,nil);
    exit;
   end;
   WM_DropFiles:
    begin
     if DragQueryFile(wParam, 0, FileName, max_str) > 0 then
     begin
       DragFinish(wParam);
       if CheckSave then
       begin
        Open(FileName);
        exit;
       end;
     end;
    end;
   WM_INPUTLANGCHANGE://Внимание, есть глюк
   begin
    kbl_upd;
    exit;//не всегда срабатывает :(
   end;
 end;
 RTFProc:=CallWindowProc(Pointer(lpfnOldRTFProc),Window,Message,wParam,lParam);
end;

procedure TasmAbout(a,b:integer); external;{$L SAbout}

procedure UpdateToolbar;//где-то тут есть глюк
var
 tf:UINT;
begin
    if IsClipboardFormatAvailable(CF_TEXT) then
            tf:= TBSTATE_ENABLED else tf:= TBSTATE_INDETERMINATE;
    SendMessage(Tool,
                TB_SETSTATE,
                id_paste,
                MAKELONG(tf, 0));

    if SendMessage(RTF, EM_SELECTIONTYPE, 0, 0)<> SEL_EMPTY then tf:=TBSTATE_ENABLED else tf:= TBSTATE_INDETERMINATE;
    SendMessage(Tool,
                TB_SETSTATE,
                id_del,
                MAKELONG(tf, 0));
    SendMessage(Tool,
                TB_SETSTATE,
                id_cut,
                MAKELONG(tf, 0));
    SendMessage(Tool,
                TB_SETSTATE,
                id_copy,
                MAKELONG(tf, 0));
    if (SendMessage(RTF, EM_GETMODIFY, 0, 0)=0)or (not NoModify and (pUndo=nil)) then
        tf:=TBSTATE_INDETERMINATE else tf:=TBSTATE_ENABLED;
    SendMessage(Tool,
                TB_SETSTATE,
                id_save,
                MAKELONG(tf, 0));
    if NoUndo then
    begin
     if SendMessage(RTF, EM_CANUNDO, 0, 0) <> 0 then tf:=TBSTATE_ENABLED else tf:=TBSTATE_INDETERMINATE;
    end else
    begin
     if pUndo<>nil then tf:=TBSTATE_ENABLED else tf:=TBSTATE_INDETERMINATE;
    end;
    SendMessage(Tool,
                TB_SETSTATE,
                id_undo,
                MAKELONG(tf, 0));
    if WWrap=0 then  tf:=TBSTATE_ENABLED or TBSTATE_CHECKED else tf:=TBSTATE_ENABLED;
    SendMessage(Tool,
                TB_SETSTATE,
                id_wordwrap,
                MAKELONG(tf, 0));
end;

procedure DateTime;
var
 DT: TSystemTime;
 s:str32;
begin
 GetLocalTime(DT);
 GetDateFormat(LOCALE_USER_DEFAULT,0,@DT,nil,s,sizeOf(s));
 lstrcat(s,' ');
 MakeBackUp(4,lstrlen(s));
 SendMessage(RTF, EM_REPLACESEL, 0, Longint(@s));
 GetTimeFormat(LOCALE_USER_DEFAULT,0,@DT,nil,s,sizeOf(s));
 MakeBackUp(4, lstrlen(s));
 SendMessage(RTF, EM_REPLACESEL, 0, Longint(@s));
end;

function CharProcess(Dialog: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint; stdcall;
var
 i,j:integer;
 Data:THandle;
 DataPtr:PChar;
 FormatA:TCharFormat;
 CharRange: TCharRange;
 FileName: array[0..256]of char;
begin
  CharProcess := 1;
  case Message of
    wm_InitDialog:
    begin
      FileName[0]:=' ';
      j:=0;
      for i:=33 to 255 do
      begin
       if i mod 32=0 then
       begin
        inc(j);
        FileName[j]:=#13;
        inc(j);
        FileName[j]:=#10;
       end;
       inc(j);
       FileName[j]:=chr(i);
      end;
      FileName[256]:=#0;
      FillChar(FormatA, SizeOf(TCharFormat),0);
      with FormatA do
      begin
       cbSize := SizeOf(TCharFormat);
       dwMask:= integer(CFM_FACE or CFM_CHARSET or CFM_SIZE or CFM_BOLD or CFM_ITALIC or CFM_COLOR);
      end;
      SendMessage(RTF, EM_GETCHARFORMAT,
        SCF_SELECTION, Longint(@FormatA));
      SendDlgItemMessage(Dialog,101, EM_SETCHARFORMAT,
        SCF_ALL, Longint(@FormatA));
      SendDlgItemMessage(Dialog,101, EM_SETBKGNDCOLOR, 0, GetProfileInt_('Bk',GetSysColor(COLOR_WINDOW)));

      SendDlgItemMessage(Dialog,101, WM_SETTEXT, 0, Longint(@FileName[0]));
      Exit;
    end;
    wm_Command:
    case WParam and $ffff of
    id_Ok,102:
      begin
       SendDlgItemMessage(Dialog, 101, EM_EXGETSEL, 0, Longint(@CharRange));
       if CharRange.cpMax - CharRange.cpMin>0 then
       begin
         SendDlgItemMessage(Dialog, 101, EM_GETSELTEXT, 0, Longint(@FileName[0]));
         if wParam=102 then
         begin
          Data := GlobalAlloc(GHND or GMEM_DDESHARE, CharRange.cpMax - CharRange.cpMin+1);
          if Data<>0 then
          begin
           DataPtr := GlobalLock(Data);
           if DataPtr<>nil then
           begin
            i:=SendDlgItemMessage(Dialog, 101, EM_GETSELTEXT,
             0, Longint(DataPtr));
            if OpenClipboard(MainWindow)then
            begin
             EmptyClipboard;
             case TextD of //В NT проблемы. Нужен юникодовый контрол. :(
             0:SetClipboardData(CF_TEXT, Data);
             1:SetClipboardData(CF_OEMTEXT, Data);
             2:
             begin
              for i := 0 to i-1 do
               if DataPtr[i]>=#128 then
                DataPtr[i] := Code[3,byte(DataPtr[i])];
              SetClipboardData(CF_OEMTEXT, Data);
             end;
             end;
             CloseClipboard;
            end;
           end;
           GlobalUnlock(Data);
          end;
          EndDialog(Dialog, 1);
         end else SetFocus(GetDlgItem(Dialog,101));
         MakeBackUp(4, lstrlen(FileName));
         SendMessage(RTF, EM_REPLACESEL, 0, Longint(@FileName[0]));
       end;
       Exit;
      end;
    id_Cancel:
      begin
        EndDialog(Dialog, 1);
        Exit;
      end;
     end;
  end;
  CharProcess := 0;
end;

function GetPrinterDC:hDC ;
var
  PD:TPRINTDLG;
  lpM:PDEVMODE;
  lpN:PDEVNAMES;
begin
   result:=0;
   if (hDevNames_<>0)and(hDevMode_<>0) then
   begin
    lpN:=PDEVNAMES(GlobalLock(hDevNames_));
    lpM:=PDEVMODE(GlobalLock(hDevMode_));
    result := CreateDC(Pchar(lpN) + lpN^.wDriverOffset,
                  Pchar(lpN) + lpN^.wDeviceOffset,
                  nil,
                  lpM);
    GlobalUnLock(hDevNames_);
    GlobalUnLock(hDevMode_);
   end;
   if result = 0 then
   begin
    if hDevNames_<>0 then
    begin
     GlobalFree(hDevNames_);
     hDevNames_:=0;
    end;
    if hDevMode_<>0 then
    begin
     GlobalFree(hDevMode_);
     hDevMode_:=0;
    end;
    FillChar(PD,SizeOf(TPRINTDLG),0);
    pd.lStructSize := sizeof(TPRINTDLG);
    pd.Flags := PD_RETURNDEFAULT or PD_RETURNDC;
    pd.hDevMode:=hDevMode_;
    pd.hDevNames:=hDevNames_;

    if PrintDlg(pd) then
    begin
     result := pd.hDC;
     hDevMode_:=pd.hDevMode;
     hDevNames_:=pd.hDevNames;
    end;
   end;
end;

procedure EnumPage;//взято из M$ SDK, глючит
var
  Range: TFormatRange;
  rcTmp:TRect;
  ipg,lTextLength:integer;
  DC:hDC;
  ist:str32;
begin
   dc:=GetPrinterDC;
   ipg:=0;


   FillChar(Range, SizeOf(TFormatRange), 0);
   if dc>0 then
   with Range do
   begin
    EnableWindow(MainWindow, false);

    lTextLength := SendMessage(RTF, WM_GETTEXTLENGTH, 0, 0);
    hdc:=dc;
    hdcTarget := dc;

    rcPage.left   := 0;
    rcPage.top    := 0;
    rcPage.right  := MulDiv(GetDeviceCaps(dc, PHYSICALWIDTH),
                              1440,
                              GetDeviceCaps(dc, LOGPIXELSX));
    rcPage.bottom := MulDiv(GetDeviceCaps(dc, PHYSICALHEIGHT),
                              1440,
                              GetDeviceCaps(dc, LOGPIXELSY));

    CopyRect(rc, rcPage);
    if rcPage.right > MulDiv(FldRect.Left+
       FldRect.right,1440,2500) +1440 then
    begin
      rc.left := MulDiv(FldRect.Left,1440,2500);
      rc.right := rc.right - MulDiv(FldRect.right,1440,2500);
    end;

    if rcPage.bottom >MulDiv(FldRect.top+
         FldRect.bottom,1440,2500) +1440 then
    begin
      rc.top := MulDiv(FldRect.top,1440,2500);
      rc.bottom := rc.bottom - MulDiv(FldRect.bottom,1440,2500);
    end;

    CopyRect(rcTmp, rc);  // save for later

    chrg.cpMin := 0;
    chrg.cpMax := lTextLength;

    SendMessage(RTF, EM_FORMATRANGE, 0, 0);  // flush buffer
    repeat
     chrg.cpMin := SendMessage(RTF, EM_FORMATRANGE,0, longint(@Range));
     CopyRect(rc, rcTmp);
     inc(ipg);
    until (chrg.cpMin >= lTextLength)or (ipg>=512);

    DeleteDC(dc);

    SendMessage(RTF, EM_FORMATRANGE, 0, 0);  // flush buffer
    EnableWindow(MainWindow, TRUE);
   end;
   if (ipg>0)and(ipg<512) then wvsprintf(ist,'Total %u Page(s)',@ipg)
                      else lstrcpy(ist,'EnumPage() failed');
   Head:=MessageBox(MainWindow,'Include Number of Pages?',
     ist,mb_YesNo or MB_DEFBUTTON2 or MB_ICONQUESTION)= IdYes;
   if Head then CheckMenuItem(MainMenu,id_Header,
         MF_BYCOMMAND or MF_CHECKED)
                else CheckMenuItem(MainMenu,id_Header,
         MF_BYCOMMAND or MF_UNCHECKED);
end;

function ViewProcess(Dialog: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint; stdcall;
var
 pdi:PDRAWITEMSTRUCT;
 Range: TFormatRange;
 TempRc:TRect;
 FormatA:TCharFormat;
 OldDC,lTextLength,i,j,k:integer;
 sz:TSIZE;
 s1,s2:str255;
 cpp:TPOINT;
begin
  ViewProcess := 1;
  case Message of
    wm_InitDialog:
    begin
      CharPos:=0;
      NextPos:=0;
      ipage:=1;
      GetWindowText(MainWindow,s1,SizeOf(s1));
      s2:='PreView: ';
      lstrcat(s2,s1);
      SetWindowText(Dialog,s2);
      ShowWindow(Dialog,sw_Maximize);
      Exit;
    end;
    wm_Size:
    begin
     GetClientRect(GetDlgItem(Dialog,102),TempRc);
     k:=TempRc.Bottom;
     inc(k,4);
     if rcPage_.Right<=rcPage_.Bottom then
     begin
      j:=HIWORD(lparam)-k-2;
      i:=MulDiv(j,rcPage_.Right,rcPage_.Bottom);
     end
                                      else
     begin
      i:=LOWORD(lparam)-k;
      j:=MulDiv(i,rcPage_.Bottom,rcPage_.Right);
     end;
     MoveWindow(GetDlgItem(Dialog,104),
      (LOWORD(lParam)-i) div 2, k,
      i, j,
      false);
     InvalidateRect(Dialog,nil,true);
    end;

    wm_DrawItem:
    begin
     pdi:=PDRAWITEMSTRUCT(lParam);
     OldDC:=SaveDC(pdi^.hDC);
     FillRect(pdi^.hDC,pdi^.rcItem,GetStockObject(White_Brush));
     SetBkColor(pdi^.hDC,GetProfileInt_('Bk',GetSysColor(COLOR_WINDOW)));
     SetMapMode(pdi^.hDC,MM_ANISOTROPIC);
     SetWindowExtEx(pdi^.hdc,
      MulDiv(GetDeviceCaps(pdc,PHYSICALWIDTH),
       GetDeviceCaps(pdi^.hdc,LOGPIXELSX),GetDeviceCaps(pdc,LOGPIXELSX)) div Zoom,
        MulDiv(GetDeviceCaps(pdc,PHYSICALHEIGHT),
         GetDeviceCaps(pdi^.hdc,LOGPIXELSY),GetDeviceCaps(pdc,LOGPIXELSY)) div Zoom,nil);
     SetViewportExtEx(pdi^.hdc,pdi^.rcItem.right,pdi^.rcItem.bottom,nil);
     if Zoom<>1 then
     begin
      SetViewportOrgEx(pdi^.hdc,
       -tpp.x*(Zoom-1),
       -tpp.y*(Zoom-1),
       nil);
     end;
//--------------------------------------------------------------------------
     FillChar(Range, SizeOf(TFormatRange), 0);
     with Range do
     begin
      hdc:=pdi^.hdc;
      hdcTarget := pdc;
      CopyRect(rcPage, rcPage_);
      if HeadP then
      begin
       lTextLength:=wvsprintf(s1,'-%u-',@ipage);
       SetWindowText(GetDlgItem(Dialog,103),s1);
       GetTextExtentPoint32(pdc, s1, lTextLength,sz);
       TempRc.Left:=(RcPage_.Right - sz.cx)div 2;
       TempRc.Right:=rc_.Right;
       TempRc.Bottom:=rc_.Top;
       TempRc.Top := (rc_.Top-rcPage_.Top - sz.cy)div 2;
       CopyRect(rc, TempRc);
       chrg.cpMin := 0;
       chrg.cpMax := 20;
       FillChar(FormatA, SizeOf(TCharFormat),0);
       with FormatA do
       begin
        cbSize := SizeOf(TCharFormat);
        dwMask:= integer(CFM_FACE or CFM_CHARSET or CFM_SIZE or CFM_BOLD or CFM_ITALIC
         or CFM_COLOR);
       end;
       SendMessage(RTF, EM_GETCHARFORMAT,
         SCF_SELECTION, Longint(@FormatA));
       FormatA.yHeight:=0;
       SendDlgItemMessage(Dialog,103, EM_SETCHARFORMAT,
        SCF_ALL, Longint(@FormatA));
       SendDlgItemMessage(Dialog,103, EM_SETBKGNDCOLOR, 0, GetProfileInt_('Bk',GetSysColor(COLOR_WINDOW)));
       SendDlgItemMessage(Dialog,103, EM_FORMATRANGE, 0, 0);  // flush buffer
       SendDlgItemMessage(Dialog,103,
                               EM_FORMATRANGE,
                               1,
                               longint(@Range));
      end;
      CopyRect(rc, Rc_);
      lTextLength := SendMessage(RTF, WM_GETTEXTLENGTH, 0, 0);

      chrg.cpMin := CharPos;
      chrg.cpMax := lTextLength;

      SendMessage(RTF, EM_FORMATRANGE, 0, 0);  // flush buffer
      NextPos := SendMessage(RTF,
                               EM_FORMATRANGE,
                               1,
                               longint(@Range));
      EnableWindow(GetDlgItem(Dialog,102),NextPos<lTextLength);
      SendMessage(RTF, EM_FORMATRANGE, 0, 0);  // flush buffer
      if NextPos<lTextLength then wvsprintf(s1,'%u&.>>',@ipage)
                             else wvsprintf(s1,'%u ||',@ipage);
      SetWindowText(GetDlgItem(Dialog,102),s1);
     end;
//--------------------------------------------------------------------------
     RestoreDC(pdi^.hDC,OldDC);
     exit;
    end;
    wm_LButtonDown, wm_RButtonDown:
    begin
     cpp.x:=LOWORD(lParam);
     cpp.y:=HIWORD(lParam);
     ClientToScreen(Dialog,cpp);
     GetWindowRect(GetDlgItem(Dialog,104),TempRc);
     if PtInRect(TempRc,cpp) then
     begin
      Zoom:=4-Zoom;
      ScreenToClient(GetDlgItem(Dialog,104),cpp);
      tpp :=cpp;
      InvalidateRect(GetDlgItem(Dialog,104),nil,true);
     end;
     exit;
    end;
    wm_SetCursor:
    begin
     GetCursorPos(cpp);
     GetWindowRect(GetDlgItem(Dialog,104),TempRc);
     if PtInRect(TempRc,cpp) then
     begin
      if Zoom = 1 then SetCursor(ZoomIn) else SetCursor(ZoomOut);
      exit;
     end;
    end;
    wm_Command:
    case WParam and $ffff of
    101:
    begin
     CharPos:=0;
     ipage:=1;
     InvalidateRect(GetDlgItem(Dialog,104),nil,true);
     Exit;
    end;
    102:
    begin
     CharPos:=NextPos;
     inc(ipage);
     InvalidateRect(GetDlgItem(Dialog,104),nil,true);
     Exit;
    end;
    id_Ok,
    id_Cancel:
      begin
        EndDialog(Dialog, 1);
        Exit;
      end;
     end;
  end;
  ViewProcess := 0;
end;

procedure PreView;//взято из M$ SDK, глючит
begin
   pdc:=GetPrinterDC;
   if pdc>0 then
   begin
    rcPage_.left   := 0;
    rcPage_.top    := 0;
    rcPage_.right  := MulDiv(GetDeviceCaps(pdc, PHYSICALWIDTH),
                              1440,
                              GetDeviceCaps(pdc, LOGPIXELSX));
    rcPage_.bottom := MulDiv(GetDeviceCaps(pdc, PHYSICALHEIGHT),
                              1440,
                              GetDeviceCaps(pdc, LOGPIXELSY));
    CopyRect(rc_, rcPage_);
    if rcPage_.right > MulDiv(FldRect.Left+
       FldRect.right,1440,2500) +1440 then
    begin
      rc_.left := MulDiv(FldRect.Left,1440,2500);
      rc_.right := rc_.right - MulDiv(FldRect.right,1440,2500);
    end;

    if rcPage_.bottom >MulDiv(FldRect.top+
         FldRect.bottom,1440,2500) +1440 then
    begin
      rc_.top := MulDiv(FldRect.top,1440,2500);
      rc_.bottom := rc_.bottom - MulDiv(FldRect.bottom,1440,2500);
      HeadP:=Head;
    end else  HeadP:=false;
    Zoom:=1;
    ZoomIn:=LoadCursor(Instance,PChar(1));
    ZoomOut:=LoadCursor(Instance,PChar(2));
    DialogBoxParam(Instance, PCHAR(7), MainWindow, @ViewProcess,0);
    DeleteDC(pdc);
   end;
end;

procedure PageSetup;
var
 Dlg:TPAGESETUPDLG;
begin
 FillChar(Dlg,SizeOf(TPAGESETUPDLG),0);
 with Dlg do
 begin
    lStructSize:= SizeOf(TPAGESETUPDLG);
    hwndOwner:= MainWindow;
    hDevMode:=hDevMode_;
    hDevNames:=hDevNames_;
    Flags:=PSD_MARGINS;
    rtMargin:=FldRect;
  end;
 if PageSetupDlg(Dlg) then
 begin
        hDevMode_:= dlg.hDevMode;
        hDevNames_:= dlg.hDevNames;
        FldRect:=dlg.rtMargin;
 end;
end;

procedure Print;//взято из M$ SDK, глючит
var
  PD:TPRINTDLG;
  Range: TFormatRange;
  di:TDOCINFO;
  rcTmp,TempRc:TRect;
  nCollateCopies,i,ipg,j,lTextLength,l:integer;
  ist:str255;
  TempRTF:hWnd;
  sz:TSize;
  FormatA:TCharFormat;
  cr:TCharRange;
begin
  FillChar(PD,SizeOf(TPRINTDLG),0);
  pd.lStructSize := sizeof(TPRINTDLG);
  pd.hwndOwner   := MainWindow;
  pd.hDevMode    := hDevMode_;
  pd.hDevNames   := hDevNames_;
  pd.Flags       := PD_RETURNDC or PD_ALLPAGES;// or PD_NOPAGENUMS;
  with Range do
  begin
   SendMessage(RTF, EM_EXGETSEL, 0, longint(@chrg));
   if chrg.cpMax - chrg.cpMin <2 then pd.Flags:=pd.Flags or PD_NOSELECTION;
  end;
  pd.nFromPage   := $FFFF;
  pd.nToPage     := $FFFF;
  pd.nMaxPage    := $FFFF;
  pd.nMinPage    := 1;
  pd.nCopies     := 1;

  if PrintDlg(pd) then
  begin
    hDevMode_:= pd.hDevMode;
    hDevNames_:= pd.hDevNames;
    FillChar(di, sizeof(TDOCINFO),0);
    di.cbSize := sizeof(TDOCINFO);
    GetWindowText(MainWindow,ist,SizeOf(ist));
    di.lpszDocName := ist;
    if PD.Flags and PD_PRINTTOFILE<>0 then
     di.lpszOutput := 'FILE:';
    if StartDoc(pd.hdc, di)<=0 then
    begin
     DeleteDC(pd.hdc);
     exit;
    end;
    EnableWindow(MainWindow, false);

    if PD.Flags and PD_COLLATE<>0 then
    begin
        nCollateCopies := pd.nCopies;
        pd.nCopies := 1;
    end
    else
        nCollateCopies := 1;

   if PD.Flags and PD_PAGENUMS = 0 then pd.nToPage:=$ffff;
   FillChar(Range, SizeOf(TFormatRange), 0);
   with Range do
   begin
    hdc:=pd.hdc;
    hdcTarget := hdc;
    lTextLength := SendMessage(RTF, WM_GETTEXTLENGTH, 0, 0);

    rcPage.left   := 0;
    rcPage.top    := 0;
    rcPage.right  := MulDiv(GetDeviceCaps(hdc, PHYSICALWIDTH),
                              1440,
                              GetDeviceCaps(hdc, LOGPIXELSX));
    rcPage.bottom := MulDiv(GetDeviceCaps(hdc, PHYSICALHEIGHT),
                              1440,
                              GetDeviceCaps(hdc, LOGPIXELSY));

    CopyRect(rc, rcPage);
    if rcPage.right > MulDiv(FldRect.Left+
       FldRect.right,1440,2500) +1440 then
    begin
      rc.left := MulDiv(FldRect.Left,1440,2500);
      rc.right := rc.right - MulDiv(FldRect.right,1440,2500);
    end;
    TempRTF:=0;
    if rcPage.bottom >MulDiv(FldRect.top+
         FldRect.bottom,1440,2500) +1440 then
    begin
      rc.top := MulDiv(FldRect.top,1440,2500);
      rc.bottom := rc.bottom - MulDiv(FldRect.bottom,1440,2500);
      if Head then
      begin
       TempRTF:=CreateWindowEx(0,
                        RICHEDIT_CLASS10A,
                        nil,
                        WS_CHILD,
                        0, 0,
                        512,
                        255,
                        MainWindow,
                        0,
                        Instance,
                        nil );
       FillChar(FormatA, SizeOf(TCharFormat),0);
       with FormatA do
       begin
        cbSize := SizeOf(TCharFormat);
        dwMask:= integer(CFM_FACE or CFM_CHARSET or CFM_SIZE or CFM_BOLD or CFM_ITALIC
         or CFM_COLOR);
       end;
       SendMessage(RTF, EM_GETCHARFORMAT,
         SCF_SELECTION, Longint(@FormatA));
       FormatA.yHeight:=0;
       SendMessage(TempRTF, EM_SETBKGNDCOLOR, 0, GetProfileInt_('Bk',GetSysColor(COLOR_WINDOW)));
       SendMessage(TempRTF, EM_SETCHARFORMAT,
        SCF_ALL, Longint(@FormatA));
      end;
    end;

    CopyRect(rcTmp, rc);  // save for later

    for i := 1 to nCollateCopies do
    begin
        ipg:=1;

        // Set range for the entire document (default)
        chrg.cpMin := 0;
        chrg.cpMax := lTextLength;

        // Are we only printing the current selection?
        if PD.Flags and PD_SELECTION<>0 then
        begin
            SendMessage(RTF, EM_EXGETSEL, 0, longint(@chrg));
            if chrg.cpMax >= chrg.cpMin then
                lTextLength := chrg.cpMax;    // don't go past this character
        end;
        SendMessage(RTF, EM_FORMATRANGE, 0, 0);  // flush buffer

        repeat
         if TempRTF<>0 then
         begin
          cr:=chrg;
          l:=wvsprintf(ist,'-%u-',@ipg);
          SetWindowText(TempRTF,ist);
          GetTextExtentPoint32(hdc, ist, l,sz);
          TempRc.Left:=(RcPage.Right - sz.cx)div 2;
          TempRc.Right:=rc.Right;
          TempRc.Bottom:=rc.Top;
          TempRc.Top := (rc.Top-rcPage.Top - sz.cy)div 2;
          CopyRect(rc, TempRc);
          chrg.cpMin := 0;
          chrg.cpMax := l;
          SendMessage(TempRTF, EM_FORMATRANGE, 0, 0);  // flush buffer
          SendMessage(TempRTF,
                               EM_FORMATRANGE,
                               0,
                               longint(@Range));
          chrg:=cr;
          CopyRect(rc, RcTmp);
         end;
           chrg.cpMin := SendMessage(RTF,
                                        EM_FORMATRANGE,
                                        0,      // FALSE ==> format only (don't print)
                                        longint(@Range));
           if not((PD.Flags and PD_PAGENUMS<>0)
                    and (ipg < pd.nFromPage)) then
           begin
            for j := 1 to pd.nCopies do
                begin
                    StartPage(hdc);
                    if TempRTF<>0 then
                    begin
                     CopyRect(rc, TempRC);
                     SendMessage(TempRTF,
                                EM_DISPLAYBAND,
                                0,
                                Longint(@Range.rc));
                      CopyRect(rc, RcTmp);
                    end;
                    SendMessage(RTF,
                                EM_DISPLAYBAND,
                                0,
                                Longint(@Range.rc));
                    EndPage(hdc);
                end;
           end;
           CopyRect(rc, rcTmp);  // EM_FORMATRANGE tends to modify rc.bottom, reset here
           inc(ipg);
           // Are we done?
        until (chrg.cpMin >= lTextLength) or (ipg > pd.nToPage);

    end;   // collate loop
    EndDoc(pd.hdc);
    DeleteDC(pd.hdc);
    If TempRTF<>0 then DestroyWindow(TempRTF);
    SendMessage(RTF, EM_FORMATRANGE, 0, 0);  // flush buffer
    EnableWindow(MainWindow, TRUE);
   end;
  end;
end;
//Сделайте нормальный HEX EDITOR. Если надо :)
function HackProcess(Dialog: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint; stdcall;

var
  st: array[0..max_str] of char;
  f,l,v,fl,newb:integer;
  oldb,b:byte;
procedure HexVal(const st:PChar;var v,b:integer);
begin
       b:=0;
       v:=0;
       while (st[b]>#0)and(b<8) do
       begin
        case st[b] of
        '0'..'9':v:=v shl 4+byte(st[b])-48;
        'A'..'F':v:=v shl 4+byte(st[b])-byte('A')+10;
        'a'..'f':v:=v shl 4+byte(st[b])-byte('a')+10;
          else exit;
        end;
        inc(b);
       end;
       b:=0;
end;

begin
  HackProcess := 1;
  case Message of
    wm_InitDialog:
    begin
      st:='Change byte: ';
      GetFileTitle(HackFileName, @st[13], max_str-14);
      SetWindowText(Dialog,st);
      Exit;
    end;
    wm_Command:
    case LoWord(WParam) of
    201:if (hiWord(wParam)=EN_SETFOCUS)or (hiWord(wParam)=EN_CHANGE) then
      begin
       f:= _lOpen(HackFileName, OF_READ);
       GetWindowText(GetDlgItem(Dialog,201),st,SizeOf(st));
       HexVal(st,v,l);
       if l=0 then
       begin
        fl:= GetFileSize(f,nil);
        if v<=fl then
        if _llseek(f,v,FILE_BEGIN)<>-1 then
        if _lread(f,@b,1)<>HFILE_ERROR then
        begin
         l:=b mod 16;
         b:=b shr 4;
         if b>9 then st[0]:=chr(b+byte('A')-10) else st[0]:=chr(b+48);
         if l>9 then st[1]:=chr(l+byte('A')-10) else st[1]:=chr(l+48);
         st[2]:=#0;
         SetWindowText(GetDlgItem(Dialog,211),st);
         EnableWindow(GetDlgItem(Dialog,103),true);
         _lclose(f);
         exit;
        end
       end;
       _lclose(f);
       EnableWindow(GetDlgItem(Dialog,103),false);
       SetWindowText(GetDlgItem(Dialog,211),'ERROR');
       Exit;
      end;
    103:
      begin
       f:= _lOpen(HackFileName, OF_READWRITE);
       if F = -1 then
       begin
         SetWindowText(GetDlgItem(Dialog,211),'ERROR');
         exit;
       end;
       GetWindowText(GetDlgItem(Dialog,201),st,SizeOf(st));
       HexVal(st,v,l);
       if l=0 then
       begin
        fl:= GetFileSize(f,nil);
        if v<=fl then
        if _llseek(f,v,FILE_BEGIN)<>-1 then
        if _lread(f,@oldb,1)<>HFILE_ERROR then
        begin
         GetWindowText(GetDlgItem(Dialog,211),st,SizeOf(st));
         HexVal(st,newb,l);
         b:=byte(newb);
         if (l=0)and(b<>oldb) then
         begin
          if MESSAGEBOX(Dialog, 'Are you sure?', WinName,MB_YESNO or MB_ICONQUESTION)=id_YES then
          begin
           _llseek(f,v,FILE_BEGIN);
           _lwrite(f,@b,1);
          end
         end else EnableWindow(GetDlgItem(Dialog,103),false);
         _lclose(f);
         exit;
        end
       end;
       _lclose(f);
       SetWindowText(GetDlgItem(Dialog,211),'ERROR');
       Exit;
      end;
    id_Cancel:
      begin
        EndDialog(Dialog, 1);
        Exit;
      end;
     end;
  end;
  HackProcess := 0;
end;

procedure Hack;
var
 OpenFN: TOpenFileName;
begin
  HackFileName:='';
  FillChar(OpenFN, SizeOf(TOpenFileName),0);
  with OpenFN do
     begin
      hwndOwner     := MainWindow;
      lpstrFilter   := 'EXE Files (*.exe)'#0'*.exe'#0'All Files (*.*)'#0'*.*'#0;
      lStructSize   := sizeof(TOpenFileName);
      lpstrFile     := HackFileName;
      nMaxFile      := SizeOf(HackFileName);
      lpstrDefExt   := 'exe';
      flags         := OFN_EXPLORER
                      or OFN_FILEMUSTEXIST or
                       OFN_NOREADONLYRETURN or OFN_HIDEREADONLY;
  end;
  if GetOpenFileName(OpenFN) then
  begin
   DialogBoxParam(Instance, PCHAR(2), MainWindow, @HackProcess, 0);
  end;
end;


function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
begin
  SendDlgItemMessage(longint(Data),101,cb_AddString,0,Longint(@LogFont.lfFaceName));
  inc(maxc);
  if lstrcmpi(Font_,LogFont.lfFaceName)=0 then
   SendDlgItemMessage(longint(Data),101,cb_setcursel, maxc, 0);
  Result := 1;
end;

function UserFont(Dialog: HWnd; Message, WParam: Longint;
   LParam: Longint): Longint; stdcall;
var
 i,j:integer;
 s__:str32;
 DC:hDC;
 FormatA:TCharFormat;
const
 css:array[0..2] of PChar = ('RUSSIAN_CHARSET', 'OEM_CHARSET', 'DEFAULT_CHARSET');
begin
  Result := 1;
  case Message of
    wm_InitDialog:
    begin
     maxc:=0;
     s__:='';//Не убирать
     SendDlgItemMessage(Dialog,101,cb_AddString,0,Longint(@s__[0]));//Не убирать
     DC := GetDC(0);
     EnumFontFamilies(DC, nil, @EnumFontsProc, Dialog);
     ReleaseDC(0, DC);
     for i:=0 to 2 do
     begin
      SendDlgItemMessage(Dialog,102,cb_AddString,0,Longint(css[i]));
      if charsets[i]=Set_ then SendDlgItemMessage(Dialog,102,cb_setcursel, i, 0)
     end;
     for i:=1 to 20 do
     begin
      wvsprintf(s__,'%u',@i);
      SendDlgItemMessage(Dialog,103,cb_AddString,0,Longint(@s__[0]));
      if i=FHeight div 20 then
       SendDlgItemMessage(Dialog,103,cb_setcursel, i-1, 0)
     end;
     FillChar(FormatA, SizeOf(TCharFormat),0);
     with FormatA do
     begin
      yHeight:=FHeight;
      cbSize := SizeOf(TCharFormat);
      dwMask:= integer(CFM_FACE or CFM_CHARSET or CFM_SIZE or CFM_BOLD or CFM_ITALIC
       or CFM_COLOR);
      crTextColor:=GetProfileInt_('Cl',COLOR_WINDOWTEXT);
      dwEffects:=Effects;
      bCharSet:=Set_;
      lstrcpy(szFaceName,Font_);
      if szFaceName[0]=#0 then bPitchAndFamily:= FF_MODERN;
     end;
     SendDlgItemMessage(Dialog, 100, EM_SETCHARFORMAT,
        SCF_ALL, Longint(@FormatA));
     SendDlgItemMessage(Dialog,100, EM_SETBKGNDCOLOR, 0, GetProfileInt_('Bk',GetSysColor(COLOR_WINDOW)));
     if Effects and CFE_BOLD>0 then SendDlgItemMessage(Dialog,104,bm_setCheck,1,0);
     if Effects and CFE_ITALIC>0 then SendDlgItemMessage(Dialog,105,bm_setCheck,1,0);

     SetWindowText(GetDlgItem(Dialog,100), HackFileName);
     Exit;
    end;
    wm_Command:
      case LoWord(WParam) of
       101..105:
       begin
        GetWindowText(GetDlgItem(Dialog,101),s__,sizeOf(s__));
        FillChar(FormatA, SizeOf(TCharFormat),0);
        with FormatA do
        begin
         cbSize := SizeOf(TCharFormat);
         yHeight:=(1+SendDlgItemMessage(Dialog,103,cb_getcursel, 0, 0))*20;
         bCharSet:=charsets[SendDlgItemMessage(Dialog,102,cb_getcursel, 0, 0)];
         dwMask:= integer(CFM_FACE or CFM_CHARSET or CFM_SIZE or CFM_BOLD or CFM_ITALIC);
         lstrcpy(szFaceName,s__);
         if szFaceName[0]=#0 then bPitchAndFamily:= FF_MODERN;
         if SendDlgItemMessage(Dialog,104,bm_getCheck,0,0)<>0
          then dwEffects:=CFE_BOLD;
         if SendDlgItemMessage(Dialog,105,bm_getCheck,0,0)<>0
          then dwEffects:=dwEffects or CFE_ITALIC;
        end;
        SendDlgItemMessage(Dialog, 100, EM_SETCHARFORMAT,
          SCF_ALL, Longint(@FormatA));
        exit;
       end;
       id_Ok:
       begin
        GetWindowText(GetDlgItem(Dialog,101),s__,sizeOf(s__));
        FHeight:=(1+SendMessage(GetDlgItem(Dialog,103),cb_getcursel, 0, 0))*20;
        j:=SendDlgItemMessage(Dialog,102,cb_getcursel, 0, 0);
        Set_:=charsets[j];
        Font_:=s__;
        if SendDlgItemMessage(Dialog,104,bm_getCheck,0,0)<>0
          then Effects:=CFE_BOLD else Effects:=0;
        if SendDlgItemMessage(Dialog,105,bm_getCheck,0,0)<>0
          then Effects:=Effects or integer(CFE_ITALIC);
        EndDialog(Dialog, 1);
        Exit;
       end;
       id_Cancel:
       begin
        EndDialog(Dialog, 2);
        Exit;
       end;
      end;
  end;
  Result := 0;
end;

procedure FontClick(id:integer);
var
i:integer;
begin
  FHeight:= GetProfileInt_(s2_[id],200);
  Effects:=GetProfileInt_(s3_[id],0);
  Set_:= GetProfileInt_(s4_[id],charsets[id]);
  GetProfileString_(s5_[id],Font_,sizeOf(Font_));
  for i:=0 to 77 do
  begin
   HackFileName[i]:=q1[i];
   if 1<>id  then
    if q1[i]>=#128 then HackFileName[i]:=Code[id,byte(q1[i])];
  end;
  if DialogBoxParam(Instance, PChar(4), MainWindow, @UserFont,0)=1 then
  begin
        WriteProfileString_(s5_[id],Font_);
        WriteProfileInt_(s4_[id],Set_);
        WriteProfileInt_(s3_[id],Effects);
        WriteProfileInt_(s2_[id],FHeight);
        SetFont;
  end
end;
//Все кодировки
procedure Coding(const id,cp1,cp2:integer);
var
 m1,m2:TMemRec;
 i,k,l,j: Integer;
 CharRange,Cr:TCHARRANGE;
 v:Integer;
 AllText:boolean;
var
 WordCount, Ri, Li, WordSpace, Space, Fi, TempLi, WordLen:integer;
 Ignore:boolean;
label
 asshole, penis, hole, null,asshole2;
function Delitimer(c:Char):boolean;
begin
 result:=(c=#0)or(c=#9)or(c=#32)or(c=#13) or (c=#10);
end;

begin
       SendMessage(RTF, WM_SETREDRAW, 0, 0);
       SendMessage(RTF, EM_EXGETSEL, 0, Longint(@CharRange));
       i:= CharRange.cpMax - CharRange.cpMin;
       j:=SendMessage(RTF, EM_GETFIRSTVISIBLELINE, 0, 0);
       AllText:=i=0;
       if (i=0)or(id=id_RTF) then
       begin
        CR.cpMin:=0;
        CR.cpMax:=SendMessage(RTF,WM_GETTEXTLENGTH, 0, 0);
        i:=Cr.cpMax;
        SendMessage(RTF, EM_EXSETSEL, 0, Longint(@CR));
       end else if (id=id_justify)or (id=id_center)or (id=id_left)or (id=id_right) then
       begin
        Cr.cpMax:= SendMessage(RTF, EM_EXLINEFROMCHAR, 0, CharRange.cpMin);
        Cr.cpMin := CharRange.cpMin - SendMessage(RTF, EM_LINEINDEX, Cr.cpMax, 0);
        if Cr.cpMin>0 then
        begin
         CharRange.cpMin:=CharRange.cpMin-Cr.cpMin;
         Cr.cpMax:= SendMessage(RTF, EM_EXLINEFROMCHAR, 0, CharRange.cpMax);
         v:=SendMessage(RTF, EM_LINEINDEX, Cr.cpMax, 0);
         Cr.cpMin := CharRange.cpMax - v;
         k:=SendMessage(RTF, EM_LINELENGTH, v, 0);
         if Cr.cpMin<k then CharRange.cpMax:=CharRange.cpMax+k-Cr.cpMin;
         SendMessage(RTF, EM_EXSETSEL, 0, Longint(@CharRange));
         i:= CharRange.cpMax - CharRange.cpMin;
        end;
       end;
       if i=0 then goto AssHole2;
       m2.Handle:=0;
       m1.Handle:= GlobalAlloc(GPTR,i+2);
       if m1.Handle=0 then goto AssHole2;
       m1.MemSize:=SendMessage(RTF, EM_GETSELTEXT, 0, Longint(m1.MemStream));

       case id of
           id_toWin,id_toDos,id_toKoi8,id_Fido,id_other:
           begin
            if cp1>=0 then for i := 0 to m1.MemSize-1 do
              if byte(m1.MemStream[i])>=128 then
                m1.MemStream[i] := Code[cp1,byte(m1.MemStream[i])];
            if (cp2>=0)and(cp2<=7) then for i := 0 to m1.MemSize-1 do
              if byte(m1.MemStream[i])>=128 then
                m1.MemStream[i] := Code[cp2,byte(m1.MemStream[i])];
            if cp2=9 then
            for i := 0 to m1.MemSize-1 do
             case byte(m1.MemStream[i]) of
              $E0:m1.MemStream[i] := 'p';
              $8D:m1.MemStream[i] := 'H';
             end;
            if AllText and (id<>id_other) then
              begin
               MakeBackUp(6, m1.MemSize);
               TextD:=id-id_toWin;
               if id=id_fido then TextD:=1;
               SetFont_;
              end else MakeBackUp(4, m1.MemSize);
            SetRTFText(@m1,SF_TEXT or SFF_SELECTION);
            SendMessage(RTF, EM_EXSETSEL, 0, Longint(@CharRange));
           end;
         id_Translit:
         begin
           m2.Handle:= GlobalAlloc(GPTR, i*2+1);
           if m2.Handle=0 then goto penis;
           m2.MemSize:=-1;
           if TextD<>1 then for i :=0 to m1.MemSize-1 do
              if byte(m1.MemStream[i])>=128 then
                m1.MemStream[i] := Code[cp_1[TextD],byte(m1.MemStream[i])];
           for i := 0 to m1.MemSize do
           begin
            inc(m2.MemSize);
            if byte(m1.MemStream[i])>=128 then
            begin
              m2.MemStream[m2.MemSize] :=Code[8,byte(m1.MemStream[i])];
              case byte(m1.MemStream[i]) of
              134,151..153:begin inc(m2.MemSize);m2.MemStream[m2.MemSize] :='H'end;
              166,231..233:begin inc(m2.MemSize);m2.MemStream[m2.MemSize] :='h'end;
              158:begin inc(m2.MemSize);m2.MemStream[m2.MemSize] :='U'end;
              238:begin inc(m2.MemSize);m2.MemStream[m2.MemSize] :='u'end;
              159:begin inc(m2.MemSize);m2.MemStream[m2.MemSize] :='A'end;
              239:begin inc(m2.MemSize);m2.MemStream[m2.MemSize] :='a'end;
              end;
            end
                                         else
              m2.MemStream[m2.MemSize] :=m1.MemStream[i];
           end;
           MakeBackUp(4, m2.MemSize);
           SetRTFText(@m2,SF_TEXT or SFF_SELECTION);
           CharRange.cpMax:=CharRange.cpMin+m2.MemSize;
           SendMessage(RTF, EM_EXSETSEL, 0, Longint(@CharRange));
         end;
       id_RTF:if (m1.MemStream[0]='{')and (m1.MemStream[1]='\')and (m1.MemStream[2]='r')
        and (m1.MemStream[3]='t')and (m1.MemStream[4]='f') then
         begin
            ShowWindow(RTF,sw_hide);
            MakeBackUp(6, 0);
            SetRTFText(@m1,SF_RTF);
            SendMessage(RTF, EM_SETSEL, 0, 0);
            if WWrap = 0 then
              WWrap:=ES_AUTOHSCROLL or WS_HSCROLL
                         else
              WWrap:=0;
            SetWWrap;
         end;

       id_Quoted:begin
          m2.Handle:= GlobalAlloc(GPTR, i*2+1);
          if m2.Handle=0 then goto penis;
          m2.MemSize:=-1;
          i := 0;
          while i<=m1.MemSize do
          begin
             inc(m2.MemSize);
             if m1.MemStream[i]='=' then
             begin
              v:=0;
              for k:=1 to 2 do
              begin
               case m1.MemStream[i+k] of
               '0'..'9':v:=v shl 4+byte(m1.MemStream[i+k])-48;
               'A'..'F':v:=v shl 4+byte(m1.MemStream[i+k])-byte('A')+10;
                else goto Asshole;
               end
              end;
              inc(i,2);
              m2.MemStream[m2.MemSize] := chr(v);
             end
                                  else
AssHole:     m2.MemStream[m2.MemSize] :=m1.MemStream[i];
             inc(i);
          end;
          MakeBackUp(4, m2.MemSize);
          SetRTFText(@m2,SF_TEXT or SFF_SELECTION);
          CharRange.cpMax:=CharRange.cpMin+m2.MemSize;
          SendMessage(RTF, EM_EXSETSEL, 0, Longint(@CharRange));
         end;
        id_Break:begin
            m2.Handle:= GlobalAlloc(GPTR, i*2+1);
            if m2.Handle=0 then goto penis;
            m2.MemSize:=-1;
            for i := 0 to m1.MemSize do
            begin
             inc(m2.MemSize);
             m2.MemStream[m2.MemSize]:=m1.MemStream[i];
             if (m1.MemStream[i]=#13)and(m1.MemStream[i+1]<>#10) then
             begin
              inc(m2.MemSize);
              m2.MemStream[m2.MemSize] :=#10;
             end;
            end;
            MakeBackUp(4, m2.MemSize);
            SetRTFText(@m2,SF_TEXT or SFF_SELECTION);
            CharRange.cpMax:=CharRange.cpMin+m2.MemSize;
            SendMessage(RTF, EM_EXSETSEL, 0, Longint(@CharRange));
           end;
      id_justify, id_center, id_left, id_right:
      begin
           m2.Handle:= GlobalAlloc(GPTR, i*8+$ffff);
           if m2.Handle=0 then goto penis;
           m2.MemSize:=-1;
           Ignore:=GetProfileInt_('IG',0)<>0;
           Li:=GetProfileInt_('LI',0);
           Fi:=GetProfileInt_('FI',0);
           Ri:=GetProfileInt_('RI',80);
           if id=id_center then Fi:=Li;
           if li>=ri-8 then li:=0;
           if fi>=ri-8 then fi:=0;

           TempLi:=Fi;
           for k:=Fi downto 1 do
           begin
            inc(m2.MemSize);
            m2.MemStream[m2.MemSize] :=' ';
           end;
           i:=0;
           while i<m1.MemSize do
           begin
            if Fi<0 then
            begin
             for k:=Li downto 1 do
             begin
              inc(m2.MemSize);
              m2.MemStream[m2.MemSize] :=' ';
             end;
             TempLi:=Li;
            end else Fi:=-1;

            WordCount:=0;
            WordLen:=0;
            k:=i;
            while (k<m1.MemSize-1)and(WordLen+WordCount-1<=Ri-TempLi) do
            begin
             while (k<m1.MemSize-1)and Delitimer(m1.MemStream[k]) do
             begin
              inc(k);
              if not Ignore then
               if (m1.MemStream[k]=#10) then goto Null;
             end;
             if k<m1.MemSize-1 then inc(WordCount);
             while (k<m1.MemSize-1)and not Delitimer(m1.MemStream[k]) do
             begin
              inc(k);
              inc(WordLen);
             end;
            end;
Null:       if (WordLen+WordCount-1>Ri-TempLi)and(WordCount>1) then
            begin
             dec(WordCount);
             while (k>0) and Delitimer(m1.MemStream[k]) do
              dec(k);
             while (k>0) and not Delitimer(m1.MemStream[k]) do
             begin
               dec(k);
               dec(WordLen);
             end;
            end;
            WordSpace:=Ri-TempLi-WordLen-WordCount+1;
            case id of
  id_justify:
            begin
             Space:=0;
             if (WordSpace>0)and(WordCount>1)and(k<m1.MemSize-1) then
             begin
              Space:=WordSpace mod (WordCount-1);
              WordSpace:=WordSpace div (WordCount-1)+1;
             end
               else
              WordSpace:=1;
             while i<=k do
             begin
              while (i<=k)and Delitimer(m1.MemStream[i]) do inc(i);
              if (i<=k)and not Delitimer(m1.MemStream[i]) then dec(WordCount);
              while (i<=k)and not Delitimer(m1.MemStream[i]) do
              begin
               inc(m2.MemSize);
               m2.MemStream[m2.MemSize] :=m1.MemStream[i];
               inc(i);
              end;
              if (WordCount>0)and(i<k) then
              begin
               for v:=1 to WordSpace do
               begin
                inc(m2.MemSize);
                m2.MemStream[m2.MemSize] :=' ';
               end;
               if Space>0 then
               begin
                inc(m2.MemSize);
                m2.MemStream[m2.MemSize] :=' ';
                dec(Space);
               end;
              end;
             end;
            end;
    id_center:
            begin
             for v:=WordSpace div 2 downto 1 do
             begin
               inc(m2.MemSize);
               m2.MemStream[m2.MemSize] :=' ';
             end;
             goto Hole;
            end;
      id_left:goto Hole;
      id_right:
            begin
             for v:=WordSpace downto 1 do
             begin
               inc(m2.MemSize);
               m2.MemStream[m2.MemSize] :=' ';
             end;
Hole:        while i<=k do
             begin
              while (i<=k)and Delitimer(m1.MemStream[i]) do inc(i);
              if (i<=k)and not Delitimer(m1.MemStream[i]) then dec(WordCount);
              while (i<=k)and not Delitimer(m1.MemStream[i]) do
              begin
               inc(m2.MemSize);
               m2.MemStream[m2.MemSize] :=m1.MemStream[i];
               inc(i);
              end;
              if (WordCount>0)and(i<k) then
              begin
                inc(m2.MemSize);
                m2.MemStream[m2.MemSize] :=' ';
              end;
             end;
            end;
            end;
            inc(m2.MemSize);
            m2.MemStream[m2.MemSize] :=#13;
            inc(m2.MemSize);
            m2.MemStream[m2.MemSize] :=#10;
           end;
           inc(m2.MemSize);
           MakeBackUp(4, m2.MemSize);
           SetRTFText(@m2,SF_TEXT or SFF_SELECTION);
           CharRange.cpMax:=CharRange.cpMin;
           SendMessage(RTF, EM_EXSETSEL, 0, Longint(@CharRange));
         end;

           end;{case}
          if m2.Handle<>0 then
         GlobalFree(m2.Handle);
penis:   GlobalFree(m1.Handle);
AssHole2:l:=SendMessage(RTF, EM_GETFIRSTVISIBLELINE, 0, 0);
         if l>j then
          SendMessage(RTF, EM_LineScroll, 0, j-l);
         SendMessage(RTF, WM_SETREDRAW, 1, 0);
         InvalidateRect(RTF, nil, false);
end;

function Cod(Dialog: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint; stdcall;
var
 i, j:integer;
begin
  result := 1;
  case Message of
    wm_InitDialog:
    begin
     for i:=cp_n downto 0 do
     begin
      SendDlgItemMessage(Dialog,101,lb_insertString,0,Longint(s1_[i]));
      SendDlgItemMessage(Dialog,102,lb_insertString,0,Longint(s1_[i]));
     end;
     SendDlgItemMessage(Dialog,101,lb_setcursel, getprofileint_('CP1',0), 0);
     SendDlgItemMessage(Dialog,102,lb_setcursel, getprofileint_('CP2',2), 0);
    end;
    wm_Command:
    case WParam and $ffff of
    id_Ok:
      begin
       i:=SendDlgItemMessage(Dialog,101,lb_getcursel, 0, 0);
       j:=SendDlgItemMessage(Dialog,102,lb_getcursel, 0, 0);
       writeprofileint_('CP1',i);
       writeprofileint_('CP2',j);
       Coding(id_other, cp_1[i], cp_2[j]);
       EndDialog(Dialog, 1);
       Exit;
      end;
    id_Cancel:
      begin
        EndDialog(Dialog, 2);
        Exit;
      end;
     end;
  end;
  result := 0;
end;

procedure HTML_refresh;//Richedit не годится для этого
var
 CF:TCHARFORMAT;
 CR, CharRange:TCHARRANGE;
 m1{,m2}:TMemRec;
 mmm, i,j,k:integer;
begin
        CharRange.cpMin:=0;
        CharRange.CpMax:=SendMessage(RTF,WM_GETTEXTLENGTH, 0, 0);
//        SendMessage(RTF, EM_EXGETSEL, 0, longint(@CharRange));
        if CharRange.CpMax<2 then exit;
        m1.Handle:= GlobalAlloc(GPTR,CharRange.CpMax+1);
        if m1.Handle=0 then exit;
        SendMessage(RTF, WM_SETREDRAW, 0, 0);
//        EnableWindow(RTF, false);
        mmm:=SendMessage(RTF, EM_GETMODIFY, 0, 0);
        j:=SendMessage(RTF, EM_GETFIRSTVISIBLELINE, 0, 0);
        SendMessage(RTF, EM_EXGETSEL, 0, longint(@CR));
        SendMessage(RTF, EM_EXSETSEL, 0, longint(@CharRange));
        m1.MemSize:=SendMessage(RTF, EM_GETSELTEXT, 0, Longint(m1.MemStream));
        FillChar(CF, SizeOf(TCharFormat),0);
        with CF do
        begin
         cbSize := SizeOf(TCharFormat);
         dwMask:= CFM_COLOR;
        end;
        SendMessage(RTF, EM_SETCHARFORMAT, SCF_SELECTION, longint(@CF));
        CF.crTextColor := GetProfileInt_('HTML', RGB(0,0,255));
        i := 0;
        while i<= m1.MemSize-1 do
        begin
         if m1.MemStream[i]='<' then
         begin
          CharRange.cpMin:=i;
          while i<= m1.MemSize-1 do
          begin
           inc(i);
           if (m1.MemStream[i]='>') then
           begin
            CharRange.cpMax:=i+1;
            SendMessage(RTF, EM_EXSETSEL, 0, longint(@CharRange));
            SendMessage(RTF, EM_SETCHARFORMAT, SCF_SELECTION, longint(@CF));
            break
           end else
           if (m1.MemStream[i]='<') then
           begin
            CharRange.cpMin:=i;
           end;
          end;
         end;
         inc(i);
        end;
        SendMessage(RTF, EM_EXSETSEL, 0, longint(@CR));
        SendMessage(RTF, EM_SETMODIFY, mmm, 0);
        k:=SendMessage(RTF, EM_GETFIRSTVISIBLELINE, 0, 0);
        if k>j then
         SendMessage(RTF, EM_LineScroll, 0, j-k);
//        EnableWindow(RTF, true);
        SendMessage(RTF, WM_SETREDRAW, 1, 0);
        InvalidateRect(RTF, nil, true);
        GlobalFree(m1.Handle);
end;

procedure Cl;
var
  Cl:TCHOOSECOLOR;
  acrCustClr:array[0..16]of ColorRef;
  FormatA:TCharFormat;
  i:integer;
begin
       FillChar(acrCustClr,sizeOf(acrCustClr),0);
       for i:=16 downto 0 do acrCustClr[i]:=GetSysColor(i);
       FillChar(Cl,sizeOf(TCHOOSECOLOR),0);
       cl.lStructSize:=sizeOf(TCHOOSECOLOR);
       cl.hwndOwner:=MainWindow;
       cl.rgbResult:=GetProfileInt_('Cl',COLOR_WINDOWTEXT);
       cl.lpCustColors:=@acrCustClr;
       cl.Flags:=CC_FULLOPEN or CC_RGBINIT;
       if ChooseColor(Cl) then
       begin
        WriteProfileInt_('Cl',Cl.rgbResult);
        FillChar(FormatA, SizeOf(TCharFormat),0);
        with FormatA do
        begin
         cbSize := SizeOf(TCharFormat);
         dwMask:=CFM_COLOR;
         crTextColor := Cl.rgbResult;
        end;
        SendMessage(RTF, EM_SETCHARFORMAT,
         SCF_ALL, LPARAM(@FormatA));
       end;
end;

procedure HTML;
var
  Cl:TCHOOSECOLOR;
  acrCustClr:array[0..16]of ColorRef;
  i:integer;
begin
       FillChar(acrCustClr,sizeOf(acrCustClr),0);
       for i:=16 downto 0 do acrCustClr[i]:=GetSysColor(i);
       FillChar(Cl,sizeOf(TCHOOSECOLOR),0);
       cl.lStructSize:=sizeOf(TCHOOSECOLOR);
       cl.hwndOwner:=MainWindow;
       cl.rgbResult:=GetProfileInt_('HTML',RGB(0,0,255));
       cl.lpCustColors:=@acrCustClr;
       cl.Flags:=CC_FULLOPEN or CC_RGBINIT;
       if ChooseColor(Cl) then
       begin
        WriteProfileInt_('HTML',Cl.rgbResult);
        HTML_refresh;
       end;
end;

procedure Bk;
var
  Cl:TCHOOSECOLOR;
  acrCustClr:array[0..16]of ColorRef;
  i:integer;
begin
       FillChar(acrCustClr,sizeOf(acrCustClr),0);
       for i:=16 downto 0 do acrCustClr[i]:=GetSysColor(i);
       FillChar(Cl,sizeOf(TCHOOSECOLOR),0);
       cl.lStructSize:=sizeOf(TCHOOSECOLOR);
       cl.hwndOwner:=MainWindow;
       cl.rgbResult:=GetProfileInt_('Bk',GetSysColor(COLOR_WINDOW));
       cl.lpCustColors:=@acrCustClr;
       cl.Flags:=CC_FULLOPEN or CC_RGBINIT;
       if ChooseColor(Cl) then
       begin
        WriteProfileInt_('Bk',Cl.rgbResult);
        SendMessage(RTF, EM_SETBKGNDCOLOR, 0, Cl.rgbResult);
       end;
end;

function Val(buf:PChar):integer;
begin
        result:=0;
        while Buf^>#0 do
        begin
          result:=result*10 + byte(Buf^)-48;
          inc(Buf);
        end;
end;

function ToolProcess(Dialog: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint; stdcall;
var
 i:integer;
label
 AssHole;
begin
  ToolProcess := 1;
  case Message of
    wm_InitDialog:
    begin
     SendDlgItemMessage(Dialog,108,bm_setCheck,ord(Too),0);
     SendDlgItemMessage(Dialog,109,bm_setCheck,ord(Sta),0);
     SendDlgItemMessage(Dialog,110,bm_setCheck,ord(not NoUndo),0);
     SendDlgItemMessage(Dialog,111,bm_setCheck,ord(autosave),0);
     SendDlgItemMessage(Dialog,101,bm_setCheck,ord(BIGbutton),0);
     i:=GetProfileInt_('IG',1);
     SendDlgItemMessage(Dialog,144,bm_setCheck,i,0);
     i:=GetProfileInt_('FI',0);
     CreateUpDownControl(WS_CHILD or WS_VISIBLE or
                          UDS_ARROWKEYS or
                          UDS_ALIGNRIGHT or UDS_SETBUDDYINT, 0, 0, 0, 0,
        Dialog,  122, Instance, GetDlgItem(Dialog,121),
        80, 0, i);
     i:=GetProfileInt_('LI',0);
     CreateUpDownControl(WS_CHILD or WS_VISIBLE or
                          UDS_ARROWKEYS or
                          UDS_ALIGNRIGHT or UDS_SETBUDDYINT, 0, 0, 0, 0,
        Dialog,  114, Instance, GetDlgItem(Dialog,113),
        80, 0, i);
     i:=GetProfileInt_('RI',80);
     CreateUpDownControl(WS_CHILD or WS_VISIBLE or
                          UDS_ARROWKEYS or
                          UDS_ALIGNRIGHT or UDS_SETBUDDYINT, 0, 0, 0, 0,
        Dialog,  116, Instance, GetDlgItem(Dialog,115),
        128, 10, i);
     Exit;
    end;
    wm_Command:
    case loWord(WParam) of
    id_Ok:
      begin
       Too:=SendDlgItemMessage(Dialog,108,bm_getCheck,0,0)<>0;
       Sta:=SendDlgItemMessage(Dialog,109,bm_getCheck,0,0)<>0;
       NoUndo:=SendDlgItemMessage(Dialog,110,bm_getCheck,0,0)=0;
       autosave:=SendDlgItemMessage(Dialog,111,bm_getCheck,0,0)<>0;
       BIGbutton:=SendDlgItemMessage(Dialog,101,bm_getCheck,0,0)<>0;
       i:=SendDlgItemMessage(Dialog,144,bm_getCheck,0,0);
       WriteProfileInt_('IG',i);
       i:=SendDlgItemMessage(Dialog,114,UDM_GETPOS, 0, 0);
       if HiWord(i)<>0 then i:=0;
       WriteProfileInt_('LI',i);
       i:=SendDlgItemMessage(Dialog,116,UDM_GETPOS, 0, 0);
       if HiWord(i)<>0 then i:=80;
       WriteProfileInt_('RI',i);
       i:=SendDlgItemMessage(Dialog,122,UDM_GETPOS, 0, 0);
       if HiWord(i)<>0 then i:=0;
       WriteProfileInt_('FI',i);
       EndDialog(Dialog, 1);
      end;
    id_Cancel:
      begin
        EndDialog(Dialog, 2);
        Exit;
      end;
     end;
  end;
  ToolProcess := 0;
end;

procedure Opt;
var
 r:TRect;
begin
  Sta:=Stat<>0;
  Too:=Tool<>0;
  if DialogBoxParam(Instance, PCHAR(5), MainWindow, @ToolProcess,0)=1 then
  begin
   WriteProfileInt_('ST',integer(Sta));
   WriteProfileInt_('TL',integer(Too));
   WriteProfileInt_('NO',integer(NoUndo));
   WriteProfileInt_('AU',integer(autosave));
   WriteProfileInt_('BIG',integer(BIGbutton));
   if NoUndo then
     begin
      MakeUndoEmpty;
      NoModify:=true;
     end;
   if Tool<>0 then ToolDown;
   if Too then ToolInit;
   if Sta then
     begin
      if Stat=0 then
      begin
       StatInit;
       ins_upd;
       OldCr.cpMin:=-1;
       UpdateCaretPos;
      end;
     end
      else
     begin
      if Stat<>0 then StatDown
     end;
   GetClientRect(MainWindow,r);
   PostMessage(MainWindow, wm_Size,0,MakeLong(r.right,r.bottom));
  end;
end;

procedure ToolSetup;
var
 R:TRect;
begin
 if Tool=0 then ToolInit;
 GetClientRect(MainWindow,r);
 PostMessage(MainWindow, wm_Size,0,MakeLong(r.right,r.bottom));
 SendMessage(Tool, TB_CUSTOMIZE,0,0);
end;

procedure UpdateMenu0(const i:integer; const Temp, FileName:PChar);
var
 j,l:integer;
 s:array[0..2] of char;
 List:array[0..10]of char;
begin
 FileName[0]:=#0;
 GetProfileString_(MRU,List,SizeOf(List));
 if lstrlen(List)<=i then exit;
 s[0]:=List[i];
 s[1]:=#70;
 s[2]:=#0;
 GetProfileString_(s,Temp,max_str);
 if Temp[0]>#0 then
 begin
  FileName[0]:='&';
  FileName[1]:=chr(i+48);
  FileName[2]:=' ';
  l:=lstrlen(Temp);
  j:=l;
  while (j>2)and(Temp[j-1]<>'\') do dec(j);
  CharLower(@Temp[j+1]);
  if l-j<14 then lstrcpy(@FileName[3],@Temp[j])
  else
  begin
   lstrcpy(@FileName[3],@Temp[j]);
   lstrcpy(@FileName[15],'...');
  end;
 end;
end;

procedure OnMeasureItem(const lpmis:PMEASUREITEMSTRUCT);
var
 hfntPrev:HFONT;
 r:TRect;
 DC:hDC;
 FileName: array[0..31]of char;
 Temp: array[0..max_str]of char;
begin
 if lpmis.CtlType=ODT_MENU then
 begin
    if lpmis.itemID>=900 then
     UpdateMenu0(lpmis.itemID-900, @Temp[0], @FileName[0])
                         else
     lstrcpy(FileName, SzMenu[lpmis.itemID]);
    SetRectEmpty(r);
    if FileName[0]<>#0 then
    begin
     DC:=GetDC(0);
     hfntPrev:= SelectObject(DC, MyFont);
     DrawText(DC, FileName,
            lstrlen(FileName),
            r,
            DT_SINGLELINE or DT_CALCRECT or DT_LEFT);
     SelectObject(DC, hfntPrev);
     ReleaseDC(0, DC);
     if r.bottom<18 then r.Bottom:=18;
     if r.bottom<NonClientMetrics.iMenuHeight then
      r.bottom:=NonClientMetrics.iMenuHeight;
     inc(r.right, 18);
    end;
    lpmis.itemWidth := r.Right;
    lpmis.itemHeight := r.Bottom;
 end;
end;

procedure OnDrawItem(const lpdis:PDRAWITEMSTRUCT);
var
 clrPrevText, clrNewText: COLORREF;
 hfntPrev:HFONT;
 r,r1:TRect;
 mode,i:integer;
 FileName: array[0..31]of char;
 Temp: array[0..max_str]of char;
// FileInfo: TSHFileInfo;
 ico:hIcon;
 memDC:hDC;
 Old:hGDIObj;
 Flag:boolean;
 b:byte;
begin
 if lpdis.CtlType=ODT_MENU then
 begin
    i:=lpdis.itemID;
    ico:=0;
    if i>=900 then
    begin
     UpdateMenu0(lpdis.itemID-900, @Temp[0], @FileName[0]);
     if (lstrcmpi(@Temp[lstrlen(Temp)-4],'.htm')=0)
      or(lstrcmpi(@Temp[lstrlen(Temp)-5],'.html')=0) then
         ico:=HTMLIcoSm else
     if (lstrcmpi(@Temp[lstrlen(Temp)-4],'.txt')=0) then
           ico:=IcoSm;
    end
                         else
     lstrcpy(FileName, SzMenu[i]);
    if FileName[0]=#0 then exit;

    CopyRect(r,lpdis.rcItem);
    Flag:=(((lpdis.itemState and ODS_GRAYED)=0) and(
         ((i<>id_ansi)and(i<>id_oem)and(i<>id_koi8r)
         and(i<>id_tokoi8)and(i<>id_towin)and(i<>id_todos))or
          ((lpdis.itemState and ODS_CHECKED)<>0)))and not ((ico=0)and(i>=900));
    if Flag then inc(r.Left, 19);
    SetRect(r1,lpdis.rcItem.Left,lpdis.rcItem.Top,lpdis.rcItem.Left+18,lpdis.rcItem.Bottom);
    if (lpdis.itemState and ODS_SELECTED)<>0 then
    begin
        if (lpdis.itemState and ODS_GRAYED)<>0 then
         clrNewText:=COLOR_GRAYTEXT
        else
        begin
         clrNewText:=COLOR_HIGHLIGHTTEXT;
         if Flag then
         if (lpdis.itemState and ODS_CHECKED)<>0 then
          DrawEdge(lpdis.hDC, r1, BDR_SUNKENOUTER, BF_RECT)
         else
          DrawEdge(lpdis.hDC, r1, BDR_RAISEDINNER, BF_RECT);
        end;
        FillRect(lpdis.hDC, r, hBrush(COLOR_HIGHLIGHT+1));
    end
    else
    begin
        if (lpdis.itemState and ODS_GRAYED)<>0 then
        begin
         clrNewText:=COLOR_GRAYTEXT;
        end
        else
        begin
         clrNewText:=COLOR_MENUTEXT;
         if Flag then
         DrawEdge(lpdis.hDC, r1, BDR_RAISEDINNER, BF_RECT or BF_FLAT);
        end;
        FillRect(lpdis.hDC, r, hBrush(COLOR_MENU+1));
     end;
     inc(r.left, 2);
     if i>=900 then
        begin
         if ico>0 then
          DrawIconEx(lpdis.hDC, lpdis.rcItem.Left,(lpdis.rcItem.Top+
           lpdis.rcItem.Bottom-16)div 2,
            Ico, 0,0,0, 0, DI_NORMAL) ;
        end  else
        begin
         if Flag then
         begin
          memDC:=CreateCompatibleDC(lpdis.hDC);
          if i<16  then
           Old:=SelectObject(memDC, MenuBmp)
           else
          begin
           Old:=SelectObject(memDC, MenuBmp2);
           dec(i,15);
          end;
          BitBlt(lpdis.hDC, lpdis.rcItem.Left+1, (lpdis.rcItem.Top+
            lpdis.rcItem.Bottom-16)div 2,
            16, 16, memDC, 16*(i-1), 0, SRCCOPY);
          SelectObject(memDC, Old);
          DeleteDC(memDC);
         end;
        end;
     if not Flag then inc(r.Left, 19);
     hfntPrev:= SelectObject(lpdis.hDC, MyFONT);
     mode:=SetBkMode(lpdis.hDC, TRANSPARENT);


     if ((lpdis.itemState and ODS_GRAYED)<>0) and
     ((lpdis.itemState and ODS_SELECTED)=0) then
     begin
      clrPrevText := SetTextColor(lpdis.hDC,
           GetSysColor(COLOR_BTNHILIGHT));
      OffsetRect(r,1,1);
      DrawText(lpdis.hDC, FileName,
            lstrlen(FileName),
            r,
            DT_SINGLELINE or DT_VCENTER);
      OffsetRect(r,-1,-1);
      SetTextColor(lpdis.hDC, GetSysColor(clrNewText));
     end
      else
      clrPrevText := SetTextColor(lpdis.hDC,
           GetSysColor(clrNewText));
     DrawText(lpdis.hDC, FileName,
            lstrlen(FileName),
            r,
            DT_SINGLELINE or DT_VCENTER or DT_LEFT);
     SetBkMode(lpdis.hDC, mode);
     SelectObject(lpdis.hDC, hfntPrev);
     SetTextColor(lpdis.hDC, clrPrevText);
  end;
end;


function WindowProc(Window: HWnd; Message, WParam: Longint;
  LParam: Longint): Longint;  stdcall;
var
  HasSelection:boolean;
  l:integer;
  Data: THandle;
  DataPtr: PChar;
  Cr:TCharRange;
  r,r1:TRect;
  m:TMemRec;
  buf:array[0..32]of char;
  FileName_: array[0..max_str]of char;
  wp:TWindowPlacement;
  DataSize,DataType:integer;
  phk:hkey;
  b:byte;
  c,d:SHORT;
label
  AssHole;
begin
  WindowProc := 0;
  case Message of
     wm_Command:
      case LoWord(WParam) of
      id_Help:
       begin
        WinHelp(Window, WinName, HELP_CONTENTS, 0);
        exit
       end;
      id_About://Это не попытка оставить автограф. Просто из Delphi ShellAbout не вызовешь.
       begin
        TasmAbout(Window,
           LoadIcon(Instance,PChar(1)));
        exit
       end;
      id_Exit:
       begin
        SendMessage(Window,wm_Close,0,0);
        exit
       end;
      id_ANSI,id_oem,id_koi8r:
       begin
        TextD:=loWord(wParam)-id_ansi;
        SetFont;
        exit
       end;
      id_Undo:
      begin
       if NoUndo then
        SendMessage(RTF, EM_UNDO, 0, 0) else DoUndo;
        exit
      end;
      id_Sea:
      begin
       if Repl then
       begin
        makebackup(6,0);
        repeat
         if not SearchAgain then break;
        until not RpAll
       end
              else
       if not SearchAgain then
         FindClick;
        exit
      end;
      id_Select:
      begin
//       Cr.cpMin:=0;
//       Cr.CpMax:=SendMessage(RTF,WM_GETTEXTLENGTH, 0, 0);
       SendMessage(RTF, EM_SETSEL, 0, -1);//longint(@Cr));
       exit
      end;
      id_WordWrap:
      begin
       SetWWrap;
        exit
      end;
      id_ODOS:
      begin
       if CheckSave then OpenDos;
        exit
      end;
      id_insert:
      begin
       Insert;
      end;
      id_SaveAs:
      begin
       Save_As;
        exit
      end;
      id_Save:
      begin
       if lstrcmp(PathName,DefaultFileName)=0 then Save_As
                 else RTF_Save;
        exit
      end;
      id_New:
      begin
      if CheckSave then
       begin
        SetWindowText(RTF, nil);
        MakeUndoEmpty;
        SendMessage(RTF, EM_SETMODIFY, 0, 0);
        lstrcpy(PathName, DefaultFileName);
        SetCaption;
       end;
       exit
      end;
      id_Del:goto AssHole;
      id_Cut:
      begin
        SendMessage(Window,wm_Command,id_Copy,0);
AssHole:makebackup(4,0);
        SendMessage(RTF, WM_CLEAR, 0, 0);
        exit
      end;
      id_Copy://В NT проблемы. Нужен юникодовый контрол. :(
      begin
       SendMessage(RTF, EM_EXGETSEL, 0, Longint(@CR));
       L:= CR.cpMax - CR.cpMin;
       if L=0 then exit;
       Data := GlobalAlloc(GHND or GMEM_DDESHARE, L+1);
       if Data<>0 then
       begin
        DataPtr := GlobalLock(Data);
        if DataPtr<>nil then
        begin
         SendMessage(RTF, EM_GETSELTEXT,
          0, Longint(DataPtr));
         if OpenClipboard(Window)then
         begin
          EmptyClipboard;
          case TextD of
          0:SetClipboardData(CF_TEXT, Data);
          1:SetClipboardData(CF_OEMTEXT, Data);
          2:
          begin
           for L := 0 to L-1 do
            if byte(DataPtr[L])>=128 then
             DataPtr[L] := Code[3,byte(DataPtr[L])];
            SetClipboardData(CF_OEMTEXT, Data);
          end;
          end;
          CloseClipboard;
         end;
        end;
        GlobalUnlock(Data);
       end;
        exit
      end;
      id_Paste://В NT проблемы. Нужен юникодовый контрол. :(
      begin
       if IsClipboardFormatAvailable(CF_TEXT) then
       if OpenClipboard(Window)then
       begin
        if TextD=0  then Data := GetClipboardData(CF_TEXT)else
         Data := GetClipboardData(CF_OEMTEXT);
        if Data <> 0 then
        begin
         DataPtr := PChar(GlobalLock(Data));
         if DataPtr<>nil then
         begin
          m.MemSize:=lstrlen(DataPtr);
          makebackup(4,m.MemSize);
          if TextD<>2 then
          begin
           m.MemStream:=DataPtr;
           SetRTFText(@m,SFF_SELECTION or SF_TEXT);
          end
           else
          begin
           m.Handle:= GlobalAlloc(GPTR, m.MemSize+1);
           if m.Handle<>0 then
           begin
            for L:=0 to m.MemSize-1 do
            begin
             if DataPtr[L]<#128 then m.MemStream[L]:=DataPtr[L]
               else m.MemStream[L]:=Code[2,byte(DataPtr[L])];
            end;
            SetRTFText(@m,SFF_SELECTION or SF_TEXT);
            GlobalFree(m.Handle);
           end;
          end;
         end;
         GlobalUnlock(Data);
        end;
        CloseClipboard;
       end;
       exit
      end;
      id_SizeP:
      begin
          l:=GetProfileInt_(s2_[TextD],200);
          if l<20*26 then
          begin
           inc(l,20);
           WriteProfileInt_(s2_[TextD],l);
           SetFont;
           exit
          end
      end;
      id_SizeM:
      begin
        l:=GetProfileInt_(s2_[TextD],200);
        if l>20*4 then
        begin
         dec(l,20);
         WriteProfileInt_(s2_[TextD],l);
         SetFont;
         exit
        end
      end;
      id_Date:
      begin
        DateTime;
        exit
      end;
      id_Char:
      begin
       DialogBoxParam(Instance, PCHAR(6), Window, @CharProcess,0);
       exit
      end;
      id_Header:
      begin
       EnumPage;
       exit;
      end;
      id_View:
      begin
       PreView;
      end;
      id_Setup:
      begin
       PageSetup;
      end;
      id_Print:
      begin
       Print;
      end;
      id_Hack:
      begin
       Hack;
      end;
      id_UserW,id_UserD,id_UserK:
      begin
        FontClick(LoWord(WParam)-id_UserW);
      end;
      id_toWin,id_todos,id_tokoi8:
      begin
       Coding(LoWord(WParam),cp_1[TextD], cp_2[loWord(wParam)-id_toWin]);
      end;
      id_Fido:
      begin
       Coding(LoWord(WParam),cp_1[TextD], 9);
      end;
      id_Translit,id_RTF,id_Quoted,id_Break,id_justify,id_center,id_left,id_right:
      begin
       Coding(LoWord(WParam),-1, -1);
      end;
      id_other:
      begin
       SendMessage(RTF, EM_HIDESELECTION, 0, 1);
       DialogBoxParam(Instance, PChar(8), MainWindow, @Cod, 0);
       SendMessage(RTF, EM_HIDESELECTION, 1, 1);
      end;
      id_Options:
      begin
       Opt;
      end;
      id_ToolBar:
      begin
       ToolSetup;
      end;
      id_find,id_Replace:
      begin
       Repl:=LoWord(WParam)=id_Replace;
       FindClick;
       exit
      end;
      id_FColor:
      begin
       CL;
      end;
      id_BColor:
      begin
       BK;
      end;
      id_HTMLColor:
      begin
       HTML;
      end;
      id_HTML:
      begin
       HTML_refresh;
      end;
      100..102:
      begin
        if cp_m<0 then
         cp_m:=LoWord(wParam)-100
         else
         begin
          if LoWord(wParam)-100=cp_m then
          begin
           TextD:=cp_m;
           SetFont;
          end
           else
           Coding(LoWord(wParam)-100+id_towin, cp_1[cp_m], cp_2[LoWord(wParam)-100]);
          cp_m:=-1;
         end;
      end;
//      id_sdown..id_dright:{if TextD=1 then
//       Arrow(LoWord(wParam)) else }MessageBeep(0);
//
      900..909:
      if CheckSave then
      begin
       GetProfileString_(MRU,FileName_,SizeOf(FileName_));
       if lstrlen(FileName_)<=LoWord(WParam)-900 then exit;
       buf[0]:=FileName_[LoWord(WParam)-900];
       buf[1]:=#70;
       buf[2]:=#0;
       GetProfileString_(buf,FileName_,SizeOf(FileName_));
       if not Open(FileName_) then
       begin
        WriteProfileString_(buf,'');
        for l:=909 downto 900 do
        begin
         ModifyMenu(MainMenu, l, MF_BYCOMMAND or MF_STRING, l, '');
         ModifyMenu(MainMenu, l, MF_BYCOMMAND or MF_OWNERDRAW, l, nil);
        end;
       end;
       exit
      end;
     end;

     WM_QUERYENDSESSION:
     begin
      if not CheckSave then exit;
     end;
     WM_NOTIFY:
     begin
      if PTOOLTIPTEXT(lparam).hdr.code = 0-520 then
      begin
       lstrcpyn(PTOOLTIPTEXT(lparam).szText,
         SzMenu[PTOOLTIPTEXT(lparam).hdr.idFrom],79)
      end else
      begin
       case PNMHDR(lParam).code of
        TBN_BEGINADJUST, TBN_BEGINDRAG, TBN_ENDDRAG,
        TBN_QUERYDELETE, TBN_QUERYINSERT, TBN_ENDADJUST:
        begin
         WindowProc:=1;
         exit;
        end;
        TBN_TOOLBARCHANGE:
        begin
         SendMessage(Tool, TB_SAVERESTORE, 1, longint(@TBS));
         WindowProc:=1;
         exit;
        end;
        TBN_GETBUTTONINFO:
        begin
         with PTBNOTIFY(lParam).TBButton do
         begin
          case PTBNOTIFY(lParam).iItem of
           0..3,5..14,18..21:
           begin
            idCommand:=PTBNOTIFY(lParam).iItem+1;
            iBitmap:=PTBNOTIFY(lParam).iItem;
           end;
           4:
           begin
            idCommand:=id_insert;
            iBitmap:=7;
           end;
           15..17:
           begin
            idCommand:=PTBNOTIFY(lParam).iItem+14;
            iBitmap:=PTBNOTIFY(lParam).iItem;
           end;
           22..23:
           begin
            idCommand:=PTBNOTIFY(lParam).iItem+1;
            iBitmap:=10;
           end;
           24:
           begin
            idCommand:=id_wordwrap;
            iBitmap:=10;
            fsState:=TBSTATE_ENABLED;
            fsStyle:= TBSTYLE_CHECK;
            dwData:=0;
            bReserved[1]:=0;
            bReserved[2]:=0;
            iString:=0;
            lstrcpyn(PTBNOTIFY(lParam).pszText, SzMenu[idCommand],
              PTBNOTIFY(lParam).cchText);
            WindowProc:=1;
            exit;
           end;
           25:
           begin
            idCommand:=PTBNOTIFY(lParam).iItem+1;
            iBitmap:=8;
           end;
           26:
           begin
            idCommand:=id_options;
            iBitmap:=10;
           end;
           27..31:
           begin
            idCommand:=PTBNOTIFY(lParam).iItem+5;
            iBitmap:=22;
           end;
            else
            begin
//             WindowProc:=0;
             exit;
            end;
          end;

          fsState:=TBSTATE_ENABLED;
          fsStyle:=TBSTYLE_BUTTON;
          dwData:=0;
          bReserved[1]:=0;
          bReserved[2]:=0;
          iString:=0;
          lstrcpyn(PTBNOTIFY(lParam).pszText, SzMenu[idCommand],
            PTBNOTIFY(lParam).cchText);
         end;
         WindowProc:=1;
         exit;
        end;
        TBN_RESET:
        begin
         SendMessage(Tool, TB_SAVERESTORE, 0, longint(@TBS));{???}
         WindowProc:=1;
         exit;
        end;
        TBN_CUSTHELP:
        begin
         PostMessage(Window, wm_command, id_help, 0);
         WindowProc:=1;
         exit;
        end;
       end;
      end;
     end;
     WM_MENUCHAR:
     begin
      for b:=0 to Accnt-1 do
      begin
       if (PopMenu[Accels[b].m]=hMenu(lParam)) then
       begin
        if lobyte(VkKeyScan(Accels[b].c))=lobyte(VkKeyScan(chr(Loword(wParam)))) then
        if (GetMenuState(lParam, Accels[b].ID, MF_BYCOMMAND)and MF_GRAYED)=0 then
        begin
         SendMessage(Window, WM_COMMAND, Accels[b].ID, 0);
         result:=1 shl 16;
         break
        end;
       end
      end;
      exit;
     end;
     WM_MEASUREITEM:OnMeasureItem(PMEASUREITEMSTRUCT(lParam));
     WM_DRAWITEM:OnDrawItem(PDRAWITEMSTRUCT(lParam));
     WM_Close:
     begin
      if (RTF<>0)then
       if not CheckSave then exit;
     end;
     wm_InitMenuPopup:if HiWord(lParam)=0 then
     case LoWord(lParam) of
     0,1:
     begin
      if NoUndo then EnableMenuItem(wParam,id_Undo,
         ENABLEDS[SendMessage(RTF, EM_CANUNDO, 0, 0) <> 0])else
         EnableMenuItem(wParam,id_Undo, ENABLEDS[pUndo<>nil]);
      EnableMenuItem(wParam,id_Paste,
          ENABLEDS[IsClipboardFormatAvailable(CF_TEXT)]);
      EnableMenuItem(wParam,id_Save,
         ENABLEDS[SendMessage(RTF, EM_GETMODIFY, 0, 0) <> 0]);

      HasSelection:=SendMessage(RTF, EM_SELECTIONTYPE, 0, 0)<> SEL_EMPTY;
      EnableMenuItem(wParam,id_Copy,
          ENABLEDS[HasSelection]);
      EnableMenuItem(wParam,id_Cut,
          ENABLEDS[HasSelection]);
      EnableMenuItem(wParam,id_Del,
          ENABLEDS[HasSelection]);
     end;
     end;
     wm_Size:
     begin
      if Tool<>0 then
      begin
       SendMessage(Tool,Message,0,0);
       GetWindowRect(Tool, r1)
      end  else SetRectEmpty(r1);
      if Stat<>0 then
      begin
       SendMessage(Stat,Message,0,0);
       GetWindowRect(Stat, r)
      end  else SetRectEmpty(r);
      MoveWindow(RTF, 0, r1.bottom-r1.top, LOWORD(lparam),
       HIWORD(lparam)-r.bottom+r.top-(r1.bottom-r1.top), true);
     end;
     wm_SetFocus:
      SetFocus(RTF);
     wm_User+1:UpdateCaretPos;
     wm_Destroy:
      begin
       if curautosave then
       begin
        RegOpenKey(HKEY_CURRENT_USER, BredKey, phk);
        wp.length:=sizeof(TWINDOWPLACEMENT);
        DataSize:=wp.length;
        DataType := REG_BINARY;
        GetWindowPlacement(Window,@wp);
        RegSetValueEx(phk, 'DEF', 0,  DataType, @wp, DataSize);
        RegCloseKey(phk);
       end;
       RTFEDIT_Shutdown;
       PostQuitMessage(0);
       exit
      end;
  end;
  WindowProc := DefWindowProc(Window, Message, WParam, LParam);
end;

procedure MenuInit;
var
 m__:UINT;
 st:array[0..31] of char;

procedure AddOwnerDraw(const a,b:uint);
var
 m__:integer;
begin
    ModifyMenu(PopMenu[a], b, MF_BYCOMMAND or MF_OWNERDRAW,
     b, nil);
    for m__:=0 to lstrlen(SzMenu[b])-1 do
     if (SzMenu[b][m__]='&')and(SzMenu[b][m__+1]<>'&') then
     begin
      Accels[Accnt].m:=a;
      Accels[Accnt].C:=SzMenu[b][m__+1];
      Accels[Accnt].ID:=b;
      inc(Accnt);
      break;
     end;
end;


begin
    MainMenu:=GetMenu(MainWindow);
    for m__:=0 to 7 do
     PopMenu[m__]:=GetSubMenu(MainMenu, m__);
    for m__:=1 to bmps do
    begin
     GetMenuString(MainMenu, m__, st, SizeOf(st), MF_BYCOMMAND);
     lstrcpyn(SzMenu[m__], st, SizeOf(SzMenu[m__]));
    end;
    AddOwnerDraw(0,id_new);
    AddOwnerDraw(0,id_odos);
    AddOwnerDraw(0,id_save);

    for m__:=900 to 909 do
    begin
     ModifyMenu(PopMenu[0], m__, MF_BYCOMMAND or MF_OWNERDRAW, m__, nil);
     Accels[Accnt].m:=0;
     Accels[Accnt].C:=chr(m__-900+48);
     Accels[Accnt].ID:=m__;
     inc(Accnt);
    end;
    AddOwnerDraw(1,id_undo);
    AddOwnerDraw(1,id_cut);
    AddOwnerDraw(1,id_copy);
    AddOwnerDraw(1,id_paste);
    AddOwnerDraw(1,id_del);

    AddOwnerDraw(2,id_justify);
    AddOwnerDraw(2,id_right);
    AddOwnerDraw(2,id_left);
    AddOwnerDraw(2,id_center);

    AddOwnerDraw(3,id_view);
    AddOwnerDraw(3,id_print);


    AddOwnerDraw(4,id_find);
    AddOwnerDraw(4,id_replace);

    AddOwnerDraw(5,id_oem);
    AddOwnerDraw(5,id_koi8r);
    AddOwnerDraw(5,id_ansi);
    ModifyMenu(PopMenu[5], id_towin, MF_BYCOMMAND or MF_OWNERDRAW or
     MF_MENUBARBREAK,
     id_towin, nil);
    for m__:=0 to lstrlen(SzMenu[id_towin])-1 do
     if (SzMenu[id_towin][m__]='&')and(SzMenu[id_towin][m__+1]<>'&') then
     begin
      Accels[Accnt].m:=5;
      Accels[Accnt].C:=SzMenu[id_todos][m__+1];
      Accels[Accnt].ID:=id_towin;
      inc(Accnt);
      break;
     end;
    AddOwnerDraw(5,id_tokoi8);
    AddOwnerDraw(5,id_todos);
    AddOwnerDraw(7,id_help);
end;

procedure RTFEDIT_Init;
type
  PInitCommonControlsEx = ^TInitCommonControlsEx;
  TInitCommonControlsEx = packed record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
  end;
var
  t: PChar;
  a:TMemoryStatus;
  CmdLine:PChar;
  FileName: array[0..max_str]of char;
  m__{, ID}:integer;
  _InitCommonControlsEx: function(var ICC: TInitCommonControlsEx): Bool; stdcall;
  ICC:TInitCommonControlsEx;
//  mii:TMENUITEMINFO;
const
  ICC_LISTVIEW_CLASSES = $00000001; // listview, header
  ICC_TREEVIEW_CLASSES = $00000002; // treeview, tooltips
  ICC_BAR_CLASSES      = $00000004; // toolbar, statusbar, trackbar, tooltips
  ICC_TAB_CLASSES      = $00000008; // tab, tooltips
  ICC_UPDOWN_CLASS     = $00000010; // updown
  ICC_PROGRESS_CLASS   = $00000020; // progress
  ICC_HOTKEY_CLASS     = $00000040; // hotkey
  ICC_ANIMATE_CLASS    = $00000080; // animate
  ICC_WIN95_CLASSES    = $000000FF;
  ICC_DATE_CLASSES     = $00000100; // month picker, date picker, time picker, updown
  ICC_USEREX_CLASSES   = $00000200; // comboex
  ICC_COOL_CLASSES     = $00000400; // rebar (coolbar) control


begin
     hRTFLib:= LoadLibrary(lib);
     if 0=hRTFLib then
     begin
      IOError;
      PostQuitMessage(255);
     end;
     WWrap:=GetProfileInt_('WW',ES_AUTOHSCROLL or WS_HSCROLL);
     if WWrap=0 then CheckMenuItem(MainMenu,id_WordWrap,
         MF_BYCOMMAND or MF_CHECKED);
     NoUndo:=GetProfileInt_('NO',0)<>0;
     NoModify:=NoUndo;
     FillChar(OpenFN, SizeOf(TOpenFileName),0);
     with OpenFN do
     begin
      lStructSize   := sizeof(TOpenFileName);
      hwndOwner     := MainWindow;
      lpstrFilter   := 'Text Files (*.txt,*.diz,*.rtf)'#0'*.txt;*.diz;*.rtf'#0+
      'All Files (*.*)'#0'*.*'#0+
      'HTML Files (*.htm,*.html)'#0'*.htm;*.html'+
  #0'Pascal Files (*.pas,*.dpr,*.asm)'#0'*.pas;*.dpr;*.asm'#0'C Files (*.c,*.cpp,*.h,*.rc)'+
  #0'*.c;*.h;*.cpp;*.rc'#0'OS Files (*.bat,*.log,*.ini)'#0'*.bat;*.log;*.ini'#0;
      nMaxFile      := max_str;
      lpfnHook      := ExplorerHook;
     end;
    lstrcpy(PathName, DefaultFileName);
    SetRect(FldRect,2500,2500,2500,2500);
    a.dwLength:=SizeOf(TMemoryStatus);
    GlobalMemoryStatus(a);
    maxtextlen:=(a.dwTotalPhys div 2)or $fffff;

    @_InitCommonControlsEx:=GetProcAddress(GetModuleHandle(comctl), 'InitCommonControlsEx');
    if @_InitCommonControlsEx<>nil then
    begin
      ICC.dwSize := SizeOf(TInitCommonControlsEx);
      ICC.dwICC := ICC_BAR_CLASSES;
      _InitCommonControlsEx(ICC);
      ICC.dwICC := ICC_UPDOWN_CLASS;
      _InitCommonControlsEx(ICC);
    end else
       InitCommonControls;
    if GetProfileInt_('ST',1)<>0 then StatInit;

    with RichEditOleCallbackMT, IUnknownMT do begin
       QueryInterface := TIRichEditOleCallback_QueryInterface;
       AddRef         := TIRichEditOleCallback_AddRef;
       Release        := TIRichEditOleCallback_Release;

       GetNewStorage:= TIRichEditOleCallback_GetNewStorage;
       GetInPlaceContext:= TIRichEditOleCallback_GetInPlaceContext;
       ShowContainerUI:= TIRichEditOleCallback_ShowContainerUI;
       QueryInsertObject:= TIRichEditOleCallback_QueryInsertObject;
       DeleteObject:= TIRichEditOleCallback_DeleteObject;
       QueryAcceptData:= TIRichEditOleCallback_QueryAcceptData;
       ContextSensitiveHelp:= TIRichEditOleCallback_ContextSensitiveHelp;
       GetClipboardData:= TIRichEditOleCallback_GetClipboardData;
       GetDragDropEffect:= TIRichEditOleCallback_GetDragDropEffect;
       GetContextMenu:= TIRichEditOleCallback_GetContextMenu;
      end;
    RichEditOleCallback:=@RichEditOleCallbackMT;
    RTFEDIT_ReCreate;
    BIGbutton:=GetProfileInt_('BIG',0)<>0;
    if GetProfileInt_('TL',1)<>0 then ToolInit;

    CmdLine:=GetCommandLine();
    if CmdLine[0]='"' then
    begin
     inc(CmdLine);
     while (CmdLine[0]<>#0)and(CmdLine[0]<>'"') do inc(CmdLine);
    end else
    while (CmdLine[0]<>#0)and(CmdLine[0]<>' ') do inc(CmdLine);

    while (CmdLine[0]='"')or(CmdLine[0]=' ') do inc(CmdLine);
    t:=CmdLine;
    if (t[0]='/')and((t[1]='p')or(t[1]='P')) then
    begin
     while (CmdLine[0]<>#0)and(CmdLine[0]<>' ') do inc(CmdLine);
     while (CmdLine[0]='"')or(CmdLine[0]=' ') do inc(CmdLine);
     t:=CmdLine;
     PostMessage(MainWindow, wm_command, id_print, 0);
    end;
    while (CmdLine[0]<>#0)and(CmdLine[0]<>'"') do inc(CmdLine);
    CmdLine[0]:=#0;

    GetFullPathName(t, max_str,
       FileName, t);
    Open(FileName);

    ToolBmp:=0;

    MenuBmp:=LoadImage(GetModuleHandle(comctl), PChar(120), IMAGE_BITMAP, 0, 0,
        LR_LOADMAP3DCOLORS);
    LoadToolBmp(false,MenuBmp2);
end;


procedure WinMain;
var
  Message: TMsg;
  SI: TStartupInfo;
  WindowClass: TWndClassEx;
  wp:TWindowPlacement;
  DataSize,DataType:integer;
  phk:hkey;
  pp:pointer;
begin
  Instance:=GetModuleHandle(nil);
  FillChar(WindowClass,SizeOf(TWndClassEx),0);
  WindowClass.cbSize:= SizeOf(TWndClassEx);
  WindowClass.lpfnWndProc:= @WindowProc;
  WindowClass.hInstance := Instance;
  WindowClass.lpszMenuName:= PChar(1);
  WindowClass.lpszClassName:= WinName;
  WindowClass.hIcon := LoadIcon(Instance,PChar(1));
  HTMLIcoSm:=LoadImage(Instance,PChar(3),IMAGE_ICON,
                                   16,16, 0);
  IcoSm:=LoadImage(Instance,PChar(2),IMAGE_ICON,
                                   16,16, 0);
  WindowClass.hIconSm :=IcoSm;
  if RegisterClassEx(WindowClass) = 0 then
   if RegisterClass(PWNDCLASS(@WindowClass.style)^) = 0 then Halt(255);

  PathName[0]:='[';
  lstrcat(PathName,DefaultFileName);
  lstrcat(PathName, ']-BRED2');
  MainWindow := CreateWindowEx(0,
    WinName,
    PathName,
    WS_OVERLAPPEDWINDOW{ or WS_CLIPCHILDREN не включать! Конфликт с RichEdit},
    integer(cw_UseDefault),
    integer(cw_UseDefault),
    integer(cw_UseDefault),
    integer(cw_UseDefault),
    0,
    0,
    Instance,
    nil);
  MenuInit;

  RTFEdit_Init;

  autosave:=GetProfileInt_('AU',1)<>0;
  SI.cb:=sizeof(TStartupInfo);
  GetStartupInfo(SI);
  if SI.dwFlags and STARTF_USESHOWWINDOW = 0 then
   SI.wShowWindow := SW_SHOWDEFAULT;
  curautosave:=autosave and ((SI.wShowWindow=SW_SHOWDEFAULT)
   or(SI.wShowWindow=SW_SHOWNORMAL));
  if curautosave then
  begin
   DataSize:=sizeof(TWINDOWPLACEMENT);
   DataType := REG_BINARY;
   RegOpenKey(HKEY_CURRENT_USER, BredKey, phk);
   if RegQueryValueEx(phk, 'DEF', nil,  @DataType, @wp, @DataSize)=ERROR_SUCCESS then
   begin
    SI.wShowWindow:=wp.showCmd;
    SetWindowPlacement(MainWindow,@wp);
   end;
   RegCloseKey(phk);
  end;

  NonClientMetrics.cbSize := sizeof(NonClientMetrics);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0);
  MyFont := CreateFontIndirect(NonClientMetrics.lfMenuFont);

  ShowWindow(MainWindow, SI.wShowWindow);

  hAccl:= LoadAccelerators(Instance, PChar(1));
  repeat
   if GetMessage(Message, 0, 0, 0) then
   begin
    TranslateMessage(Message);
    DispatchMessage(Message);
   end else break;
   if (Tool<>0) and not PeekMessage(Message, 0, 0, 0,PM_NOREMOVE) then UpdateToolBar;//Взято из MFC
  until false;

  DeleteObject(ToolBmp);
  DeleteObject(MenuBmp);
  DeleteObject(MenuBmp2);

  DeleteObject(MyFont);

  Halt(Message.wParam);
end;

begin
  WinMain;
end.
//здесь был BoundsChecker.