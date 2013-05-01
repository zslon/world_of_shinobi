#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 3
set heroname "naruto"
set herolevel 1
set ai_type "normal"
autosave 0 3
breefing
proc slide_1 {} {
	global locations bonus skills
	lappend skills "kyubi-enabled"
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	kunai_trap 950
	kunai_trap 650
	scenery_message {Prompt}
}
proc slide_2 {} {
	global locations
	phon 2
	set locations [list 1 1 1 1]
	genin_robber 1000 520
}
proc slide_3 {} {
	global locations
	phon 3
	set locations [list 1 2 2 1]
	genin_robber 1000 520
	medpack 950 520
}
proc slide_4 {} {
	global locations ai_type etap
	phon 4 
	set locations [list 1 1 1 1]
	scenery_message {Prompt}
	kubakufuda_trap 350
	kubakufuda_trap 650
	kubakufuda_trap 950
	green_table 950 520
}
proc slide_5 {} {
	global locations bonus
	phon 5
	set locations [list 1 1 1 1]
	genin_robber 1000 520 1 1 1 1 {}
	genin_robber 700 520 1 1 1 1 {}
}
proc slide_6 {} {
	global locations bonus ai_type uplev
	set uplev 1
	set ai_type "special"
	phon 6
	set locations [list 1 2 3 -3]
	hatake_kakashi 1000 320 {} 1
	haruno_sakura 700 520 {"kage-bunshin" "shofu"} 1 
}
proc special_sakura_ai {n tech p} {
	#ranged battle is always recommended
	global effects sake
	set nin 2
	while {$nin >= 0} {
		if {[is_in [list "kage-bunshin" enemy$n $nin] $effects]} {
			set sake 2
		}
		incr nin -1
	}
	if {$sake != 2} {
		set sake 0
	} else {
		set sake 1
	}
	if {[get_hitpoints enemy$n] < 26} {
		teleport_out "sakura" $n
	} elseif {$sake == 0} {
		set sake 1
		set l [bonus_tech_ai $n]
	} else {
		standart_ai $n $tech $p
	}		
}
proc special_kakashi_ai {n tech p} {
	global dclones
	if {[get_location hero] == [get_location enemy$n] && [get_height hero] == [get_height enemy$n]} {
		get_speed hero 0
		get_speed enemy$n 0
		victory
		set dclones 1
	}
}
proc victory_special {} {
	global skills
	set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
	.c raise panel
}
