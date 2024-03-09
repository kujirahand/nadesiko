unit GLDZLIB;

// ******************************************************
// *                                                    *
// *  GLDZLIB ver 3.02    ZLIB Decode/Encode class      *
// *                                                    *
// *   1999-2001 CopyRight Tarquin All Rights Reserved. *
// *                                                    *
// ******************************************************
//

{$I taki.inc}

interface

uses
 Windows, Classes, SysUtils, Graphics,
 SFunc, TKZLIB;

const
 PNGJustFilter         = 0;
 PNGNoneFilter         = 1;
 PNGSubFilter          = 2;
 PNGUpFilter           = 3;
 PNGAvgFilter          = 4;
 PNGPaethFilter        = 5;

type
 PGLDZLIBInfo=^TGLDZLIBInfo;
 TGLDZLIBInfo=record
  owner:             pointer;     // �f�[�^�W�J�E���k�N���X�|�C���^
  zstream:           TZStreamRec; // ZLIB�f�[�^
  zbuf:              pbyte;       // ZLIB�p�o�b�t�@
  zbuflen:           integer;     // ZLIB�p�o�b�t�@�o�C�g��
  IOProc:            function (info: PGLDZLIBInfo): integer; // �ǂݏ����֐�
 end;

 PGLDPNGInfo=^TGLDPNGInfo;
 TGLDPNGInfo=record
  zinfo:             TGLDZLIBInfo; // ZLIB�p�f�[�^

  // r/w
  linelen:           integer;      // �W�J����f�[�^�̃o�C�g��
  outbuf:            pbyte;        // �W�J�����f�[�^�̃o�b�t�@
  prev_row:          pbyte;        // �O���C���f�[�^�o�b�t�@
  pixel_depth:       integer;      // �P�v�f�̃r�b�g��

  // w only
  compressmode:      integer;      // ���k���[�h
  bitcnt:            integer;      // �P�s�N�Z���̃r�b�g��
  filbuf1,filbuf2:   pbyte;        // �t�B���^�p�o�b�t�@
  hist:              pbyte;        // �]�����̃o�b�t�@
 end;

// ZLIB�֌W
function  ZLIBDecodeInit(pg: PGLDZLIBInfo): integer;
procedure ZLIBDecodeFinish(pg: PGLDZLIBInfo);
procedure ZLIBDecodeFlush(pinfo: PGLDZLIBInfo);
function  ZLIBDecode(pinfo: PGLDZLIBInfo; outbuf: pbyte; outlen: integer): integer;

function  ZLIBEncodeInit(pg: PGLDZLIBInfo; compresslevel,zbsize: integer): integer;
procedure ZLIBEncodeFinish(pg: PGLDZLIBInfo);
function  ZLIBEncodeFlush(pg: PGLDZLIBInfo): integer;
function  ZLIBEncode(pinfo: PGLDZLIBInfo; inbuf: pbyte; len: integer): integer;

// PNG�֌W
function png_read_line(pg: PGLDPNGInfo): integer;
function png_write_line(pg: PGLDPNGInfo): integer;


implementation

const
 ZBUFSIZE = 32768;


//---------------------------------------------------------
//  ZLIB�W�J����
//---------------------------------------------------------


//------- ZLIBDecodeInit => �����ݒ�


function ZLIBDecodeInit(pg: PGLDZLIBInfo): integer;
begin
 with pg^ do
 begin
  // ���f�[�^�J��
  if zbuf<>nil then ZLIBDecodeFinish(pg);
  // �������m��
  try
   GetMem(zbuf,ZBUFSIZE)
  except
   zbuf:=nil;
   result:=-1;
   Exit;
  end;
  zstream.next_in:=pchar(zbuf);
  zstream.avail_in:=0;
  zstream.zalloc:=pointer(@zlibAllocMem);
  zstream.zfree:=pointer(@zlibFreeMem);
  zbuflen:=ZBUFSIZE;
  if InFlateInit(zstream)<>Z_OK then
   result:=-1
  else
   result:=0;
 end;
end;


//------- ZLIBDecodeFinish => ZLIB�W�J�I��


procedure ZLIBDecodeFinish(pg: PGLDZLIBInfo);
begin
 with pg^ do
 begin
  if zbuf<>nil then
   begin
    FreeMem(zbuf);
    zbuf:=nil;
    zbuflen:=0;
   end;
  InFlateEnd(zstream);
 end;
end;


//------- ZLIBDecode => ZLIB�œW�J


function ZLIBDecode(pinfo: PGLDZLIBInfo; outbuf: pbyte; outlen: integer): integer;
begin
 result:=0;
 with pinfo^ do
 begin
  zstream.next_out:=pointer(outbuf);
  zstream.avail_out:=outlen;
  while (zstream.avail_out>0) do
  begin
   if zstream.avail_in=0 then
    begin
     result:=IOProc(pinfo);
     if result<>0 then Exit;
    end;
   // �W�J
   result:=inFlate(zstream,0);
   if result<0 then Exit;
  end;
 end;
end;


//------- ZLIBDecodeFlush => ZLIB���Z�b�g


procedure ZLIBDecodeFlush(pinfo: PGLDZLIBInfo);
begin
 InFlateReset(pinfo^.zstream);
 pinfo^.zstream.next_in:=pchar(pinfo^.zbuf);
 pinfo^.zstream.avail_in:=0;
end;


//---------------------------------------------------------
//  PNG�W�J����
//---------------------------------------------------------


//------- png_read_filter_row => �t�B���^����


function png_read_filter_row(pg: PGLDPNGInfo): integer;
var
 i,j,bpp,a,b,c,p,pa,pb,pc,rowbytes: integer;
 rp,lp,pp,cp,xrow,prow: pbyte;

begin
 result:=0;
 with pg^ do
 begin
  j:=outbuf^;
  xrow:=outbuf;
  Inc(xrow);
  prow:=prev_row;
  Inc(prow);
  rowbytes:=linelen-1;
  case j of
   0: // �Ȃ�
      begin
       Exit;
      end;
   1: // VALUE_SUB
      begin
       bpp:=(pixel_depth+7) div 8;
       rp:=xrow;
       Inc(rp,bpp);
       lp:=xrow;
       i:=bpp;
       while(i<rowbytes) do
       begin
        rp^:=(rp^+lp^) and $FF;
        Inc(rp);
        Inc(lp);
        Inc(i);
       end;
      end;
   2: // VALUE_UP
      begin
       i:=0;
       rp:=xrow;
       pp:=prow;
       while(i<rowbytes) do
       begin
        rp^:=(rp^+pp^) and $FF;
        Inc(rp);
        Inc(pp);
        Inc(i);
       end;
      end;
   3: // VALUE_AVG
      begin
       bpp:=(pixel_depth+7) div 8;
       i:=0;
       rp:=xrow;
       pp:=prow;
       while(i<bpp) do
       begin
        rp^:=(rp^+(pp^ div 2)) and $FF;
        Inc(i);
        Inc(rp);
        Inc(pp);
       end;
       lp:=xrow;
       while (i<rowbytes) do
       begin
        rp^:=(rp^+((pp^+lp^) div 2)) and $FF;
        Inc(i);
        Inc(rp);
        Inc(lp);
        Inc(pp);
       end;
      end;
   4: // VALUE_PAETH
      begin
       bpp:=(pixel_depth+7) div 8;
       i:=0;
       rp:=xrow;
       pp:=prow;
       lp:=xrow;
       Dec(lp,bpp);
       cp:=prow;
       Dec(cp,bpp);
       while(i<rowbytes) do
       begin
        b:=pp^;
        if (i>=bpp) then
         begin
          c:=cp^;
          a:=lp^;
         end
        else
         begin
          c:=0;
          a:=0;
         end;
        p:=a+b-c;
        pa:=p-a;
        pb:=p-b;
        pc:=p-c;
        if pa<0 then pa:=-pa;
        if pb<0 then pb:=-pb;
        if pc<0 then pc:=-pc;

        if (pa <= pb) and (pa <= pc) then
         p:=a
        else
         if (pb<=pc) then
          p:=b
         else
          p:=c;
        rp^:=(rp^+p) and $FF;

        Inc(rp);
        Inc(pp);
        Inc(lp);
        Inc(cp);
        Inc(i);
       end;
      end;
  else
   result:=-1;
  end;
 end;
end;


//------- png_read_line => 1���C���W�J(PNG�p)


function png_read_line(pg: PGLDPNGInfo): integer;
begin
 with pg^ do
 begin
  // ZLIB�œW�J
  result:=ZLIBDecode(@(pg^.zinfo),outbuf,linelen);
  if result<0 then Exit;
  // �t�B���^����
  result:=png_read_filter_row(pg);
  if result<0 then Exit;
 end;
end;


//---------------------------------------------------------
//  ZLIB���k����
//---------------------------------------------------------


//------- ZLIBEncodeInit => �����ݒ�


function ZLIBEncodeInit(pg: PGLDZLIBInfo; compresslevel,zbsize: integer): integer;
begin
 with pg^ do
 begin
  // �o�b�t�@�T�C�Y�`�F�b�N
  if (zbsize<=0) or (zbsize>=$40000) then zbsize:=ZBUFSIZE;
  // �J��
  if zbuf<>nil then ZLIBEncodeFinish(pg);
  // �������m��
  try
   GetMem(zbuf,zbsize);
  except
   zbuf:=nil;
   result:=-1;
   Exit;
  end;
  zbuflen:=zbsize;
  zstream.next_out:=pchar(zbuf);
  zstream.avail_out:=zbuflen;
  zstream.zalloc:=pointer(@zlibAllocMem);
  zstream.zfree:=pointer(@zlibFreeMem);

  if deflateInit(zstream,compresslevel)<>Z_OK then
   result:=-1
  else
   result:=0;
 end;
end;


//------- ZLIBEncodeFlush => ���܂��Ă���f�[�^���ꎞ�f���o��


function ZLIBEncodeFlush(pg: PGLDZLIBInfo): integer;
var
 ret: integer;

begin
 with pg^ do
 begin
  // �c������k
  repeat
   ret:=deflate(zstream,Z_FINISH);
   if ret<0 then
    begin
     result:=-1;
     Exit;
    end;
   if (ret<>Z_STREAM_END) and (zstream.avail_out=0) then
    begin
     result:=IOProc(pg);
     if result<>0 then Exit;
     zstream.next_out:=pointer(zbuf);
     zstream.avail_out:=zbuflen;
    end;
  until (ret=Z_STREAM_END);

  // �c��̃f�[�^����������
  if (zstream.avail_out<zbuflen) then result:=IOProc(pg);
  // ZLIB������
  deflateReset(zstream);
 end;
end;


//------- ZLIBEncodeFinish => ZLIB���k�I��


procedure ZLIBEncodeFinish(pg: PGLDZLIBInfo);
begin
 with pg^ do
 begin
  if zbuf<>nil then
   begin
    FreeMem(zbuf);
    zbuf:=nil;
    zbuflen:=0;
   end;
  deFlateEnd(zstream);
 end;
end;


//------- ZLIBEncode => ZLIB�ň��k


function ZLIBEncode(pinfo: PGLDZLIBInfo; inbuf: pbyte; len: integer): integer;
begin
 with pinfo^ do
 begin
  // ZLIB�ň��k
  zstream.next_in:=pointer(inbuf);
  zstream.avail_in:=len;
  while (zstream.avail_in>0) do
  begin
   result:=deflate(zstream,Z_NO_FLUSH);
   if (result<0) then Exit;
   if (zstream.avail_out=0) then
    begin
     result:=IOProc(pinfo);
     if result<>0 then Exit;
     zstream.next_out:=pointer(zbuf);
     zstream.avail_out:=zbuflen;
    end;
  end;
 end;
end;


//---------------------------------------------------------
//  PNG���k����
//---------------------------------------------------------


//------- png_filtercheck => �t�B���^���ʕ]��


function png_filtercheck(pg: PGLDPNGInfo; buf: pbyte): integer;
var
 phist: PArrayLongint;
 i,m,n,len,top1,top2,top3: integer;
 pp: pbyte;

begin
 result:=0;
 with pg^ do
 begin
  phist:=pointer(hist);
  FillChar(phist^,256*sizeof(longint),0);
  // ���v���Ƃ�
  m:=linelen;
  n:=m;
  pp:=buf;
  while (n>0) do
  begin
   phist^[pp^]:=phist^[pp^]+1;
   Inc(pp);
   Dec(n);
  end;
  len:=0;
  top1:=0; top2:=0; top3:=0;
  for i:=0 to 255 do
  begin
   n:=phist^[i];
   if n<>0 then
    begin
     Inc(len);
     if top1<=n then
      begin
       top3:=top2;
       top2:=top1;
       top1:=n;
      end
     else
      if top2<=n then
       begin
        top3:=top2;
        top2:=n;
       end
      else
       if top3<=n then
        top3:=n;
    end;
  end;
  // �]��
  if len<=8 then result:=-1;  // �m��I�I
  if ((top1 div m)*100)>=90 then result:=-1; // �m��I�I
  if result=0 then
   if pg^.pixel_depth<8 then
    result:=Trunc(((m/1.5)/len)*1500+((top1+top2)/m)*1000)
   else
    result:=Trunc(((m/1.5)/len)*1000+((top1+top2+top3)/m)*1000);
 end;
end;


//------- png_write_filter => �t�B���^����


procedure png_write_filter(pg: PGLDPNGInfo);
var
 prow, brow, rbuf, rp, dp, lp, pp, cp: pbyte;
 bpp: integer;
 v, i, n: integer;
 a, b, c, pa, pb, pc, p: integer;

 filtermode, ss: integer;

begin
 with pg^ do
 begin
  bpp:=(pixel_depth+7) div 8;
  prow:=pointer(prev_row);
  brow:=pointer(outbuf);
  rbuf:=pointer(brow);
  n:=linelen-1;
  filtermode:=CompressMode and $FF;

  // �t�B���^�Ȃ��Ȃ甲����
  if (filtermode=PNGNoneFilter) or (filtermode>PNGPaethFilter) then
   begin
    filbuf1^:=0;
    pp:=filbuf1;
    Inc(pp);
    Move(rbuf^,pp^,n);
    Exit;
   end;

  // �Ȃ�
  if (filtermode=PNGJustFilter) then
   begin
    filbuf1^:=0;
    pp:=filbuf1;
    Inc(pp);
    Move(rbuf^,pp^,n);
    ss:=png_filtercheck(pg,filbuf1);
    if ss=-1 then Exit;
    case bitcnt of
     4: Exit;
     1,8: ss:=ss*2;
    end;
   end
  else
   ss:=-1;

  // sub filter
  if (filtermode=PNGSubFilter) or (filtermode=PNGJustFilter) then
   begin
    rp:=pointer(rbuf);
    dp:=pointer(filbuf2);
    Inc(dp);
    lp:=rp;
    i:=0;
    while (i<bpp) do
    begin
     v:=rp^;
     dp^:=v;
     Inc(i);
     Inc(rp);
     Inc(dp);
    end;
    while (i<n) do
    begin
     v:=(rp^-lp^) and $FF;
     dp^:=v;
     Inc(rp);
     Inc(lp);
     Inc(dp);
     Inc(i);
    end;
    filbuf2^:=1;
    if filtermode=PNGJustFilter then a:=png_filtercheck(pg,filbuf2) else a:=-1;
    if (a=-1) or (ss<a) then
     begin
      pp:=filbuf2;
      filbuf2:=filbuf1;
      filbuf1:=pp;
      if a=-1 then Exit;
      ss:=a;
     end;
   end;

   // up filter
   if (filtermode=PNGUpFilter) or (filtermode=PNGJustFilter) then
    begin
     rp:=pointer(rbuf);
     dp:=pointer(filbuf2);
     Inc(dp);
     pp:=pointer(prow);
     i:=0;
     while (i<n) do
     begin
      v:=(rp^-pp^) and $FF;
      dp^:=v;
      Inc(rp);
      Inc(pp);
      Inc(dp);
      Inc(i);
     end;
     // �]��
     filbuf2^:=2;
     if filtermode=PNGJustFilter then a:=png_filtercheck(pg,filbuf2) else a:=-1;
     if (a=-1) or (ss<a) then
      begin
       pp:=filbuf2;
       filbuf2:=filbuf1;
       filbuf1:=pp;
       if a=-1 then Exit;
       ss:=a;
      end;
    end;

   // avg filter
   if (filtermode=PNGAvgFilter) or (filtermode=PNGJustFilter) then
    begin
     rp:=pointer(rbuf);
     dp:=pointer(filbuf2);
     Inc(dp);
     pp:=pointer(prow);
     lp:=rp;
     i:=0;
     while (i<bpp) do
     begin
      v:=(rp^- (pp^ shr 1)) and $FF;
      dp^:=v;
      Inc(rp);
      Inc(dp);
      Inc(pp);
      Inc(i);
     end;
     while i<n do
     begin
      v:=(rp^-((pp^+lp^) shr 1)) and $FF;
      dp^:=v;
      Inc(rp);
      Inc(pp);
      Inc(lp);
      inc(dp);
      Inc(i);
     end;
     // �]��
     filbuf2^:=3;
     if filtermode=PNGJustFilter then a:=png_filtercheck(pg,filbuf2) else a:=-1;
     if (a=-1) or (ss<a) then
      begin
       pp:=filbuf2;
       filbuf2:=filbuf1;
       filbuf1:=pp;
       if a=-1 then Exit;
       ss:=a;
      end;
    end;

   // Paeth filter
   if (filtermode=PNGPaethFilter) or (filtermode=PNGJustFilter) then
    begin
     rp:=pointer(rbuf);
     dp:=pointer(filbuf2);
     Inc(dp);
     pp:=pointer(prow);
     lp:=rp;
     cp:=pp;
     i:=0;
     while (i<bpp) do
     begin
      v:=(rp^-pp^) and $FF;
      dp^:=v;
      Inc(dp);
      Inc(rp);
      Inc(pp);
      Inc(i);
     end;
     while (i<n) do
     begin
      b:=pp^;
      c:=cp^;
      a:=lp^;

      p:=a+b-c;
      pa:=Abs(p-a);
      pb:=Abs(p-b);
      pc:=Abs(p-c);

      if (pa<=pb) and (pa<=pc) then
       p:=a
      else
       if (pb<=pc) then
        p:=b
       else
        p:=c;

      v:=(rp^-p) and $FF;
      dp^:=v;
      Inc(i);
      Inc(rp);
      Inc(dp);
      Inc(cp);
      Inc(pp);
      Inc(lp);
     end;
     // �]��
     filbuf2^:=4;
     if filtermode=PNGJustFilter then a:=png_filtercheck(pg,filbuf2) else a:=-1;
     if (a=-1) or (ss<a) then
      begin
       pp:=filbuf2;
       filbuf2:=filbuf1;
       filbuf1:=pp;
       if a=-1 then Exit;
       ss:=a;
      end;
    end;
 end;
end;


//------- png_write_line => �P���C����������


function png_write_line(pg: PGLDPNGInfo): integer;
begin
 with pg^ do
 begin
  // �t�B���^�[����
  png_write_filter(pg);
  // ZLIB�ň��k
  result:=ZLIBEncode(@(pg^.zinfo),filbuf1,linelen);
 end;
end;



end.
