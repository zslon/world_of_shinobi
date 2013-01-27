#!/usr/bin/wish8.5
#directory
set campdir [file normalize [file dirname $argv0]]
set mydir [file join $campdir .. ..]
#mission
global m
set m [lindex $argv 0]
#window
wm geometry . 1024x576
wm maxsize . 1024 576
wm minsize . 1024 576
wm title . {World of Shinobi}
canvas .c -height 576 -width 1024 -bg black
source [file join $mydir utils math.tcl]
source [file join $mydir utils image.tcl]
source [file join $mydir utils help.tcl]
#Rock Lee statistic 
proc rock_lee_stats {{type "skill"}} {
	global campdir mydir skills accessskills tai speed tailist hidenlist nin gen
	source [file join $campdir personstat.tcl]
	set tailist [list "konoha-senpu" "shofu" "konoha-dai-senpu" "omote-renge" "ura-renge" "konoha-goriki-senpu" "tsuten-kyaku" "asakujaku" "konoha-congoriki-senpu" "hirudora"]
	set hidenlist [list "suiken" "hachimon-1" "hachimon-2" "hachimon-3" "hachimon-4" "hachimon-5" "hachimon-6" "hachimon-7" "hachimon-8"]
	#suiken, kaimon, shofu and konoha senpu is always accessible
	set accessskills [list "suiken" "hachimon-1" "shofu" "konoha-senpu"]
	if {[is_in "hachimon-1" $skills]} {
		lappend accessskills "hachimon-2"
	}
	if {[is_in "hachimon-2" $skills] && ($level > 1)} {
		lappend accessskills "hachimon-3"
	}
	if {[is_in "hachimon-3" $skills]} {
		lappend accessskills "hachimon-4"
	}
	if {[is_in "hachimon-4" $skills] && ($level > 2)} {
		lappend accessskills "hachimon-5"
	}
	if {[is_in "hachimon-5" $skills]} {
		lappend accessskills "hachimon-6"
	}
	if {[is_in "hachimon-6" $skills] && ($level > 3)} {
		lappend accessskills "hachimon-7"
	}
	if {[is_in "hachimon-7" $skills]} {
		lappend accessskills "hachimon-8"
	}
	if {$level > 1 && [is_in "konoha-senpu" $skills]} {
		lappend accessskills "konoha-dai-senpu"
	}
	if {$level > 1 && [is_in "hachimon-1" $skills]} {
		lappend accessskills "omote-renge"
	}	
	if {$level > 1 && [is_in "hachimon-3" $skills]} {
		lappend accessskills "ura-renge"
	}
	if {$level > 2 && [is_in "konoha-dai-senpu" $skills]} {
		lappend accessskills "konoha-goriki-senpu"
	}
	if {$level > 2 && [is_in "hachimon-6" $skills]} {
		lappend accessskills "asakujaku"
	}
	if {$level > 2} {
		lappend accessskills "tsuten-kyaku"
	}
	if {$level > 3 && [is_in "hachimon-7" $skills]} {
		lappend accessskills "hirudora"
	}
	if {$level > 3 && [is_in "konoha-goriki-senpu" $skills]} {
		lappend accessskills "konoha-congoriki-senpu"
	}
	set i 0
	while {$i < [llength $accessskills]} {
		if {[is_in [lindex $accessskills $i] $skills]} {
			set accessskills [lreplace $accessskills $i $i] 
		} else {
			incr i
		}
	}
	image create photo individualpanel -file [file join $mydir images skills lee lee-[set level].gif]
	image create photo accesspanel -file [file join $mydir images skills lee accessible.gif]
	create_skillpanel
	list_placing $tailist 325 98
	list_placing $hidenlist 705 98
}
proc click_skill {ex ey {status "skill"}} {
	global tai speed mydir tailist hidenlist campdir m
	list_info $tailist $ex $ey 325 98 $status "tai"
	list_info $hidenlist $ex $ey 705 98 $status
	#attack button
	if {[object_in $ex $ey 149 544 45 45]} {
		skillinfo {Strike} {attack} [expr 3 + $tai] [expr 2 + $tai/2]
	}	
	#kunai button
	if {[object_in $ex $ey 212 544 45 45]} {
		skillinfo {Kunai throw} {kunai} 5 $speed
	}
	if {$status == "no skill"} {
		#go button
		if {[object_in $ex $ey 817 502 125 25]} {
			catch {
				destory .i
				destroy .m
			}
			.c delete all
			source [file join $campdir mission$m.tcl]
		}
		#exit button
		if {[object_in $ex $ey 817 537 125 25]} {
			exec [file join $mydir menu.tcl] &
			exit
		}
	}
}
proc begin {} {
	bind .c <ButtonPress> {
		click_skill %x %y "no skill"
	}
	rock_lee_stats 
}
rock_lee_stats 
if {[lindex $argv 1] == 0} {
	set st "no skill"
} else {
	set st "skill"
	after 250 {skillmessage}
}
bind .c <ButtonPress> {
	click_skill %x %y $st
}
pack .c -side top
