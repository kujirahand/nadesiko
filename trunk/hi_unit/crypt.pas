unit crypt;

{$LINK crypt3.obj}

interface

function _crypt(pw,salt:PChar):PChar;cdecl;external;

implementation

end.
