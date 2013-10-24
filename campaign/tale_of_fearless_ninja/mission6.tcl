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
	global locations bonus effects ai_type genin tur skills
	lappend skills "kyubi-enabled"
	set tur 1
	set genin 1
	set ai_type "special"
	set bonus 0
	phon 1
	set locations [list 1 1 3 -3]
	genin_waterfall 700 420 3 1 1 1 {"doton-doryu-heki" "doton-domu" "kawarimi"} 
}
proc special_genin-waterfall_ai {num tech p} {
	global genin tur enemy effects
	set tag enemy$num
	set l [list ]
	#sensor
	if {$genin == 1} {
		if {[get_hitpoints $tag] < 51} {
			rolic "sasuke_no_ryuka_no_jutsu"
		} elseif {$tur == 1} {
			mov_ai enemy$num "hero"
			set tur 2
		} elseif {$tur == 2} {
			if {[is_in [list "kibakufuda" "hero" 0] $effects] && [get_chakra $tag] > 10} {
				tech_kawarimi $tag
				lappend effects [list "kawarimi" enemy$num [enciclopedia "kawarimi" "number" [get_nin $tag]]]
			} elseif {[is_in [list "kibakufuda" "hero" 0] $effects]} {
				rolic "sasuke_no_ryuka_no_jutsu"
			} elseif {($tech == "futon-shinku-dai-gyoku" || $tech == "futon-shinkuha") && [get_chakra $tag] > 30} {
				set l [ranged_tech_ai $num]
			} elseif {($tech == "futon-shinku-dai-gyoku" || $tech == "futon-shinkuha") && [get_chakra $tag] > 10} {
				tech_kawarimi $tag
				lappend effects [list "kawarimi" enemy$num [enciclopedia "kawarimi" "number" [get_nin $tag]]]
			} elseif {($tech == "futon-shinku-dai-gyoku" && [get_hitpoints $tag] < 61) || ($tech == "futon-shinkuha" && [get_hitpoints $tag] < 31)} {
				rolic "sasuke_no_ryuka_no_jutsu"
			} elseif {[get_location $tag] != [get_location "hero"] && $tech != "run"} {
				mov_ai enemy$num "hero"
			} elseif {![if_domu $tag] && [get_chakra $tag] > 30} {
				tech_doton-domu $tag
				lappend effects [list "doton-domu" enemy$num [enciclopedia "doton-domu" "number" [get_nin $tag]]]
			}
		}
	}
	if {[llength $l] == 0 && $tech != "run" && $tech != "none" && $tech != "busy"} {
		if {[is_ranged $tech] && [get_height hero] == [get_height enemy$num]} {
			ranged_tech "hero" enemy$num $tech $p "none" 0
		} elseif {[is_melee $tech] && [get_height hero] == [get_height enemy$num] && [get_location hero] == [get_location enemy$num]} {
			melee_tech "hero" enemy$num $tech $p "attack" [get_tai enemy$num]
		} elseif {[is_melee_max $tech] && [get_height hero] == [get_height enemy$num]} {
			melee_tech "hero" enemy$num $tech $p "attack" [get_tai enemy$num]
		} elseif {[is_ranged $tech] && [get_height hero] != [get_height enemy$num] && [is_longranged $tech]} {
			ranged_tech "hero" enemy$num $tech $p "none" 0
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
proc special_sasuke_ai {num tech p} {
	set l [get_location hero]
	set h [get_height hero]
	if {$l == 2 && $h == 2 && $tech == "run" && $p == 2} {
		rolic "naruto_in_a_tree"
	}
}
proc animation_sasuke_no_ryuka_no_jutsu {} {
	global effects enemy skills mydir
	catch {
		destroy .s
	}
	if {[get_chakra enemy1] < 11} {
		set_chakra enemy1 11
	}
	kawarimi_teleport enemy1 [get_name enemy1]
	after 1100 "get_image enemy1 [file join $mydir images heroes [get_name enemy1] stand 1.gif]"
	after 500 {uchiha_sasuke_friend 50 320 {"katon-gokakyu" "kai" "kawarimi" "raiko-kenka" "sharingan-1" "katon-ryuka" "sofusha-san-no-tachi"} 2}
	set t 1000
	set i 1
	while {$i <= 4} {
		set t [expr $t + 100]
		after $t ".c raise enemy2
		get_image enemy2 [file join $mydir images heroes sasuke sofusha-san-no-tachi $i.gif]"
		incr i
	}
	set t 1200
	set x0 50
	set y0 320
	get_image sasu1 [file join $mydir images attacks sofusha attack-1.gif]
	get_image sasu2 [file join $mydir images attacks sofusha attack-2.gif]
	after $t ".c create image $x0 $y0 -image sasu1 -tag suriken1
		  .c create image $x0 $y0 -image sasu2 -tag suriken2"
	set i1 1
	set i2 2
	while {$t <= 2200} {
		incr i1 1
		incr i2 1
		if {$i1 == 4} {
			set i1 1
		}
		if {$i2 == 4} {
			set i2 1
		}
		after $t "
		get_image sasu1 [file join $mydir images attacks sofusha attack-$i1.gif]
		get_image sasu2 [file join $mydir images attacks sofusha attack-$i2.gif]"
		set t [expr $t + 50]
	}
	set t 1200
	while {$t <= 1500} {
		set t [expr $t + 50]
		after $t "tross enemy2 suriken1 -10
		tross enemy2 suriken2 10
		.c move suriken1 30 4
		.c move suriken2 30 -4"		
	}
	set i 1
	while {$i <= 10} {
		set t [expr $t + 50]
		after $t "tross enemy2 suriken1 -10
		tross enemy2 suriken2 10
		one_tenth_traectory suriken1 enemy1 $i
		one_tenth_traectory suriken2 enemy1 $i"
		incr i	
	}
	after [expr $t + 50] "tross enemy2 suriken1 -10
	tross enemy2 suriken2 10"
	set t 1520
	while {$t <= 1820}  {
		set t [expr $t + 50]
		after $t "tross enemy2 suriken1 -10
		tross enemy2 suriken2 10
		.c move suriken1 30 8
		.c move suriken2 30 -8"		
	}
	after 2200 ".c delete suriken1
	.c delete suriken2"
	set h [get_hitpoints enemy1]
	set h2 [expr $h - 14]
	after 2200 "set_hitpoints enemy1 $h2"
	after 2200 "set_chakra enemy2 85"
	set t 2500
	set i 5
	while {$t <= 2700}  {
		after $t "get_image enemy2 [file join $mydir images heroes sasuke sofusha-san-no-tachi $i.gif]"
		incr i	
		set t [expr $t + 100]
	}	
	after $t "get_image enemy2 [file join $mydir images heroes sasuke stand 1.gif]"
	get_image dragonfire [file join $mydir images attacks sofusha fire-1.gif]
	set k 1
	set i 1
	after $t ".c create image $x0 $y0 -image dragonfire -tag dragonfire"
	while {$i <= 10} {
		incr k 1
		if {$k == 4} {
			set k 1
		}
		after $t "
		get_image dragonfire [file join $mydir images attacks sofusha fire-$k.gif]
		one_tenth_traectory dragonfire enemy1 $i"
		incr i 
		set t [expr $t + 50]
	}
	after [expr $t + 100] ".c delete dragonfire
	.c delete tross_enemy2_suriken1
	.c delete tross_enemy2_suriken2
	set_hitpoints enemy1 0
	set_chakra enemy2 65
	set_speed enemy2 0"
	after 4000 {
		dies
	}
	after 4500 {
		replic "naruto-1" 3000
	}
	after 7600 {
		replic "sasuke-1" 4000
	}
	after 11700 {
		set_speed hero 2
		set_speed enemy1 2
		end_rolic
	}
}
proc animation_naruto_in_a_tree {} {
	global effects enemy skills mydir
	catch {
		destroy .s
	}
	clones_interface "hero" "remove_all"
	set_speed hero 2
	set t 1500
	set tag "heroi"
	set class "hero"
	set name "naruto"
	after 2000 "get_image $tag [file join $mydir images heroes $name jump 1.gif] 2 $class clones"
	after 2100 "get_image $tag [file join $mydir images heroes $name jump 1.gif] 2 $class clones"
	after 2300 "get_image $tag [file join $mydir images heroes $name jump 2.gif] 2 $class clones"
	after 2500 "get_image $tag [file join $mydir images heroes $name jump 3.gif] 2 $class clones"
	set t 2025	
	set u -5
	set m 7
	while {$t <= 2500} {
		after $t ".c move $tag $m $u
move_all_clones $class $m $u" 
		incr t 25
	}
	set u 3
	while {$t <= 2750} {
		after $t ".c move $tag $m $u
move_all_clones $class $m $u" 
		incr t 25
	}
	set u 2
	while {$t <= 3000} {
		after $t ".c move $tag $m $u
move_all_clones $class $m $u" 
		incr t 25
	}
	set t 3000
	set e 6
	while {$t <= 3150} {
		after $t "get_image $tag [file join $mydir images heroes $name jump $e.gif] 2 $class clones" 
		incr t 50
		incr e
	}
	set t 3500
	after 3500 "get_image $tag [file join $mydir images heroes $name jump 1.gif] 2 $class clones"
	after 3600 "get_image $tag [file join $mydir images heroes $name jump 1.gif] 2 $class clones"
	after 3800 "get_image $tag [file join $mydir images heroes $name jump 2.gif] 2 $class clones"
	after 4000 "get_image $tag [file join $mydir images heroes $name jump 3.gif] 2 $class clones"
	set t 3525	
	set u -10
	set m 0
	while {$t < 4000} {
		after $t ".c move $tag $m $u
move_all_clones $class $m $u" 
		incr t 25
	}
	after 4000 {end_rolic
	move_hero_to
	next_slide}
}
proc move_hero_to {} {
	set x [getx heroi]
	set y [gety heroi]
	.c move heroi [expr 50 - $x] [expr 520 - $y]
}
proc slide_2 {} {
	global locations
	#replic "naruto-1" 4000
	phon 2
	set locations [list 1 1 1 1]
	.c move heroi 0 200
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
	} elseif {$etap == 1} {
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
		} elseif {[is_ranged $tech] && [get_height hero] != [get_height enemy$num] && [is_longranged $tech]} {
			ranged_tech "hero" enemy$num $tech $p "none" 0
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
