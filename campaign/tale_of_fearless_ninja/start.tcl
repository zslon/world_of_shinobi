#!/usr/bin/wish8.5
#directory
global campdir st mydir
set campdir [file join $mydir campaign tale_of_fearless_ninja]
#mission
if {$m == 1} {
	set f [open [file join $campdir personstat.tcl] w]
	puts $f "set level 1"
	puts $f "set tai 2"
	puts $f "set gen 1"
	puts $f "set nin 2"
	puts $f "set speed 1"
	puts $f "set skills \{taju-kage-bunshin nine-tails\}" 
	close $f 
}
if {$ar == 0} {
	set st "no skill"
} else {
	set st "skill"
	after 250 {skillmessage}
}
#window
source [file join $mydir utils math.tcl]
source [file join $mydir utils image.tcl]
source [file join $mydir utils help.tcl]
catch {
	canvas .c -height 576 -width 1024 -bg black
}
.c delete all

#Rock Lee statistic 
proc rock_lee_stats {{type "skill"}} {
	global campdir mydir skills accessskills tai speed tailist genlist futonlist fuinlist kuchieselist hidenlist nin gen
	source [file join $campdir personstat.tcl]
	set tailist [list "shofu" "konoha-senpu" "bunshin-taiatari" "naruto-rendan" "tsuten-kyaku" "naruto-nisen-rendan" "naruto-yonsen-rendan" "kawazu-kumite"]
	set genlist [list "kawarimi" "kage-bunshin" "kibakufuda-no-kawarimi"]
	set futonlist [list "futon-shinku-gyoku" "futon-hien" "futon-shinku-dai-gyoku" "futon-shinkuha" "futon-reppusho" "futon-shinku-renpa" "futon-rasengan" "futon-kazekiri" "futon-kiryu-ranbu" "futon-rasensuriken"]
	set kuchieselist [list "kuchiese-gamabunta" "kuchiese-yatai-kuzushi" "senpo-kawazu-naki"]
	set fuinlist [list "kai" "kibakufuda" "hakke-fuin-shiki"]
	set hidenlist [list "nine-tails" "taju-kage-bunshin" "shihohappo-suriken" "bunshin-no-henge" "rasengan" "odama-rasengan" "rasen-cho-tarengan" "sennin-mode"]
	#kyubi no koromo, kage-bunsin, taju-kage-bunshin, kawarimi, kai, shinku gyoku, hien, shofu and konoha senpu.
	set accessskills [list "nine-tails" "taju-kage-bunshin" "kawarimi" "kage-bunshin" "kai" "shofu" "konoha-senpu" "futon-shinku-gyoku" "futon-hien"]
	if {[is_in "taju-kage-bunshin" $skills] && ($level > 1)} {
		lappend accessskills "bunshin-taiatari"
		lappend accessskills "naruto-rendan"
		lappend accessskills "shihohappo-suriken"
	}
	if {[is_in "kage-bunshin" $skills] && $level > 1} {
		lappend accessskills "bunshin-no-henge"
	}
	if {[is_in "futon-shinku-gyoku" $skills] && $level > 1} {
		lappend accessskills "futon-shinku-dai-gyoku"
	}
	if {$level > 1} {
		lappend accessskills "futon-shinkuha"
		lappend accessskills "futon-reppusho"
		lappend accessskills "kibakufuda"
		lappend accessskills "hakke-fuin-shiki"
	}
	if {[is_in "kibakufuda" $skills] && [is_in "kawarimi" $skills]} {
		lappend accessskills "kibakufuda-no-kawarimi"
	}
	if {[is_in "futon-shinku-dai-gyoku" $skills] && $level > 2} {
		lappend accessskills "futon-shinku-renpa"
	}
	if {[is_in "rasengan" $skills] && $level > 2} {
		lappend accessskills "futon-rasengan"
	}
	if {$level > 2} {
		lappend accessskills "futon-kazekiri"
	}
	if {[is_in "futon-rasengan" $skills] && $level > 3} {
		lappend accessskills "futon-rasensuriken"
	}
	if {$level > 3} {
		lappend accessskills "futon-kiryu-ranbu"
	}
	if {([is_in "kage-bunshin" $skills] || [is_in "taju-kage-bunshin" $skills]) && $level > 2} {
		lappend accessskills "rasengan"
	}
	if {[is_in "rasengan" $skills] && $level > 2} {
		lappend accessskills "odama-rasengan"
	}
	if {[is_in "rasengan" $skills] && $level > 3} {
		lappend accessskills "rasen-cho-tarengan"
	}
	if {[is_in "naruto-rendan" $skills] && ($level > 2)} {
		lappend accessskills "naruto-nisen-rendan"
	}
	if {$level > 2} {
		lappend accessskills "tsuten-kyaku"
		lappend accessskills "kuchiese-gamabunta"
	}
	if {[is_in "kuchiese-gamabunta" $skills] && $level > 2} {
		lappend accessskills "kuchiese-yatai-kuzushi"
	}
	if {[is_in "naruto-nisen-rendan" $skills] && ($level > 3)} {
		lappend accessskills "naruto-yonsen-rendan"
	}
	if {[is_in "sennin-mode" $skills] && ($level > 3)} {
		lappend accessskills "kawazu-kumite"
		lappend accessskills "senpo-kawazu-naki"
	}
	set i 0
	while {$i < [llength $accessskills]} {
		if {[is_in [lindex $accessskills $i] $skills]} {
			set accessskills [lreplace $accessskills $i $i] 
		} else {
			incr i
		}
	}
	image create photo individualpanel -file [file join $mydir images skills naruto naruto-[set level].gif]
	image create photo accesspanel -file [file join $mydir images skills naruto accessible.gif]
	create_skillpanel
	list_placing $tailist 325 98
	list_placing $genlist 395 98
	list_placing $futonlist 465 98
	list_placing $hidenlist 705 98
	list_placing $kuchieselist 785 548
	list_placing $fuinlist 865 98
}
proc click_skill {ex ey {status "skill"}} {
	global tai speed mydir tailist genlist futonlist fuinlist kuchieselist hidenlist campdir m nin gen
	list_info $tailist $ex $ey 325 98 $status "tai"
	list_info $genlist $ex $ey 395 98 $status "gen"
	list_info $futonlist $ex $ey 465 98 $status "nin"
	list_info $hidenlist $ex $ey 705 98 $status
	list_info $kuchieselist $ex $ey 785 348 $status "nin"
	list_info $fuinlist $ex $ey 865 98 $status "gen"
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
				destroy .i
				destroy .m
			}
			.c delete all
			source [file join $campdir mission$m.tcl]
		}
		#exit button
		if {[object_in $ex $ey 817 537 125 25]} {
			.c delete all
			pack forget .c 
			source [file join $mydir menu.tcl]
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
bind .c <ButtonPress> {
	click_skill %x %y $st
}
pack .c -side top
