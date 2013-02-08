#effects
global effects used
set effects [list]
set used [list]
proc effect_work {} {
	global effects
	set i 0
	foreach e $effects {
		set do [lindex $e 0]
		set owner [lindex $e 1]
		set t [lindex $e 2]
		effect $do $owner "do"
		if {$t > 0} {
			incr t -1
		} else {
		}
		if {$t == 0} {
			set effects [lreplace $effects $i $i]
			effect $do $owner "remove"
		} else {
			lset effects $i [list $do $owner $t]
			incr i
		}
	}
}
proc effect {name owner what} {
	global used campdir enemy $owner slide mydir
	source [file join $campdir personstat.tcl]
	if {$what == "do"} {
		if {$name == "suiken" && $owner == "hero"} {
			hero_ai_agressive
		}
	}
	if {$what == "remove"} {
		if {$name == "kibakufuda"} {
			detonation $owner
		}
		if {$name == "suiken"} {
			set_speed $owner [expr [get_speed $owner] - 2]
		}
		if {$name == "shadow-clon" && [get_hitpoints $owner] > 0} {
			set_hitpoints $owner 0
			clon-pufff $owner [get_name $owner]
			set x [getx original_$owner]
			set y [gety original_$owner]
			if {$x > 0 && $x < 1024 && $y > 0 && $y < 600} {
				after 1100 "teleport $owner $x $y"
			} else {
				after 1100 "get_image die$owner [file join $mydir images heroes [get_name $owner] clon-pufff 10.gif] run $owner
				.c itemconfigure $owner -image die$owner
				die $owner
				clon_message
				replace"
				if {$owner != "enemy$enemy"} {
					#last enemy to empty place
					set xa [getx panel$owner]
					set ya [gety panel$owner]
					set xe [getx panelenemy$enemy]
					set ye [gety panelenemy$enemy]
					.c move panelenemy$enemy [expr $xa - $xe] [expr $ya - $ye]
					set [set owner] [set enemy$enemy]
					after 2000 "
					.c addtag $owner withtag enemy$enemy
					.c dtag enemy$enemy
					.c itemconfigure $owner -image $owner
					$owner copy enemy$enemy
					stand_animation $owner [get_name $owner] $slide"
				}
				set enemy [expr $enemy - 1]
			}
		}
		if {$name == "hachimon-1"} {
			set_tai $owner [expr [get_tai $owner] - 1]
			remove_form $owner
		}
		if {$name == "hachimon-2"} {
		}
		if {$name == "hachimon-3"} {
			set_speed $owner [expr [get_speed $owner] - 1]
		}
		if {$name == "kuchiese-meisu"} {
			set s [expr $speed - 1]
			set_speed $owner [expr [get_speed $owner] + $s]
			set_tai $owner [expr [get_tai $owner] - $s]
		}
		if {$owner == "hero" && $name != "suiken"} {
			set u 0
			set i -1
			foreach s $used {
				if {$s == $name} {
					set i $u
				}
				incr u
			} 
			if {$i >= 0} {
				set used [lreplace $used $i $i]
			}
		}
	}
}
proc take_damage {p d t} {
	global effects
	if {[get_hitpoints $p] > 0 && $d > 0} {
	set_hitpoints $p [expr [get_hitpoints $p] - $d]
		set k -1
		while {$k <= 5} {
			if {[is_in [list "shadow-clon" $p $k] $effects]} {
				after 900 "effect shadow-clon $p remove"
				#remove damage
				set_hitpoints $p [expr [get_hitpoints $p] + $d]
				set u 0
				set i -1
				foreach s $effects {
					if {$s == [list "shadow-clon" $p $k]} {
						set i $u
					}
					incr u
				} 
				if {$i >= 0} {
					set effects [lreplace $effects $i $i]
				}

			}
			incr k 1
		}
	}
}
#techincs
#Taijitsu
proc tech_kunai {x y r p {timestart 0} d {type "little"}} {
	global mydir effects
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks kunai 2.gif]
	} else {
		get_image i_$randomnumber [file join $mydir images attacks kunai 1.gif]
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	if {$type == "big"} {
		after $t " .c move t_$randomnumber 0 -20"
	}
	while {$t < [expr $timestart + 200]} {
		after $t ".c move t_$randomnumber [expr $r / 10] 0"
		incr t 20	
	}
	after $t ".c delete t_$randomnumber
	replace"
	#damage
	set s [get_speed $p]
	set chance [expr 100 - $s*15]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "kunai"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_kubakufuda {x y r p {timestart 0} d} {
	global mydir enemy
	if {$p == "hero"} {
		set tag "heroi"
	} else {
		set tag $p
	}
	set x [getx $tag]
	set y [gety $tag]
	set randomnumber [expr 100*rand()]
	get_image i_$randomnumber [file join $mydir images attacks kubakufuda 1.gif]
	set t $timestart
	set i 1
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	while {$t < [expr $timestart + 500]} {
		after $t "get_image i_$randomnumber [file join $mydir images attacks kubakufuda $i.gif]"
		incr t 50
		incr i 1
	}
	after $t ".c delete t_$randomnumber
	replace"
	#damage (very mark)
	set e 1
	set enemylist [list]
	while {$e <= $enemy} {
		lappend enemylist enemy$e
		incr e
	}
	lappend enemylist "hero"
	foreach purpose $enemylist {
		if {[get_location $purpose] == [get_location $p] && [get_height $purpose] == [get_height $p]} {
			set s [get_speed $purpose]
			set randomnumber [expr 100*rand()]
			set chance [expr 100 - $s*5]
			if {$randomnumber < $chance} {
				#hit
				take_damage $purpose $d "kubakufuda"
				after [expr $t - 100] "set_speed $p 0"
				if {[get_hitpoints $purpose] > 0} {
					after [expr $t + 900] "set_speed $p $s"
				}
				after [expr $t - 150] "nokout $purpose"
				if {[get_chakra $purpose] == 0} {
					set_hitpoints $purpose 0
				}
			}
		}
	}
}
proc tech_suriken {x y r p {timestart 0} d} {
	global mydir effects
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks suriken 2.gif]
	} else {
		get_image i_$randomnumber [file join $mydir images attacks suriken 1.gif]
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	while {$t < [expr $timestart + 200]} {
		after $t ".c move t_$randomnumber [expr $r / 10] 0"
		incr t 20	
	}
	after $t ".c delete t_$randomnumber
	replace"
	#damage
	set s [get_speed $p]
	set chance [expr 100 - $s*10]
	if {$randomnumber < $chance} {
		#hit (have more chances, and more damage then kunai, but not many shoots)
		take_damage $p $d "raiko-kenka"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_kusarigama {x y r p {timestart 0} d {type "little"}} {
	global mydir effects
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks kusarigama 1-1.gif]
		set pref 1
	} else {
		get_image i_$randomnumber -[file join $mydir images attacks kusarigama 2-1.gif]
		set pref 2
	}
	set t $timestart
	if {$r > 0} {
		after $t ".c create image [expr $x + 175] $y -image i_$randomnumber -tag t_$randomnumber"
	}
	if {$r < 0} {
		after $t ".c create image [expr $x - 175] $y -image i_$randomnumber -tag t_$randomnumber"
	}
	if {$type == "big"} {
		after $t ".c move t_$randomnumber 0 -20"
	}
	set i 1
	while {$i < 8} {
		after $t "get_image i_$randomnumber [file join $mydir images attacks kusarigama [set pref]-[set i].gif]"
		incr t 28
		incr i 1
	}
	incr i -1
	incr t 28
	while {$i > 0} {
		after $t "get_image i_$randomnumber [file join $mydir images attacks kusarigama [set pref]-[set i].gif]"
		incr t 28
		incr i -1
	}	
	after [expr $timestart + 400] ".c delete t_$randomnumber"
	#damage
	set s [get_speed $p]
	set chance [expr 100 - $s*15]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "kuchiese-kusarigama"
		set_speed $p 0
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 1100] "set_speed $p $s"
		}
	}
}
proc tech_attack {u p {timestart 0} interval d} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set h [expr 3*rand()]
	if {$h < 1} {
		set r 1
	}
	if {$h > 1 && $h < 2} {
		set r 2
	}
	if {$h > 2} {
		set r 3
	}
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user attack $r-$i.gif] run $u"
		incr i
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]
	replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "attack"
	}
}
proc tech_meisu {u p {timestart 0} interval d} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user meisu $i.gif]"
		incr i
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]
	replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "kuchiese-meisu"
	}
}
proc tech_nunchaka {u p {timestart 0} interval d} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user soshuga $i.gif]"
		incr i
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]
	replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#decrease enemy taijitsu by 1
		take_damage $p $d "soshuga"
	}
}
proc tech_konoha-senpu {u p {timestart 0} interval d {type "begin"} {strikes 0}} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		if {$type == "begin"} {
			after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user konoha-senpu $i.gif]"
			incr i
		}
		if {$type == "final"} {
			after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user attack 3-$i.gif]"
			incr i
		}
	}
	if {$type == "begin"} {
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user konoha-senpu 8.gif]
replace"
	} else {
		after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]
		replace"
	}
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "konoha-senpu"
		if {$type == "final"} {
			set_speed $p 0
			set_speed $u 0 
			after [expr $t + 900] "set_speed $u $s1"
			if {[get_hitpoints $p] > 0} {
				after [expr $t + 900] "set_speed $p $s2"
			}
			if {$strikes > 0} {
				tech_final-konoha-senpu $u $p $t $interval $d $strikes
			}
		}
	}
}
proc tech_final-konoha-senpu {u p {timestart 0} interval d strikes} {
	global mydir locations
	if {$u == "hero"} {
		set tag "heroi"
		set tag2 $p
	} else {
		set tag $u
		set tag2 "heroi"
	}
	.c raise $tag
	set user [get_name $u]
	set purpose [get_name $p]
	set t $timestart
	while {$strikes > 0} {
		set i 2
		while {$i <= 7} {
			set t [expr $t + $interval]
			after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user konoha-senpu $i.gif]"
			incr i
		}
		set t [expr $t + $interval]
		#damage
		set s1 [get_speed $u]
		set s2 [get_speed $p]
		set chance [expr 50 - ($s2-$s1)*10]
		set randomnumber [expr 100*rand()]
		if {$randomnumber < $chance} {
			#hit
			take_damage $p $d "konoha-senpu"
		}
		incr strikes -1
	}
	set tincr 0
	while {$tincr < 300} {
		after [expr $timestart + $tincr] ".c move $tag2 0 -8
.c move $tag 0 -10"
		incr tincr 25
	}
	while {$tincr < 600} {
		after [expr $timestart + $tincr] ".c move $tag2 0 8
.c move $tag 0 10"
		incr tincr 25
	}
	after [expr $timestart + 75] "get_image $tag2 [file join $mydir images heroes $purpose wound 2.gif]"
	after [expr $timestart + $tincr] ".c move $tag2 0 -10
	get_image $tag2 [file join $mydir images heroes $purpose wound 3.gif]"
	after [expr $timestart + $tincr + 25] ".c move $tag2 0 -10"
	after [expr $timestart + $tincr + 50] ".c move $tag2 0 10"
	after [expr $timestart + $tincr + 100] ".c move $tag2 0 10"
	after [expr $timestart + $tincr + 125] "get_image $tag2 [file join $mydir images heroes $purpose wound 4.gif]"
	after [expr $timestart + $tincr + 150] "get_image $tag2 [file join $mydir images heroes $purpose wound 5.gif]"
	after [expr $timestart + $tincr + 175] "get_image $tag2 [file join $mydir images heroes $purpose wound 6.gif]"
	after [expr $timestart + $tincr + 200] "get_image $tag2 [file join $mydir images heroes $purpose wound 7.gif]"
	if {[get_hitpoints $p] > 0} {
		after [expr $timestart + $tincr + 200] "get_image $tag2 [file join $mydir images heroes $purpose wound 8.gif]"
		after [expr $timestart + $tincr + 225] "get_image $tag2 [file join $mydir images heroes $purpose stand 1.gif]"
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
}
proc tech_shofu {u p {timestart 0} interval d} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	.c raise $tag
	set_chakra $u [expr [get_chakra $u] - 10]
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user attack 3-$i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "shofu"
		set_speed $p 0
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 900] "set_speed $p $s2
			replace"
		}
		after [expr $t - 100] "nokout $p"
	}
}
proc tech_shoshitsu {u p {timestart 0} interval d} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 5} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user shoshitsu $i.gif]"
		incr i
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]
	replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "shoshitsu"
	}
}
proc tech_hosho {u p {timestart 0} interval d} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
		set tag2 $p
	} else {
		set tag $u
		set tag2 "heroi"
	}
	.c raise $tag
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user attack 1-$i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "hosho"
		set_speed $p 0
		after [expr $t - 300] "wound_animation $tag2 [get_name $p] fast"
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 100] "set_speed $p $s2
			replace"
		}
	}
}
proc tech_omote-renge {u p {timestart 0} interval d} {
	global mydir locations
	if {$u == "hero"} {
		set tag "heroi"
		set tag2 $p
		#throw
		set pos [get_location $u]
		if {$pos < 3} {
			set l1 [get_height $u]
			set l2 [lindex $locations [expr $pos + 1]]
			if {$l1 >= abs($l2) || $l2 > 0} {
				set dx 10
				if {$l1 <= abs($l2)} {
					set dy 15
					set ds 0
				} else {
					set ds [expr $l1 - abs($l2)]
					set dy [expr 15 + 10*$ds]
				}
			}
		} else {
			set ds 0
			set dx 0
			set dy 15
		}
	} else {
		set tag $u
		set tag2 "heroi"
		#throw
		set pos [get_location $u]
		if {$pos > 0} {
			set l1 [get_height $u]
			set l2 [lindex $locations [expr $pos - 1]]
			if {$l1 >= abs($l2) || $l2 > 0} {
				set dx -10
				if {$l1 <= abs($l2)} {
					set dy 15
					set ds 0
				} else {
					set ds [expr $l1 - abs($l2)]
					set dy [expr 15 + 10*$ds]
				}
			}
		} else {
			set dx 0
			set dy 15
			set ds 0
		}
	}
	.c raise $tag
	set_chakra $u [expr [get_chakra $u] - 25]
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user attack 3-$i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]
#10% more mark then simple strike 	
	set chance [expr 60 - ($s2-$s1)*10]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "omote-renge"
		set_speed $p 0
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 1000] "set_speed $p $s2"
		}
		after [expr $t - 100] "passive_fly $p 1700"
		set i 1
		set t2 $t
		while {$i <= 6} {
			after $t2 ".c move $tag2 0 -25"
			set t2 [expr $t2 + $interval]
			incr i
		}
		set i 1
		set t [expr $t + $interval*3]
		while {$i <= 4} {
			after $t "get_image $tag [file join $mydir images heroes $user omote-renge $i.gif]"
			after $t ".c move $tag 0 -25"
			set t [expr $t + $interval / 2]
			incr i
		}
		set i 3
		while {$i <= 4} {
			after $t "get_image $tag [file join $mydir images heroes $user omote-renge $i.gif]"
			after $t ".c move $tag 0 -25"
			set t [expr $t + $interval / 2]
			incr i
		}
		while {$i <= 8} {
			after $t ".c move $tag2 0 5"
			after $t "get_image $tag [file join $mydir images heroes $user omote-renge $i.gif]"
			set t [expr $t + $interval]
			incr i
		}
		after $t "get_image $tag2 [file join $mydir images heroes empty.gif]"
		while {$i <= 12} {
			after $t ".c move $tag $dx $dy"
			after $t ".c move $tag2 $dx $dy"
			after $t "get_image $tag [file join $mydir images heroes $user omote-renge $i.gif]"
			set t [expr $t + $interval / 2]
			incr i
		}
		set i 9
		while {$i <= 12} {
			after $t ".c move $tag $dx $dy"
			after $t ".c move $tag2 $dx $dy"
			after $t "get_image $tag [file join $mydir images heroes $user omote-renge $i.gif]"
			set t [expr $t + $interval / 2]
			incr i
		}
		set i 9
		while {$i <= 10} {
			after $t ".c move $tag $dx $dy"
			after $t ".c move $tag2 $dx $dy"
			after $t "get_image $tag [file join $mydir images heroes $user omote-renge $i.gif]"
			set t [expr $t + $interval / 2]
			incr i
		}
		after $t ".c move $tag2 0 -20"
		set dx [expr $dx * 2]
		set t2 $t
		set i 1
		while {$i <= 10} {
			set t2 [expr $t2 + $interval]
			after $t2 ".c move $tag2 $dx -3"
			incr i
		}
		set dx [expr $dx/2]
		after [expr $t2 + $interval/2] ".c move $tag2 0 30"
		after $t "get_image $tag2 [file join $mydir images heroes [get_name $p] wound 2.gif]"
		after $t "get_image $tag [file join $mydir images heroes $user omote-renge 13.gif]"
		set t [expr $t + $interval]
		after $t "get_image $tag [file join $mydir images heroes $user omote-renge 14.gif]"
		set t [expr $t + $interval]
		after $t "get_image $tag [file join $mydir images heroes $user omote-renge 15.gif]"
		after $t ".c move $tag [expr $dx*(-10)] [expr $ds*(-100)]"
		set t [expr $t + $interval]
		after $t "get_image $tag [file join $mydir images heroes $user omote-renge 14.gif]"
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
}
#ranged 
#ninjitsu
proc tech_soshoryu {u r p {timestart 0} d} {
	global mydir enemy locations
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_chakra $u [expr [get_chakra $u] - 25]
	set x [getx $tag]
	set y [expr [gety $tag] - 75]
	set t $timestart
	set i 1
	set name [get_name $u]
	while {$i <= 20} {
		set t [expr $t + 100]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $name soshoryu $i.gif]"
		incr i 1
	}
	after $t "get_image $tag [file join $mydir images heroes $name stand 1.gif]
	replace"
	set k 1
	set t 1100
	while {$t < 1900} {
		after $t "traectory $x $y $k soshoryu $u"
		after $t "traectory $x $y [expr -1*$k] soshoryu $u"
		incr k
		incr t 100
	}
	#multiply damage
	set l [get_location $u]
	set h [get_height $u]
	set e 1
	set enemylist [list]
	while {$e <= $enemy} {
		lappend enemylist enemy$e
		incr e
	}
	lappend enemylist "hero"
	foreach purpose $enemylist {
		if {[get_height $purpose] == $h && [get_location $purpose] != $l} {
			set s [get_speed $purpose]	
			set randomnumber [expr 100*rand()]
			set miss_chance [expr $s*15]
			if {$randomnumber > $miss_chance} {
				#full hit
			} else {
				#halfhit
				if {$randomnumber > [expr $miss_chance / 2]} {
					set d [expr $d / 2]
				} else {
					#quarthit
					if {$randomnumber > [expr $miss_chance / 4]} {
						set d [expr $d / 4]
					} else {
						#octahit
						if {$randomnumber > [expr $miss_chance / 8]} {
							set d [expr $d / 8]
						} else {
							#miss
							set d 0
						}
					}
				}
			}
			take_damage $purpose $d "soshoryu"
		}
	}
}
proc tech_sogu-tensasai {u r p {timestart 0} d} {
	global mydir enemy locations
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_chakra $u [expr [get_chakra $u] - 50]
	set x [getx $tag]
	set y [expr [gety $tag] - 75]
	set randomnumber [expr 100*rand()]
	set t $timestart
	set i 1
	set name [get_name $u]
	while {$i <= 20} {
		set t [expr $t + 100]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $name soshoryu $i.gif]"
		incr i 1
	}
	after $t "get_image $tag [file join $mydir images heroes $name stand 1.gif]
	replace"
	set k 1
	set t 1100
	while {$t < 1900} {
		after $t "traectory $x $y $k soshoryu $u"
		after $t "traectory $x $y [expr -1*$k] soshoryu $u"
		after $t "traectory $x $y [expr 9 - $k] soshoryu $u"
		after $t "traectory $x $y [expr -9 + 1*$k] soshoryu $u"
		incr k
		incr t 100
	}
	#multiply damage
	set l [get_location $u]
	set h [get_height $u]
	set e 1
	set enemylist [list]
	while {$e <= $enemy} {
		lappend enemylist enemy$e
		incr e
	}
	lappend enemylist "hero"
	foreach purpose $enemylist {
		if {[get_height $purpose] == $h && [get_location $purpose] != $l} {
			set s [get_speed $purpose]	
			set miss_chance [expr $s*15]
			if {$randomnumber > $miss_chance} {
				#full hit
			} else {
				#halfhit
				if {$randomnumber > [expr $miss_chance / 2]} {
					set d [expr $d / 2]
				} else {
					#quarthit
					if {$randomnumber > [expr $miss_chance / 4]} {
						set d [expr $d / 4]
					} else {
						#octahit
						if {$randomnumber > [expr $miss_chance / 8]} {
							set d [expr $d / 8]
						} else {
							#miss
							set d 0
						}
					}
				}
			}
			take_damage $purpose $d "sogu-tensasai"
		}
	}
}
#futon
proc tech_futon-zankuha {x y r p {timestart 0} d} {
	global mydir effects enemy
	
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks zankuha 2.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		set_chakra $u [expr [get_chakra $u] - 15]
	} else {
		get_image i_$randomnumber [file join $mydir images attacks zankuha 1.gif]
		set_chakra "hero" [expr [get_chakra "hero"] - 15]
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	#damage (very mark)
	set s [get_speed $p]
	set chance [expr 100 - $s*5]
	while {$t < [expr $timestart + 500]} {
		if {$randomnumber < $chance} {
			after $t "if_delete t_$randomnumber $u
.c move t_$randomnumber [expr $r / 25] 0"
		} else {
			after $t ".c move t_$randomnumber [expr $r / 25] 0"
		}
		incr t 20	
	}
	after $t ".c delete t_$randomnumber
	replace"
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "futon-zankuha"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_futon-zankukyokuha {x y r p {timestart 0} d} {
	global mydir effects enemy
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks zankukyokuha 2.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		set_chakra $u [expr [get_chakra $u] - 25]
	} else {
		get_image i_$randomnumber [file join $mydir images attacks zankukyokuha 1.gif]
		set_chakra "hero" [expr [get_chakra "hero"] - 25]
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	#damage (very very mark - minimal chance is 70% vs naruto in fox-mode)
	set s [get_speed $p]
	set chance [expr 100 - $s*3]
	while {$t < [expr $timestart + 500]} {
		if {$randomnumber < $chance} {
			after $t "if_delete t_$randomnumber $u
.c move t_$randomnumber [expr $r / 25] 0"
		} else {
			after $t ".c move t_$randomnumber [expr $r / 25] 0"
		}
		incr t 20	
	}
	after $t ".c delete t_$randomnumber
	replace"
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "futon-zankukyokuha"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
		#throws enemy
		after [expr $t - 100] "set_speed $p 0"
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 900] "set_speed $p $s"
		}
		after [expr $t - 100] "nokout $p"
	}
}
#bonus
proc tech_raiko-kenka {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set i 0
	foreach ef $effects {
		if {$ef == [list "soshuga" $u -1] || $ef == [list "kuchiese-meisu" $u -1] ||  $ef == [list "kuchiese-kusarigama" $u -1]} {
			set effects [lreplace $effects $i $i]
			effect [lindex $ef 0] $u "remove"
		} else {
			incr i
		}
	}
	set_chakra $u [expr [get_chakra $u] - 15]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 9} {
		after $t "get_image $tag [file join $mydir images heroes $user kuchiese $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "get_image $tag [file join $mydir images heroes $user kuchiese suriken.gif]"
	after [expr $t + 100] "get_image $tag [file join $mydir images heroes $user kuchiese suriken.gif]"
	after $t "replace"
}
proc tech_kuchiese-kusarigama {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set i 0
	foreach ef $effects {
		if {$ef == [list "kuchiese-meisu" $u -1] || $ef == [list "raiko-kenka" $u -1] ||  $ef == [list "soshuga" $u -1]} {
			set effects [lreplace $effects $i $i]
			effect [lindex $ef 0] $u "remove"
		} else {
			incr i
		}
	}
	set_chakra $u [expr [get_chakra $u] - 15]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 9} {
		after $t "get_image $tag [file join $mydir images heroes $user kuchiese $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "get_image $tag [file join $mydir images heroes $user kuchiese kusarigama.gif]"
	after [expr $t + 100] "get_image $tag [file join $mydir images heroes $user kuchiese kusarigama.gif]"
	after $t "replace"
}
proc tech_suiken {u} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_speed $u [expr [get_speed $u] + 2]
	set_chakra $u [expr [get_chakra $u] - 25]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 11} {
		after $t "get_image $tag [file join $mydir images heroes $user suiken $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
}
proc tech_hachimon-1 {u} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_tai $u [expr [get_tai $u] + 1]
	set_chakra $u [expr [get_chakra $u] - 20]
	set user [get_name $u]
	set_form $u "hachimon"
	set t 100
	set i 1
	while {$i <= 20} {
		after $t "get_image $tag [file join $mydir images heroes $user hachimon $i.gif] run $u"
		incr i
		incr t 50
	}
	after $t "replace"
}
proc tech_hachimon-2 {u} {
	global mydir effects herolevel bonus enemy
	if {$u == "hero"} {
		set tag "heroi"
		set level $herolevel
	} else {
		set tag $u
#not exact
		set level [expr $bonus / ($enemy/20) - 1]
	}
	if {[is_in [list "hachimon-1" $u -1] $effects]} {

	} else {
#first gate
		lappend effects [list "hachimon-1" $u -1]
		set_form $u "hachimon"
		set_tai $u [expr [get_tai $u] + 1]
		set_chakra $u [expr [get_chakra $u] - 20]
	}
	set_chakra $u [expr [get_chakra $u] - 20]
#effect
	set_chakra $u [expr [get_chakra $u] + 25]
	set_hitpoints $u [expr [get_hitpoints $u] + 50]
	if {[get_hitpoints $u] > [expr 50*($level + 1)]} {
		set_hitpoints $u [expr 50*($level + 1)]
	}

	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 20} {
		after $t "get_image $tag [file join $mydir images heroes $user hachimon $i.gif] run $u"
		incr i
		incr t 50
	}
	after $t "replace"
}
proc tech_hachimon-3 {u} {
	global mydir effects herolevel enemy bonus
	if {$u == "hero"} {
		set tag "heroi"
		set level $herolevel
	} else {
		set tag $u
#not exact
		set level [expr $bonus / ($enemy/20) - 1]
	}
	if {[is_in [list "hachimon-1" $u -1] $effects]} {

	} else {
#first gate
		lappend effects [list "hachimon-1" $u -1]
		set_form $u "hachimon"
		set_tai $u [expr [get_tai $u] + 1]
		set_chakra $u [expr [get_chakra $u] - 20]
	}
	if {[is_in [list "hachimon-2" $u -1] $effects]} {

	} else {
#second gate
		lappend effects [list "hachimon-2" $u -1]
		set_chakra $u [expr [get_chakra $u] - 20]
		set_chakra $u [expr [get_chakra $u] + 25]
		set_hitpoints $u [expr [get_hitpoints $u] + 50]
		if {[get_hitpoints $u] > [expr 50*($level + 1)]} {
			set_hitpoints $u [expr 50*($level + 1)]
		}
	}
	set_speed $u [expr [get_speed $u] + 1]
	set_chakra $u [expr [get_chakra $u] - 20]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 20} {
		after $t "get_image $tag [file join $mydir images heroes $user hachimon $i.gif] run $u"
		incr i
		incr t 50
	}
	after $t "replace"
}
proc tech_soshuga {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set i 0
	foreach ef $effects {
		if {$ef == [list "kuchiese-meisu" $u -1] || $ef == [list "raiko-kenka" $u -1] ||  $ef == [list "kuchiese-kusarigama" $u -1]} {
			set effects [lreplace $effects $i $i]
			effect [lindex $ef 0] $u "remove"
		} else {
			incr i
		}
	}
	set_chakra $u [expr [get_chakra $u] - 25]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 9} {
		after $t "get_image $tag [file join $mydir images heroes $user kuchiese $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "get_image $tag [file join $mydir images heroes $user kuchiese soshuga.gif]"
	after [expr $t + 100] "get_image $tag [file join $mydir images heroes $user kuchiese soshuga.gif]"
	after $t "replace"
}
proc tech_kuchiese-meisu {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set i 0
	foreach ef $effects {
		if {$ef == [list "soshuga" $u -1] || $ef == [list "raiko-kenka" $u -1] ||  $ef == [list "kuchiese-kusarigama" $u -1]} {
			set effects [lreplace $effects $i $i]
			effect [lindex $ef 0] $u "remove"
		} else {
			incr i
		}
	}
	set s [expr [get_speed $u] - 1]
	set_speed $u [expr [get_speed $u] - $s]
	set_tai $u [expr [get_tai $u] + $s]
	set_chakra $u [expr [get_chakra $u] - 25]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 9} {
		after $t "get_image $tag [file join $mydir images heroes $user kuchiese $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "get_image $tag [file join $mydir images heroes $user kuchiese meisu.gif]"
	after [expr $t + 100] "get_image $tag [file join $mydir images heroes $user kuchiese meisu.gif]"
	after $t "replace"
}
proc tech_kibakufuda {u} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set x [getx $tag]
	set y [gety $tag]
	get_image kibakufuda_$u [file join $mydir images attacks kubakufuda 1.gif]
	set_nin $u 0
	set_chakra $u [expr [get_chakra $u] - 10]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 5} {
		after $t "get_image $tag [file join $mydir images heroes $user kibakufuda $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
	after $t ".c create image $x $y -image kibakufuda_$u -tag kibakufuda_$u"
}
proc detonation {u} {
	global mydir enemy
	set x [getx kibakufuda_$u]
	set y [gety kibakufuda_$u]
	set enemylist [list]
	set e 1
	while {$e <= $enemy} {
		lappend enemylist enemy$e
		incr e
	}
	lappend enemylist "heroi"
	set p "none"
	foreach purpose $enemylist {
		if {$x > [expr [getx $purpose] - 100] && $x < [expr [getx $purpose] + 100] && $y < [expr [gety $purpose] + 100] && $y > [expr [gety $purpose] - 100]} {
			set p $purpose
			if {$purpose == "heroi"} {
				set p "hero"
				block_animation "heroi" [get_name "hero"]
			}
			break
		} 
	}
	if {$p == "none"} {
		set randomnumber [expr rand()*100]
		get_image i_$randomnumber [file join $mydir images attacks kubakufuda 1.gif]
		.c create image $x $y -image i_$randomnumber -tag t_$randomnumber
		set t 0
		set i 1
		while {$t < 500} {
			after $t "get_image i_$randomnumber [file join $mydir images attacks kubakufuda $i.gif]"
			incr t 50
			incr i 1
		}
		after $t ".c delete t_$randomnumber"
	} else {
		tech_kubakufuda $x $y 0 $p 0 50
		block_battlepanel
		after 1000 {unblock_battlepanel}
	}
	.c delete kibakufuda_$u
}
#genjitsu bonus
proc tech_kawarimi {u} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_nin $u 0
	set_chakra $u [expr [get_chakra $u] - 10]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 5} {
		after $t "get_image $tag [file join $mydir images heroes $user kawarimi $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
} 
