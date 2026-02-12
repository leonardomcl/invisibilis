program Invisibilis;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  Principal in 'Principal.pas' {FPrincipal},
  Utils in 'Utils.pas',
  Crypt in 'Crypt.pas',
  Image in 'Image.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.Run;
end.
