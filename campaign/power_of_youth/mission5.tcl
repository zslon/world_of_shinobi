#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 5
set heroname "lee"
set herolevel 2
set ai_type "normal"
autosave 1 5
breefing
proc slide_1 {} {
	global locations bonus
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	genin_sound 1000 520 2 2 2 1 {"futon-zankuha" "kawarimi"}
}
proc slide_2 {} {
	global locations
	phon 2
	set locations [list 1 1 1 1]
	genin_sound 1000 520 2 2 2 1 {"futon-zankuha" "kawarimi"}
	genin_sound 700 520 2 1 2 2
}
proc slide_3 {} {
	global locations ai_type
	set ai_type "high"
	phon 3
	set locations [list 2 -2 -2 -2]
	genin_sound_armmaster 1000 420 1 1 2 4 {"raiko-kenka" "soshoryu"}
}
proc slide_4 {} {
	global locations ai_type
	set ai_type "normal"
	phon 4
	set locations [list 3 3 3 3]
	genin_sound 1000 420 2 1 2 1 {"futon-zankuha" "kawarimi"}
	genin_sound 1000 320 2 1 2 1 {"futon-zankuha" "kawarimi"}
	genin_sound 1000 520 2 1 2 1 {"futon-zankuha" "kawarimi"}
}
proc slide_5 {} {
	global locations
	phon 5
	set locations [list 3 1 1 1]
	genin_sound 400 520
	medpack 50 520
}
proc slide_6 {} {
	global locations ai_type
	set ai_type "high"
	phon 6
	set locations [list 1 1 1 1]
	genin_sound_armmaster 1000 520 1 1 2 4 {"raiko-kenka" "soshoryu"}
	genin_sound_armmaster 700 520 1 1 2 4 {"kuchiese-meisu"}
}
proc slide_7 {} {
	global locations
	phon 7
	set locations [list 1 1 1 1]
	yellow_table 950 520
	genin_sound_armmaster 700 520 2 2 2 4 {"raiko-kenka" "futon-zankuha" "kawarimi"}
}
proc slide_8 {} {
	global locations effects
	set locations [list 1 3 2 3]
	phon 8
	lappend effects [list "shadow-clon" enemy1 -1]
	chunin_sound 1000 320 3 3 3 3 {"futon-zankukyokuha" "hosho" "shoshitsu" "kawarimi"}
	kubakufuda_trap 650
	kubakufuda_trap 350
}
proc slide_9 {} {
	global locations ai_type
	set ai_type "special"
	set locations [list 3 2 1 1]
	phon 9
	chunin_sound 400 420 3 3 3 3 {"futon-zankukyokuha" "kibakufuda" "hosho" "shoshitsu" "shofu" "kawarimi"}
}
global ac
set ac 0
proc special_chunin-sound_ai {n tech p} {
	global ac effects
	set tag "enemy$n"
	set ans "none"
	if {[get_hitpoints $tag] > 75} {
		if {$ac < 0} {
			#from first to second, from third to fourth study.
			set ac [expr -1 * $ac] 
		}
		if {$ac == 0} {
			#first study - hero in (0,3) position
			if {[is_bonus $tech] || $tech == "none"} {
				#hero uses suiken or hachimon or simple standing in his place
				bonus_tech_ai $n
				set ac -1
			} else {
				#hero runs to contact
				move $tag "right"  
			}
		}
		if {$ac == 1} {
			#second study - enemy must increase distantion between him and hero
			if {[get_location $tag] < 3} {
				move $tag "right" 
			} else {
				#momentally to third study
				set ac 2
			}
		}
		if {$ac == 2} {
			#third study is first shoot
			if {[get_height hero] == 1 && [get_location hero] < 3} {
				#enemy uses futon: zankukyokuha 
				replic "chunin-1"
				ranged_tech $tag hero "futon-zankukyokuha" [get_nin $tag] none 0
				set ac -3
			} elseif {[get_location hero] == 3} {
				#enemy uses kawarimi, but this event is imossible in this time
				tech_kawarimi $tag
				lappend effects "kawarimi" $tag 1
				replace
				set ac -3 
			} else {
				#wait
			}
		}
		if {$ac == 3} {
			#fourth study is ranged fight
			if {[get_height hero] == 1 && [get_location hero] < [get_location $tag] && [get_chakra $tag] > 25} {
				#shoot
				ranged_tech $tag hero "futon-zankukyokuha" [get_nin $tag] none 0
			} elseif {[get_chakra $tag] < 26} {
				#momentally to fifth study
				set ac 4
			} elseif {[get_height hero] > 1 && [get_location $tag] < 3} {
				#return to position
				move $tag "right"
			} elseif {[get_height hero] > 1 && [get_location $tag] == 3} {
				#wait
			} elseif {[get_height hero] == 1 && [get_location hero] == [get_location $tag]} {
				#you must have chakra to kawarimi, becouse you have chakra to zankukyokuha
				tech_kawarimi $tag
				lappend effects "kawarimi" $tag 1
				replace
			} elseif {[get_height hero] == 1 && [get_location hero] > [get_location $tag]} {
				#make trap
				tech_kibakufuda $tag
				lappend effects "kibakufuda" $tag 2
				replace
			}
		}
		if {$ac == 4} {
			#enemy have no longer chakra to zankukyokuha - melee fight
			if {[get_height hero] != [get_height hero] || [get_location hero] != [get_location $tag]} {
				if {$tech == "run" && [get_location hero] < [get_location $tag]} {
					#wait
				} else {
					mov_ai $tag "hero"
				}
			} elseif {[get_chakra $tag] > 10 && [get_location hero] == 0} {
				#enemy and hero is in (0,x) position - make trap or kawarimi (if you have trap) 
				if {![is_in [list "kibakufuda" $tag 1] $effects]} {
					tech_kibakufuda $tag
					lappend effects "kibakufuda" $tag 2
					replace
				} else {
					tech_kawarimi $tag
					lappend effects "kawarimi" $tag 1
					replace
				}
			} else {
				#fight
			}
		}
	} else {
		rolic "power_of_youth_end"
	}
	if {$tech != "run" && $tech != "none"} {
		if {[get_location hero] == [get_location $tag] && [get_height hero] == [get_height $tag] && [is_melee $tech]} {
			melee_tech "hero" $tag $tech $p "attack" [get_tai $tag]
		} elseif {[get_location hero] < [get_location $tag] && [get_height hero] == [get_height $tag] && [is_ranged $tech]} {
			ranged_tech "hero" $tag $tech $p "kunai" [get_speed $tag]
		}
	}
}
proc animation_power_of_youth_end {} {
	global mydir locations
	might_guy 1025 520 {"konoha-senpu" "konoha-dai-senpu" "konoha-goriki-senpu" "tsuten-kyaku" "konoha-congoriki-senpu"}
	replic "guy-1" 1500
	move "hero" "up" "scenery"
	if {[get_location "hero"] > 1 || ([get_location "hero"] == 1 && ([get_height "hero"] == 2))} {
		#lee jumps back  
		set k 50
		while {$k <= 1000} {
			after $k ".c move heroi -15 0" 
			incr k 50
		}
	} elseif {[get_location "hero"] < 2 && [get_height "hero"] < [lindex $locations [get_location "hero"]]} {
		#lee simple jumps up
	} elseif {[get_location "hero"] == 0 && [get_height "hero"] == 3} {
		#lee jumps forward throught enemy
		set k 300
		while {$k <= 1000} {
			after $k ".c move heroi 20 0" 
			incr k 50
		}
		set k 550 
		while {$k <= 1000} {
			#double down moving becouse 1st location have only 2 floors.
			after $k ".c move heroi 0 -10" 
			incr k 50
		}
	}
	#guy is enemy-2, chunin is enemy-1
	set tag "enemy2"
	set vrag "enemy1"
	if {[get_location $vrag] < 3} {
		set d [expr ([get_location $vrag] - 3) * 300]
		#fast move of might guy
		set m [expr $d / 20]
		set t 25
		while {$t <= 500} {
			after $t ".c move $tag $m 0" 
			incr t 25
		}
		set t 0
		set e 1
		while {$t <= 500} {
			after $t "get_image $tag [file join $mydir images heroes gui run $e.gif]"
			incr e 1
			if {$e == 7} {
				set e 1
			}
			incr t 50
		}
		if {[get_height $vrag] > 1} {
			set v [expr ([get_height $vrag] - 1) * -100]
			#fast jump of might guy
			set n [expr $d / 10]
			set t 525
			while {$t <= 750} {
				after $t ".c move $tag 0 $n" 
				incr t 25
			}
			after 525 "get_image $tag [file join $mydir images heroes gui jump 1.gif]"
			after 575 "get_image $tag [file join $mydir images heroes gui jump 2.gif]"
			after 625 "get_image $tag [file join $mydir images heroes gui jump 3.gif]"
			set t 750
			set e 6
			while {$t <= 825} {
				after $t "get_image $tag [file join $mydir images heroes gui jump $e.gif]" 
				incr t 25
				incr e
			}
		}		
	} else {
	#if was runnig, now t is 500. is was runnig and jump, now t is 825. if no running, t is 0 
		set t 0
		.c move $tag -20 0
		.c move $vrag -20 0
	}
	#begin attack
	set t [expr $t + 100]
	#konoha congoriki senpu
	set i 1
	while {$i <= 7} {
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes gui attack 3-$i.gif]"
		incr i
		set t [expr $t + 25]
	}
	#gui have taijitsu 5 - 8x4 damage (+1 from konoha senpu and +2 from konoha goriki senpu) = 11x4. first strike - is congoriki senpu with double 		#damage 22. and three strikes in process of konoha senpu (22+ 33 = 55 total). Then, last Tsuten Kyaku strike with 55 damage. It is 110 damage total 		#for only 25 chakra points in process of simple attack!
	take_damage enemy1 22 "konoha-senpu" 
	after $t "replace"
	set purpose "chunin-sound"
	set strikes 3
	set t2 $t
	while {$strikes > 0} {
		set i 2
		while {$i <= 7} {
			after $t2 ".c raise $tag
get_image $tag [file join $mydir images heroes gui konoha-senpu $i.gif]"
			incr i
			set t2 [expr $t2 + 25]
		}
		set t2 [expr $t2 + 25]
		after $t2 "take_damage enemy1 11 konoha-senpu"
		incr strikes -1
	}
	after $t2 "replace"
	set tincr 0
	while {$tincr < 540} {
		after [expr $t + $tincr] ".c move $vrag 0 -8
.c move $tag 0 -10"
		incr tincr 45
	}
	#tsuten-kyaku
	set t2 [expr $t + $tincr]
	set i 1
	while {$i <= 7} {
		after $t2 ".c raise $tag
get_image $tag [file join $mydir images heroes gui tsuten-kyaku $i.gif]"
		incr i
		set t2 [expr $t2 + 35]
	}
	set_chakra enemy2 [expr [get_chakra enemy2] - 25]
	after $t2 "take_damage enemy1 55 tsuten-kyaku
	replace"
	set tincr 720
	while {$tincr < 1120} {
		after [expr $t + $tincr] ".c move $tag 0 10"
		incr tincr 35
	}
	set tincr 720
	while {$tincr < 900} {
		after [expr $t + $tincr] ".c move $vrag 0 8"
		incr tincr 15
	}
	after [expr $t + 75] "get_image $vrag [file join $mydir images heroes $purpose wound 2.gif]"
	after [expr $t + $tincr] ".c move $vrag 0 -10
get_image $vrag [file join $mydir images heroes $purpose wound 3.gif]"
	after [expr $t + $tincr + 30] ".c move $vrag 0 -10"
	after [expr $t + $tincr + 60] ".c move $vrag 0 -10
get_image $vrag [file join $mydir images heroes $purpose wound 4.gif]"
	after [expr $t + $tincr + 90] ".c move $vrag 0 10"
	after [expr $t + $tincr + 120] ".c move $vrag 0 10"
	after [expr $t + $tincr + 150] ".c move $vrag 0 10
get_image $vrag [file join $mydir images heroes $purpose wound 5.gif]"
	after [expr $t + $tincr + 180] "get_image $vrag [file join $mydir images heroes $purpose wound 6.gif]"
	after [expr $t + $tincr + 210] "get_image $vrag [file join $mydir images heroes $purpose wound 7.gif]"
	after [expr $t + $tincr + 210] "get_image $tag [file join $mydir images heroes gui stand 1.gif]"
	after [expr $t + $tincr + 400] ".c delete $vrag
	replace"
	set t [expr $t + $tincr + 450]
	after $t "replic lee-1 3000"
	after [expr $t + 3100] "replic guy-2 3000"
	after [expr $t + 6150] "campaign_victory"
}
proc special_gui_ai {n tech p} {
}
proc campaign_victory {} {
	global mydir effects skills
	source [file join $mydir gamestat.tcl]
	set f [open [file join $mydir gamestat.tcl] w]
	puts $f "set regim normal"
	puts $f "set camp_0_person \{naruto\}"
	puts $f "set camp_1_person \{sasuke\}"
	puts $f "set camp_2_person \{\}"
	puts $f "set camp_0_mission 0"
	puts $f "set camp_1_mission 0" 
	puts $f "set camp_2_mission 0" 
	close $f 
	lappend effects [list "endgame" "hero" 0]
	victory_image
	set leeskills [list [list "lee" 100 150 4 1 2 3 {}]]
	foreach s $skills {
		lappend leeskills $s
	} 
	set guiskills [list [list "gui" 250 300 5 2 2 5 {}] "konoha-senpu" "konoha-dai-senpu" "konoha-goriki-senpu" "konoha-congoriki-senpu" "shofu" "omote-renge" "ura-renge" "tsuten-kyaku" "asakujaku" "hirudora" "kawarimi" "kage-bunshin" "soshuga" "kuchiese-ninkame" "tengoku-no-kuchiese" "kai" "kibakufuda" "hachimon-1" "hachimon-2" "hachimon-3" "hachimon-4" "hachimon-5" "hachimon-6" "hachimon-7" "hachimon-8"]
	set tentenskills [list [list "tenten" 100 150 3 3 1 2 {}] "kawarimi" "kuchiese-kusarigama" "soshuga" "raiko-kenka" "kuchiese-meisu" "soshoryu"]
	after 3000 "end_panel {$leeskills} {$guiskills} {$tentenskills}"
}
