unit Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, Winapi.Windows,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ExtCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Layouts, System.IOUtils,
  FMX.Effects, System.Threading, FMX.Edit, System.Math,
  System.NetEncoding, Crypt, Utils, Image, Winapi.MMSystem, FMX.Media,
  Winapi.ShellAPI, FMX.DialogService;

type
  TFPrincipal = class(TForm)
    StatusBar1: TStatusBar;
    Text1: TText;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Rectangle1: TRectangle;
    DropTarget1: TDropTarget;
    MTextoEscrita: TMemo;
    Rectangle2: TRectangle;
    Text2: TText;
    TxtBitsDisponiveis: TText;
    BtnResetHideContent: TSpeedButton;
    ImgHidePreview: TImage;
    Rectangle3: TRectangle;
    Image1: TImage;
    ChkRemoveMetadados: TCheckBox;
    BtnHideContent: TRectangle;
    Text4: TText;
    Image2: TImage;
    ShadowEffect1: TShadowEffect;
    OpenToHideImage: TOpenDialog;
    EdtHideCryptKey: TEdit;
    BtnHideCryptText: TButton;
    Rectangle4: TRectangle;
    DropTarget2: TDropTarget;
    MTextoShow: TMemo;
    Rectangle5: TRectangle;
    BtnResetShowContent: TSpeedButton;
    ImageShowPreview: TImage;
    EdtDecryptKey: TEdit;
    Button1: TButton;
    OpenToShowImage: TOpenDialog;
    Rectangle6: TRectangle;
    Image3: TImage;
    BtnShowImageContent: TRectangle;
    Text3: TText;
    Image4: TImage;
    ShadowEffect2: TShadowEffect;
    TabItem3: TTabItem;
    MediaPlayer1: TMediaPlayer;
    ImageViewer1: TImageViewer;
    Text5: TText;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Text6: TText;
    procedure BtnResetHideContentClick(Sender: TObject);
    procedure DropTarget1Dropped(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure DropTarget1DragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure DropTarget1Click(Sender: TObject);
    procedure MTextoEscritaKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure MTextoEscritaChange(Sender: TObject);
    procedure EdtHideCryptKeyChange(Sender: TObject);
    procedure EdtHideCryptKeyKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure BtnHideCryptTextClick(Sender: TObject);
    procedure BtnHideContentClick(Sender: TObject);
    procedure DropTarget2Click(Sender: TObject);
    procedure BtnResetShowContentClick(Sender: TObject);
    procedure DropTarget2DragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure DropTarget2Dropped(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure Button1Click(Sender: TObject);
    procedure BtnShowImageContentClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Text6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddImageToHide(FileName: string);
    procedure AddImageToShow(FileName: string);
  end;

var
  FPrincipal: TFPrincipal;
  TotalBitsDispEscrita: int64;

implementation

{$R *.fmx}

procedure TFPrincipal.AddImageToShow(FileName: string);
begin

  TTask.Run(
    procedure
    var
      LBitmap: TBitmap;
      LBitsDisp: int64;
    begin
      LBitmap := TBitmap.Create;
      try
        LBitmap.LoadFromFile(FileName);

        TThread.Synchronize(nil,
          procedure
          begin
            ImageShowPreview.Bitmap.Assign(LBitmap);
            DropTarget2.Visible := False;
            ImageShowPreview.Visible := true;
            EdtDecryptKey.Text := '';
          end);
      finally
        LBitmap.Free;
      end;
    end);
end;

procedure TFPrincipal.AddImageToHide(FileName: string);
begin

  TTask.Run(
    procedure
    var
      LBitmap: TBitmap;
      LBitsDisp: int64;
    begin
      LBitmap := TBitmap.Create;
      try
        LBitmap.LoadFromFile(FileName);
        LBitsDisp := CalcularBytesDisponiveis(LBitmap);

        // Tudo que mexe na tela volta para a MainThread
        TThread.Synchronize(nil,
          procedure
          begin
            ImgHidePreview.Bitmap.Assign(LBitmap);
            DropTarget1.Visible := False;
            ImgHidePreview.Visible := true;
            MTextoEscrita.MaxLength := LBitsDisp;
            TotalBitsDispEscrita := LBitsDisp;
            TxtBitsDisponiveis.Text := LBitsDisp.ToString;
            EdtHideCryptKey.Text := GenRandomKey();
            EdtHideCryptKey.Enabled := true;
            MTextoEscrita.Enabled := true;
          end);
      finally
        LBitmap.Free;
      end;
    end);

end;

procedure TFPrincipal.DropTarget1Click(Sender: TObject);
begin
  OpenToHideImage.Execute;

  if OpenToHideImage.Files.Count > 1 then
  begin
    OpenToHideImage.Files.Clear;
    TDialogService.MessageDialog('Selecione apenas 1 arquivo!',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if not IsFormatoValido(OpenToHideImage.FileName) then
  begin
    OpenToHideImage.Files.Clear;
    TDialogService.MessageDialog('Escolha um arquivo de imagem válido!',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  AddImageToHide(OpenToHideImage.FileName);

end;

procedure TFPrincipal.DropTarget1DragOver(Sender: TObject;
const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if Length(Data.Files) > 1 then
    Operation := TDragOperation.None

end;

procedure TFPrincipal.DropTarget1Dropped(Sender: TObject;
const Data: TDragObject; const Point: TPointF);
var
  FileName: string;
begin

  if Length(Data.Files) > 1 then
  begin
    TDialogService.MessageDialog('Por favor, arraste apenas um arquivo por vez',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  FileName := Data.Files[0];

  // 2. Verifica se é uma pasta
  if TDirectory.Exists(FileName) then
  begin

    TDialogService.MessageDialog
      ('Você arrastou uma pasta. Por favor, selecione um arquivo de imagem.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if not IsFormatoValido(FileName) then
  begin

    TDialogService.MessageDialog('Escolha um arquivo de imagem válido!',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  AddImageToHide(FileName);

end;

procedure TFPrincipal.DropTarget2Click(Sender: TObject);
begin
  OpenToShowImage.Execute;

  if OpenToShowImage.Files.Count > 1 then
  begin
    OpenToShowImage.Files.Clear;
    TDialogService.MessageDialog('Selecione apenas 1 arquivo!',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if not IsFormatoValido(OpenToShowImage.FileName) then
  begin
    OpenToShowImage.Files.Clear;
    TDialogService.MessageDialog('Escolha um arquivo de imagem válido!',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  AddImageToShow(OpenToShowImage.FileName);
end;

procedure TFPrincipal.DropTarget2DragOver(Sender: TObject;
const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if Length(Data.Files) > 1 then
    Operation := TDragOperation.None
end;

procedure TFPrincipal.DropTarget2Dropped(Sender: TObject;
const Data: TDragObject; const Point: TPointF);
var
  FileName: string;
begin

  if Length(Data.Files) > 1 then
  begin

    TDialogService.MessageDialog('Por favor, arraste apenas um arquivo por vez',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  FileName := Data.Files[0];

  // 2. Verifica se é uma pasta
  if TDirectory.Exists(FileName) then
  begin

    TDialogService.MessageDialog
      ('Você arrastou uma pasta. Por favor, selecione um arquivo de imagem.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if not IsFormatoValido(FileName) then
  begin
    TDialogService.MessageDialog('Escolha um arquivo de imagem válido!',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  AddImageToShow(FileName);

end;

procedure TFPrincipal.EdtHideCryptKeyChange(Sender: TObject);
begin
  if EdtHideCryptKey.Text.Trim = '' then
  begin
    BtnHideCryptText.Enabled := False;
    Exit;
  end;
  BtnHideCryptText.Enabled := true;
end;

procedure TFPrincipal.EdtHideCryptKeyKeyUp(Sender: TObject; var Key: Word;
var KeyChar: WideChar; Shift: TShiftState);
begin
  if EdtHideCryptKey.Text.Trim = '' then
  begin
    BtnHideCryptText.Enabled := False;
    Exit;
  end;
  BtnHideCryptText.Enabled := true;
end;

procedure TFPrincipal.FormShow(Sender: TObject);
var
  ResStream: TResourceStream;
  TempPath: string;
begin
  TempPath := TPath.Combine(TPath.GetTempPath, 'song.mp3');

  // 2. Extrai o MP3 do executável para o disco (se ainda não existir)
  if not TFile.Exists(TempPath) then
  begin
    ResStream := TResourceStream.Create(HInstance, 'SONG', RT_RCDATA);
    try
      ResStream.SaveToFile(TempPath);
    finally
      ResStream.Free;
    end;
  end;

  // 3. Configura o MediaPlayer para tocar o arquivo extraído
  MediaPlayer1.FileName := TempPath;
  MediaPlayer1.Play;
end;

procedure TFPrincipal.MTextoEscritaChange(Sender: TObject);
var
  totalRestante: Integer;
begin
  if (ImgHidePreview.Bitmap.IsEmpty) then
    Exit;

  totalRestante := TotalBitsDispEscrita - Length(MTextoEscrita.Text);
  TxtBitsDisponiveis.Text := totalRestante.ToString

end;

procedure TFPrincipal.MTextoEscritaKeyUp(Sender: TObject; var Key: Word;
var KeyChar: WideChar; Shift: TShiftState);
var
  totalRestante: Integer;
begin
  if (ImgHidePreview.Bitmap.IsEmpty) then
    Exit;

  totalRestante := TotalBitsDispEscrita - Length(MTextoEscrita.Text);
  TxtBitsDisponiveis.Text := totalRestante.ToString;

end;

procedure TFPrincipal.SpeedButton1Click(Sender: TObject);
begin
  MediaPlayer1.Play;
end;

procedure TFPrincipal.SpeedButton2Click(Sender: TObject);
begin
  MediaPlayer1.Stop;
end;

procedure TFPrincipal.Text6Click(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://github.com/leonardomcl/invisibilis'),
    nil, nil, SW_SHOWNORMAL);
end;

procedure TFPrincipal.BtnResetShowContentClick(Sender: TObject);
begin
  ImageShowPreview.Bitmap := nil;
  ImageShowPreview.Visible := False;
  DropTarget2.Visible := true;
  MTextoShow.Lines.Clear;
end;

procedure TFPrincipal.BtnShowImageContentClick(Sender: TObject);
var
  BytesExtraidos: TBytes;
  ConteudoExtraido: string;
begin
  // 1. Extrai os bytes da imagem de revelação (conforme sua unit Image)
  BytesExtraidos := ExtrairBytesDaImagem(ImageShowPreview.Bitmap);

  if Length(BytesExtraidos) = 0 then
  begin

    TDialogService.MessageDialog('Nenhuma mensagem encontrada nesta imagem.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  try
    // 2. Verificamos se há uma senha no campo de descriptografia
    if EdtDecryptKey.Text <> '' then
    begin
      try
        // Tentamos descriptografar os bytes extraídos
        // A função DescriptografarParaInvisibilis já retorna a String UTF8 correta
        ConteudoExtraido := DescriptografarParaInvisibilis(BytesExtraidos,
          EdtDecryptKey.Text);
        MTextoShow.Text := ConteudoExtraido;
      except
        // Se a descriptografia falhar (senha errada ou dados corrompidos),
        // tentamos exibir o conteúdo como texto puro ou Base64 para inspeção
        MTextoShow.Text := TNetEncoding.Base64.EncodeBytesToString
          (BytesExtraidos);
        TDialogService.MessageDialog
          ('Não foi possível descriptografar. Verifique a senha.',
          TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);

      end;
    end
    else
    begin
      // 3. Se não houver senha, tentamos converter para string UTF8 (caso seja texto comum)
      // ou exibimos o Base64 se for um binário criptografado.
      try
        ConteudoExtraido := TEncoding.UTF8.GetString(BytesExtraidos);
        MTextoShow.Text := ConteudoExtraido;
      except
        MTextoShow.Text := TNetEncoding.Base64.EncodeBytesToString
          (BytesExtraidos);
      end;
    end;
  finally

    TDialogService.MessageDialog('Processo de extração concluído.',
      TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
  end;
end;

procedure TFPrincipal.Button1Click(Sender: TObject);
var
  StringBytes: TBytes;
  ByteString: String;
begin
  if EdtDecryptKey.Text.Trim = '' then
  begin

    TDialogService.MessageDialog('Digite uma chave para descriptografar.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  StringBytes := TNetEncoding.Base64.DecodeStringToBytes(MTextoShow.Lines.Text);

  ByteString := DescriptografarParaInvisibilis(StringBytes, EdtDecryptKey.Text);

  MTextoShow.Text := ByteString;
end;

procedure TFPrincipal.BtnHideContentClick(Sender: TObject);
var
  SaveDialog: TSaveDialog;
  HideBytesText: TBytes;
  TempBitmap: TBitmap;
  CleanText: string;
begin
  if (MTextoEscrita.Text.Trim = '') or (ImgHidePreview.Bitmap.IsEmpty) then
  begin

    TDialogService.MessageDialog
      ('Certifique-se de carregar uma imagem e digitar um texto.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  // Limpamos possíveis espaços ou quebras de linha que o Base64 pode ter ganho no Memo
  CleanText := MTextoEscrita.Text.Trim.Replace(#13, '').Replace(#10, '');

  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.FileName := 'hided.png';
    SaveDialog.Filter := 'Imagem PNG (*.png)|*.png';

    if SaveDialog.Execute then
    begin
      // Se o texto no memo for o Base64 da criptografia, descodificamos para bytes puros
      if IsBase64(CleanText) then
        HideBytesText := TNetEncoding.Base64.DecodeStringToBytes(CleanText)
      else
        HideBytesText := TEncoding.UTF8.GetBytes(CleanText);

      if ChkRemoveMetadados.IsChecked then
      begin
        TempBitmap := RemoverMetadados(ImgHidePreview.Bitmap);
        try
          EsconderBytesNaImagem(HideBytesText, TempBitmap, SaveDialog.FileName);
          ImgHidePreview.Bitmap.Assign(TempBitmap);
        finally
          TempBitmap.Free;
        end;
      end
      else
      begin
        EsconderBytesNaImagem(HideBytesText, ImgHidePreview.Bitmap,
          SaveDialog.FileName);
      end;

      TDialogService.MessageDialog('Dados ocultados com sucesso!',
        TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  finally
    SaveDialog.Free;
  end;
end;

procedure TFPrincipal.BtnHideCryptTextClick(Sender: TObject);
var
  TextoCriptografadoBase64: string;
  ByteString: TBytes;
begin
  if MTextoEscrita.Text.Trim = '' then
  begin

    TDialogService.MessageDialog('Digite um texto para criptografar.',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  // 1. Gera os bytes criptografados
  ByteString := CriptografarParaInvisibilis(MTextoEscrita.Text,
    EdtHideCryptKey.Text);

  // 2. Converte os bytes "sujos" em uma string Base64 "limpa"
  TextoCriptografadoBase64 := TNetEncoding.Base64.EncodeBytesToString
    (ByteString);

  // 3. Exibe no Memo (Limpando o texto original)
  MTextoEscrita.Lines.Clear;
  MTextoEscrita.Text := TextoCriptografadoBase64;

  TDialogService.MessageDialog('Texto criptografado e convertido para Base64!',
    TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
end;

procedure TFPrincipal.BtnResetHideContentClick(Sender: TObject);
begin
  ImgHidePreview.Bitmap := nil;
  ImgHidePreview.Visible := False;
  DropTarget1.Visible := true;
  TxtBitsDisponiveis.Text := '0';
  TotalBitsDispEscrita := 0;
  MTextoEscrita.MaxLength := 0;
  EdtHideCryptKey.Text := '';
  EdtHideCryptKey.Enabled := False;
  MTextoEscrita.Lines.Clear;
  MTextoEscrita.Enabled := False;

end;

end.
