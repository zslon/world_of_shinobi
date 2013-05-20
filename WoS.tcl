#!/usr/bin/wish8.5
#fonts
font create Arial -family Courier -size 10
#directory
set mydir [file normalize [file dirname $argv0]]
source [file join $mydir menu.tcl]
