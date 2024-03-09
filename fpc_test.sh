#!/bin/bash

PWD=$(cd $(dirname $0);pwd)
CNAKO=$PWD/cnako1fpc

# compile for fpc
fpc -Mdelphi -g -gv -dFPC -dCNAKOEX -vewh cnako1fpc.dpr

$CNAKO $PWD/fpc_test.nako | iconv -f cp932


