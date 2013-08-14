#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 4
set heroname "naruto"
set herolevel 1
set ai_type "normal"
autosave 0 4
breefing
proc slide_1 {} {
	global locations bonus skills effects
	lappend skills "kyubi-enabled"
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	lappend effects [list "water-clon" enemy1 -1]
	lappend effects [list "water-clon" enemy2 -1]
	genin_mist_watermaster 700 520
	genin_mist_watermaster 1000 520 
}
proc slide_2 {} {
	global locations ai_type
	set ai_type "high"
	replic "naruto-1" 4000
	phon 2
	set locations [list 1 1 1 1]
	hatake_kakashi 1000 520 {"doton-moguragakure"}
	#genin_mist_watermaster 1000 520 2 3 1 1 {"suiton-suika" "suiton-suiro"}
}
proc slide_3 {} {
	global locations ai_type
	set ai_type "high"
	phon 3
	set locations [list 1 1 1 1]
	genin_mist_watermaster 700 520 2 3 1 1 {"suiton-suika" "suiton-mizu-bunshin"}
	medpack 950 520
}
proc slide_4 {} {
	global locations ai_type
	set ai_type "normal"
	replic "naruto-2" 3000
	phon 4 
	set locations [list 1 1 1 1]
	genin_robber 400 520 2 1 1 1 {"shofu"}
}
proc slide_5 {} {
	global locations ai_type
	phon 5
	scenery_message {Red pill}
	set locations [list 1 1 1 1]
	genin_robber 1000 520 2 1 1 1 {"senbon"} 
	red_table 950 520
}
proc slide_6 {} {
	global locations bonus ai_type effects
	set ai_type "special"
	kubakufuda_trap 1000
	phon 6
	set locations [list 1 2 -2 -2]
	set_chakra enemy1 5
}
proc special_trap_ai {n tech p} {
	global enemy
	if {$enemy > 1} {
	} else {
		rolic "clon_of_sakura"
	}
}
proc animation_clon_of_sakura {} {
	global effects enemy skills
	set_speed hero 1
	catch {
		destroy .s
	}
	replic "naruto-3" 3000
	lappend effects [list "shadow-clon" enemy2 -1]
	after 2000 {
		haruno_sakura 1000 420 {} 1 
		set_speed enemy2 0
		move enemy2 "left" "scenery"
	}
	after 3050 {
		replic "sakura-1" 3000
	}
	after 6100 {
		clon-pufff enemy2 "sakura" "shadow" "scenery"
		replic "naruto-4" 3000
	}
	after 6900 {
		.c delete enemy2
		.c delete enemy1
		set_enemy_zero
		replace
	}
	after 9100 {
		end_rolic
	}
}
proc set_enemy_zero {} {
	global enemy
	set enemy 0
}
proc special_sakura_ai {n tech p} {
}
proc slide_7  {} {
	global locations bonus ai_type effects etap
	set etap 1
	set ai_type "special"
	phon 7
	set locations [list -2 -2 -2 -2]
	haku 1000 420 {"senbon" "hyoton-korikyo" "hyoton-sensatsu-suisho" "hyoton-koridomu" "hyoton-makyo-hyosho"}
}
proc special_haku_ai {n tech p} {
	global etap enemy effects
	set tag enemy$n
	set nin [get_nin $tag]
	set on [get_nin hero]
	if {$on < 1} {
		set on 1
		set tech "busy"
	}
	set speed [get_speed $tag]
	set chikara [get_chakra $tag]
	set tai [get_tai $tag]
	if {$etap == 34} {
		#from etap 4 back to etap 3
		set etap 3
	}
	if {$etap == 6} {
		#have no chakra to tech
		standart_ai $n $tech $p
	}
	if {$etap == 5} {
		#naruto in ice prison
		set h [get_height $tag]
		set l [get_location $tag]
		set hl [expr $h * 10 + $l]
		if {![is_in [list "hyoton-makyo-hyosho-user" $tag $hl] $effects]} {
			set etap 4
		}
		if {$chikara > 10} {
			set_nin $tag 0 
			#wait
		} else {
			set etap 6
		}
	}
	if {$etap == 4} {
		#melee fight
		if {$tech == "run" && $p == 1} {
			set etap 34
		} elseif {[get_location "hero"] == [get_location $tag]} {
			if {$tech == "none" || [is_bonus $tech] || [is_ranged $tech]} {
				if {$chikara > 26 && ![is_in [list "shadow-clon" "hero" 2] $effects] && ![is_in [list "shadow-clon" "hero" 1] $effects]} {
					set etap 5
					melee_tech $tag "hero" "hyoton-makyo-hyosho" $nin "attack" [get_tai "hero"] 
				} elseif {$chikara > 15} {
					melee_tech $tag "hero" "hyoton-sensatsu-suisho" $speed "attack" [get_tai "hero"] 
				} else {
					#nonething
					set etap 6
				}
			} elseif {$tech == "busy"} {
				if {$chikara > 26 && ![is_in "shadow-clon" "hero" 2] && ![is_in "shadow-clon" "hero" 1]} {
					set etap 5
					melee_tech $tag "hero" "hyoton-makyo-hyosho" $nin "none" 0
				} elseif {$chikara > 15} {
					melee_tech $tag "hero" "hyoton-sensatsu-suisho" $speed "none" 0
				} else {
					#nonething
					set etap 6
				}
			} elseif {$tech == "melee"} {
				if {$chikara > 26 && ![is_in "shadow-clon" "hero" 2] && ![is_in "shadow-clon" "hero" 1]} {
					set etap 5
					melee_tech "hero" $tag $tech $p "hyoton-makyo-hyosho" $nin
				} elseif {$chikara > 15} {
					melee_tech "hero" $tag $tech $p "hyoton-sensatsu-suisho" $speed
				} else {
					melee_tech "hero" $tag $tech $p "attack" $tai
					set etap 6
				}
			}
		} elseif {[get_location "hero"] != [get_location $tag]} {
			set etap 3
		}
	}
	if {$etap == 3} {
		#haku in right border
		if {$tech == "run" && $p == 0 && [get_location "hero"] == [expr [get_location $tag] - 1]} {
			set etap 4
		} elseif {[is_ranged $tech]} {
			if {$chikara > 10} {
				ranged_tech "hero" $tag $tech $p "hyoton-koridomu" $nin
			} else {
				ranged_tech "hero" $tag $tech $p "none" 0
			}
		} else {
			#stand and wait
		}
	}
	if {$etap == 2} {
		#center fight
		if {$tech == "run" && $p == 0 && [get_location "hero"] == [expr [get_location $tag] - 1]} {
			if {$chikara > 10} {
				tech_hyoton-korikyo $tag
				replace
			} else {
				move $tag "right"
			}
			set etap 3
		} elseif {[is_ranged $tech]} {
			if {$chikara > 10} {
				ranged_tech "hero" $tag $tech $p "hyoton-koridomu" $nin
			} else {
				ranged_tech "hero" $tag $tech $p "none" 0
			}
		} else {
			#stand and wait
		}
	}
	if {$etap == 1} {
		#begin
		if {$tech == "run" && $p == 0} {
			move $tag "left"
			set etap 2
		} elseif {[is_ranged $tech]} {
			if {$chikara > 10} {
				ranged_tech "hero" $tag $tech $p "hyoton-koridomu" $nin
			} else {
				ranged_tech "hero" $tag $tech $p "none" 0
			}
		} else {
			#stand and wait
		}
	}
}
proc slide_8 {} {
	global locations bonus ai_type effects etap
	set ai_type "special"
	phon 8
	set locations [list 2 2 2 1]
	hatake_kakashi 50 520 {"sharingan-1" "sharingan-2" "sharingan-3" "raiton-raikiri" "doton-moguragakure" "doton-doryu-heki" "doton-tsuiga" "katon-endan" "suiton-daibakufu" "suiton-suiryudan" "kage-bunshin" "shofu" "kawarimi"}
	momochi_zabuza 1000 520 {"kubikiribocho" "sairento-kiringu" "suiton-kirigakure" "suiton-mizurappa" "suiton-mizu-bunshin" "suiton-suijinheki" "suiton-daibakufu" "suiton-suiryudan" "suiton-baku-suishoha" "suiton-suiro"} 
}
proc victory_special {} {
	global skills
	set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
	.c raise panel
}
