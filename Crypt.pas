unit Crypt;

interface

uses
  uTPLb_CryptographicLibrary, uTPLb_Codec, uTPLb_CBC, System.SysUtils,
  System.Classes;

function CriptografarParaInvisibilis(const Texto, Senha: string): TBytes;
function DescriptografarParaInvisibilis(const Dados: TBytes;
  const Senha: string): string;

implementation

function DescriptografarParaInvisibilis(const Dados: TBytes;
  const Senha: string): string;
var
  CryptoLib: TCryptographicLibrary;
  Codec: TCodec;
  StreamSaida: TMemoryStream;
  BufferTexto: TBytes;
begin
  Result := '';
  if Length(Dados) = 0 then
    Exit;

  CryptoLib := TCryptographicLibrary.Create(nil);
  Codec := TCodec.Create(nil);
  StreamSaida := TMemoryStream.Create;
  try
    // 1. Configurações idênticas às da Criptografia
    Codec.CryptoLibrary := CryptoLib;
    Codec.StreamCipherId := 'native.StreamToBlock';
    Codec.BlockCipherId := 'native.AES-128';
    Codec.ChainModeId := 'native.CBC';
    Codec.Password := Senha;

    // 2. Sincroniza o motor
    Codec.Reset;

    // 3. Inicia a Descriptografia
    Codec.Begin_DecryptMemory(StreamSaida);
    try
      // Passamos o array de bytes para o motor
      Codec.DecryptMemory(Dados[0], Length(Dados));
    finally
      Codec.End_DecryptMemory;
    end;

    // 4. Converte o resultado de volta para String UTF8
    if StreamSaida.Size > 0 then
    begin
      SetLength(BufferTexto, StreamSaida.Size);
      StreamSaida.Position := 0;
      StreamSaida.ReadBuffer(BufferTexto[0], StreamSaida.Size);
      Result := TEncoding.UTF8.GetString(BufferTexto);
    end;

  finally
    StreamSaida.Free;
    Codec.Free;
    CryptoLib.Free;
  end;
end;

function CriptografarParaInvisibilis(const Texto, Senha: string): TBytes;
var
  CryptoLib: TCryptographicLibrary;
  Codec: TCodec;
  StreamSaida: TMemoryStream;
  BufferTexto: TBytes;
begin
  CryptoLib := TCryptographicLibrary.Create(nil);
  Codec := TCodec.Create(nil);
  StreamSaida := TMemoryStream.Create;
  try
    // 1. Vincula a biblioteca
    Codec.CryptoLibrary := CryptoLib;

    // 2. Configura os IDs exatamente como no exemplo do GitHub
    // No LockBox 3, o StreamCipherId deve ser 'native.StreamToBlock' para usar cifras de bloco como AES
    Codec.StreamCipherId := 'native.StreamToBlock';
    Codec.BlockCipherId := 'native.AES-128';
    // Ou 'native.AES-192' como no seu exemplo
    Codec.ChainModeId := 'native.CBC';

    // 3. Define a senha
    Codec.Password := Senha;

    // 4. Converte o texto para bytes
    BufferTexto := TEncoding.UTF8.GetBytes(Texto);

    // 5. O Reset sincroniza os IDs com o motor interno
    Codec.Reset;

    // 6. Criptografia
    Codec.Begin_EncryptMemory(StreamSaida);
    try
      if Length(BufferTexto) > 0 then
        Codec.EncryptMemory(BufferTexto, Length(BufferTexto));
    finally
      Codec.End_EncryptMemory;
    end;

    // 7. Retorno dos bytes
    SetLength(Result, StreamSaida.Size);
    StreamSaida.Position := 0;
    if StreamSaida.Size > 0 then
      StreamSaida.ReadBuffer(Result[0], StreamSaida.Size);

  finally
    StreamSaida.Free;
    Codec.Free;
    CryptoLib.Free;
  end;
end;

end.
