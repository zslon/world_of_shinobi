#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 1
set heroname "naruto"
set herolevel 1
set ai_type "normal"
autosave 0 1
breefing
proc slide_1 {} {
	global locations bonus
	set bonus 0
	phon 1
	set locations [list 1 2 -2 1]
	training_lumber 1000 520
	kunai_trap 650
	kubakufuda_trap 350
	scenery_message {Training 1: Obstacle Course}
}
proc slide_2 {} {
	global locations ai_type
	phon 2
	set ai_type "special"
	set locations [list 1 1 1 1]
	haruno_sakura 1000 520 {} 1 
}
proc special_sakura_ai {n tech p} {
	#ranged battle is always recommended
	global effects
	if {[get_hitpoints enemy$n] < 26} {
		teleport_out "sakura" $n
	} else {
		standart_ai $n $tech $p
	}		
}
proc slide_3 {} {
	global locations
	phon 3
	set locations [list 3 3 3 3]
	medpack 950 320
	map_trap "oxkokokkoxko"
	scenery_message {Map}
}
proc slide_4 {} {
	global locations
	phon 4 
	set locations [list 3 1 1 1]
	uchiha_sasuke 100 420 {} 1
}
proc slide_5 {} {
	global locations
	phon 5
	set locations [list 3 3 3 1]
	kunai_trap 950
	kunai_trap 650
	kunai_trap 350
}
proc slide_6 {} {
	global locations
	phon 6
	set locations [list 1 1 1 3]
	might_guy 1000 320 {"shofu"}
}
proc special_gui_ai {n tech p} {
	if {[is_bonus $tech]} {
		set tech "run"
		set p 2
	}
	set ln [get_location enemy$n]
	set lh [get_location hero]
	set hn [get_height enemy$n]
	set hh [get_height hero]	
	if {$ln == $lh && $hn == $hh} {
		set s [get_status hero]
		set tn [get_tai enemy$n]
		set th [get_tai hero]
		if {$tech == "run"} {
		} elseif {$tech == "none"} {
			melee_tech enemy$n "hero" "shofu" $tn "attack" $th
		} else {
			melee_tech enemy$n "hero" "shofu" $tn $tech $p
		}
	} else {
	}
	set li [get_hitpoints "hero"]
	set guy [get_hitpoints enemy$n]
	if {$li > 0 && $guy < 244} {
		victory
	}
}
proc victory_special {} {
	.c raise panel
	after 1000 {move enemy1 "left"}
}