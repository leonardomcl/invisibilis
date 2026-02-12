unit Utils;

interface

uses
System.RegularExpressions, System.SysUtils, FMX.Graphics, System.IOUtils;

function IsBase64(const AText: string): Boolean;
function GenRandomKey(Tamanho: Integer = 16): string;
function GetFormatoByFileName(const AFileName: string): String;
function IsFormatoValido(const AFileName: string): Boolean;
function CalcularBytesDisponiveis(ABitmap: TBitmap): int64;

implementation

function GenRandomKey(Tamanho: Integer = 16): string;
const
  Alfabeto = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
var
  i: Integer;
begin
  Result := '';
  // Randomize inicializa o gerador de números aleatórios com o relógio do sistema
  Randomize;

  for i := 1 to Tamanho do
  begin
    // Escolhe um caractere aleatório da constante Alfabeto
    Result := Result + Alfabeto[Random(Length(Alfabeto)) + 1];
  end;
end;

function GetFormatoByFileName(const AFileName: string): String;
var
  Ext: string;
begin
  Ext := TPath.GetExtension(AFileName).ToLower;
  Result := Ext;
end;

function IsFormatoValido(const AFileName: string): Boolean;
var
  Ext: string;
begin
  Ext := GetFormatoByFileName(AFileName);
  Result := (Ext = '.png') or (Ext = '.jpg') or (Ext = '.jpeg') or
    (Ext = '.bmp');
end;

function CalcularBytesDisponiveis(ABitmap: TBitmap): int64;
var
  TotalPixels: int64;
begin

  if (ABitmap = nil) or (ABitmap.IsEmpty) then
    Exit(0);

  TotalPixels := ABitmap.Width * ABitmap.Height;

  Result := (TotalPixels * 3) div 8;

end;

function IsBase64(const AText: string): Boolean;
const
  // Regex que valida o alfabeto Base64 e o padding correto
  B64_REGEX = '^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$';
begin
  Result := (AText <> '') and TRegEx.IsMatch(AText, B64_REGEX);
end;

end.
