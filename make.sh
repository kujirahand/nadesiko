#!/bin/sh

# compile for fpc
fpc -Mdelphi -g -gv -dFPC -dCNAKOEX -vewh cnako1fpc.dpr

# clear cache
#echo "=== clear cache"
#rm hi_unit/*.ppu
#rm hi_unit/*.o
#rm *.ppu
#echo "========"
#fpc -Mdelphi -g -gv -dFPC -vewh dnako.dpr
#mv libdnako.dylib plug-ins/
#echo "========"
#echo "remove cnako_function cache"
#rm hi_unit/cnako_function.ppu
#rm hi_unit/cnako_function.o
#fpc -Mdelphi -g -gv -dFPC -uCNAKOEX -vewh cnako.dpr
#echo "========"
#./cnako1 | iconv -f cp932


