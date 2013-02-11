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
	global locations ai_type effects
	set locations [list 1 3 2 3]
	phon 8
	lappend effects [list "shadow-clon" enemy1 -1]
	chunin_sound 1000 320 3 3 3 3 {"futon-zankukyokuha" "hosho" "shoshitsu" "kawarimi"}
	kubakufuda_trap 350
	kubakufuda_trap 650
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
				scenery_message {Chunin of Sound Village!}
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
		#you win
		puts "win!!!"
	}
}
proc victory_special {} {
}
