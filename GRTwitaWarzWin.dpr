//{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}

program GRTwitaWarzWin;



{$R *.dres}

uses
  Vcl.Forms,
  Winapi.Windows,
  MainFrm in 'MainFrm.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles,
  UStartup in 'UStartup.pas',
  WarFrm in 'WarFrm.pas' {frmWar},
  EndScreenFrm in 'EndScreenFrm.pas' {frmEndScreen};

{$R *.res}

function CanStart: Boolean;  // mutex HELPER kinda thing for my app
var
  Wdw: HWND;
begin
  Wdw := FindDuplicateMainWdw;
  if Wdw = 0 then
    Result := True
  else
    Result := not SwitchToPrevInst(Wdw);
end;

begin
  if CanStart then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
  end;
end.
