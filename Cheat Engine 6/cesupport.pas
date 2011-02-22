unit cesupport;

{$mode delphi}

interface

uses
  lclintf, Classes, SysUtils,forms, controls, windows, activex, comobj, LMessages,
  ExtCtrls;

type TADWindow=class(TCustomForm)
  private
    browserisvalid: boolean;
    browser: Olevariant;


    attachedForm: TCustomForm;
    attachedwindowproc: TWndMethod;
    attachside: TAnchorKind;

    secondsSinceLastShowAd: integer;
    showAdTimer: TTimer;
    counter: integer;
    userurl: string;
    userpercentage: integer;

    procedure checkAdTimer(sender: TObject);
    function getoptionalstring: string;
    function getBase: string;
    procedure hook(var TheMessage: TLMessage);
  public
    optional: string;
    procedure handleMove;
    procedure AttachToForm(form: TCustomForm);
    procedure setPosition(side: TAnchorKind);
    procedure setUserUrl(url: string);
    procedure setUserPercentage(percentage: integer);
    procedure LoadAd;
    constructor CreateNew(AOwner: TComponent;canclose: boolean);
    destructor destroy; override;
end;

var adwindow: TADWindow;

implementation



procedure TADWindow.setUserUrl(url: string);
begin
  userurl:=url;
end;

procedure TADWindow.setUserPercentage(percentage: integer);
begin
  userpercentage:=min(75, percentage);
end;

procedure TADWindow.checkAdTimer(sender: TObject);
begin
  inc(secondsSinceLastShowAd);


end;

procedure TADWindow.handleMove;
var m: TLMMove;
  wr: trect;
  ar: trect;
begin
  LCLIntf.GetWindowRect(attachedform.handle, wr);
  LCLIntf.GetWindowRect(handle, ar);

  case attachside of
    akBottom:
    begin
      top:=wr.Bottom;
      left:=attachedform.left+(attachedform.width div 2) - (width div 2);
    end;

    akTop:
    begin
      top:=wr.top-(ar.bottom-ar.Top);
      left:=attachedform.left+(attachedform.width div 2) - (width div 2);
    end;

    akLeft:
    begin
      left:=attachedform.left-(ar.Right-ar.left)-2;
      top:=attachedform.top+(attachedform.height div 2) - (height div 2);
    end;

    akRight:
    begin
      left:=wr.right;
      top:=attachedform.top+(attachedform.height div 2) - (height div 2);
    end;

  end;
end;

procedure TADWindow.hook(var TheMessage: TLMessage);
begin
  if TheMessage.msg=LM_MOVE then
    handleMove;

  attachedwindowproc(TheMessage);
end;

procedure TADWindow.setPosition(side: TAnchorKind);
begin
  attachside:=side;
  handleMove;
end;

procedure TADWindow.AttachToForm(form: TCustomForm);
var updatemessage: TLMMove;
begin
  //first undo in case a new form is chosen
  if assigned(attachedwindowproc) then
    attachedform.WindowProc:=attachedwindowproc;

 attachedform:=form;
 attachedwindowproc:=form.WindowProc;

 form.WindowProc:=hook;


end;

function TADWindow.getoptionalstring: string;
begin
  if optional<>'' then
    result:='&'+optional
  else
    result:='';
end;

function TADWindow.getBase: string;
begin
  result:='http://www.cheatengine.org/ceads.php';
  if userurl<>'' then //let's see if it's time to show the url of the user
  begin
    if (Random(100)+1)<=userpercentage then  //(1-100) <= userpercentage
      result:=userurl; //do the users url instead

  end;



end;

procedure TADWindow.LoadAd;
var url: widestring;
  pid: dword;
begin

  if (counter=0) or (secondsSinceLastShowAd>120) then
  begin
    GetWindowThreadProcessId(GetForegroundWindow,pid);
    if (counter=0) or (GetCurrentProcessId=pid) then //only show the ad when the foreground window is ce or if it's the first ad
    begin
      if visible and browserisvalid then
      begin
       // BringToFront;
        inc(counter);
        url:=getbase+'?cewidth='+inttostr(clientwidth)+'&ceheight='+inttostr(clientheight)+'&counter='+inttostr(counter)+getoptionalstring;
        browser.Navigate(url);
      end;

      secondsSinceLastShowAd:=0;
    end;
  end;


end;

constructor TADWindow.createNew(AOwner: TComponent; canclose: boolean);
begin
  inherited createnew(AOwner);

  if canClose then
  begin
    BorderStyle:=bsToolWindow;
    bordericons:=[biSystemMenu];
  end
  else
  begin
    BorderStyle:=bsNone;
  end;


  {$ifdef windows}
  try
    browser := CreateOleObject('InternetExplorer.Application');
    windows.setparent(browser.hwnd, handle); // you can use panel1.handle, etc..
    browser.toolbar:=false;
    browser.fullscreen:=true;
    browser.Resizable:=false;
    browser.visible:=true;
    browserisvalid:=true; //we got to this point without a horrible crash, so I guess it's ok
  except

  end;
  {$endif}

  //loadAd;

  showAdTimer:=TTimer.create(self);
  showAdTimer.interval:=1000; //every second
  showAdTimer.OnTimer:=checkAdTimer;
  showAdTimer.enabled:=true;

end;

destructor TADWindow.destroy;
begin
 // browser.Quit();
  browser:=Unassigned;


  if attachedform<>nil then
    attachedform.WindowProc:=attachedwindowproc;

  CoFreeUnusedLibraries;

  inherited destroy;
end;

end.

