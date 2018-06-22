Unit umainform;

{$mode objfpc}{$H+}

Interface

Uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Spin,
  TypesHelpers, uGifViewer;

Type

  { TMainForm }

  TMainForm = Class(TForm)
    btnPauseAnimation: TButton;
    btnStartAnimation: TButton;
    btnStopAnimation: TButton;
    chkCenterGIF: TCheckBox;
    chkStretchGIF: TCheckBox;
    btnChooseBackgroundColor: TColorButton;
    chkTansparent: TCheckBox;
    chkViewRawFrame: TCheckBox;
    edtViewFrameIndex: TSpinEdit;
    Label1: TLabel;
    Label4: TLabel;
    lblCurrentFrame: TLabel;
    Label6: TLabel;
    lblTotalFrame: TLabel;
    lblFileName: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblVersion: TLabel;
    lblFrameCount: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    pnlAnimationPlayer: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    pnlSelectFrame: TPanel;
    pnlView: TPanel;
    Procedure btnChooseBackgroundColorColorChanged(Sender: TObject);
    Procedure btnPauseAnimationClick(Sender: TObject);
    Procedure btnStartAnimationClick(Sender: TObject);
    Procedure btnStopAnimationClick(Sender: TObject);
    Procedure chkCenterGIFClick(Sender: TObject);
    Procedure chkStretchGIFChange(Sender: TObject);
    Procedure chkTansparentChange(Sender: TObject);
    Procedure edtViewFrameIndexChange(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormDropFiles(Sender: TObject; Const FileNames: Array Of String);
  private
  protected
    GifViewer : TGIFViewer;
    GIFLoaded : Boolean;
    Procedure DoOnBitmapLoadError(Sender: TObject; Const ErrorCount: Integer; Const ErrorList: TStringList);
    Procedure DoOnFrameChange(Sender: TObject);
  public


  End;

Var
  MainForm: TMainForm;

Implementation

{$R *.lfm}

Uses uErrorBoxForm;

Function EllipsisPath(Const sFilePath: String; MaxChar: Integer): String;
Const
  Sep = '...';
Var
  pName, aPath, plpath, prPath: String;
  Diff, middle, maxl, fileLen:  Integer;
Begin
  Result := sFilePath;
  maxl := MaxChar - 4;

  If (Length(sFilePath) > maxl) Then
  Begin
    pName := ExtractFileName(sFilePath);
    fileLen := Length(pName);
    middle := Length(sFilePath) - (filelen) Div 2;
    If middle > maxchar Then
    Begin
      middle := (maxchar - filelen) Div 2;
    End;
    aPath := ExtractFilePath(sFilePath);
    plPath := LeftStr(aPath, middle - 3);
    Diff := Maxl - (middle - 3);
    prPath := RightStr(aPath, diff);
    Result := plPath + Sep + prPath + pName;
  End;
End;

{ TMainForm }

Procedure TMainForm.DoOnBitmapLoadError(Sender: TObject; Const ErrorCount: Integer; Const ErrorList: TStringList);
Begin
  If ErrorCount > 0 then
  begin
    ErrorBoxForm.Memo1.Lines.Clear;
    ErrorBoxForm.Memo1.Lines := ErrorList;
    ErrorBoxForm.ShowModal;
  End;
End;

Procedure TMainForm.DoOnFrameChange(Sender: TObject);
Begin
  lblCurrentFrame.Caption := Succ(GIFViewer.CurrentFrameIndex).ToString;
End;

Procedure TMainForm.FormDropFiles(Sender: TObject; Const FileNames: Array Of String);
  function GetCharWidth : Integer;
  var
    bmp: TBitmap;
  begin
    Result := 0;
    bmp := TBitmap.Create;
    try
      bmp.Canvas.Font.Assign(Self.Font);
      Result := bmp.Canvas.TextWidth('W');
    finally
      bmp.Free;
    end;
  end;

var
   ImageFileName : String;
Begin
  Try
    Try
      GIFLoaded := False;
      Screen.Cursor := crHourGlass;
      ImageFileName := FileNames[0];
      GifViewer.LoadFromFile(ImageFileName);
      lblFileName.Caption := EllipsisPath(ImageFileName, (lblFileName.ClientWidth Div GetCharWidth));
      lblVersion.Caption := GifViewer.Version;
      lblFrameCount.Caption := GifViewer.FrameCount.ToString;
      pnlAnimationPlayer.Enabled := (GifViewer.FrameCount>1);
      pnlSelectFrame.Enabled := (GifViewer.FrameCount>1);
      edtViewFrameIndex.MaxValue := GifViewer.FrameCount-1;
      edtViewFrameIndex.Value := 0;
      lblCurrentFrame.Caption := '1';
      lblTotalFrame.Caption := GifViewer.FrameCount.ToString;
      GIFLoaded := True;

    Finally
      Screen.Cursor := crDefault;
    End;
  Except
    On E: Exception Do
    Begin
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
      Exit;
    End
    Else
    Begin
      MessageDlg('Erreur Inconnue : ' +//E.Message+
        #13 + #10 + 'Ok pour continuer' + #13 + #10 + 'Abandonner pour quitter l''application', mtError, [mbOK, mbAbort], 0);
    End;
  End;;
end;

Procedure TMainForm.btnStartAnimationClick(Sender: TObject);
Begin
  pnlSelectFrame.Enabled := False;
  lblCurrentFrame.Caption := '1';
  GifViewer.Start;
end;

Procedure TMainForm.btnStopAnimationClick(Sender: TObject);
Begin
  pnlSelectFrame.Enabled := True;
  lblCurrentFrame.Caption := '1';
  GifViewer.Stop;
end;

Procedure TMainForm.chkCenterGIFClick(Sender: TObject);
Begin
  GifViewer.Center := not(GifViewer.Center);
end;

Procedure TMainForm.chkStretchGIFChange(Sender: TObject);
Begin
  GifViewer.Stretch := not(GifViewer.Stretch);
end;

Procedure TMainForm.chkTansparentChange(Sender: TObject);
Begin
  GifViewer.Transparent := not(GifViewer.Transparent);
end;

Procedure TMainForm.edtViewFrameIndexChange(Sender: TObject);
Begin
  if not(GIFLoaded) then exit;
  if edtViewFrameIndex.Text<>'' then
  begin
    if not(chkViewRawFrame.Checked) then GIFViewer.DisplayFrame(edtViewFrameIndex.Value)
    else GIFViewer.DisplayRawFrame(edtViewFrameIndex.Value);
  End;
end;

Procedure TMainForm.FormCreate(Sender: TObject);
Begin
  GifViewer := TGIFVIewer.Create(Self);
  With GifViewer do
  Begin
    Parent := pnlView;
    Align := alClient;
    Top := 10;
    Left := 10;
    Center := True;
    AutoSize := true;
    OnLoadError := @DoOnBitmapLoadError;
    OnFrameChange := @DoOnFrameChange;
    //OnFrameChanged := @DoOnFrameChanged;
  End;
end;

Procedure TMainForm.FormDestroy(Sender: TObject);
Begin
  FreeAndNil(GifViewer);
end;

Procedure TMainForm.btnPauseAnimationClick(Sender: TObject);
Begin
  GifViewer.Pause;
end;

Procedure TMainForm.btnChooseBackgroundColorColorChanged(Sender: TObject);
Begin
  pnlView.Color := btnChooseBackgroundColor.ButtonColor;
  pnlView.Invalidate;
end;

End.

