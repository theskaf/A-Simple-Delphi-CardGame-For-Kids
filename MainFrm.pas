unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Math,
  System.Classes, System.UITypes, System.DateUtils,
  Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MainDtm, Vcl.StdCtrls, Vcl.ExtCtrls,
  Generics.Collections, Vcl.ComCtrls, Vcl.Themes,
  Registry, Vcl.Imaging.GIFImg,             //Mv.VCL.Helper.Imaging,
  UStartup, //mutex HELPER kinda thing for my app
  WarFrm, EndScreenFrm, Vcl.MPlayer, mmsystem,
  ShellAPI;


type

  TCard = record
    Rank: integer;
    Name: string;
    Index: integer;

    constructor Create(ARank: Integer; AName: String; AIndex: Integer);
  end;


  TfrmMain = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Shape1: TShape;
    Shape2: TShape;
    prgBarCaptives: TProgressBar;
    Shape3: TShape;
    Button1: TButton;
    GroupBox1: TGroupBox;
    rbtnFast: TRadioButton;
    rbtnNormal: TRadioButton;
    GroupBox2: TGroupBox;
    Edit1: TEdit;
    lblPlayer: TLabel;
    lblTheSkaf: TLabel;
    Button2: TButton;
    ScrollBox1: TScrollBox;
    GroupBox3: TGroupBox;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblAbandoned: TLabel;
    lblLost: TLabel;
    lblWon: TLabel;
    Label4: TLabel;
    lblStats: TLabel;
    Shape4: TShape;
    Memo1: TMemo;
    pnlPlayer: TPanel;
    pnlTheSkaf: TPanel;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    lblPlName: TLabel;
    lblTSName: TLabel;
    lblPlRank: TLabel;
    lblTSRank: TLabel;
    lblM1: TLabel;
    lblM2: TLabel;
    prgBarTSCards: TProgressBar;
    prgBarTSStack: TProgressBar;
    prgBarPLCards: TProgressBar;
    prgBarPLStack: TProgressBar;
    lblCDPl: TLabel;
    lblCDTs: TLabel;
    lblCSPl: TLabel;
    lblCSTs: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblVer: TLabel;
    GroupBox4: TGroupBox;
    cbStyles: TComboBox;
    Label9: TLabel;
    lblClix: TLabel;
    imgPL: TImage;
    imgTS: TImage;
    GroupBox5: TGroupBox;
    chkbThanasis: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); //procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbStylesChange(Sender: TObject);
    procedure lblTheSkafClick(Sender: TObject);
    procedure lblPlayerClick(Sender: TObject);
    procedure lblPlNameClick(Sender: TObject);
    procedure lblTSNameClick(Sender: TObject);


  private
    someColor: TColor;
    strProperStyleName: String;
    iClickityClick: Integer;

    procedure ProcessParam(const Param: string); //    mutex HELPER kinda thing for my app
    procedure UMEnsureRestored(var Msg: TMessage); //  mutex HELPER kinda thing for my app
      message UM_ENSURERESTORED; //                    mutex HELPER kinda thing for my app
    procedure WMCopyData(var Msg: TWMCopyData); //     mutex HELPER kinda thing for my app
      message WM_COPYDATA; //                          mutex HELPER kinda thing for my app

    procedure reShuffle;
    function UpdPBarsAndFLabels(iCaptives, iTSCards, iTSStack, iPLCards, iPLStack,  iYATmp : Integer): Boolean;
    function fileVer: string;
    procedure ShuffleList(List: TList<Integer>);
    function InformEndingAndAsk(iWhich: Integer): Integer;
    procedure FGPlayASound(const AResName: string; bLoop: Boolean);
    procedure OpenLinkByClickAnyLbl(aDaLbl: TLabel );

  protected
    procedure CreateParams(var Params: TCreateParams);
      override;

  public
    Cards: TList<TCard>;
    bGameInProgress, bNormal: BOOL;
    lstPLCards, lstTSCards,
    lstCaptives,
    lstPLStack, lstSTStack,
    lstPlayground: TList<Integer>;
    iCliXXX,
    DelphiAndRegistryDontMatchWON,
    DelphiAndRegistryDontMatchLOST,
    DelphiAndRegistryDontMatchABANDONED: Integer;
    HResource: TResourceHandle;
    HResData: THandle;
    PWav: Pointer;

    procedure InitFirstPart;
    procedure AddCreateCards;
    function FindCardByIndex(Index: Integer): Variant;
    function assColorz(n: Integer): TColor; //uses Vcl.Graphics
    function RegistryAssignOrRead(): Variant;
    procedure RegistryUpdatesWhenGameEnds(endMode: Integer);
    procedure InitSecondPart;
    procedure DesignStuff(aaPLcard, aaTScard:Integer; vrntRNPL, vrntRNTS: Variant; bSMdl: Boolean);
    function DaResourceIdent(iRank: Integer): string;
  end;


var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

var
  PLGIFImage, TSGIFImage: TGIFImage;


procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  buttonSelected : Integer;
begin
  if bGameInProgress then
  begin
    buttonSelected := MessageDlg('Έχετε παιχνίδι σε εξέλιξη. Είστε βέβαιοι ότι θέλετε να κλείσετε την ΕΦΑΡΜΟΓΑΡΑ μου;', mtConfirmation, [mbYes, mbNo], 0);
    if buttonSelected = mrYes then
    begin
      RegistryUpdatesWhenGameEnds(666);
    end
    else
      Abort;
  end
  else
    MessageDlg('Ρε μαν μου.', mtInformation, [mbOK], 0);
end;


procedure TfrmMain.FormCreate(Sender: TObject);
var
  I: Integer;                  // mutex HELPER kinda thing for my app
  PLCardsStr: string;
begin
  for I := 1 to ParamCount do  // mutex HELPER kinda thing for my app
    ProcessParam(ParamStr(I)); // mutex HELPER kinda thing for my app

  someColor := RGB(0, 206, 209);
  bGameInProgress := False;
  chkbThanasis.Checked := False;
  InitFirstPart;
  AddCreateCards;
  lstPLCards    := TList<Integer>.Create;
  lstTSCards    := TList<Integer>.Create;
  lstCaptives   := TList<Integer>.Create;
  lstPLStack    := TList<Integer>.Create;
  lstSTStack    := TList<Integer>.Create;
  lstPlayground := TList<Integer>.Create;
  InitSecondPart;
end;


procedure TfrmMain.FormResize(Sender: TObject);
begin
  ClientWidth := 360;
  ClientHeight := 640;
end;



procedure TfrmMain.InitFirstPart;
var
  vTmp: Variant;
  strTmpStyle: string;
begin
  lblVer.Caption := fileVer;

  Shape1.Brush.Color := someColor;
  Shape2.Brush.Color := someColor;
  Shape3.Brush.Color := someColor;
  Shape4.Brush.Color := someColor;
  lblPlayer.Font.Color := someColor;
  lblTheSkaf.Font.Color := someColor;

  lblStats.Font.Color := someColor;
  lblAbandoned.Font.Color := someColor;
  lblWon.Font.Color := someColor;
  lblLost.Font.Color := someColor;
  lblClix.Font.Color := someColor;
  Scrollbox1.HorzScrollBar.Visible := False;
  lblM1.Font.Color := someColor;
  lblM2.Font.Color := someColor;

  lblPlName.StyleElements := [];
  lblPlName.StyleName := 'Windows';
  lblPlRank.StyleElements := [];
  lblPlRank.StyleName := 'Windows';
  lblTSName.StyleElements := [];
  lblTSName.StyleName := 'Windows';
  lblTSRank.StyleElements := [];
  lblTSRank.StyleName := 'Windows';

  vTmp := RegistryAssignOrRead();

  if vTmp[0] = 'Yes' then
    CheckBox1.Checked := True
  else
    CheckBox1.Checked := False;

  Edit1.Text := vTmp[1];

  try //VarIsNull(vTmp[7]) μόνο αν έχει σβήσει το κλειδί registry χερουλάτα
    strTmpStyle := VarToStr(vTmp[7]);
    if Assigned(TStyleManager.ActiveStyle) then
    begin
      if strTmpStyle = '-1' then
      begin
        strProperStyleName := 'Tablet Dark';
        cbStyles.ItemIndex := -1;
      end
      else
      if strTmpStyle = '0' then
      begin
        strProperStyleName := 'Golden Graphite';
        cbStyles.ItemIndex := 0;
      end
      else
      if strTmpStyle = '1' then
      begin
        strProperStyleName := 'Charcoal Dark Slate';
        cbStyles.ItemIndex := 1;
      end
      else
      if strTmpStyle = '2' then
      begin
        strProperStyleName := 'Ruby Graphite';
        cbStyles.ItemIndex := 2;
      end
      else
      if strTmpStyle = '3' then
      begin
        strProperStyleName := 'Cobalt XEMedia';
        cbStyles.ItemIndex := 3;
      end
      else
      if strTmpStyle = '4' then
      begin
        strProperStyleName := 'Glossy';
        cbStyles.ItemIndex := 4;
      end
      else
      begin
        strProperStyleName := 'Windows';
        cbStyles.ItemIndex := -1;
      end;
    end
    else
    begin
      strProperStyleName := 'Windows';
        cbStyles.ItemIndex := -1;
    end;
  except
    strProperStyleName := 'Windows';
    cbStyles.ItemIndex := -1;
  end;
  TStyleManager.TrySetStyle(strProperStyleName);



  if vTmp[2] = 'Yes' then
  begin
    rbtnNormal.Checked := True;
    bNormal := True;
  end
  else
  begin
    rbtnFast.Checked := True;
    bNormal := False;
  end;



  PageControl1.ActivePageIndex := 0;
  lblStats.Caption := FormatDateTime('dd/mm/yyyy', VarToDateTime(vTmp[3]));
  lblWon.Caption := IntToStr(vTmp[4]);
  lblLost.Caption := IntToStr(vTmp[5]);
  lblAbandoned.Caption := IntToStr(vTmp[6]);

  lblClix.Caption := VarToStr(vTmp[8]);
  iClickityClick := vTmp[8];

  prgBarCaptives.Min := 0;
  prgBarCaptives.Max := 100;
  prgBarCaptives.Position := 0;
  prgBarTSCards.Min := 0;
  prgBarTSCards.Max := 100;
  prgBarTSCards.Position := 0;
  prgBarTSStack.Min := 0;
  prgBarTSStack.Max := 100;
  prgBarTSStack.Position := 0;
  prgBarPLCards.Min := 0;
  prgBarPLCards.Max := 100;
  prgBarPLCards.Position := 0;
  prgBarPLStack.Min := 0;
  prgBarPLStack.Max := 100;
  prgBarPLStack.Position := 0; //When a progress bar is created, Min and Max represent percentages, where Min is 0 (0% complete) and Max is 100 (100% complete).
  lblTSName.Caption := EmptyStr;
  lblTSRank.Caption := EmptyStr;
  lblPlName.Caption := EmptyStr;
  lblPlRank.Caption := EmptyStr;
  lblM1.Caption := EmptyStr;
  lblM2.Caption := EmptyStr;
end;




procedure TfrmMain.InitSecondPart;
const
  totCards = 109;
  eachDeck = 54;
var
  CardList: TList<TCard>;
  RandomIndices: TList<Integer>; // array of Integer; // TArray<Integer>;
  i, RandIndex: Integer;
begin
  //
  if Assigned(PWav) then
    sndPlaySound(nil, SND_NODEFAULT);
  if Assigned(TSGIFImage) then
  begin
    TSGIFImage.Free;
    TSGIFImage := nil;
  end;
  if Assigned(PLGIFImage) then
  begin
    PLGIFImage.Free;
    PLGIFImage := nil;
  end;

  if Assigned(lstPLCards) then
    lstPLCards.Clear;
  if Assigned(lstTSCards) then
    lstTSCards.Clear;
  if Assigned(lstCaptives) then
    lstCaptives.Clear;
  if Assigned(lstPLStack) then
    lstPLStack.Clear;
  if Assigned(lstSTStack) then
    lstSTStack.Clear;
  if Assigned(lstPlayground) then
    lstPlayground.Clear;

  //if Button1.Enabled = False then
  Button1.Enabled := True;

   DelphiAndRegistryDontMatchWON       := 0;
   DelphiAndRegistryDontMatchLOST      := 0;
   DelphiAndRegistryDontMatchABANDONED := 0;


  try
    CardList := Cards;

    RandomIndices := TList<Integer>.Create; // Create a new TList to store the random indices

    while RandomIndices.Count < eachDeck do
    begin
      RandIndex := Random(totCards);
      if not RandomIndices.Contains(RandIndex) then
        RandomIndices.Add(RandIndex);
    end;

    for i := 0 to RandomIndices.Count - 1 do
      lstPLCards.Add(CardList[RandomIndices[i]].Index);

    for i := 0 to totCards - 1 do
    begin
      if not lstPLCards.Contains(CardList[i].Index) then
        lstTSCards.Add(CardList[i].Index);
    end;

    //At this point: lstPLCards 54 lstTSCards 55
    lstTSCards.Delete(0); //delete the first of the list
    lstSTStack.TrimExcess;
    ShuffleList(lstPLCards);

    lblCDPl.Caption := IntToStr(lstPLCards.Count);
    lblCDTs.Caption := IntToStr(lstTSCards.Count);
    lblCSPl.Caption := IntToStr(lstPLStack.Count);
    lblCSTs.Caption := IntToStr(lstSTStack.Count);

    RandomIndices.Free;
  except
    on e: Exception do
    begin
      MessageDlg('Ουψ. Exception class name : ' + e.ClassName + ' ' + 'Exception message : ' + e.Message, mtError, mbOKCancel, 0);
    end;
  end;
end;




procedure TfrmMain.lblPlayerClick(Sender: TObject);
begin
  if GetKeyState(VK_CONTROL) < 0 then  //if control key is pressed
    OpenLinkByClickAnyLbl(TLabel(Sender));
end;

procedure TfrmMain.lblPlNameClick(Sender: TObject);
begin
  if GetKeyState(VK_CONTROL) < 0 then  //if control key is pressed
    OpenLinkByClickAnyLbl(TLabel(Sender));
end;

procedure TfrmMain.lblTheSkafClick(Sender: TObject);
begin
  if GetKeyState(VK_CONTROL) < 0 then  //if control key is pressed
    OpenLinkByClickAnyLbl(TLabel(Sender));
end;

procedure TfrmMain.lblTSNameClick(Sender: TObject);
begin
  if GetKeyState(VK_CONTROL) < 0 then  //if control key is pressed
    OpenLinkByClickAnyLbl(TLabel(Sender));
end;

procedure TfrmMain.OpenLinkByClickAnyLbl(aDaLbl: TLabel);
var
  strCaptureName: string;
begin
  strCaptureName := StringReplace(Trim(aDaLbl.Caption), '@', '', [rfReplaceAll]);
  strCaptureName := 'https://twitter.com/' + strCaptureName;
  try
    ShellExecute(0, 'open', PChar(strCaptureName), nil, nil, SW_SHOWNORMAL);
  except
    MessageDlg('Meh. Δεν μπόρεσα να ανοίξω το λινκ. Soz.', mtError, [mbOK], 0);
  end;
end;



function TfrmMain.assColorz(n: Integer): TColor;
begin
  case n of //uses Winapi.Windows for RGB:
    2: Result := RGB(220, 220, 220); // Gainsboro (light grey)
    3: Result := RGB(255, 255, 0); // Yellow
    4: Result := RGB(154, 205, 50); // Yellow-green
    5: Result := RGB(255, 215, 0); //Yellow-orange
    6: Result := RGB(0, 128, 0); //Green
    7: Result := RGB(255, 165, 0); //Orange
    8: Result := RGB(0, 128, 128); //Blue-green
    9: Result := RGB(0, 0, 255); //Blue
    10: Result := RGB(255, 69, 0); //Red-orange
    11: Result := RGB(255, 0, 0); //Red
    12: Result := RGB(138, 43, 226); //Blue-purple
    13: Result := RGB(204, 50, 153); //Red-purple
    14: Result := RGB(128, 0, 128); //Purple
    15: Result := RGB(128, 128, 128); //Grey
  else
    raise Exception.Create('Ουψ.');
  end;
end;


procedure TfrmMain.PageControl1Changing(Sender: TObject; var AllowChange: Boolean);  // NOT : TfrmMain.PageControl1Change(Sender: TObject);
begin
  AllowChange := False;
end;


procedure TfrmMain.Button2Click(Sender: TObject);
var
  sName: string;
  vTmp: Variant;
  rgstr : TRegistry;
  bRslt : Boolean;
begin
  sName := EmptyStr;
  bRslt := False;


  try
    vTmp := RegistryAssignOrRead();

    rgstr := TRegistry.Create(KEY_READ);
    rgstr.RootKey := HKEY_CURRENT_USER;

    rgstr.Access := KEY_WRITE;
    bRslt := rgstr.OpenKey('Software\theTheTheTwitty\', True);
    if not bRslt then
    begin
      MessageDlg('Θεματάκια με την registry. Απροσδόκητα.', mtError, [mbOK], 0);
      raise Exception.Create('Ουψ.');
    end;

    try
      DelphiAndRegistryDontMatchWON := vTmp[4];
      DelphiAndRegistryDontMatchLOST := vTmp[5];
      DelphiAndRegistryDontMatchABANDONED := vTmp[6];

      if CheckBox1.Checked then
      begin
        rgstr.WriteString('Sounds and Music', 'Yes');
        FGPlayASound('MobyWav', True);
      end
      else
      begin
        rgstr.WriteString('Sounds and Music', 'No');
        FGPlayASound('Ding', False);
      end;

      sName := vTmp[1];
      sName := Trim(sName);
      Edit1.Text := Trim(Edit1.Text);
      if Edit1.Text = '' then
        Edit1.Text := 'Παίχτουραζ';

      if sName <> Edit1.Text then
      begin
         if sName = '' then
         begin
           rgstr.WriteString('Player Name', 'Παίχτουραζ');
           sName := 'Παίχτουραζ';
         end
         else
         begin
           rgstr.WriteString('Player Name', Edit1.Text);
           sName := Edit1.Text;
         end;
      end;

      lblPlayer.Caption := sName;
      Label6.Caption := 'Μπάζες ' + sName;
      Label7.Caption := 'Κάρτες ' + sName;

      if ((rbtnNormal.Checked and (vTmp[2] = 'No')) or
          (rbtnFast.Checked and (vTmp[2] = 'Yes')) or
          (not rbtnNormal.Checked and not rbtnFast.Checked)) then
      begin
        if rbtnNormal.Checked then
        begin
          rgstr.WriteString('Normal Mode', 'Yes');
          bNormal := True;
        end
        else
        begin
          rgstr.WriteString('Normal Mode', 'No');
          bNormal := False;
        end;
      end;

      if (Trim(VarToStr(vTmp[7])) <> Trim(IntToStr(cbStyles.ItemIndex))) then
        rgstr.WriteInteger('Visual Style', cbStyles.ItemIndex);

    finally
      rgstr.CloseKey();
      rgstr.Free;
    end;


    try
      PageControl1.OnChanging := nil;
      PageControl1.ActivePageIndex := 1;
    finally
      PageControl1.OnChanging := PageControl1Changing;
    end;


    bGameInProgress := True;


    except on e: Exception do
      begin
        MessageDlg('Ουψ. Exception class name : ' + e.ClassName + ' ' + 'Exception message : ' + e.Message, mtError, [mbOK], 0);
        Exit();
      end;
  end;
end;






procedure TfrmMain.DesignStuff(aaPLcard, aaTScard:Integer;  vrntRNPL, vrntRNTS: Variant; bSMdl: Boolean);
var
  clrTmp: TColor;
  iTmpPl, iTmpTs: Integer;
  sTmpPl, sTmpTs: string;
  instanceWar: TfrmWar;

  ResStreamPL, ResStreamTS: TResourceStream;
begin
  iTmpPl := vrntRNPL[0];
  sTmpPl := vrntRNPL[1];

  clrTmp := assColorz(iTmpPl);
  with pnlPlayer do
    StyleElements := StyleElements - [seClient];
  pnlPlayer.Color := clrTmp;

  lblPlName.Caption := sTmpPl;
  lblPlRank.Caption := IntToStr(iTmpPl);

  iTmpTs := vrntRNTS[0];
  sTmpTs := vrntRNTS[1];

  clrTmp := assColorz(iTmpTs);
  with pnlTheSkaf do
    StyleElements := StyleElements - [seClient];
  pnlTheSkaf.Color := clrTmp;

  lblTSName.Caption := sTmpTs;
  lblTSRank.Caption := IntToStr(iTmpTs);

  if bSMdl then
  begin
    if iTmpPl = iTmpTs {CardInfoPL[0] = CardInfoTS[0]} then
    begin
      lblM1.Caption := '=';
      lblM2.Caption := '=';

      //if i am to use current procedure twice (1 before changing lists and 2 after) then it's good as it is

      try
        instanceWar := TfrmWar.Create(Self); //TfrmWar.Create(nil);
        instanceWar.ShowModal;
      finally
        instanceWar.Free;
      end;
    end;
  end;

  if iTmpPl > iTmpTs then
  begin
    lblM1.Caption := '<';
    lblM2.Caption := '<';
  end;

  if iTmpPl < iTmpTs then
  begin
    lblM1.Caption := '>';
    lblM2.Caption := '>';
  end;


  if chkbThanasis.Checked then
  begin
    try
      if Assigned(PLGIFImage) then
        PLGIFImage.Free;
      PLGIFImage := TGIFImage.Create;
      ResStreamPL := TResourceStream.Create(HInstance, DaResourceIdent(iTmpPl), RT_RCDATA); //ResStreamPL := TResourceStream.Create(HInstance, 'GifImgHighResTest', RT_RCDATA);
      try
        PLGIFImage.LoadFromStream(ResStreamPL);
      finally
        ResStreamPL.Free;
      end;
      imgPL.Picture.Assign(PLGIFImage);
      (imgPL.Picture.Graphic as TGIFImage).Animate := True;
      imgPL.Stretch := True;

      if Assigned(TSGIFImage) then
        TSGIFImage.Free;
      TSGIFImage := TGIFImage.Create;
      ResStreamTS := TResourceStream.Create(HInstance, DaResourceIdent(iTmpTs), RT_RCDATA);
      try
        TSGIFImage.LoadFromStream(ResStreamTS);
      finally
        ResStreamTS.Free;
      end;
      imgTS.Picture.Assign(TSGIFImage);
      (imgTS.Picture.Graphic as TGIFImage).Animate := True; //TODO: chk AnimateLoop and AnimateSpeed
      imgTS.Stretch := True;

    except on e: Exception do
      begin
        e.Message := 'Error while loading GIF image from resource: ' + e.Message;
        raise;
      end;
    end;
  end;


  if not UpdPBarsAndFLabels(lstCaptives.Count, lstTSCards.Count, lstSTStack.Count, lstPLCards.Count, lstPLStack.Count, 108) then
  begin
    MessageDlg('Ουψ. Ουψ. Ουψ.', mtError, [mbOK], 0);
    raise Exception.Create('Ουψ.');
  end;
end;


procedure TfrmMain.FGPlayASound(const AResName: string; bLoop: Boolean);
//Now public: //var
//   HResource: TResourceHandle;
//   HResData: THandle;
//   PWav: Pointer;
 begin
  HResource := FindResource(HInstance, PChar(AResName), RT_RCDATA);
  if HResource <> 0 then begin
    HResData:=LoadResource(HInstance, HResource);
    if HResData <> 0 then begin
      PWav:=LockResource(HResData);
      if Assigned(PWav) then
      begin
        // uses MMSystem
        sndPlaySound(nil, SND_NODEFAULT); // nil = stop currently playing

        if bLoop then
          sndPlaySound(PWav, SND_ASYNC or SND_MEMORY or SND_LOOP)
        else
          sndPlaySound(PWav, SND_ASYNC or SND_MEMORY);
      end;
      //      UnlockResource(HResData); // unnecessary per MSDN
      //      FreeResource(HResData);   // unnecessary per MSDN
    end;
  end
  else
    RaiseLastOSError;
end;

function TfrmMain.DaResourceIdent(iRank: Integer): string;
var
  strResourceName: string;
begin
  strResourceName := EmptyStr;
  case iRank of
     2: strResourceName := 'GifImage02';
     3: strResourceName := 'GifImage03';
     4: strResourceName := 'GifImage04';
     5: strResourceName := 'GifImage05';
     6: strResourceName := 'GifImage06';
     7: strResourceName := 'GifImage07';
     8: strResourceName := 'GifImage08';
     9: strResourceName := 'GifImage09';
    10: strResourceName := 'GifImage10';
    11: strResourceName := 'GifImage11';
    12: strResourceName := 'GifImage12';
    13: strResourceName := 'GifImage13';
    14: strResourceName := 'GifImage14';
    15: strResourceName := 'GifImage15';
    else
      strResourceName := '';
  end;
  Result := strResourceName;
end;


procedure TfrmMain.Button1Click(Sender: TObject);
var
  CardInfoPL, CardInfoTS: Variant;
  j, i1, i2,
  iInformEndingAndAskTmp: Integer;
begin
  iInformEndingAndAskTmp := -1;
  iClickityClick := iClickityClick + 1;

  lstPLCards.TrimExcess;
  lstTSCards.TrimExcess;
  lstPLStack.TrimExcess;
  lstSTStack.TrimExcess;
  lstCaptives.TrimExcess;
  lstPlayground.TrimExcess;


  if ((lstPLCards.Count > 2) and (lstTSCards.Count > 2)) then
  begin
        i1 := lstPLCards[0];
        lstPLCards.Delete(0);
        i2 := lstTSCards[0];
        lstTSCards.Delete(0);
        CardInfoPL := FindCardByIndex(i1);
        CardInfoTS := FindCardByIndex(i2);

        DesignStuff(i1, i2, CardInfoPL, CardInfoTS, True);

        if CardInfoPL[0] > CardInfoTS[0] then
        begin
          if lstCaptives.Count > 0 then
          begin
            for j := 0 to lstCaptives.Count - 1 do
            begin
              lstPLStack.Add(lstCaptives[j]);
            end;
          end;
          lstPLStack.Add(i1);
          lstPLStack.Add(i2);
          if Assigned(lstCaptives) then
            lstCaptives.Clear;
        end;

        if CardInfoPL[0] < CardInfoTS[0] then
        begin
          if lstCaptives.Count > 0 then
          begin
            for j := 0 to lstCaptives.Count - 1 do
            begin
              lstSTStack.Add(lstCaptives[j]);
            end;
          end;
          lstSTStack.Add(i1);
          lstSTStack.Add(i2);
          if Assigned(lstCaptives) then
            lstCaptives.Clear;
        end;

        if CardInfoPL[0] = CardInfoTS[0] then
        begin
          lstCaptives.Add(i1);
          i1 := lstPLCards[0];
          lstPLCards.Delete(0);
          lstCaptives.Add(i1);
          i1 := lstPLCards[0];
          lstPLCards.Delete(0);

          lstCaptives.Add(i2);
          i2 := lstTSCards[0];
          lstTSCards.Delete(0);
          lstCaptives.Add(i2);
          i2 := lstTSCards[0];
          lstTSCards.Delete(0);

          try
            Button1.Enabled := False;
            Sleep(100);
            Button1.Enabled := True;
          finally
            Button1.Enabled := True;
          end;
        end;

        DesignStuff(i1, i2, CardInfoPL, CardInfoTS, False);
  end
  else
  begin
    bGameInProgress := False; //αλλάζει σε True παρακάτω στην περίπτωση του normal + reshuffle

    if bNormal then
    begin // Κανονικό \/   \/   \/   \/   \/   \/   \/   \/   \/   \/

      if ((Trim(lblTSRank.Caption) = EmptyStr) or (Trim(lblPlRank.Caption) = EmptyStr)) then
      begin
        if lstSTStack.Count >= lstPLStack.Count then
        begin //player looses
          RegistryUpdatesWhenGameEnds(2);
          iInformEndingAndAskTmp := InformEndingAndAsk(-1);

          if iInformEndingAndAskTmp < 0 then
            raise Exception.Create('Ουψ.')
          else
          begin
            if iInformEndingAndAskTmp = 1 then
            begin
              imgPL.Picture := nil;
              imgTS.Picture := nil;

              pnlPlayer.StyleElements := pnlPlayer.StyleElements + [seClient];
              pnlPlayer.Repaint;
              pnlTheSkaf.StyleElements := pnlTheSkaf.StyleElements + [seClient];
              pnlTheSkaf.Repaint;

              InitFirstPart;
              InitSecondPart;
              try
                PageControl1.OnChanging := nil;
                PageControl1.ActivePageIndex := 0;
              finally
                PageControl1.OnChanging := PageControl1Changing;
              end;
            end;
            if iInformEndingAndAskTmp = 2 then
            begin
              Button1.Enabled := False; // disable ώστε να μην τρέξει ξανά η RegistryUpdatesWhenGameEnds(1) - no way Ηose να βάλω counters κλπ
            end;
          end;
        end
        else
        begin //player wins
          RegistryUpdatesWhenGameEnds(1);
          iInformEndingAndAskTmp := InformEndingAndAsk(1);

          if iInformEndingAndAskTmp < 0 then
            raise Exception.Create('Ουψ.')
          else
          begin
            if iInformEndingAndAskTmp = 1 then
            begin
              imgPL.Picture := nil;
              imgTS.Picture := nil;

              pnlPlayer.StyleElements := pnlPlayer.StyleElements + [seClient];
              pnlPlayer.Repaint;
              pnlTheSkaf.StyleElements := pnlTheSkaf.StyleElements + [seClient];
              pnlTheSkaf.Repaint;

              InitFirstPart;
              InitSecondPart;
              try
                PageControl1.OnChanging := nil;
                PageControl1.ActivePageIndex := 0;
              finally
                PageControl1.OnChanging := PageControl1Changing;
              end;
              //TODO
            end;
            if iInformEndingAndAskTmp = 2 then
            begin
              Button1.Enabled := False; // disable ...
              //TODO
            end;
          end;
        end;
      end
      else
      begin
        bGameInProgress := True; //*
        MessageDlg('Ανακάτεμα των μπαζών και τοποθέτησή τους ως κάρτες για παίξιμο.', mtInformation, [mbOK], 0);
        reShuffle;
      end;
    end
    else
    begin // Γρήγορο \/   \/   \/   \/   \/   \/   \/   \/   \/   \/
        if lstSTStack.Count >= lstPLStack.Count then
        begin //player looses
          RegistryUpdatesWhenGameEnds(2);
          iInformEndingAndAskTmp := InformEndingAndAsk(-1);

          if iInformEndingAndAskTmp < 0 then
            raise Exception.Create('Ουψ.')
          else
          begin
            if iInformEndingAndAskTmp = 1 then
            begin
              imgPL.Picture := nil;
              imgTS.Picture := nil;

              pnlPlayer.StyleElements := pnlPlayer.StyleElements + [seClient];
              pnlPlayer.Repaint;
              pnlTheSkaf.StyleElements := pnlTheSkaf.StyleElements + [seClient];
              pnlTheSkaf.Repaint;

              InitFirstPart;
              InitSecondPart;
              try
                PageControl1.OnChanging := nil;
                PageControl1.ActivePageIndex := 0;
              finally
                PageControl1.OnChanging := PageControl1Changing;
              end;
            end;
            if iInformEndingAndAskTmp = 2 then
            begin
              Button1.Enabled := False; // disable ώστε ...
            end;
          end;
        end
        else
        begin //player wins
          RegistryUpdatesWhenGameEnds(1);
          iInformEndingAndAskTmp := InformEndingAndAsk(1);

          if iInformEndingAndAskTmp < 0 then
            raise Exception.Create('Ουψ.')
          else
          begin
            if iInformEndingAndAskTmp = 1 then
            begin
              imgPL.Picture := nil;
              imgTS.Picture := nil;

              pnlPlayer.StyleElements := pnlPlayer.StyleElements + [seClient];
              pnlPlayer.Repaint;
              pnlTheSkaf.StyleElements := pnlTheSkaf.StyleElements + [seClient];
              pnlTheSkaf.Repaint;

              InitFirstPart;
              InitSecondPart;
              try
                PageControl1.OnChanging := nil;
                PageControl1.ActivePageIndex := 0;
              finally
                PageControl1.OnChanging := PageControl1Changing;
              end;
            end;
            if iInformEndingAndAskTmp = 2 then
            begin
               Button1.Enabled := False; // disable ώστε ..
            end;
          end;
        end;
    end;
  end;
end;




procedure TfrmMain.reShuffle;
  function RandomBoolean: Boolean;
  begin
    Randomize;
    Result := Random(2) = 0;
  end;
var
  i, j: Integer;
  sTmp: string;
  lstCTmp: TList<TCard>;
  tmpCard: TCard;
begin
  try
    lstPLCards.TrimExcess;
    lstTSCards.TrimExcess;
    lstPLStack.TrimExcess;
    lstSTStack.TrimExcess;
    lstCaptives.TrimExcess;
    lstPlayground.TrimExcess;
    if Assigned(lstPlayground) then
      lstPlayground.Clear;
    lstCTmp := TList<TCard>.Create;
    lstCTmp.AddRange(Cards);

    if lstCaptives.Count > 0 then
    begin
      for i := 0 to lstCaptives.Count - 1 do
        lstPlayground.Add(lstCaptives[i]);
    end;

    for i := 0 to lstCTmp.Count - 1 do
    begin
      tmpCard := lstCTmp[i];

      if (  (tmpCard.Name = Trim(lblTSName.Caption)) or (tmpCard.Name = Trim(lblPlName.Caption)) ) then
        lstPlayground.Add( tmpCard.Index );
    end;


    if lstPLCards.Count > 0 then
    begin
      for i := 0 to lstPLCards.Count - 1 do
        lstPlayground.Add(lstPLCards[i]);
    end;

    if lstTSCards.Count > 0 then
    begin
      for i := 0 to lstTSCards.Count - 1 do
        lstPlayground.Add(lstTSCards[i]);
    end;

    if Assigned(lstPLCards) then
      lstPLCards.Clear;
    if Assigned(lstTSCards) then
      lstTSCards.Clear;

    lstPLCards.AddRange(lstPLStack);
    lstTSCards.AddRange(lstSTStack);

    i := StrToInt(lblTSRank.Caption); //                  *   ***************************************
    j := StrToInt(lblPlRank.Caption); //                  *
    if i > j then                     //                  *   Εν τω μεταξύ εδώ είναι
      lstTSCards.AddRange(lstPlayground); //              *   οι "δείκτες" μου ότι
    if i < j then //                                      *   τελείωσε η κανονική έκδοση στο παιχνίδι:
      lstPLCards.AddRange(lstPlayground); //              *   Αν τα captions των δύο labels είναι
    if i = j then //                                      *   άδεια, σημαίνει ότι ξαναπέρασε μέσα στην
    begin //                                              *   reShuffle
      if RandomBoolean then //Randomly assign ξέμπαρκες   *
        lstPLCards.AddRange(lstPlayground) //             *
      else //                                             *
        lstTSCards.AddRange(lstPlayground); //            *
    end; //                                               *   ****************************************

    if Assigned(lstPLStack) then
      lstPLStack.Clear;
    if Assigned(lstSTStack) then
      lstSTStack.Clear;
    if Assigned(lstCaptives) then
      lstCaptives.Clear;


    pnlPlayer.Color := PageControl1.Pages[1].Brush.Color;
    pnlTheSkaf.Color := PageControl1.Pages[1].Brush.Color;

    if not UpdPBarsAndFLabels(lstCaptives.Count, lstTSCards.Count, lstSTStack.Count, lstPLCards.Count, lstPLStack.Count, 108) then
    begin
      MessageDlg('Ουψ. Ουψ. Ουψ.', mtError, [mbOK], 0);
      raise Exception.Create('Ουψ.');
    end;

    lblTSName.Caption := EmptyStr;
    lblTSRank.Caption := EmptyStr;
    lblPlName.Caption := EmptyStr;
    lblPlRank.Caption := EmptyStr;
    lblM1.Caption := EmptyStr;
    lblM2.Caption := EmptyStr;

    lstCTmp.Free;
  except
    raise Exception.Create('Ουψ.');
  end;
end;


procedure TfrmMain.ShuffleList(List: TList<Integer>);
var
  I, J, Temp: Integer;
begin
  Randomize;
  for I := List.Count - 1 downto 1 do
  begin
    J := Random(I + 1);
    Temp := List[J];
    List[J] := List[I];
    List[I] := Temp;
  end;
end;

function TfrmMain.UpdPBarsAndFLabels(iCaptives, iTSCards, iTSStack, iPLCards, iPLStack, iYATmp: Integer): Boolean;
var
  bRes: Boolean;
begin
  bRes := False;
  try
    prgBarCaptives.Position := Round((iCaptives / iYATmp) * 100);
    prgBarTSCards.Position  :=  Round((iTSCards / iYATmp) * 100);
    prgBarPLCards.Position  :=  Round((iPLCards / iYATmp) * 100);

    prgBarTSStack.Position :=  Round((iTSStack / iYATmp) * 100);
    prgBarPLStack.Position :=  Round((iPLStack / iYATmp) * 100);

    lblCDPl.Caption := IntToStr(iPLCards);
    lblCDTs.Caption := IntToStr(iTSCards);
    lblCSPl.Caption := IntToStr(iPLStack);
    lblCSTs.Caption := IntToStr(iTSStack);

    bRes := True;
  except
    bRes := False;
  end;
  Result := bRes;
end;



function TfrmMain.InformEndingAndAsk(iWhich: Integer): Integer;
var
  formVarShowResultz: TfrmEndScreen;
  iUserClicked: Integer;
begin
  iUserClicked := -1;
  try
    formVarShowResultz := TfrmEndScreen.Create(Self); //TfrmEndScreen.Create(nil);
    formVarShowResultz.openCondition := iWhich;
    try
      formVarShowResultz.ShowModal;
      iUserClicked := formVarShowResultz.userChoice;
    finally
      formVarShowResultz.Free;
    end;
  except
    iUserClicked := -1;
  end;
  Result := iUserClicked;
end;



{ TCard }

constructor TCard.Create(ARank: Integer; AName: String; AIndex: Integer);
begin
  Rank := ARank;
  Name := AName;
  Index := AIndex;
end;


procedure TfrmMain.AddCreateCards;
//var
//  Cards: TList<TCard>;    <-- Made it public
begin
    Cards := TList<TCard>.Create;

    try
      Cards.Add(TCard.Create(15, '@i0annaA', 1));
      Cards.Add(TCard.Create(15, '@fdelafraga', 2));
      Cards.Add(TCard.Create(15, '@loukritia_sin', 3));
      Cards.Add(TCard.Create(15, '@Myriam_K', 4));
      Cards.Add(TCard.Create(15, '@meta_capsule', 5));
      Cards.Add(TCard.Create(14, '@Axmaria2', 6));
      Cards.Add(TCard.Create(14, '@SorayaMntNegro', 7));
      Cards.Add(TCard.Create(14, '@Efpraxia_Z', 8));
      Cards.Add(TCard.Create(14, '@MinaBirakou', 9));
      Cards.Add(TCard.Create(14, '@asimiti', 10));
      Cards.Add(TCard.Create(14, '@hlektronio', 11));
      Cards.Add(TCard.Create(14, '@NtinaKo', 12));
      Cards.Add(TCard.Create(14, '@ecpoir', 13));
      Cards.Add(TCard.Create(13, '@mhulots', 14));
      Cards.Add(TCard.Create(13, '@The_Stranger_gr', 15));
      Cards.Add(TCard.Create(13, '@YannisNenes', 16));
      Cards.Add(TCard.Create(13, '@komo_dino', 17));
      Cards.Add(TCard.Create(13, '@kurosawa7', 18));
      Cards.Add(TCard.Create(13, '@dust_road', 19));
      Cards.Add(TCard.Create(13, '@kakomyrios', 20));
      Cards.Add(TCard.Create(13, '@isminouta', 21));
      Cards.Add(TCard.Create(12, '@Sofie_Lestrange', 22));
      Cards.Add(TCard.Create(12, '@achilleas_i', 23));
      Cards.Add(TCard.Create(12, '@snolly', 24));
      Cards.Add(TCard.Create(12, '@elever', 25));
      Cards.Add(TCard.Create(12, '@lalakats', 26));
      Cards.Add(TCard.Create(12, '@Eirwn', 27));
      Cards.Add(TCard.Create(12, '@sissoni_', 28));
      Cards.Add(TCard.Create(12, '@virtuelaPr', 29));
      Cards.Add(TCard.Create(11, '@PareToMiden', 30));
      Cards.Add(TCard.Create(11, '@Elendaf', 31));
      Cards.Add(TCard.Create(11, '@c0n_An', 32));
      Cards.Add(TCard.Create(11, '@KrinostoKtinos', 33));
      Cards.Add(TCard.Create(11, '@arizarkan', 34));
      Cards.Add(TCard.Create(11, '@wannabe_bitch', 35));
      Cards.Add(TCard.Create(11, '@kokkini_toufa', 36));
      Cards.Add(TCard.Create(11, '@beatBukowski', 37));
      Cards.Add(TCard.Create(10, '@mariatoualeta', 38));
      Cards.Add(TCard.Create(10, '@Abuelitah', 39));
      Cards.Add(TCard.Create(10, '@JenGtz', 40));
      Cards.Add(TCard.Create(10, '@Anastasialadiab', 41));
      Cards.Add(TCard.Create(10, '@pepe_g12', 42));
      Cards.Add(TCard.Create(10, '@aeisixtir', 43));
      Cards.Add(TCard.Create(10, '@belzeboulis', 44));
      Cards.Add(TCard.Create(10, '@to_vraki', 45));
      Cards.Add(TCard.Create(9, '@TsimasN', 46));
      Cards.Add(TCard.Create(9, '@NotaSM', 47));
      Cards.Add(TCard.Create(9, '@la_FouM', 48));
      Cards.Add(TCard.Create(9, '@psarianot', 49));
      Cards.Add(TCard.Create(9, '@mao_tse_tung', 50));
      Cards.Add(TCard.Create(9, '@domianos', 51));
      Cards.Add(TCard.Create(9, '@apyrenus', 52));
      Cards.Add(TCard.Create(9, '@SimosoKastoras', 53));
      Cards.Add(TCard.Create(8, '@ste_pl', 54));
      Cards.Add(TCard.Create(8, '@kurosakis_kunt', 55));
      Cards.Add(TCard.Create(8, '@ni_taf_zita', 56));
      Cards.Add(TCard.Create(8, '@avraamakis', 57));
      Cards.Add(TCard.Create(8, '@Pitsie_Pop', 58));
      Cards.Add(TCard.Create(8, '@SookiCookie', 59));
      Cards.Add(TCard.Create(8, '@xxChaosCreator', 60));
      Cards.Add(TCard.Create(8, '@kokotron', 61));
      Cards.Add(TCard.Create(7, '@To_pouli_tou_Ro', 62));
      Cards.Add(TCard.Create(7, '@iosif3rd', 63));
      Cards.Add(TCard.Create(7, '@spigaro', 64));
      Cards.Add(TCard.Create(7, '@PGPapanikolaou', 65));
      Cards.Add(TCard.Create(7, '@v_margar', 66));
      Cards.Add(TCard.Create(7, '@loch_nerd', 67));
      Cards.Add(TCard.Create(7, '@KostasVL', 68));
      Cards.Add(TCard.Create(7, '@AchilleasK', 69));
      Cards.Add(TCard.Create(6, '@Cato_Fong', 70));
      Cards.Add(TCard.Create(6, '@JohnPless1', 71));
      Cards.Add(TCard.Create(6, '@stavroulaber', 72));
      Cards.Add(TCard.Create(6, '@Biskotes', 73));
      Cards.Add(TCard.Create(6, '@diakoptis', 74));
      Cards.Add(TCard.Create(6, '@zolam_a', 75));
      Cards.Add(TCard.Create(6, '@didakou', 76));
      Cards.Add(TCard.Create(6, '@pastafloraki', 77));
      Cards.Add(TCard.Create(5, '@Nanukaki', 78));
      Cards.Add(TCard.Create(5, '@abouterleichda', 79));
      Cards.Add(TCard.Create(5, '@pru4ever', 80));
      Cards.Add(TCard.Create(5, '@s4nuy3', 81));
      Cards.Add(TCard.Create(5, '@distinction_an', 82));
      Cards.Add(TCard.Create(5, '@lydiavs', 83));
      Cards.Add(TCard.Create(5, '@th4lis', 84));
      Cards.Add(TCard.Create(5, '@PartyGirl_Laura', 85));
      Cards.Add(TCard.Create(4, '@el_sewhere', 86));
      Cards.Add(TCard.Create(4, '@FlamingosPascal', 87));
      Cards.Add(TCard.Create(4, '@chelsomina', 88));
      Cards.Add(TCard.Create(4, '@The3dacc', 89));
      Cards.Add(TCard.Create(4, '@AnastasiaTheGr', 90));
      Cards.Add(TCard.Create(4, '@ay_chaparrita', 91));
      Cards.Add(TCard.Create(4, '@PhDPainslut', 92));
      Cards.Add(TCard.Create(4, '@FUITA__', 93));
      Cards.Add(TCard.Create(3, '@AGiamali', 94));
      Cards.Add(TCard.Create(3, '@ChristosCnikas', 95));
      Cards.Add(TCard.Create(3, '@kukutux', 96));
      Cards.Add(TCard.Create(3, '@belleelene', 97));
      Cards.Add(TCard.Create(3, '@samoporadidop', 98));
      Cards.Add(TCard.Create(3, '@tsakoyan', 99));
      Cards.Add(TCard.Create(3, '@ChatziSoti', 100));
      Cards.Add(TCard.Create(3, '@fstylekallithea', 101));
      Cards.Add(TCard.Create(2, '@Byzoskability', 102));
      Cards.Add(TCard.Create(2, '@GregKafetzo', 103));
      Cards.Add(TCard.Create(2, '@Mafaldadadaaaa', 104));
      Cards.Add(TCard.Create(2, '@annamouxatheis', 105));
      Cards.Add(TCard.Create(2, '@Anastasiaklgrf', 106));
      Cards.Add(TCard.Create(2, '@energeiofaga', 107));
      Cards.Add(TCard.Create(2, '@Diaprysios_', 108));
      Cards.Add(TCard.Create(2, '@Cheemba', 109));
    except
      raise Exception.Create('Ουψ. Cards gone wrong');
    end;
end;






function TfrmMain.FindCardByIndex(Index: Integer): Variant;
var
  lstCardzzz: TList<TCard>;
  Card: TCard;
  I: Integer;
begin
  try
    lstCardzzz := TList<TCard>.Create;
    lstCardzzz.AddRange(Cards);

    for I := 0 to lstCardzzz.Count - 1 do
    begin
      Card := lstCardzzz[I];
      if Card.Index = Index then
      begin
        Result := VarArrayOf([Card.Rank, Card.Name]);
        Exit;
      end;
    end;
    raise Exception.CreateFmt('Ουψ. Card with index %d not found', [Index]);
  finally
    lstCardzzz.Free;
  end;
end;




procedure TfrmMain.cbStylesChange(Sender: TObject);
var
  i: Integer;
begin
  i := cbStyles.ItemIndex;
  try
    case i of
      -1: begin
        strProperStyleName := 'Tablet Dark';
      end;
      0: begin
        strProperStyleName := 'Golden Graphite';
      end;
      1: begin
        strProperStyleName := 'Charcoal Dark Slate';
      end;
      2: begin
        strProperStyleName := 'Ruby Graphite';
      end;
      3: begin
        strProperStyleName := 'Cobalt XEMedia';
      end;
      4: begin
        strProperStyleName := 'Glossy';
      end;
      else
      begin
        strProperStyleName := 'Windows';
      end;
    end;
  except
    strProperStyleName := 'Windows';
  end;

  if Assigned(TStyleManager.ActiveStyle) then
    TStyleManager.TrySetStyle(strProperStyleName)
  else
    TStyleManager.TrySetStyle('Windows');
end;




function TfrmMain.RegistryAssignOrRead(): Variant;
var
  reg : TRegistry;
  openResult : Boolean;

  strSoundz, strPlayer, strNormal: String;
  dtCollectedSince: TDateTime;
  iGamesWon, iGamesLost, iGamesAb,
  iStyle, iBtnClickedX: Integer;
begin
  strSoundz        := 'No';
  strPlayer        := 'Παίχτουρας';
  strNormal        := 'No';
  dtCollectedSince := Now(); //EncodeDateTime(1971, 6, 16, 16, 30, 0, 0);
  iGamesWon        := 0;
  iGamesLost       := 0;
  iGamesAb         := 0;
  iStyle           := -1;
  iBtnClickedX     := 0;

  try
    reg := TRegistry.Create(KEY_READ);
    reg.RootKey := HKEY_CURRENT_USER;



    if (not reg.KeyExists('Software\theTheTheTwitty\')) then
    begin
      reg.Access := KEY_WRITE;
      openResult := reg.OpenKey('Software\theTheTheTwitty\', True);

      if (openResult = False) then
      begin
        MessageDlg('Θεματάκια με την registry, χρησιμοποιώ default τιμές.', mtError, mbOKCancel, 0);

        lblAbandoned.Caption := '-';
        lblLost.Caption := '-';
        lblWon.Caption := '-';
        rbtnFast.Checked := True;
        Edit1.Text := 'Παίχτουραζ';
        cbStyles.ItemIndex := -1;
        lblClix.Caption := '-';

        Result :=
          VarArrayOf(['Zonk',
                      'Παίχτουραζ',
                      'Zonk',
                      EncodeDateTime(1971, 6, 16, 16, 30, 0, 0),
                      -1,
                      -1,
                      -1,
                      -1,
                      -1]);
      end;

      try
        if not reg.KeyExists('Koulis aka Moses aka Cheetah') then
          reg.WriteString('Koulis aka Moses aka Cheetah', '🤡');
        if not reg.KeyExists('Sounds and Music') then
          reg.WriteString('Sounds and Music', 'No');
        if not reg.KeyExists('Player Name') then
          reg.WriteString('Player Name', 'Παίχτουρας');
        if not reg.KeyExists('Normal Mode') then
          reg.WriteString('Normal Mode', 'No');
        if not reg.KeyExists('Stats collected since') then
          reg.WriteDateTime('Stats collected since', dtCollectedSince);
        if not reg.KeyExists('Games Won') then
          reg.WriteInteger('Games Won', 0);
        if not reg.KeyExists('Games Lost') then
          reg.WriteInteger('Games Lost', 0);
        if not reg.KeyExists('Games Abandoned') then
          reg.WriteInteger('Games Abandoned', 0);

        if not reg.KeyExists('Visual Style') then
          reg.WriteInteger('Visual Style', -1);
        if not reg.KeyExists('Times Clicked') then
          reg.WriteInteger('Times Clicked', 0);
      finally
        reg.CloseKey();
        reg.Free;
      end;

    end
    else //KeyExists('Software\theTheTheTwitty\') ΟΠΟΤΕ ΔΙΑΒΑΖΟΥΜΕ ΕΔΩ : <------
    begin
      reg.Access := KEY_READ; //KEY_WRITE;
      openResult := reg.OpenKey('Software\theTheTheTwitty\', False);
      if not openResult then
      begin
        Exit();  //kaboom
      end;

      try
        if reg.ValueExists('Sounds and Music') then
          strSoundz := reg.ReadString('Sounds and Music')
        else
          strSoundz := 'Zonk';

        if reg.ValueExists('Player Name') then
          strPlayer := reg.ReadString('Player Name')
        else
          strPlayer := 'Παίχτουραζ';

        if reg.ValueExists('Normal Mode') then
          strNormal := reg.ReadString('Normal Mode')
        else
          strNormal := 'Zonk';

        if reg.ValueExists('Stats collected since') then
          dtCollectedSince := reg.ReadDateTime('Stats collected since')
        else
          dtCollectedSince := EncodeDateTime(1971, 6, 16, 16, 30, 0, 0);

        if reg.ValueExists('Games Won') then
          iGamesWon := reg.ReadInteger('Games Won')
        else
          iGamesWon := -1;

        if reg.ValueExists('Games Lost') then
          iGamesLost := reg.ReadInteger('Games Lost')
        else
          iGamesLost := -1;

        if reg.ValueExists('Games Abandoned') then
          iGamesAb := reg.ReadInteger('Games Abandoned')
        else
          iGamesAb := -1;

        if reg.ValueExists('Visual Style') then
          iStyle := reg.ReadInteger('Visual Style')
        else
          iStyle := -1;

        if reg.ValueExists('Times Clicked') then
          iBtnClickedX := reg.ReadInteger('Times Clicked')
        else
          iBtnClickedX := 0;


      finally
        reg.CloseKey();
        reg.Free;
      end;
    end;

    Result :=
      VarArrayOf([strSoundz,
                  strPlayer,
                  strNormal,
                  dtCollectedSince,
                  iGamesWon,
                  iGamesLost,
                  iGamesAb,
                  iStyle,
                  iBtnClickedX]);
  except
    on e: Exception do
    begin
      MessageDlg('Ουψ. Exception class name : ' + e.ClassName + ' ' + 'Exception message : ' + e.Message, mtError, [mbOK], 0);
      Exit();
    end;
  end;
end;



procedure TfrmMain.RegistryUpdatesWhenGameEnds(endMode: Integer);
var
  reg : TRegistry;
  openResult : Boolean;
  iTmp: Integer;
begin
  iTmp := 0;
  try
    reg := TRegistry.Create(KEY_READ OR KEY_WOW64_64KEY); //reg := TRegistry.Create(KEY_READ);
    reg.RootKey := HKEY_CURRENT_USER;
    if (reg.KeyExists('Software\theTheTheTwitty\')) then
    begin
      reg.Access := KEY_WRITE OR KEY_WOW64_64KEY; //reg.Access := KEY_WRITE;
      openResult := reg.OpenKey('Software\theTheTheTwitty\', True);
      if (openResult = False) then
        raise Exception.Create('Ουψ.');
      try
        reg.WriteInteger('Times Clicked', iClickityClick);


        if endMode = 666 then //το σταμάτησε στην μέση
        begin
          //reg.Access := KEY_READ OR KEY_WOW64_64KEY; //reg.Access := KEY_READ;
          //iTmp := reg.ReadInteger('Games Abandoned');
          //reg.Access := KEY_WRITE OR KEY_WOW64_64KEY; //reg.Access := KEY_WRITE;
          iTmp := DelphiAndRegistryDontMatchABANDONED + 1;
          reg.WriteInteger('Games Abandoned', iTmp);
        end
        else
        if endMode = 1 then //έφτασε μέχρι τέλους, δεν το σταμάτησε στην μέση : NIKHΣE
        begin
          //reg.Access := KEY_READ OR KEY_WOW64_64KEY; //reg.Access := KEY_READ;
          //iTmp := reg.ReadInteger('Games Won');
          //reg.Access := KEY_WRITE OR KEY_WOW64_64KEY; //reg.Access := KEY_WRITE;
          iTmp := DelphiAndRegistryDontMatchWON + 1;
          reg.WriteInteger('Games Won', iTmp);
        end
        else
        if endMode = 2 then //έφτασε μέχρι τέλους, δεν το σταμάτησε στην μέση : ΕΧΑΣΕ
        begin
          //reg.Access := KEY_READ OR KEY_WOW64_64KEY; //reg.Access := KEY_READ;
          //iTmp := reg.ReadInteger('Games Lost');
          //reg.Access := KEY_WRITE OR KEY_WOW64_64KEY; //reg.Access := KEY_WRITE;
          iTmp := DelphiAndRegistryDontMatchLOST + 1;
          reg.WriteInteger('Games Lost', iTmp);
        end
        else
          raise Exception.Create('Ουψ.');
      finally
        reg.CloseKey();
        reg.Free;
      end;
    end
    else
      raise Exception.Create('Ουψ.');
  except
    on e: Exception do
    begin
      MessageDlg('Ουψ. Exception class name : ' + e.ClassName + ' ' + 'Exception message : ' + e.Message, mtError, [mbOK], 0);
      Exit();
    end;
  end;
end;






function TfrmMain.fileVer: string;
var
  FileName: string;
  VersionInfo: Pointer;
  VersionInfoSize, Dummy: DWORD;
  VersionValue: PVSFixedFileInfo;
  strR: string;
begin
  strR := EmptyStr;
  try
    FileName := ParamStr(0);
    VersionInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);

    if VersionInfoSize > 0 then
    begin
      GetMem(VersionInfo, VersionInfoSize);

      try
        if GetFileVersionInfo(PChar(FileName), 0, VersionInfoSize, VersionInfo) then
        begin
          if VerQueryValue(VersionInfo, '\', Pointer(VersionValue), Dummy) then
          begin
            strR :=
              IntToStr(VersionValue.dwFileVersionMS shr 16) + '.' +
              IntToStr(VersionValue.dwFileVersionMS and $FFFF) + '.' +
              IntToStr(VersionValue.dwFileVersionLS shr 16) + '.' +
              IntToStr(VersionValue.dwFileVersionLS and $FFFF);
          end;
        end;
      finally
        FreeMem(VersionInfo);
      end;
    end;
    Result := strR;
  except
    Result := EmptyStr;
  end;
end;

//mutex HELPER kinda thing for my app BLOCK \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//mutex HELPER kinda thing for my app BLOCK \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
//mutex HELPER kinda thing for my app BLOCK \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

procedure TfrmMain.ProcessParam(const Param: string);
begin
  // TODO : Code to process a parameter if any, will think about it
end;

procedure TfrmMain.UMEnsureRestored(var Msg: TMessage);
begin
  if IsIconic(Application.Handle) then
    Application.Restore;
  if not Visible then
    Visible := True;
  Application.BringToFront;
  SetForegroundWindow(Self.Handle);
end;

procedure TfrmMain.WMCopyData(var Msg: TWMCopyData);
var
  PData: PChar;
  Param: string;
begin
  if Msg.CopyDataStruct.dwData <> cCopyDataWaterMark then
    raise Exception.Create(
      'Ουψ. Invalid data structure passed in WM_COPYDATA'
    );
  PData := Msg.CopyDataStruct.lpData;
  while PData^ <> #0 do
  begin
    Param := PData;
    ProcessParam(Param);
    Inc(PData, Length(Param) + 1);
  end;
  Msg.Result := 1;
end;

procedure TfrmMain.CreateParams(var Params: TCreateParams);
begin
  inherited;
  StrCopy(Params.WinClassName, cWindowClassName);
end;

//mutex HELPER kinda thing for my app BLOCK /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//mutex HELPER kinda thing for my app BLOCK /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
//mutex HELPER kinda thing for my app BLOCK /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\



initialization
  ReportMemoryLeaksOnShutdown := True;

end.
