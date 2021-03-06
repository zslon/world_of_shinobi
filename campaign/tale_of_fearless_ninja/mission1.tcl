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
	global locations ai_type sake
	phon 2
	set ai_type "special"
	set sake 0
	set locations [list 1 1 1 1]
	haruno_sakura 1000 520 {"kage-bunshin"} 1 
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
proc slide_3 {} {
	global locations
	phon 3
	set locations [list 3 3 3 3]
	medpack 950 320
	map_trap "oxkokokkoxko"
	scenery_message {Map}
}
proc slide_4 {} {
	global locations ai_type etap
	set etap 1
	set ai_type "special"
	phon 4 
	set locations [list 3 1 1 1]
	uchiha_sasuke 100 420 {katon-gokakyu} 1
	set_speed enemy1 2
}
proc slide_5 {} {
	global locations skills bonus 
	lappend skills "kyubi-enabled"
	phon 5
	set locations [list 1 1 1 1]
	uchiha_sasuke 1000 520 {katon-gokakyu} 1
	kubakufuda_trap 350
}
proc special_sasuke-enemy_ai {n tech p} {
	global etap enemy effects dclones
	set tag enemy$n
	if {$etap == 3 && [get_location hero] == [get_location $tag]} {
		set etap 4
	}
	if {$etap == 4} {
		if {[is_in [list "kyubi-1" "hero" -1] $effects] || [get_hitpoints $tag] < 26} {
			destroy .s
			set dclones 1
			set_chakra hero 15 
			victory
		} else {
			standart_ai $n $tech $p
		}
	}
	if {$etap == 3 && [get_location hero] < [get_location $tag]} {
		if {[is_in [list "kyubi-1" "hero" -1] $effects] || [get_hitpoints $tag] < 26} {
			destroy .s
			set dclones 1
			set_chakra hero 15 
			victory
		} elseif {[get_chakra $tag] > 15} {
			ranged_tech $tag "hero" "katon-gokakyu" [get_nin $tag] "none" 0
		} else {
			set etap 4
		}
	}
	if {$etap == 2 && ([get_location hero] == [get_location $tag] || ([get_location hero] == [expr [get_location $tag] - 1] && $tech == "run" && $p == 0))} {
		if {[get_hitpoints $tag] < 20} {
			teleport_out "sasuke-enemy" $n
		} elseif {[get_location $tag] < 3} {
			move $tag "right"
		} else {
			set enemy 0
			move $tag "right"
			after 2000 ".c delete $tag"
			set etap 3
		}
	} 
	if {$etap == 1} {
		move $tag "right"
		set etap 2
	}
}
proc special_kakashi_ai {n tech p} {
}
proc victory_special {} {
	global skills
	set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
	.c raise panel
	hatake_kakashi 1000 1000 {}
	set x1 [getx enemy1]
	set x2 [getx heroi]
	teleport enemy2 [expr ($x1+$x2)/2] 520
	after 500 {replic kakashi-1 3000}
}
