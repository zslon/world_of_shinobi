#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 6
set heroname "naruto"
set herolevel 2
set ai_type "normal"
autosave 0 6
breefing
proc slide_1 {} {
	global locations bonus effects ai_type
	set ai_type "high"
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	sarutobi_konohomaru 1000 520 {"kawarimi"} 1
}
proc slide_2 {} {
	global locations
	#replic "naruto-1" 4000
	phon 2
	set locations [list 1 1 1 1]
	genin_leaf_firemaster 1000 520 2 3 1 2 {"katon-endan" "katon-ryuka"}
}
proc slide_3 {} {
	global locations ai_type
	set ai_type "high"
	phon 3
	set locations [list 2 2 2 2]
	genin_leaf_firemaster 1000 420 2 3 1 2 {"katon-haisekisho" "katon-housenka"}
}
proc slide_4 {} {
	global locations ai_type
	phon 4 
	set locations [list -2 -2 -2 1]
	genin_leaf_genjitsu 700 420 2 1 3 2 {"kokoni-arazu" "kawarimi"}
	medpack 950 520
}
proc slide_5 {} {
	global locations ai_type
	phon 5
	set locations [list 1 1 1 1]
	genin_leaf_genjitsu 1000 520 2 1 3 2 {"narakumi" "kawarimi"}
}
proc slide_6 {} {
	global locations bonus ai_type effects etap kokoni naraku
	set kokoni 0
	set naraku 0
	set etap 1
	set ai_type "special"
	phon 6
	green_table 50 320
	chunin_leaf_genjitsu 1000 420 3 2 4 3 {"narakumi" "kokoni-arazu" "kage-bunshin" "kawarimi" "konoha-senpu" "futon-shinku-gyoku"}
	sarutobi_konohomaru 1100 320 {"kawarimi"} 1
	set locations [list 3 3 3 3]
}
proc special_chunin-leaf-genjitsu_ai {num tech p} {
	global etap kokoni naraku enemy
	set tag enemy$num
	set l [list ]
	if {[get_hitpoints enemy$num] < 30} {
		teleport_out "chunin-leaf-genjitsu" $num
	} if {$etap == 1} {
		set l [get_location "hero"]
		if {$tech == "run" && $p == 2} {
			set etap 2
			set l [bonus_tech_ai $num]
		}
	} elseif {$etap == 2} {
		if {[get_location $tag] > [get_location $hero] && !($tech == "run" && $p == 2) && [get_chakra $tag] > 35} {
			set l [list "futon-shiku-gyoku" [get_nin $tag]]
		} elseif {[get_location $tag] > [get_location $hero] && !($tech == "run" && $p == 2) && [get_chakra $tag] > 20 && $naraku == 0} {
			set l [bonus_tech_ai $num]
			set naraku 1
		} elseif {[get_location $tag] > [get_location $hero] && !($tech == "run" && $p == 2) && ([get_chakra $tag] <= 20 || $naraku == 1)} {
			mov_ai enemy$num "hero"
		} elseif {[get_location $tag] == [get_location $hero] && ([get_chakra $tag] <= 20 || $kokoni == 1)} {
			#nonething
		} elseif {[get_location $tag] == [get_location $hero] && [get_chakra $tag] > 20 && $kokoni == 0} {
			tech_kokoni-arazu enemy$num
			set kokoni 1
			lappend effects [list "kokoni-arazu" enemy$num [enciclopedia "kokoni-arazu" "number" [get_gen enemy$num]]]
		} elseif {[get_location $tag] < [get_location $hero] && [get_chakra $tag] > 20 && !($tech == "run" && $p == 2) && $naraku == 0} {
			set l [bonus_tech_ai $num]
		} elseif {[get_location $tag] < [get_location $hero] && ([get_chakra $tag] > 20 || $naraku == 1)} {
			mov_ai enemy$num "hero"
		} elseif {$tech == "run" && $p == 2} {
			set etap 3
		}
	} elseif {$etap == 3} {
		move enemy$num "up"
		set etap 4
	} elseif {$etap == 4} {
		if {[get_location $tag] == [get_location $hero]} {
			#nonething
		} else {
			mov_ai enemy$num "hero"
		}
	}
#sensor
	if {[llength $l] == 0 && $tech != "run" && $tech != "none" && $tech != "busy"} {
		if {[is_ranged $tech] && [get_height hero] == [get_height enemy$num]} {
			ranged_tech "hero" enemy$num $tech $p "none" 0
		} elseif {[is_melee $tech] && [get_height hero] == [get_height enemy$num] && [get_location hero] == [get_location enemy$num]} {
			melee_tech "hero" enemy$num $tech $p "attack" [get_tai enemy$num]
		} elseif {[is_melee_max $tech] && [get_height hero] == [get_height enemy$num]} {
			melee_tech "hero" enemy$num $tech $p "attack" [get_tai enemy$num]
		}
	}
	if {[lindex $l 0] == "kunai" || [lindex $l 0] == "attack"} {
		set tmo 1000
	} else {
		set tmo 0
	}
	if {[llength $l] != 0 && [lindex $l 0] == "nonething"} {
		set_nin enemy$num 0 
		if {$tech == "busy" || $tech == "none" || $tech == "run"} {
		} elseif {[is_melee $tech] && [get_location hero] == [get_location enemy$num] && [get_height hero] == [get_height enemy$num]} {
			after $tmo "melee_tech hero enemy$num $tech $p none 0"
		} elseif {[is_ranged $tech] && [get_location hero] < [get_location enemy$num] && [get_height hero] == [get_height enemy$num]} {
			after $tmo "ranged_tech hero enemy$num $tech $p none 0"
		} 
	} elseif {[llength $l] != 0 && $tech == "busy"} {
		if {[is_ranged [lindex $l 0]]} {
			after $tmo "ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
		} elseif {[is_melee [lindex $l 0]]} {
			after $tmo "melee_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
		}
	} elseif {[llength $l] != 0 && $tech != "run" && $tech != "none"} {
		if {[is_ranged [lindex $l 0]] && [is_ranged $tech]} {
			ranged_tech "hero" enemy$num $tech $p [lindex $l 0] [lindex $l 1]
		} elseif {[is_ranged [lindex $l 0]] && ![is_ranged $tech]} {
			if {[dist "heroi" enemy$num] < 360 && [is_melee_max $tech]} {
				melee_tech "hero" enemy$num $tech $p "attack" [get_tai enemy$num]
			} else {
				ranged_tech enemy$num "hero" [lindex $l 0] [lindex $l 1] "none" 0
			}
		} elseif {[is_melee [lindex $l 0]] && [is_melee $tech]} {	
			melee_tech "hero" enemy$num $tech $p [lindex $l 0] [lindex $l 1]
		} elseif {[is_melee [lindex $l 0]] && ![is_melee $tech]} {
			melee_tech enemy$num "hero" [lindex $l 0] [lindex $l 1] "attack" [get_tai "hero"] 
		}
	} elseif {[llength $l] != 0 && ($tech == "run" || $tech == "none")} {
		if {$tech == "none"} {
			if {[get_location hero] == [get_location enemy$num] && [get_height hero] == [get_height enemy$num]} {
				melee_tech enemy$num hero [lindex $l 0] [lindex $l 1] "attack" [get_tai "hero"]
				set_nin hero 0
			} elseif {[get_location hero] == [expr [get_location enemy$num] - 1] && [get_height hero] == [get_height enemy$num]} {
				ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] kunai [get_speed hero]
		        } elseif {[get_height hero] == [get_height enemy$num]} {
				after $tmo "ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
			}
		} elseif {$p == 2} {
		} elseif {$p == 0 && [get_location hero] < [get_location enemy$num]} {
			if {[dist "heroi" enemy$num] < 360} {
				after $tmo "melee_tech enemy$num hero attack [get_tai enemy$num] none 0"
			} elseif {[is_ranged [lindex $l 0]] && [dist "heroi" enemy$num] < 660} {
				after $tmo "ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
			} elseif {[is_ranged [lindex $l 0]]} {
				after $tmo "ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
			}
		} elseif {$p == 1 && [get_location hero] > [get_location enemy$num]} {
			if {[dist "heroi" enemy$num] < 360} {
				after $tmo "melee_tech enemy$num hero attack [get_tai enemy$num] none 0"
			} elseif {[is_ranged [lindex $l 0]] && [dist "heroi" enemy$num] < 660} {
				after $tmo "ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
			} elseif {[is_ranged [lindex $l 0]]} {
				after $tmo "ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
			}
		} elseif {[get_location hero] == [get_location enemy$num] && [get_height hero] == [get_height enemy$num]} {
			if {[is_melee [lindex $l 0]] && [is_melee_max [lindex $l 0]]} {
				after $tmo "melee_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
			} elseif {[is_melee [lindex $l 0]]} {
				after $tmo "ranged_tech enemy$num hero kunai [get_speed enemy$num] none 0"
			}
		}
	}
}
proc special_konohomaru-ai {num tech p} {
	global enemy
	if {$enemy < 2} {
		move enemy$num "left"
		victory
	}
}
proc victory_special {} {
	global skills
	set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
	.c raise panel
}
