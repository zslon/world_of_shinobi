#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 4
set heroname "lee"
set herolevel 1
set ai_type "special"
autosave 1 4
breefing
levelup 1 0 1 1
proc slide_1 {} {
	global locations bonus
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	scenery_message {Forward!!!}
	ten_ten 1000 520 {"raiko-kenka" "soshuga"} 2
}
proc special_tenten_ai {n tech p} {
	#ranged battle is always recommended
	global effects
	if {[get_hitpoints enemy$n] < 50} {
		teleport "tenten" $n
	} elseif {![is_in [list "raiko-kenka" enemy$n -1] $effects] && ![is_in [list "kuchiese-kusarigama" enemy$n -1] $effects] && [dist "heroi" enemy$n] > 300} {
		#use shooting arm
		set s [get_chakra enemy$n]
		if {$s > 20} {
			set_chakra enemy$n 20
			set l [bonus_tech_ai $n]
			set_chakra enemy$n [expr $s - (20 - [get_chakra enemy$n])]
		} else {
			set l [bonus_tech_ai $n]
		}
	} elseif {[get_height hero] == [get_height enemy$n] && [get_location hero] != [get_location enemy$n]} {
		if {$tech == "run"} {
			if {[dist "heroi" enemy$n] > 360 && [dist "heroi" enemy$n] < 660 && $p == 0} {
				set l [ranged_tech_ai $n]
				if {[llength $l] != 0} {
					ranged_tech enemy$n "hero" [lindex $l 0] [lindex $l 1] "none" 0
				}
				#else stand and wait
			} elseif {[dist "heroi" enemy$n] > 360 && [dist "heroi" enemy$n] < 660} {
				set l [ranged_tech_ai $n]
				if {[llength $l] != 0} {
					ranged_tech enemy$n "hero" [lindex $l 0] [lindex $l 1] "none" 0
				}
			}
			if {[dist "heroi" enemy$n] < 360 && $p == 0} {
				set t [try_retreat $n]
				if {$t == 0} {
					#use melee arm
					set l [bonus_tech_ai $n]
				}
			} elseif {[dist "heroi" enemy$n] < 360} {
				mov_ai enemy$n "hero"
			}
			if {[dist "heroi" enemy$n] > 660} {
				set l [ranged_tech_ai $n]
				if {[llength $l] != 0} {
					ranged_tech enemy$n "hero" [lindex $l 0] [lindex $l 1] "none" 0
				}
			}
		} else {
			if {[dist "heroi" enemy$n] > 360} {
				set l [ranged_tech_ai $n]
				if {[llength $l] != 0} {
					ranged_tech enemy$n "hero" [lindex $l 0] [lindex $l 1] "none" 0
				}
			} else {
				set l [ranged_tech_ai $n]
				if {[llength $l] != 0} {
					ranged_tech enemy$n "hero" [lindex $l 0] [lindex $l 1] "none" 0
				}
			}
		}
	} else {
		if {[get_height hero] == [get_height enemy$n]} {
			if {[is_melee $tech]} {
				melee_tech "hero" enemy$n $tech $p "attack" [get_tai enemy$n]
				set t 0
			} else {
				set t [try_retreat $n]
			}
			if {$t == 0} {
				#stand and fight
			}
		} else {
			mov_ai enemy$n "hero"
		}		
	}
}
proc slide_2 {} {
	global locations
	phon 2
	set locations [list 3 -3 2 1]
	might_guy 400 320 {"shofu" "konoha-senpu"}
}
proc special_gui_ai {n tech p} {
	#melee battle is always recommended
	global effects
	set l [list]
	if {[get_hitpoints enemy$n] < 200} {
		teleport "gui" $n
	} elseif {[get_height hero] == [get_height enemy$n] && [get_location hero] == [get_location enemy$n]} {
		if {$tech == "run" && $p == 1} {
			#stand and wait to kunai
		} else {
			set l [melee_tech_ai $n]
		}
	} else {
		if {$tech == "run" && $p != 2} {
			if {[dist "heroi" enemy$n] > 360} {
				mov_ai enemy$n "hero"
			} else {
				set l [bonus_tech_ai $n]
			}
		} else {
			mov_ai enemy$n "hero"
		}
	}
	if {[llength $l] != 0} {
		if {[lindex $l 0] != "kunai" && [is_melee $tech]} {	
			melee_tech "hero" enemy$n $tech $p [lindex $l 0] [lindex $l 1]
		} elseif {[lindex $l 0] != "kunai" && [lindex $l 0] != "melee"} {
			melee_tech enemy$n "hero" [lindex $l 0] [lindex $l 1] "attack" [get_tai "hero"] 
		}
	}
}
proc slide_3 {} {
	global locations
	phon 3
	set locations [list 1 1 3 1]
	ten_ten 700 320 {"raiko-kenka" "kuchiese-meisu"} 2 
}
proc slide_4 {} {
	global locations
	phon 4
	set locations [list 2 1 1 1]
	green_table 50 420
	might_guy 1000 520 {"konoha-senpu" "soshuga"}
	scenery_message {Forward!!!}
}
proc slide_5 {} {
	global locations
	phon 5
	set locations [list 2 -2 3 -3]
	ten_ten 1000 320 {"kuchiese-kusarigama" "soshuga"} 2 
}
proc slide_6 {} {
	global locations
	phon 6
	set locations [list -3 -3 -3 -3]
	ten_ten 1000 320 {"kuchiese-kusarigama" "soshuga" "raiko-kenka" "kuchiese-meisu" "soshoryu"} 2 
}
proc slide_7 {} {
	global locations
	victory
	phon 7
	set locations [list -3 3 -2 2]
	might_guy 1000 420 {"shofu"}
	ten_ten 1000 520 {"kuchiese-kusarigama" "soshuga" "raiko-kenka" "kuchiese-meisu" "soshoryu"} 2 
}
proc victory_special {} {
}
