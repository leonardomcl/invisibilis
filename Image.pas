unit Image;

interface

uses
FMX.Graphics, System.SysUtils, System.Types, System.UITypes, System.Classes;

function RemoverMetadados(const ImagemOriginal: TBitmap): TBitmap;
function ExtrairBytesDaImagem(const Imagem: TBitmap): TBytes;
procedure EsconderBytesNaImagem(const Dados: TBytes;
  const ImagemOriginal: TBitmap; const CaminhoSalvar: string);

implementation

function RemoverMetadados(const ImagemOriginal: TBitmap): TBitmap;
var
  NovoBitmap: TBitmap;
begin
  // 1. Cria um novo objeto Bitmap com as mesmas dimensões
  NovoBitmap := TBitmap.Create(ImagemOriginal.Width, ImagemOriginal.Height);
  try
    // 2. O segredo: Ao usar Canvas.DrawBitmap, o Delphi copia apenas os
    // pixels para o novo objeto, deixando para trás os cabeçalhos EXIF/IPTC.
    if NovoBitmap.Canvas.BeginScene then
    begin
      try
        NovoBitmap.Canvas.DrawBitmap(ImagemOriginal,
          RectF(0, 0, ImagemOriginal.Width, ImagemOriginal.Height),
          RectF(0, 0, ImagemOriginal.Width, ImagemOriginal.Height), 1.0);
      finally
        NovoBitmap.Canvas.EndScene;
      end;
    end;

    // 3. Retorna a cópia limpa
    Result := NovoBitmap;
  except
    NovoBitmap.Free;
    raise;
  end;
end;

function ExtrairBytesDaImagem(const Imagem: TBitmap): TBytes;
var
  PixelData: TBitmapData;
  X, Y, BitPos, BitIndex, ByteIndex, TotalBits, DadosSize: Integer;
  ColorRec: TAlphaColorRec;
  R, G, B: Byte;
  Header: array[0..3] of Byte;
  CurrentBit: Byte;
begin
  Result := nil;
  if not Imagem.Map(TMapAccess.Read, PixelData) then Exit;
  try
    BitIndex := 0;
    // Precisamos de 32 bits (4 bytes) para ler o tamanho inicial (Header)
    TotalBits := 32;
    DadosSize := 0;

    for Y := 0 to Imagem.Height - 1 do
    begin
      for X := 0 to Imagem.Width - 1 do
      begin
        ColorRec.Color := PixelData.GetPixel(X, Y);

        // Canais R, G, B
        for BitPos := 0 to 2 do
        begin
          if BitIndex < TotalBits then
          begin
            case BitPos of
              0: CurrentBit := ColorRec.R and 1;
              1: CurrentBit := ColorRec.G and 1;
              2: CurrentBit := ColorRec.B and 1;
            end;

            ByteIndex := BitIndex div 8;

            // Se estamos no Header
            if BitIndex < 32 then
            begin
              if BitIndex mod 8 = 0 then Header[ByteIndex] := 0;
              Header[ByteIndex] := Header[ByteIndex] or (CurrentBit shl (7 - (BitIndex mod 8)));

              // Se acabamos de ler os 32 bits do Header, descobrimos o tamanho real
              if BitIndex = 31 then
              begin
                DadosSize := PInteger(@Header[0])^;
                if (DadosSize <= 0) or (DadosSize > (Imagem.Width * Imagem.Height)) then
                  Exit; // Imagem não contém dados válidos
                SetLength(Result, DadosSize);
                TotalBits := 32 + (DadosSize * 8);
              end;
            end
            else
            begin
              // Lendo os dados reais
              ByteIndex := (BitIndex - 32) div 8;
              if (BitIndex - 32) mod 8 = 0 then Result[ByteIndex] := 0;
              Result[ByteIndex] := Result[ByteIndex] or (CurrentBit shl (7 - ((BitIndex - 32) mod 8)));
            end;

            Inc(BitIndex);
          end;
        end;
        if (TotalBits > 32) and (BitIndex >= TotalBits) then Break;
      end;
      if (TotalBits > 32) and (BitIndex >= TotalBits) then Break;
    end;
  finally
    Imagem.Unmap(PixelData);
  end;
end;

procedure EsconderBytesNaImagem(const Dados: TBytes;
  const ImagemOriginal: TBitmap; const CaminhoSalvar: string);
var
  BitIndex, ByteIndex, TotalBits: Integer;
  X, Y, BitPos: Integer;
  PixelData: TBitmapData;
  R, G, B, A: Byte;
  DataBit: Byte;
  Header: TBytes;
  FullData: TBytes;
  ColorRec: TAlphaColorRec; // Record para manipulação de cores
begin
  if (ImagemOriginal = nil) or (ImagemOriginal.IsEmpty) then
    raise Exception.Create('Imagem inválida ou vazia.');

  // 1. Criamos um "Header" de 4 bytes para salvar o TAMANHO do array de dados
  SetLength(Header, 4);
  PInteger(@Header[0])^ := Length(Dados);

  // 2. Unimos o Header (tamanho) + Dados (conteúdo)
  FullData := Header + Dados;
  TotalBits := Length(FullData) * 8;

  // Verificação de espaço (3 bits por pixel: R, G e B)
  if (ImagemOriginal.Width * ImagemOriginal.Height * 3) < TotalBits then
    raise Exception.Create
      ('Imagem muito pequena para esconder este volume de dados!');

  // 3. Acesso aos Pixels da imagem para edição
  if ImagemOriginal.Map(TMapAccess.ReadWrite, PixelData) then
    try
      BitIndex := 0;
      for Y := 0 to ImagemOriginal.Height - 1 do
      begin
        for X := 0 to ImagemOriginal.Width - 1 do
        begin
          // Pega a cor atual do pixel
          ColorRec.Color := PixelData.GetPixel(X, Y);
          R := ColorRec.R;
          G := ColorRec.G;
          B := ColorRec.B;
          A := ColorRec.A;

          // Modifica R, G e B (escondendo 3 bits por pixel)
          for BitPos := 0 to 2 do
          begin
            if BitIndex < TotalBits then
            begin
              ByteIndex := BitIndex div 8;

              // Extrai o bit individual do dado (da esquerda para a direita)
              DataBit := (FullData[ByteIndex] shr (7 - (BitIndex mod 8))) and 1;

              case BitPos of
                0:
                  R := (R and $FE) or DataBit;
                // Altera bit menos significativo do Vermelho
                1:
                  G := (G and $FE) or DataBit;
                // Altera bit menos significativo do Verde
                2:
                  B := (B and $FE) or DataBit;
                // Altera bit menos significativo do Azul
              end;
              Inc(BitIndex);
            end;
          end;

          // Atualiza a cor do pixel com os bits modificados
          ColorRec.R := R;
          ColorRec.G := G;
          ColorRec.B := B;
          ColorRec.A := A;
          PixelData.SetPixel(X, Y, ColorRec.Color);

          // Se já escondemos todos os bits, encerra o loop interno
          if BitIndex >= TotalBits then
            Break;
        end;
        // Se já escondemos todos os bits, encerra o loop externo
        if BitIndex >= TotalBits then
          Break;
      end;
    finally
      // Desmapeia a imagem para liberar a memória e aplicar as alterações
      ImagemOriginal.Unmap(PixelData);
    end;

  // 4. Salva obrigatoriamente como PNG para evitar perda de dados por compressão
  ImagemOriginal.SaveToFile(CaminhoSalvar);
end;

end.
