#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 2
set heroname "naruto"
set herolevel 1
set ai_type "normal"
autosave 0 2
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
	set bonus 0
	phon 6
	set locations [list 1 2 3 -3]
	scenery_message {WARNING! ANGRY SAKURA!}	
	hatake_kakashi 1000 320 {}
	haruno_sakura 700 520 {"kage-bunshin" "shofu"} 1 
}
proc special_sakura_ai {n tech p} {
	#ranged battle is always recommended
	global uplev mydir
	set tag enemy$n
	if {[get_hitpoints enemy$n] < 1} {
		set hero_ancof 0
		block_battlepanel
		after 2000 "
			clear
			pack forget .c 
			source [file join $mydir menu.tcl]
		"
	}
	if {$uplev == 3} {
		if {[get_location hero] == [get_location $tag] && [get_height hero] == [get_height $tag] && ($tech != "run" || $p == 2)} {
			if {[is_melee $tech] && [get_chakra $tag] > 10} {
				melee_tech "hero" $tag $tech $p "shofu" [get_tai $tag]
			} elseif {[get_chakra $tag] > 10 && [get_status hero] == "free"} {
				melee_tech "hero" $tag "attack" [get_tai hero] "shofu" [get_tai $tag]
			} elseif {[get_chakra $tag] > 10} {
				melee_tech $tag "hero" "shofu" [get_tai $tag] "none" 0
			} elseif {[is_melee $tech] && [get_chakra $tag] < 11} {
				melee_tech "hero" $tag $tech $p "attack" [get_tai $tag]
			} else {
				#nonething - fighting_sensor
			}
		} else {
			#nonething - game over
		}
	}
	if {$uplev == 2} {
		if {[is_bonus $tech] && [get_location hero] != [get_location $tag]} {
			
		} elseif {[get_location hero] == [get_location $tag] && [get_height hero] == [get_height $tag] && ($tech != "run" || $p == 2)} {
			if {[is_melee $tech] && [get_chakra $tag] > 10} {
				melee_tech "hero" $tag $tech $p "shofu" [get_tai $tag]
			} elseif {[get_chakra $tag] > 10 && [get_status hero] == "free"} {
				melee_tech "hero" $tag "attack" [get_tai hero] "shofu" [get_tai $tag]
			} elseif {[get_chakra $tag] > 10} {
				melee_tech $tag "hero" "shofu" [get_tai $tag] "none" 0
			} elseif {[is_melee $tech] && [get_chakra $tag] < 11} {
				melee_tech "hero" $tag $tech $p "attack" [get_tai $tag]
			} else {
				#nonething - fighting_sensor
			}
		} elseif {[get_height hero] > [get_height $tag] && [get_location hero] == [get_location $tag] && [get_height $tag] == 2} {
			move $tag "up"
			set uplev 3
		} elseif {[get_height hero] == [get_height $tag]} {
			if {[get_location hero] > [get_location $tag]} {
				move $tag "right"
			} elseif {[get_location hero] < [expr [get_location $tag] - 1]} {
				move $tag "left"
			} elseif {[get_location hero] == [expr [get_location $tag] - 1] && ($tech != "run" || $p != 0)} {
				move $tag "left"
			} 
		} elseif {[get_height hero] < [get_height $tag]} {
			if {[get_location hero] == [get_location $tag] && $tech == "run"} {
				if {$p == 0} {
					move $tag "right"
				} elseif {$p == 1} {
					move $tag "left"
				}
			} elseif {[get_location hero] < [expr [get_location $tag] - 1]} {
				move $tag "left"
			} elseif {[get_location hero] == [expr [get_location $tag] - 1] && ($tech != "run" || $p != 0)} {
				move $tag "left"
			} elseif {[get_location hero] >  [get_location $tag] && ($tech != "run" || $p != 1)} {
				move $tag "right"
			}
		} elseif {[get_height $tag] == 1 && [get_location $tag] == 0} {
			move $tag "right"
		} elseif {[get_height $tag] == 1} {
			move $tag "up"
		}
	}
	if {$uplev == 1} {
		if {[is_bonus $tech] && [get_location hero] != [get_location $tag]} {
			
		} elseif {[get_location hero] == [get_location $tag] && [get_height hero] == [get_height $tag] && ($tech != "run" || $p == 2)} {
			if {[is_melee $tech] && [get_chakra $tag] > 10} {
				melee_tech "hero" $tag $tech $p "shofu" [get_tai $tag]
			} elseif {[get_chakra $tag] > 10 && [get_status hero] == "free"} {
				melee_tech "hero" $tag "attack" [get_tai hero] "shofu" [get_tai $tag]
			} elseif {[get_chakra $tag] > 10} {
				melee_tech $tag "hero" "shofu" [get_tai $tag] "none" 0
			} elseif {[is_melee $tech] && [get_chakra $tag] < 11} {
				melee_tech "hero" $tag $tech $p "attack" [get_tai $tag]
			} else {
				#nonething - fighting_sensor
			}
		} elseif {$tech == "run" && $p == 0} {
			move $tag "up"
			set uplev 2
		}
	}
}
proc special_kakashi_ai {n tech p} {
	global dclones
	if {[get_location hero] < [get_location enemy$n] && [get_height hero] == [get_height enemy$n] && $tech == "run" && $p == 0} {
		after 900 "
			set_speed hero 0
			set_speed enemy$n 0
		"
		victory
		set dclones 1
	} elseif {[get_height hero] == 2 && [get_location hero] == 2 && $tech == "run" && $p == 2} {
		set s1 [get_speed hero]
		set s2 [get_speed enemy$n]
		set_speed hero 0
		set_speed enemy$n 0
		if {$s1 != 0} {
		after 1800 "
			set_speed hero $s1
		"
		}
		if {$s2 != 0} {
		after 1800 "
			set_speed enemy$n $s2
		"
		}
	} else {
		set s [get_speed enemy$n]
		set_speed enemy$n 0
		if {$s != 0} {
		after 1800 "
			set_speed enemy$n $s
		"
		}
	}
}
proc victory_special {} {
	global skills
	set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
	.c raise panel
}
