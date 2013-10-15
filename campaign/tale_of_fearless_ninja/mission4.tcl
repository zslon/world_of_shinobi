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
	genin_mist_watermaster 1000 520 2 3 1 1 {"suiton-suika" "suiton-suiro"}
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
	genin_robber 1000 520 1 1 1 1 {"senbon"} 
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
	global locations bonus ai_type effects firsttime
	set ai_type "special"
	set firsttime 1
	phon 8
	set locations [list 2 2 2 1]
	hatake_kakashi 50 520 {"sharingan-1" "sharingan-2" "sharingan-3" "raiton-raikiri" "doton-moguragakure" "doton-doryu-heki" "doton-tsuiga" "katon-endan" "suiton-daibakufu" "suiton-suiryudan" "kage-bunshin" "shofu" "kawarimi"}
	momochi_zabuza 1000 520 {"kubikiribocho" "sairento-kiringu" "suiton-kirigakure" "suiton-mizurappa" "suiton-mizu-bunshin" "suiton-suijinheki" "suiton-daibakufu" "suiton-suiryudan" "suiton-baku-suishoha" "suiton-suiro"} 
}
proc special_kakashi_ai {n tech p} {
	global firsttime
	if {$firsttime == 1} {
		rolic "kakashi_versus_zabuza"
		set firsttime 0
	} else {
		
	}
}
proc special_zabuza_ai {n tech p} {
}
proc animation_kakashi_versus_zabuza {} {
	global mydir locations enemy1_ancof enemy2_ancof
	set_speed hero 1
	catch {
		destroy .s
	}
	#turn 1. sharingan and suiton-kirigakure
	set_chakra enemy1 [expr [get_chakra enemy1] - 10]
	set_chakra enemy2 [expr [get_chakra enemy2] - 15]
	replace
	set t 0
	set enemy1_ancof 0
	set enemy2_ancof 0
	set t 100
	set i 1
	while {$i <= 10} {
		after $t "get_image enemy1 [file join $mydir images heroes kakashi sharingan 3-$i.gif]"
		incr i
		incr t 100
	}
	set c 1
	while {$c <= 10} {
		get_image mist$c [file join $mydir images attacks kirigakure $c.gif] 
		incr c
	}
	set t 100
	after $t ".c create image 512 288 -image mist1 -tag mist"
	set i 1
	while {$i <= 10} {
		after $t "get_image enemy2 [file join $mydir images heroes zabuza suiton-kirigakure $i.gif]"
		after $t ".c itemconfigure mist -image mist$i"
		incr i
		incr t 100
	}
	#turn 2. suiton-mizurappa and doton-doryu-heki (40x0.5 vs 50 - absorbed)
	set t 2500
	after $t {	
		set_chakra enemy1 [expr [get_chakra enemy1] - 5]
		set_chakra enemy1 [expr [get_chakra enemy1] - 30]
		set_chakra enemy2 [expr [get_chakra enemy2] - 10]
		replace
	}
	set i 1
	while {$i <= 4} {
		set t [expr $t + 100]
		after $t "get_image enemy2 [file join $mydir images heroes zabuza suiton-mizurappa $i.gif]"
		get_image i_100-$i [file join $mydir images attacks mizurappa 2-$i.gif]
		incr i
	}
	after 3500 "get_image enemy2 [file join $mydir images heroes zabuza stand 1.gif]"
	set x [getx enemy2]
	set y [gety enemy2]
	set ox [getx enemy1]
	set dx -100
	while {[expr $ox + 160] < $x || [expr $ox - 160] > $x} {
		set x [expr $x + $dx]
		after 3500 ".c delete t_100-$x"
		set t [expr $t + 20]
		after $t ".c create image $x $y -image i_100-1 -tag t_100-$x"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_100-$x -image i_100-2"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_100-$x -image i_100-3"
		after [expr $t + 20] ".c itemconfigure t_100-$x -image i_100-4"
	}
	set x [expr $x + $dx]
	set t [expr $t + 20]
	after $t ".c create image $x $y -image i_100-1 -tag t_100"
	after 3500 ".c delete t_100"
	set t 2500
	set i 1
	while {$i <= 10} {
		set t [expr $t + 100]
		after $t "get_image enemy1 [file join $mydir images heroes kakashi doton-doryu-heki $i.gif]"
		incr i
	}
	after 4400 ".c raise enemy1
get_image enemy1 [file join $mydir images heroes kakashi stand 1.gif]"
	set t 2800
	set i 2
	set x [getx enemy1]
	set dx 50
	get_image wallenemy1 [file join $mydir images attacks doryu-heki 1.gif]
	after $t ".c create image [expr $x + $dx] 410 -image wallenemy1 -tag wallenemy1"
	while {$t <= 4400} {
		set t [expr $t + 100]
		after $t ".c raise wallenemy1
get_image wallenemy1 [file join $mydir images attacks doryu-heki $i.gif]"
		if {$i < 10} {
			incr i
		} else {
			set i 10
		}
	}
	after $t ".c delete wallenemy1"
	#turn 3. katon-endan and suiton-suijinheki (75x0.5 vs 60 - absorbed)
	set t 5000
	after $t {
		set_chakra enemy1 [expr [get_chakra enemy1] - 5]
		set_chakra enemy1 [expr [get_chakra enemy1] - 25]
		set_chakra enemy2 [expr [get_chakra enemy2] - 50]
		replace
	}
	set i 1
	while {$i <= 4} {
		set t [expr $t + 100]
		after $t "get_image enemy1 [file join $mydir images heroes kakashi katon-endan $i.gif]"
		get_image i_200-$i [file join $mydir images attacks endan 1-$i.gif]
		incr i
	}
	after 6000 "get_image enemy1 [file join $mydir images heroes kakashi stand 1.gif]"
	set x [getx enemy1]
	set y [gety enemy1]
	set ox [getx enemy2]
	set dx 100
	while {[expr $ox + 160] < $x || [expr $ox - 160] > $x} {
		set x [expr $x + $dx]
		after 6000 ".c delete t_200-$x"
		set t [expr $t + 20]
		after $t ".c create image $x $y -image i_200-1 -tag t_200-$x"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_200-$x -image i_200-2"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_200-$x -image i_200-3"
		after [expr $t + 20] ".c itemconfigure t_200-$x -image i_200-4"
	}
	set x [expr $x + $dx]
	set t [expr $t + 20]
	after $t ".c create image $x $y -image i_200-1 -tag t_200"
	after 6000 ".c delete t_200"
	set t 5000
	set i 1
	while {$i <= 10} {
		set t [expr $t + 100]
		after $t "get_image enemy2 [file join $mydir images heroes zabuza suiton-suijinheki $i.gif]"
		incr i
	}
	after 6900 ".c raise enemy2
get_image enemy2 [file join $mydir images heroes zabuza stand 1.gif]"
	set t 5300
	set i 2
	set x [getx enemy2]
	set dx -50
	get_image wallenemy2 [file join $mydir images attacks suijinheki 1.gif]
	after $t ".c create image [expr $x + $dx] 410 -image wallenemy2 -tag wallenemy2"
	while {$t <= 6900} {
		set t [expr $t + 100]
		after $t ".c raise wallenemy2
get_image wallenemy2 [file join $mydir images attacks suijinheki $i.gif]"
		if {$i < 10} {
			incr i
		} else {
			set i 10
		}
	}
	after $t ".c delete wallenemy2"
	#turn 4. suiton-daibakufu versus suiton-daibakufu (100-100x0.8 vs 80-100х0.8 - 80 vs 64)
	set t 7500
	after $t {
		set_chakra enemy1 [expr [get_chakra enemy1] - 5]
		set_chakra enemy1 [expr [get_chakra enemy1] - 70]
		set_chakra enemy2 [expr [get_chakra enemy2] - 70]
		replace
	}
	set i 1
	while {$i <= 12} {
		set t [expr $t + 100]
		if {$i < 9} {
		after $t ".c raise enemy1
.c raise enemy2"
		} else {
		after $t ".c raise daibakufuenemy1"
		}
		after $t "
get_image enemy1 [file join $mydir images heroes kakashi suiton-daibakufu $i.gif]
get_image enemy2 [file join $mydir images heroes zabuza suiton-daibakufu $i.gif]"
		incr i
	}
	after 8800 "
	get_image enemy1 [file join $mydir images heroes kakashi stand 1.gif]
	get_image enemy2 [file join $mydir images heroes zabuza stand 1.gif]"
	set c 1
	while {$c <= 12} {
		get_image bakufu$c [file join $mydir images attacks daibakufu $c.gif] 
		incr c
	}
	after 7500 ".c create image 512 520 -image bakufu1 -tag daibakufuenemy1"
	set t 7500
	set i 1
	while {$i <= 12} {
		after $t ".c itemconfigure daibakufuenemy1 -image bakufu$i"
		incr i
		incr t 100
	}
	after $t ".c delete daibakufuenemy1"
	after 8500 {
		set_hitpoints enemy1 [expr [get_hitpoints enemy1] - 70]
		set_hitpoints enemy2 [expr [get_hitpoints enemy2] - 80]
		replace
	}
	#turn 5. suiton-suiryudan versus suiton-suirydan (125-125*0.8 vs 100-25*0.8) - 100 vs 75
	set wx 0
	set dx 20
	set tp 1
	set vx -150
	set t 10000
	after $t {
		set_chakra enemy1 [expr [get_chakra enemy1] - 5]
		set_chakra enemy1 [expr [get_chakra enemy1] - 100]
		set_chakra enemy2 [expr [get_chakra enemy2] - 100]
		replace
	}
	set i 1
	while {$i <= 18 && $t <= 11500} {
		set t [expr $t + 100]
		after $t ".c raise daibakufuenemy1
get_image enemy1 [file join $mydir images heroes kakashi suiton-suiryudan $i.gif]"
		after $t ".c raise daibakufuenemy2
get_image enemy2 [file join $mydir images heroes zabuza suiton-suiryudan $i.gif]"
		incr i
	}
	set t 10000
	set i 2
	set x [getx enemy1]
	set y [gety enemy1]
	get_image wallenemy1 [file join $mydir images attacks suijinheki 1.gif]
	after $t ".c create image $wx 426 -image wallenemy1 -tag wallenemy1"
	while {$t <= 11800} {
		set t [expr $t + 100]
		after $t ".c raise wallenemy1
get_image wallenemy1 [file join $mydir images attacks suijinheki $i.gif]"
		if {$i < 10} {
			incr i
		} else {
			if {$i == 10} {
				set i 7
			}
		}
	}
	after $t ".c delete wallenemy1"
	set t 10500
	get_image i_300-1 [file join $mydir images attacks suiryudan [set tp]-1.gif]
	get_image i_300-2 [file join $mydir images attacks suiryudan [set tp]-2.gif]
	get_image i_300-3 [file join $mydir images attacks suiryudan [set tp]-3.gif]
	get_image i_300-4 [file join $mydir images attacks suiryudan [set tp]-4.gif]
	.c create image $vx $y -image i_300-1 -tag t_300
	set k 1
	while {$t < 11500} {
		after $t ".c move t_300 $dx 0
.c itemconfigure t_300 -image i_300-$k"
		incr k 1
		if {$k > 4} {
			set k 1
		}
		incr t 20
	}
	after $t ".c delete t_300"
	set wx 1025
	set dx -20
	set tp 2
	set vx 1175
	set t 10000
	set i 2
	set x [getx enemy2]
	set y [gety enemy2]
	get_image wallenemy2 [file join $mydir images attacks suijinheki 1.gif]
	after $t ".c create image $wx 426 -image wallenemy2 -tag wallenemy2"
	while {$t <= 11800} {
		set t [expr $t + 100]
		after $t ".c raise wallenemy2
get_image wallenemy2 [file join $mydir images attacks suijinheki $i.gif]"
		if {$i < 10} {
			incr i
		} else {
			if {$i == 10} {
				set i 7
			}
		}
	}
	after $t ".c delete wallenemy2"
	set t 10500
	get_image i_400-1 [file join $mydir images attacks suiryudan [set tp]-1.gif]
	get_image i_400-2 [file join $mydir images attacks suiryudan [set tp]-2.gif]
	get_image i_400-3 [file join $mydir images attacks suiryudan [set tp]-3.gif]
	get_image i_400-4 [file join $mydir images attacks suiryudan [set tp]-4.gif]
	.c create image $vx $y -image i_400-1 -tag t_400
	set k 1
	while {$t < 11500} {
		after $t ".c move t_400 $dx 0
.c itemconfigure t_400 -image i_400-$k"
		incr k 1
		if {$k > 4} {
			set k 1
		}
		incr t 20
	}
	after $t ".c delete t_400"
	after 11500 {
		set_hitpoints enemy1 [expr [get_hitpoints enemy1] - 75]
		set_hitpoints enemy2 [expr [get_hitpoints enemy2] - 100]
		replace	
	} 
	after 11500 {
		wound_animation enemy1 kakashi
		wound_animation enemy2 zabuza
	}
#turn 6. doton-moguragakure (8 damage)
	set t 12500
	after $t {
		set_chakra enemy1 [expr [get_chakra enemy1] - 5]
		set_chakra enemy1 [expr [get_chakra enemy1] - 10]
		replace
	}
	after $t "move enemy2 left scenery"
	set tp 2
	set dx -100
	set i 1
	while {$i <= 5} {
		set t [expr $t + 100]
		after $t "get_image enemy1 [file join $mydir images heroes kakashi doton-moguragakure $i.gif]"
		incr i
	}	
	after [expr $t + 100] "get_image enemy1 [file join $mydir images heroes empty.gif]"
	after 13500 "attack_of_mole enemy1 enemy2 8 hit"
#turn 7. doton-tsuiga (5/4 turns of paralich)
	set t 15000
	after $t {
		set_chakra enemy1 [expr [get_chakra enemy1] - 5]
		set_chakra enemy1 [expr [get_chakra enemy1] - 20]
		set enemy1_ancof 0
		set enemy2_ancof 0
		replace
	}
	set i 1
	while {$i <= 9} {
		after $t "get_image enemy1 [file join $mydir images heroes kakashi kuchiese $i.gif]"
		incr i
		incr t 100
	}
	after $t "get_image enemy1 [file join $mydir images heroes kakashi kuchiese doton-tsuiga.gif]"
	after [expr $t + 100] "get_image enemy1 [file join $mydir images heroes kakashi kuchiese doton-tsuiga.gif]"
	set t 15900
	set x [getx enemy2]
	set y [gety enemy2]
	after $t "get_image dogsenemy1 [file join $mydir images attacks tsuiga-no-jutsu 1.gif]"
	get_image dogsenemy1 [file join $mydir images heroes empty.gif]
	after 15000 {.c create image [getx enemy2] [gety enemy2] -image dogsenemy1 -tag dogsenemy2}
	.c addtag enemy2 withtag dogsenemy2
	set i 1
	while {$i <= 5} {
		after $t "get_image dogsenemy1 [file join $mydir images attacks tsuiga-no-jutsu $i.gif]"
		incr i
		incr t 100
	}
#turn 8. raikri (75 damage) - zabuza r.i.p.
	set t 17500
	set i 1
	while {$i <= 10} {
		set t [expr $t + 100]
		after $t ".c raise enemy1
get_image enemy1 [file join $mydir images heroes kakashi raiton-chidori $i.gif]"
		incr i
	}
	set t [expr $t + 100]
	set d 300
	set dx 30
	set t 18500
	set i 11
	while {$i <= 20} {
		set t [expr $t + 100]
		after $t ".c raise enemy1
		get_image enemy1 [file join $mydir images heroes kakashi raiton-chidori $i.gif]
		.c move enemy1 $dx 0"
		incr i
	}
	after [expr $t + 100] "get_image enemy1 [file join $mydir images heroes kakashi stand 1.gif]"
	after 19000 {
		.c delete dogsenemy2
	}
	after 19500 {
		set_hitpoints enemy2 [expr [get_hitpoints enemy2] - 75]
		replace	
		die enemy2
	} 
	after 20500 {replace
	victory}
}
proc victory_special {} {
	global skills
	set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
	.c raise panel
}
