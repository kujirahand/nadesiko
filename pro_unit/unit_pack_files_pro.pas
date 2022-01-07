unit unit_pack_files_pro;

// define DELUX_VERSION

interface

uses
  {$IFDEF Win32}
  Windows,
  {$ENDIF}
  SysUtils, Classes, hima_types, hima_stream;

procedure DoAngou6(var ms: TMemoryStream; enc:Boolean);

implementation

// �ȈՈÍ�������6�i���s���̂ݓW�J���������^���[�U�[����̓W�J�͎��s����j
procedure DoAngou6(var ms: TMemoryStream; enc:Boolean);
var
  p: PByte;
  i, len: Integer;
  xorb: Byte;
const
  key1:string = 'hL4BQahD9ehfwwjdepQbhRS';
  mWMfOOTenAjVD0iuvnd:string =  'XUaz4yHNVJlQnDY6Aaouce7fRmAleAxWcqRXUbof'+
                'ISHyiUCqHMl8wHyIvbEnN4P0v6SNLg0Kd4';
  Rps9Tuu4rZNo9Xe4pq:string = 'NXUnldcrmD8Hl6tjNQguSlTf2B6PtJI45DmPnmn9apT5T';
  key2:string = 'W4l17woM1FaH1iLcf';

  function rand:Byte;
  var i: Integer;
  begin
    i := Random(256);
    Result := i;
  end;
  
begin
  p := ms.Memory;
  RandSeed := ms.Size;
  len := Length(mWMfOOTenAjVD0iuvnd);

  // �ȈՈÍ����̂��߂̃L�[
  for i := 0 to ms.Size - 1 do
  begin
    xorb := Ord(mWMfOOTenAjVD0iuvnd[i mod len]);
    p^ := (p^ xor xorb) xor rand;
    Inc(p);
  end;
end;

end.
