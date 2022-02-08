#!/bin/bash

PWD=$(cd $(dirname $0);pwd)

$PWD/cnako1fpc $* | nkf -w

