unit frmPointerscanConnectDialogUnit;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Sockets, resolve, CEFuncProc;

type

  { TfrmPointerscanConnectDialog }

  TfrmPointerscanConnectDialog = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    cbPriority: TComboBox;
    cbUseLoadedPointermap: TCheckBox;
    edtHost: TEdit;
    edtPort: TEdit;
    edtThreadcount: TEdit;
    lblPriority: TLabel;
    lblNrOfThread: TLabel;
    lblHost: TLabel;
    lblPort: TLabel;
    odLoadPointermap: TOpenDialog;
    procedure btnOkClick(Sender: TObject);
    procedure cbUseLoadedPointermapChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    host: THostAddr;
    port: UInt16;
    threadcount: integer;
    scannerpriority: TThreadPriority;
  end;

var
  frmPointerscanConnectDialog: TfrmPointerscanConnectDialog;

implementation

{$R *.lfm}

{ TfrmPointerscanConnectDialog }

procedure TfrmPointerscanConnectDialog.btnOkClick(Sender: TObject);
var hr:THostResolver;
begin
  hr:=THostResolver.Create(nil);
  try

    host:=StrToNetAddr(edtHost.text);

    if host.s_bytes[4]=0 then
    begin
      if hr.NameLookup(edtHost.text) then
        host:=hr.NetHostAddress
      else
        raise exception.create('host:'+edtHost.text+' could not be resolved');
    end;


  finally
    hr.free;
  end;


  port:=strtoint(edtport.text);

  threadcount:=strtoint(edtthreadcount.text);
  case cbpriority.itemindex of
    0: scannerpriority:=tpIdle;
    1: scannerpriority:=tpLowest;
    2: scannerpriority:=tpLower;
    3: scannerpriority:=tpNormal;
    4: scannerpriority:=tpHigher;
    5: scannerpriority:=tpHighest;
    6: scannerpriority:=tpTimeCritical;
  end;


  modalresult:=mrok;
end;

procedure TfrmPointerscanConnectDialog.cbUseLoadedPointermapChange(
  Sender: TObject);
begin
  if cbUseLoadedPointermap.checked and odLoadPointermap.Execute then
    cbUseLoadedPointermap.Caption:='Use loaded pointermap:'+ExtractFileName(odLoadPointermap.FileName)
  else
    cbUseLoadedPointermap.checked:=false;


end;

procedure TfrmPointerscanConnectDialog.FormCreate(Sender: TObject);
var
  cpucount: integer;
begin
  {cpucount:=GetCPUCount;
  if HasHyperthreading then
    cpucount:=1+(cpucount div 2);

  edtThreadcount.text:=inttostr(cpucount); }
end;

end.

