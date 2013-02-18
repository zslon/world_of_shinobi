source [file join $mydir utils tech.tcl]
source [file join $mydir utils ai.tcl]
proc shinobi {class name level t n g s skills} {
	global [set class] bonus
	if {$class != "hero"} {
		set bonus [expr $bonus + 10*($level+1)] 
	}
	set hitpoints [expr 50*($level+1)]
	set chakra [expr 50*$level + ($level/3)*50 + ($level/4)*150]
	if {$name == "naruto"} {
		set chakra [expr $chakra + $chakra / 2]
	}
	set [set class] [list $name $hitpoints $chakra $t $n $g $s $skills]
}
#traps
proc trap {type} {
	global enemy
	shinobi "enemy$enemy" "trap" 0 1 1 1 3 $type
}
proc kunai_trap {x} {
	global enemy mydir
	incr enemy 1
	trap "kunai"
	get_image enemy$enemy [file join $mydir images attacks kunai 1.gif]
	.c create image $x 700 -image enemy$enemy -tag enemy$enemy 
}
proc kubakufuda_trap {x} {
	global enemy mydir
	incr enemy 1
	trap "kubakufuda"
	get_image enemy$enemy [file join $mydir images attacks kunai 1.gif]
	.c create image $x 700 -image enemy$enemy -tag enemy$enemy 
}
#bonuses
proc medpack {x y} {
	global mydir
	get_image medic [file join $mydir images heroes medpack.gif]
	.c create image $x $y -image medic -tag medic
}
proc green_table {x y} {
	global mydir
	get_image gr_table [file join $mydir images heroes green-table.gif]
	.c create image $x $y -image gr_table -tag green_medic
}
proc yellow_table {x y} {
	global mydir
	get_image yl_table [file join $mydir images heroes yellow-table.gif]
	.c create image $x $y -image yl_table -tag yellow_medic
}
#shinobi
proc major_hero {x y} {
	global heroname herolevel skills tai nin gen speed
	shinobi "hero" $heroname $herolevel $tai $nin $gen $speed $skills
	[set heroname]_[set herolevel] $x $y
}

proc training_lumber {x y} {
	global enemy
	incr enemy 1
	shinobi "enemy$enemy" "lumber" 0 0 0 0 0 {}
	lumber $x $y
}
proc genin {x y village tai nin gen sp skills} {
	global enemy
	incr enemy 1
	set x [expr $x + ($enemy - 2)*10]
	shinobi "enemy$enemy" "genin-$village" 1 $tai $nin $gen $sp $skills
	genin_from_$village $x $y
	if {$tai < 2} {
		gen_minus $enemy
	}
	if {$tai > 2 || $nin > 1 || $gen > 2 || $sp > 1} {
		gen_plus $enemy
	}
}
proc genin_armmaster {x y village tai nin gen sp skills} {
	global enemy
	incr enemy 1
	set x [expr $x + ($enemy - 2)*10]
	shinobi "enemy$enemy" "genin-[set village]-armmaster" 1 $tai $nin $gen $sp $skills
	genin_armmaster_from_$village $x $y
	if {$sp < 4} {
		gen_minus $enemy
	}
	if {$tai > 1 || $nin > 1 || $gen > 2 || $sp > 4} {
		gen_plus $enemy
	}
}
proc chunin {x y village tai nin gen sp skills} {
	global enemy
	incr enemy 1
	set x [expr $x + ($enemy - 2)*10]
	shinobi "enemy$enemy" "chunin-$village" 2 $tai $nin $gen $sp $skills
	chunin_from_$village $x $y
	if {$tai < 3 || $nin < 3 || $gen < 3 || $sp < 3} {
		gen_minus $enemy
	}
	if {$tai > 3 || $nin > 3 || $gen > 3 || $sp > 3} {
		gen_plus $enemy
	}
}
proc genin_robber {x y {tai 2} {nin 1} {gen 1} {sp 1} {skills {}}} {
	genin $x $y robber $tai $nin $gen $sp $skills
}
proc genin_sound {x y {tai 2} {nin 1} {gen 2} {sp 1} {skills {}}} {
	genin $x $y sound $tai $nin $gen $sp $skills
}
proc genin_robber_armmaster {x y {tai 1} {nin 1} {gen 1} {sp 4} {skills {}}} {
	genin_armmaster $x $y robber $tai $nin $gen $sp $skills
}
proc genin_sound_armmaster {x y {tai 1} {nin 1} {gen 2} {sp 4} {skills {}}} {
	genin_armmaster $x $y sound $tai $nin $gen $sp $skills
}
proc chunin_sound {x y {tai 3} {nin 3} {gen 3} {sp 3} {skills {}}} {
	chunin $x $y sound $tai $nin $gen $sp $skills
}
#personal
proc ten_ten {x y skills {level 1}} {
	global enemy
	incr enemy 1
	set x [expr $x + ($enemy - 2)*10]
	if {$level == 1} {
		shinobi "enemy$enemy" "tenten" 1 2 2 1 1 $skills
		genin_tenten $x $y
	}
	if {$level == 2} {
		shinobi "enemy$enemy" "tenten" 2 3 3 1 2 $skills
		genin_tenten $x $y
	}
	if {$level == 3} {
		shinobi "enemy$enemy" "tenten-adult" 3 3 3 2 3 $skills
		chunin_tenten $x $y
	}
}
proc might_guy {x y skills} {
	global enemy
	incr enemy 1
	set x [expr $x + ($enemy - 2)*10]
	shinobi "enemy$enemy" "gui" 4 5 2 2 5 $skills
	jonin_might_guy $x $y
}
##
proc getx {tag} {
	set l [.c coords $tag]
	lindex $l 0 
}
proc gety {tag} {
	set l [.c coords $tag]
	lindex $l 1 
}
proc get_location {class} {
	if {$class == "hero"} {
		set tag "heroi"
	} else {
		set tag $class
	}
	set x [getx $tag]
	set l 0
	if {$x < 250} {
		set l 0
	}
	if {$x > 250 && $x < 500} {
		set l 1
	}
	if {$x > 500 && $x < 750} {
		set l 2
	}
	if {$x > 750} {
		set l 3
	}
	return $l
}
proc get_height {class} {
	if {$class == "hero"} {
		set tag "heroi"
	} else {
		set tag $class
	}
	set y [gety $tag]
	set h 1
	if {$y > 500} {
		set h 1
	} 
	if {$y > 400 && $y < 500} {
		set h 2
	}
	if {$y > 300 && $y < 400} {
		set h 3
	}
	return $h
}
proc get_status {class} {
	set t [get_tai $class]
	set n [get_nin $class]
	set g [get_gen $class]
	set s [get_speed $class]
	if {$t == 0} {
		set a "passive"
	} else {
		if {$g == 0} {
			set a "in genjitsu"
		} else {	
			if {$s == 0} {
				set a "shocked"
			} else {
				if {$n == 0} {
					set a "cast"
				} else {
					set a "free"
				}
			}
		}
	}
	return $a
}
proc get_name {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 0]
	} else {
		global [set class]
		return [lindex [set [set class]] 0]
	}
}
proc set_form {class form} {
	global $class
	set name [get_name $class]
	lset $class 0 "[set name]-[set form]"
}
proc remove_form {class} {
	global $class
	set nameform [get_name $class]
	set name [lindex [split $nameform -] 0]
	lset $class 0 $name
}
proc get_hitpoints {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 1]
	} else {
		global [set class]
		return [lindex [set [set class]] 1]
	}
}
proc set_hitpoints {class n} {
	global $class
	lset $class 1 $n
}
proc get_chakra {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 2]
	} else {
		global [set class]
		return [lindex [set [set class]] 2]
	}
}
proc set_chakra {class n} {
	global $class
	lset $class 2 $n
}
proc get_tai {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 3]
	} else {
		global [set class]
		return [lindex [set [set class]] 3]
	}
}
proc set_tai {class n} {
	global $class
	lset $class 3 $n
}
proc get_nin {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 4]
	} else {
		global [set class]
		return [lindex [set [set class]] 4]
	}
}
proc set_nin {class n} {
	global $class
	lset $class 4 $n
}
proc get_gen {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 5]
	} else {
		global [set class]
		return [lindex [set [set class]] 5]
	}
}
proc set_gen {class n} {
	global $class
	lset $class 5 $n
}
proc get_speed {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 6]
	} else {
		global [set class]
		return [lindex [set [set class]] 6]
	}
}
proc set_speed {class n} {
	global $class
	lset $class 6 $n
}
proc get_skills {class} {
	if {[llength $class] > 1} {
		return [lindex [set class] 7]
	} else {	
		global [set class]
		return [lindex [set [set class]] 7]
	}
}
proc move {class d {type "fight"}} {
	global mydir heroname locations hero_ancof
	if {$type == "fight"} {
		set s "run"
	} elseif {$type == "scenery"} {
		set s "norm"
	}
	if {$class == "hero"} {
		set tag "heroi"
		set hero_ancof 0
		set rrun "run"
		set lrun "run_away"
	} else {
		set tag $class
		set [set class]_ancof 0
		set rrun "run_away"
		set lrun "run"
	}
	set name [get_name $class]
	set h [get_height $class]
	set loc [get_location $class]
	if {$d == "up"} {
		set p [lindex $locations $loc]
		set u -10
		set m 0
		set e 1
		get_image $tag [file join $mydir images heroes $name jump 1.gif] $s $class
		after 100 "get_image $tag [file join $mydir images heroes $name jump 1.gif] $s $class"
		after 300 "get_image $tag [file join $mydir images heroes $name jump 2.gif] $s $class"
		after 500 "get_image $tag [file join $mydir images heroes $name jump 3.gif] $s $class"
		set t 25		
		while {$t <= 500} {
			after $t ".c move $tag $m $u" 
			incr t 25
		}
		set u [expr $u * -1]
		#jump up to next floor
		if {($p > 0 && $p > $h) || ($p < 0 && ([expr $p * -1] > $h))} {
			#momental jump to leave from enemy attack
			.c move $tag 0 10
			set u [expr $u - 5]
			after $t ".c move $tag 0 -10"
		}
		#
		while {$t <= 1000} {
			after $t ".c move $tag $m $u" 
			incr t 25
		}
		set t 1000
		set e 6
		while {$t <= 1150} {
			after $t "get_image $tag [file join $mydir images heroes $name jump $e.gif] $s $class" 
			incr t 50
			incr e
		}
	} else {
		if {$d == "right"} {
			set m 15
			#jump down
			set loc [expr $loc + 1]
			if {$loc != 4} {
				set p [lindex $locations $loc]
			} else {
				set p 0 
			}
			if {(abs($p) < $h) && $p != 0} {
				set ex [expr $h - abs($p)]
				set u [expr -10 * $ex]
				get_image $tag [file join $mydir images heroes $name jump 1.gif] $s $class
				after 100 "get_image $tag [file join $mydir images heroes $name jump 1.gif] $s $class"
				after 300 "get_image $tag [file join $mydir images heroes $name jump 2.gif] $s $class"
				after 500 "get_image $tag [file join $mydir images heroes $name jump 3.gif] $s $class"
				set t 1000
				set e 6
				while {$t <= 1150} {
					after $t "get_image $tag [file join $mydir images heroes $name jump $e.gif] $s $class" 
					incr t 50
					incr e
				}
				#momental jump to leave from enemy attack
				.c move $tag 0 10
				after [expr $t - 160] ".c move $tag 0 -10"		
			} else {
				set u 0
				set t 0
				set e 1
				while {$t <= 1000} {
					after $t "get_image $tag [file join $mydir images heroes $name $rrun $e.gif] $s $class"
					incr e 1
					if {$e == 7} {
						set e 1
					}
					incr t 100
				}
			}
		}
		if {$d == "left"} {
			set m -15
			#jump down
			set loc [expr $loc - 1]
			set p [lindex $locations $loc]
			if {(abs($p) < $h)} {
				set ex [expr $h - abs($p)]
				set u [expr -10 * $ex]
				get_image $tag [file join $mydir images heroes $name jump 1.gif] $s $class
				after 100 "get_image $tag [file join $mydir images heroes $name jump 1.gif] $s $class"
				after 300 "get_image $tag [file join $mydir images heroes $name jump 2.gif] $s $class"
				after 500 "get_image $tag [file join $mydir images heroes $name jump 3.gif] $s $class"
				set t 1000
				set e 6
				while {$t <= 1150} {
					after $t "get_image $tag [file join $mydir images heroes $name jump $e.gif] $s $class" 
					incr t 50
					incr e
				}	
				#momental jump to leave from enemy attack
				.c move $tag 0 10
				after [expr $t - 160] ".c move $tag 0 -10"	
			} else {
				set u 0
				set t 0
				set e 1
				while {$t <= 1000} {
					after $t "get_image $tag [file join $mydir images heroes $name $lrun $e.gif] $s $class"
					incr e 1
					if {$e == 7} {
						set e 1
					}
					incr t 100
				}
			}
		}
		set t 50
		while {$t <= 500} {
			after $t ".c move $tag $m $u" 
			incr t 50
		}
		set u [expr $u * -2]
		while {$t <= 1000} {
			after $t ".c move $tag $m $u" 
			incr t 50
		}
	}
	after $t "get_image $tag [file join $mydir images heroes $name stand 1.gif] $s $class"
}
proc end_turn {{tech "none"} {p 0}} {
	block_battlepanel
	return_nin
	major_ai $tech $p
	after 1100 {
		fighting_sensor
	}
	after 2000 {
		unblock_battlepanel
		dies
		#else effect_work
		replace
	}
}
proc return_nin {} {
	global enemy
	set n [get_nin "hero"]
	after 2000 "set_nin hero $n"
	set e 1
	while {$e <= $enemy} {
		set n$e [get_nin enemy$e]
		after 2000 "set_nin enemy$e [set n$e]"
		incr e
	}
}
proc fighting_sensor {} {
	global enemy effects herolevel
	set h [get_height "hero"]
	set l [get_location "hero"]
	set e 1
	set t "none"
	while {$e <= $enemy} {
		set eh [get_height enemy$e]
		set el [get_location enemy$e]
		if {$el == $l && [get_name enemy$e] == "trap"} {
			set t "trap"
			break
		} elseif {$eh == $h} {
			if {$el == $l && $t == "none"} {
				set t "melee"
				set ea $e
			}			
		} else {
			
		}
		incr e
	}
	if {$t == "melee"} {
		set e $ea
	}
	if {$e > $enemy} {
		set e 1
		while {$e <= $enemy} {
			set eh [get_height enemy$e]
			set el [get_location enemy$e]
			if {$eh == $h} {
				if {[expr $el - 1] == $l && [get_name enemy$e] != "trap"} {
					set t "kunai"
					break
				}			
			} else {
				
			}
			incr e
		}
	}
	if {[is_in [list "endgame" "hero" 0] $effects]} {
		set t "none"
	}
	if {$t == "none"} {
		if {[getx medic] > 0} {
			if {[object_in [getx heroi] [gety heroi] [getx medic] [gety medic] 25 25]} {
				set level $herolevel
				if {[get_hitpoints "hero"] < [expr 50*($level + 1)]} {
					set_hitpoints "hero" [expr 50*($level + 1)]
					concentrate_chakra "heroi" [get_name "hero"]
					.c delete medic				
				}
			}
		}
		if {[getx green_medic] > 0} {
			if {[object_in [getx heroi] [gety heroi] [getx green_medic] [gety green_medic] 25 25]} {
				set level $herolevel
				if {[get_hitpoints "hero"] < [expr 50*($level + 1)]} {
					set_hitpoints "hero" [expr [get_hitpoints "hero"] + 25]
					if {[get_hitpoints "hero"] > [expr 50*($level + 1)]} {
						set_hitpoints "hero" [expr 50*($level + 1)]
					}
					set_chakra "hero" [expr [get_chakra "hero"] + 25]
					concentrate_chakra "heroi" [get_name "hero"]
					.c delete green_medic				
				}
			}
		}
		if {[getx yellow_medic] > 0} {
			if {[object_in [getx heroi] [gety heroi] [getx yellow_medic] [gety yellow_medic] 25 25]} {
				set level $herolevel
				if {[get_hitpoints "hero"] < [expr 50*($level + 1)]} {
					set_hitpoints "hero" [expr [get_hitpoints "hero"] + 50]
					if {[get_hitpoints "hero"] > [expr 50*($level + 1)]} {
						set_hitpoints "hero" [expr 50*($level + 1)]
					}
					set_chakra "hero" [expr [get_chakra "hero"] + 50]
					concentrate_chakra "heroi" [get_name "hero"]
					.c delete yellow_medic				
				}
			}
		}
	} else {
		if {$t == "kunai"} {
			set s [get_speed "hero"]
			set es [get_speed enemy$e]
			if {[get_status "hero"] == "free"} {
				if {[get_status enemy$e] == "free"} {
					ranged_tech "hero" enemy$e "kunai" $s "kunai" $es
				} else {
					ranged_tech "hero" enemy$e "kunai" $s "none" $es
				}
			} else {
				
			}
		}
		if {$t == "melee"} {
			set t [get_tai "hero"]
			set et [get_tai enemy$e]
			if {[get_status "hero"] == "free"} {
				if {[get_status enemy$e] == "free"} {
					melee_tech "hero" enemy$e "attack" $t "attack" $et
					.c move heroi 10 0
					.c move enemy$e -10 0
					after 900 "
						.c move heroi -10 0
						.c move enemy$e 10 0
					"
				} else {
					melee_tech "hero" enemy$e "attack" $t "none" $et
					.c move heroi 10 0
					after 900 {.c move heroi -10 0}
				}
			}
		}
		if {$t == "trap"} {
			set s [get_speed "hero"]
			set es [get_speed enemy$e]
			set type [get_skills enemy$e]
			set y [gety "heroi"]
			set x [getx enemy$e]
			.c move enemy$e [expr 1000 - $x] [expr $y - 700]
			ranged_tech enemy$e "hero" $type $es "none" $s
			block_animation "heroi" [get_name "hero"] 
			.c move enemy$e [expr $x - 1000] [expr 700 - $y]
			set_hitpoints enemy$e 0
		}
	}
}
proc dies {} {
	global enemy bonus herolevel slide effects mydir
	if {$enemy > 0} {
		global enemy$enemy
	}
	set h [get_hitpoints hero]
	set c [get_chakra hero]
	if {$h < 1 || $c < 1} {
		set x [getx original_hero]
		set y [gety original_hero]
		if {$x > 0 && $x < 1024 && $y > 0 && $y < 600} {
			#clon-pufff
		} else {
			die hero
		}
	}
	set e 1
	set f 0
	while {$e <= $enemy} {
		global enemy$e
		set h [get_hitpoints enemy$e]
		set c [get_chakra enemy$e]
		set x [getx original_enemy$e]
		set y [gety original_enemy$e]
		if {$x > 0 && $x < 1024 && $y > 0 && $y < 600} {
			#clon-pufff
		} elseif {$h < 1} {
			if {[is_in [list "shadow-clon" enemy$e -1] $effects]} {
				after 1100 "get_image dieenemy$e [file join $mydir images heroes [get_name enemy$e] clon-pufff 10.gif] run enemy$e
				.c itemconfigure enemy$e -image dieenemy$e
				clon_message
				replace"
				set u 0
				set i -1
				foreach s $effects {
					if {$s == [list "shadow-clon" enemy$e -1]} {
						set i $u
					}
					incr u
				} 
				if {$i >= 0} {
					set effects [lreplace $effects $i $i]
				}
			}
			set f 1
			die enemy$e
			.c delete panelenemy$e
			.c addtag panelenemy$e withtag panelenemy$enemy
			if {$e != $enemy} {
#last enemy to empty place
				.c move panelenemy$enemy 0 [expr -51*($enemy - $e)]
				set enemy$e [set enemy$enemy]
				after 2000 "
				.c addtag enemy$e withtag enemy$enemy
				.c dtag enemy$enemy
				.c itemconfigure enemy$e -image enemy$e
				enemy$e copy enemy$enemy
				stand_animation enemy$e [get_name enemy$e] $slide"
				incr e -1
			}
			incr enemy -1
			if {$enemy == 0 && [get_hitpoints "hero"] > 0} {
				set level $herolevel
				if {[get_chakra "hero"] < [expr 50*$level + ($level/3)*50 + ($level/4)*150]} {
					if {[expr [get_chakra "hero"] + $bonus] > [expr 50*$level + ($level/3)*50 + ($level/4)*150]} {
						set_chakra "hero" [expr 50*$level + ($level/3)*50 + ($level/4)*150]
					} else {
						set_chakra "hero" [expr [get_chakra "hero"] + $bonus]
					}
					concentrate_chakra "heroi" [get_name "hero"]
				}
			}
			replace
		}	
		incr e
	}
	if {$f == 0} {
		effect_work
	} else {
		after 2000 {effect_work}
	}
}
proc ranged_tech {from to name par ans par2} {
	global mydir effects
	set user [get_name $from]
	set nin [get_nin $from]
	set_nin $from 0
	if {$from == "hero"} {
		set tag "heroi"
		set tag2 $to
	} else {
		set tag $from
		set tag2 "heroi"
	}
	set dam [enciclopedia $name "damage" $par]
	set num [enciclopedia $name "number" $par]
#kusarigama
	if {$name == "kunai" && [is_in [list "kuchiese-kusarigama" $from -1] $effects]} {
		set dam [expr $dam*$num]
		set num 1
		set name "kusarigama"
	}
#raiko kenka
	if {$name == "kunai" && [is_in [list "raiko-kenka" $from -1] $effects]} {
		set num [expr 1+[get_speed $from]/2]
		set dam 7
		set name "suriken"
	}
	if {$ans == "none"} {
		set num2 0
		if {[gety $tag2] > [expr [gety $tag] + 5]} {
			#jump and leave from attack
			set dam 0
		}
	} else {
		set nin2 [get_nin $to]
		set_nin $to 0
		set dam2 [enciclopedia $ans "damage" $par2]
		set num2 [enciclopedia $ans "number" $par2]
#kusarigama
		if {$ans == "kunai" && [is_in [list "kuchiese-kusarigama" $to -1] $effects]} {
			set dam2 [expr $dam2*$num2]	
			set num2 1
			set ans "kusarigama"
		}
#raiko kenka
		if {$ans == "kunai" && [is_in [list "raiko-kenka" $to -1] $effects]} {
			set num2 [expr 1+[get_speed $to]/2]
			set dam2 7
			set ans "suriken"
		}
		set user2 [get_name $to]
		set mt2 [expr 900 / $num2]
		set ti2 100
		if {$mt2 < 800 && $mt2 > 400} {
			set ti2 100
		}
		if {$mt2 < 400 && $mt2 > 200} {
			set ti2 50
		}
		if {$mt2 < 200} {
			set ti2 20
		}
	}
#futon: zankuha
	if {$name == "futon-zankuha" && [is_kunai_based $ans]} {
		set dam2 [expr $dam2 / 2]
	} 
	if {$ans == "futon-zankuha" && [is_kunai_based $name]} {
		set dam [expr $dam / 2]
	} 
	set x [getx $tag]
	set y [gety $tag]
	set x2 [getx $tag2]
	set y2 [gety $tag2]
	set r [expr $x2 - $x]
	set mt [expr 900 / $num]
#speed
	set ti 100
	if {$mt < 800 && $mt > 400} {
		set ti 100
	}
	if {$mt < 400 && $mt > 200} {
		set ti 50
	}
	if {$mt < 200} {
		set ti 20
	}
	set n 1
	if {[have_special_animate $name]} {
		tech_$name $from $r $to 0 $dam
		set num 0
	}
	if {[have_special_animate $ans]} {
		tech_$ans $to [expr -1*$r] $from 0 $dam2
		set num2 0
	}
	while {$n <= $num || $n <= $num2} {		
		if {[get_status $from] == "cast" && $n <= $num} {
			set i 1
			set t [expr $mt*($n-1)]
			while {$i <= 4} {
				set t [expr $t + $ti]
				if {$user != "trap"} {
					after $t "get_image $tag [file join $mydir images heroes $user $name $i.gif]"
				}
				incr i
			}
			if {($name == "kunai" || $name == "kusarigama") && [is_high $from]} { 
				tech_$name $x $y $r $to $t $dam "big"
			} else {
				tech_$name $x $y $r $to $t $dam
			}
			if {$name == "kusarigama"} {
				after [expr $t + 200] "get_image $tag [file join $mydir images heroes $user $name 5.gif]"
				after [expr $t + 400] "get_image $tag [file join $mydir images heroes $user $name 6.gif]"
			} else {
				after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
			}
		}
		if {[get_status $to] == "cast" && $n <= $num2} {
			set t [expr $mt2*($n-1)]
			set i 1
			while {$i <= 4} {
				set t [expr $t + $ti2]
				after $t "get_image $tag2 [file join $mydir images heroes $user2 $ans $i.gif]"
				incr i
			}	
			if {($ans == "kunai" || $ans == "kusarigama") && [is_high $to]} { 
				tech_$ans $x2 $y2 [expr -1*$r] $from $t $dam2 "big"
			} else {
				tech_$ans $x2 $y2 [expr -1*$r] $from $t $dam2
			}
			tech_$ans $x2 $y2 [expr -1*$r] $from $t $dam2
			if {$ans == "kusarigama"} {
				after [expr $t + 200] "get_image $tag2 [file join $mydir images heroes $user2 $ans 5.gif]"
				after [expr $t + 400] "get_image $tag2 [file join $mydir images heroes $user2 $ans 6.gif]"
			} else {
				after $t "get_image $tag2 [file join $mydir images heroes $user2 stand 1.gif]"
			}
		}	
		incr n
	}
}
proc melee_tech {from to name par ans par2} {
	global mydir effects
	set nin [get_nin $from]
	set_nin $from 0
	set dam [enciclopedia $name "damage" $par]
	set num [enciclopedia $name "number" $par]
	set sk [get_skills $from]
#kawarimi
	if {[is_in [list "kawarimi" $to 1] $effects] && [get_gen $from] < [expr 2*[get_gen $to]]} {
		set ans "none"
		set par2 "0"
		set dam 0
		if {$to == "hero"} {
			set tak "heroi"
		} else {
			set tak $to
		}
		kawarimi_teleport $tak [get_name $to]
	} elseif {[is_in [list "kawarimi" $to 1] $effects]} {
		set ans "attack"
		set par2 [get_tai $to]
	}
#kuchiese meisu effect
	if {$name == "attack" && [is_in [list "kuchiese-meisu" $from -1] $effects]} {
		set name "meisu"
		set dam [expr $dam * 2]
		set num [expr $num / 2]
	}
#soshuga effect
	if {$name == "attack" && [is_in [list "soshuga" $from -1] $effects]} {
		set name "nunchaka"
		if {[is_taijitsu $ans]} {
			set dam2 [enciclopedia $ans "damage" [expr $par2 - 1]]
			set num2 [enciclopedia $ans "number" [expr $par2 - 1]]
		}
	}
	if {$ans == "none"} {
		set num2 0
	} else {
		set nin2 [get_nin $to]
		set_nin $to 0
		set dam2 [enciclopedia $ans "damage" $par2]
		set num2 [enciclopedia $ans "number" $par2]
		set sk2 [get_skills $to]
#meisu
		if {$ans == "attack" && [is_in [list "kuchiese-meisu" $to -1] $effects]} {
			set ans "meisu"
			set dam2 [expr $dam2 * 2]
			set num2 [expr $num2 / 2]
		}
#soshuga
		if {$ans == "attack" && [is_in [list "soshuga" $to -1] $effects]} {
			set ans "nunchaka"
			if {[is_taijitsu $name]} {
				set dam [enciclopedia $name "damage" [expr $par - 1]]
				set num [enciclopedia $name "number" [expr $par - 1]]
			}
		}
		set mt2 [expr 900 / $num2]
		set ti2 50
		if {$mt2 < 800 && $mt2 > 400} {
			set ti2 50
		}
		if {$mt2 < 400 && $mt2 > 200} {
			set ti2 25
		}
		if {$mt2 < 200} {
			set ti2 15
		}
	}
	set mt [expr 900 / $num]
#speed (maximum strikes is 2+10/2=7, minimum mt is 128)
	set ti 50
	if {$mt < 600 && $mt > 400} {
		set ti 50
	}
	if {$mt < 400 && $mt > 200} {
		set ti 25
	}
	if {$mt < 200} {
		set ti 15
	}
	set n 1
	set h11 [get_hitpoints $to]
	set h12 [get_hitpoints $from]
	while {$n <= $num || $n <= $num2} {		
		if {[get_status $from] == "cast" && $n <= $num} {
#konoha_senpu effect
			if {$n == 1 && $name == "attack" && [is_in "konoha-senpu" $sk] && $dam > 0} {
				incr dam 1
				if {[is_in "konoha-goriki-senpu" $sk]} {	
					incr dam 2
				}
				if {[is_in "konoha-congoriki-senpu" $sk]} {
					tech_konoha-senpu $from $to [expr $mt*($n-1)] $ti [expr $dam * 2] "final" [expr $num - $n]
				} else {
					tech_konoha-senpu $from $to [expr $mt*($n-1)] $ti $dam "begin"
				}
			} else {
#shoshitsu effect
				if {$n == 1 && $name == "attack" && [is_in "shoshitsu" $sk] && $dam > 0} {
					tech_shoshitsu $from $to [expr $mt*($n-1)] $ti $dam
				} else {
					tech_$name $from $to [expr $mt*($n-1)] $ti $dam 
				}
			}
			if {$n == 2 && $name == "attack" && [is_in "konoha-dai-senpu" $sk] && $dam > 0 && [get_hitpoints $to] < $h11} {
				tech_konoha-senpu $from $to [expr $mt*($n-1)] $ti $dam "final" [expr $num - $n]
			}
			if {$n == 2 && [is_in "shoshitsu" $sk] && $dam > 0 && [get_hitpoints $to] < $h11} {
				incr num2 -1
			}
#hosho effect
			if {$n == $num && $name == "attack" && [is_in "hosho" $sk] && $dam > 0} {
				tech_hosho $from $to [expr $mt*($n-1)] $ti $dam
			}
		}
		if {[get_status $to] == "cast" && $n <= $num2} {
#konoha_senpu effect
			if {$n == 1 && $ans == "attack" && [is_in "konoha-senpu" $sk2] && $dam2 > 0} {
				incr dam2 1
				if {[is_in "konoha-goriki-senpu" $sk2]} {	
					incr dam2 2
				}
				if {[is_in "konoha-congoriki-senpu" $sk2]} {
					tech_konoha-senpu $to $from [expr $mt2*($n-1)] $ti2 [expr $dam2 * 2] "final" [expr $num2 - $n]
				} else {
					tech_konoha-senpu $to $from [expr $mt2*($n-1)] $ti2 $dam2 "begin"
				}
			} else { 
#shoshitsu effect
				if {$n == 1 && $ans == "attack" && [is_in "shoshitsu" $sk2] && $dam2 > 0} {
					tech_shoshitsu $to $from [expr $mt2*($n-1)] $ti2 $dam2 
				} else {
					tech_$ans $to $from [expr $mt2*($n-1)] $ti2 $dam2 
				}
			}
			if {$n == 2 && $ans == "attack" && [is_in "konoha-dai-senpu" $sk2] && $dam2 > 0 && [get_hitpoints $from] < $h12} {
				tech_konoha-senpu $to $from [expr $mt2*($n-1)] $ti2 $dam2 "final" [expr $num2 - $n]
			}
			if {$n == 2 && [is_in "shoshitsu" $sk2] && $dam2 > 0 && [get_hitpoints $from] < $h12} {
				incr num -1
			}
#hosho effect
			if {$n == $num2 && $ans == "attack" && [is_in "hosho" $sk2] && $dam2 > 0} {
				tech_hosho $to $from [expr $mt2*($n-1)] $ti2 $dam2 
			}
		}	
		incr n
	}
	if {$to == "hero"} {
		set tag $from
		set tag2 "heroi"	
	} else {
		set tag "heroi"
		set tag2 $to	
	}
}
proc nokout {p} {
	global locations mydir
	if {$p == "hero"} {
		set d -1
		set tag "heroi"
	} else {
		set d 1
		set tag $p
	}
	set l [get_location $p]
	set h [get_height $p]
	if {[expr $l + $d] > -1 && [expr $l + $d] < 4} {
		set s [lindex $locations [expr $l + $d]]
		if {abs($s) <= $h || $s > 0} {
			if {$s > $h} {
				set s $h
			}
			set g [expr (($h - abs($s)) * 100 + 100) / 10]
			set v [expr 240/10*$d]
			set vs [expr 20*$d]
			set n [get_name $p]
			get_image $tag [file join $mydir images heroes $n wound 2.gif]
			after 100 "get_image $tag [file join $mydir images heroes $n wound 3.gif]"
			set t 0
			.c move $tag $vs -50
			after 25 ".c move $tag $vs -25"
			after 50 ".c move $tag $vs -25"
			set t 100
			while {$t < 600} {
				after $t ".c move $tag $v $g"
				incr t 50
			}
			set t 600
			set i 4
			while {$t <= 800} {
				after $t "get_image $tag [file join $mydir images heroes $n wound $i.gif]"
				incr i				
				incr t 50
			}
			set h [get_hitpoints $p]
			if {$h > 0} {
				after $t "get_image $tag [file join $mydir images heroes $n stand 1.gif]"
			} else {
				get_image die$tag [file join $mydir images heroes $n wound 7.gif]
				after [expr $t - 50] ".c itemconfigure $tag -image die$tag"
			}
		} else {
			wound_animation $tag [get_name $p]
		}
	} else {
		wound_animation $tag [get_name $p]
	}	
}
proc passive_fly {p t} {
	global mydir
	if {$p == "hero"} {
		set tag "heroi"
	} else {
		set tag $p
	}
	set n [get_name $p]
	get_image $tag [file join $mydir images heroes $n wound 2.gif]
	set i 4
	set t2 [expr $t - 150]
	while {$t2 <= $t} {
		after $t2 "get_image $tag [file join $mydir images heroes $n wound $i.gif]"
		incr i				
		incr t2 50
	}
	set h [get_hitpoints $p]
	if {$h > 0} {
		after $t "get_image $tag [file join $mydir images heroes $n stand 1.gif]"
	} else {
		get_image die$tag [file join $mydir images heroes $n wound 7.gif]
		after [expr $t - 50] ".c itemconfigure $tag -image die$tag"
	}
}
proc victory {} {
	global effects hero_ancof campdir missionnumber
	set i 0
	foreach e $effects {
		set do [lindex $e 0]
		set owner [lindex $e 1]
		effect $do $owner "remove"
		set effects [lreplace $effects $i $i]
		incr i
	}
	set hero_ancof 1
	stand_animation "heroi" [get_name "hero"]
	lappend effects [list "endgame" "hero" 0]
	victory_image
	victory_special
	set m [expr $missionnumber + 1]
	after 5000 "next_mission $m"
}
proc clear {} {
	global allbuttonskills
	.c delete all
	destroy .right .left .jump .stand
	bind .c <ButtonPress> {
	}
	bind . <Right> {
	}
	bind . <Left> {
	}
	bind . <Up> {
	}
	bind . <space> {
	}
	foreach s $allbuttonskills {
		if {[enciclopedia $s chakra] != 0} {
			destroy .button_$s
		}
	}
}
proc next_mission {n} {
	global m ar campdir
	clear
	set m $n
	set ar 1
	source [file join $campdir start.tcl]
}
