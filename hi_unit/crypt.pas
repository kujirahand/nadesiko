unit crypt;

{$LINK crypt3.obj}

interface

function _crypt(pw,salt:PAnsiChar):PAnsiChar;cdecl;external;

implementation

end.
