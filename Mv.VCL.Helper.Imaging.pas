unit Mv.VCL.Helper.Imaging;

interface

uses
    VCL.Imaging.GifImg;

type
    TGifImageHelper = class helper for TGifImage
        procedure LoadFromResourceName(AInstance: HInst; const AName: string);
    end;


implementation

uses
    System.SysUtils,
    System.Classes,
    WinApi.Windows;     //RT_RCDATA


procedure TGifImageHelper.LoadFromResourceName(AInstance: HInst; const AName: string);
var
    ResStream: TResourceStream;
begin
    try
        ResStream := TResourceStream.Create(AInstance, AName, RT_RCDATA);
        try
            LoadFromStream(ResStream);
        finally
            ResStream.Free;
        end;
    except on E: Exception do
        begin
            E.Message := 'Error while loading GIF image from resource: ' + E.Message;
            raise;
        end;
    end;
end;

end.
