#effects
global effects used
set effects [list]
set used [list]
proc effect_work {} {
	global effects lever
	set i 0
	foreach e $effects {
		set do [lindex $e 0]
		set owner [lindex $e 1]
		set t [lindex $e 2]
		if {$t > 0 && $i < [llength $effects]} {
			lset effects $i [list $do $owner [expr $t - 1]]
		} else {
		}
		effect $do $owner "do"
		if {$t == 0} {
			set effects [lreplace $effects $i $i]
			effect $do $owner "remove"
		} else {
			incr i
		}
	}
	set lever 0
}
proc effect {name owner what {pr "nextturn"}} {
	global used campdir enemy $owner slide mydir effects herolevel
	source [file join $campdir personstat.tcl]
	if {$what == "do"} {
		if {$name == "suiken" && $owner == "hero"} {
			hero_ai_agressive
		}
		if {$name == "kyubi-1"} {
			if {[get_chakra $owner] > 20} {
				set_chakra $owner [expr [get_chakra $owner] - 20]
			} else {
				effect "nine-tails" $owner "remove"
			}
		}
		set d 0
		set sd 0
		while {$d <= 2} {
			if {[is_in [list "nine-tails" $owner $d] $effects]} {
				set sd 1
				break
			}
			incr d 1
		}
		if {$sd == 0} {
			if {$name == "kyubi-8"} {
				if {[get_chakra $owner] > 20} {
					hero_ai_fox 8
				}
			}
			if {$name == "kyubi-6" && $herolevel == 3} {
				if {[get_chakra $owner] > 20} {
					hero_ai_fox 6
				}
			}
			if {$name == "kyubi-6" && $herolevel == 2} {
				if {[get_chakra $owner] > 20} {
					hero_ai_fox 4
				}
			}
			if {$name == "kyubi-6" && $herolevel == 1} {
				if {[get_chakra $owner] > 20} {
					hero_ai_fox 2
				}
			}
		}
		if {$name == "taju-kage-bunshin"} {
			set i 0
			foreach e $effects {
				set do [lindex $e 0]
				set holder [lindex $e 1]
				set t [lindex $e 2]
				if {$do == $name && $holder == $owner} {
					lset effects $i [list $do $owner [expr $t + 1]]
				}
				incr i
			}
		}
		if {$name == "kage-bunshin"} {
			set e 0
			set k 1
			while {$k <= 10} {
				if {[is_in [list "shadow-clon" $owner $k] $effects]} {
					set e 1
				}
				incr k 1
			}
			if {$e == 0} {
				set k 1
				while {$k <= 10} {
					set u 0
					set i -1
					foreach s $effects {
						if {$s == [list "kage-bunshin" $owner $k]} {
							set i $u
						}
						incr u
					} 
					if {$i >= 0} {
						set effects [lreplace $effects $i $i]
					}
					incr k 1
				}
			}
		}
	}
	if {$what == "remove"} {
		if {$name == "kibakufuda"} {
			detonation $owner
		}
		if {$name == "suiken"} {
			set_speed $owner [expr [get_speed $owner] - 2]
		}
		if {$name == "shadow-clon"} {
			set x [getx original_$owner]
			set y [gety original_$owner]
			if {$x > 0 && $x < 1024 && $y > 0 && $y < 600} {
				block_battlepanel
				clon-pufff $owner [get_name $owner]
				clones_interface $owner "remove_all"
				after 1100 "teleport $owner $x $y
				effect kage-bunshin $owner remove
				replace"
				.c delete original_$owner
				after 2000 {unblock_battlepanel}
			} else {
				set_hitpoints $owner 0
				#die
			}
		}
		if {$name == "nine-tails"} {
			if {$herolevel == 1 && [is_in [list "kyubi-2" $owner -1] $effects] && [get_chakra $owner] > 20} {
				#nonthing becouse it`s maximum taillevel for first herolevel
			} elseif {$herolevel == 2 && [is_in [list "kyubi-4" $owner -1] $effects] && [get_chakra $owner] > 20} {
				#nonthing becouse it`s maximum taillevel for second herolevel
			} elseif {$herolevel == 3 && [is_in [list "kyubi-6" $owner -1] $effects] && [get_chakra $owner] > 20} {
				#nonthing becouse it`s maximum taillevel for third herolevel
			} elseif {[is_in [list "kyubi-8" $owner -1] $effects] && [get_chakra $owner] > 20} {
				#it`s maximum taillevel
			} elseif {$pr == "nextslide"} {
				
			} else {
				#next taillevel
				set e 1
				set nt 1
				while {$e < 9} {
					if {[is_in [list "kyubi-$e" $owner -1] $effects]} {
						incr nt 1
						set it [lsearch $effects [list "kyubi-$e" $owner -1]]
						set effects [lreplace $effects $it $it]
						effect "kyubi-$e" $owner "remove"
					}
					incr e 1			
				}
				if {[get_chakra $owner] > 20} {
					kyubi_new_tail_message $nt
				} else {
					kyubi_no_chakra_message
				}
			}
		}
		if {$name == "kyubi-1"} {
			remove_form $owner
		}
		if {$name == "kyubi-2"} {
			set_tai $owner [expr [get_tai $owner] - 1]
			set_speed $owner [expr [get_speed $owner] - 1]
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
		if {$name == "hachimon-4"} {
			set_tai $owner [expr [get_tai $owner] - 1]
			set_hitpoints $owner [expr [get_hitpoints $owner] - 50]
			#you can die
		}
		if {$name == "hachimon-5"} {
		}
		if {$name == "hachimon-6"} {
			set_gen $owner [expr [get_gen $owner] - 2]
		}
		if {$name == "hachimon-7"} {
			set_speed $owner [expr [get_speed $owner] - 2]
		}
		if {$name == "hachimon-8"} {
			#death
			set_hitpoints $owner 0
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
proc take_damage {p d t {tim 0}} {
	global effects dclones herolevel skills
	if {[get_hitpoints $p] > 0 && $d > 0} {
		set_hitpoints $p [expr [get_hitpoints $p] - $d]
		if {[clones_interface $p "get_number"] > 0} {
			if {$t == "hirudora" || $t == "futon-rasensuriken" || $t == "futon-kiryu-ranbu" || $t == "futon-kazekiri" || $t == "futon-rasengan"} {
				#save damage and remove all clones
				clones_interface $p "remove_all" 
			} elseif {$t == "soshoryu" || $t == "sogu-tensasai" || $t == "futon-shinkuha" || $t == "naruto-nisen-rendan" || $t == "naruto-yonsen-rendan"} {
				#remove all clones and remove damage
				set_hitpoints $p [expr [get_hitpoints $p] + $d]
				set d 0
				clones_interface $p "remove_all"
			} elseif {$t == "rasen-cho-tarengan"} {
				#destroy one clone and chance to destroy all clones and chance to damage original 
				clones_interface $p "remove_one"
				set a [clones_interface $p "get_number"]
				set b 1
				while {$b <= $a} {
					set randomnumber [expr rand() * 100]
					if {$randomnumber <= 25} {
 						clones_interface $p "remove_one"
					}
					incr b 1
				}
				set randomnumber [expr rand() * 100]
				if {$randomnumber <= 25} {
 					#not remove damage
				} else {
					#remove damage
					set_hitpoints $p [expr [get_hitpoints $p] + $d]
					set d 0
				}
			} else {
				#remove damage
				set_hitpoints $p [expr [get_hitpoints $p] + $d]
				set d 0
				#remove one clone
				if {[is_ranged $t]} {
					after 500 "clones_interface $p remove_one"
				} else {
					clones_interface $p "remove_one"
				}
			}
		} else {
			set k -1
			while {$k <= 10} {
				if {[is_in [list "shadow-clon" $p $k] $effects]} {
					set dclones 1
					after 900 "effect shadow-clon $p remove"
					if {$k >= 0} {
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
				}
				if {[is_in [list "kage-bunshin" $p $k] $effects]} {
					#remove damage
					set_hitpoints $p [expr [get_hitpoints $p] + $d]
					set d 0
				}
				incr k 1
			}
			if {$d >= [get_hitpoints $p]} {
				#critical damage (above 50%)
				if {[is_in "nine-tails" [get_skills $p]] && [is_in "kyubi-enabled" $skills]} {
					#Nine Tails
					#first_tail - hitpoint and chakra regenerate
					set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
					set_hitpoints $p [expr 50*($herolevel + 1)]
					set_chakra $p [expr 75*$herolevel + ($herolevel/3)*75 + ($herolevel/4)*225]
					if {[get_hitpoints $p] < $d && $herolevel > 3} {
					} elseif {[expr [get_hitpoints $p] / 2] < $d && $herolevel > 2} {
					} elseif {[expr [get_hitpoints $p] / 2] < $d && $herolevel > 1} {
					} else {
						lappend effects [list "nine-tails" $p 2]
						lappend effects [list "kyubi-1" $p -1]
						set_form $p "onetail"	
					}
				} elseif {[is_in "one-tails" [get_skills $p]] && [is_in "shukaku-enabled" $skills]} {
				#One Tails
				}
			}
		}
	}
	return $d
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
		if {[get_location $purpose] == [get_location $p] && [get_height $purpose] == [get_height $p] && [get_name $purpose] != "trap"} {
			set s [get_speed $purpose]
			set randomnumber [expr 100*rand()]
			set chance [expr 100 - $s*5]
			if {$randomnumber < $chance} {
				#hit
				set nd [take_damage $purpose $d "kubakufuda"]
				if {$nd > 0} {
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
		set nd [take_damage $p $d "kuchiese-kusarigama"]
		if {$nd > 0} {
			set_speed $p 0
			if {[get_hitpoints $p] > 0 && $s != 0} {
				after [expr $timestart + 900] "set_speed $p $s
				replace"
			}
		}
	}
}
proc tech_clones-attack {u p {timestart 0} interval d num} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set t $timestart
	clones_interface $u "attack-$num"	
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 75 - ($s2-$s1)*5]
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "attack"
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
	if {[is_in "futon-hien" [get_skills $u]]} {
		incr d 1
		incr s1 1
	}
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
		set nd [take_damage $p $d "konoha-senpu"]
		if {$type == "final" && $nd > 0} {
			set_speed $p 0
			set_speed $u 0 
			after [expr $t + 500] "set_speed $u $s1
			replace"
			if {[get_hitpoints $p] > 0} {
				after [expr $t + 500] "set_speed $p $s2
				replace"
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
#two strikes from dai senpu our one double strike from congoriki senpu
	set summary_d [expr $d * 2]
	while {$strikes > 0} {
		set i 2
		while {$i <= 7} {
			set t [expr $t + $interval]
			if {[is_in "tsuten-kyaku" [get_skills $u]] && $t > 300} {
				#stop animate - tsuten kyaku

			} else {
				after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user konoha-senpu $i.gif]"
			}
			incr i
		}
		set t [expr $t + $interval]
		set s1 [get_speed $u]
		set s2 [get_speed $p]
		set chance [expr 50 - ($s2-$s1)*10]
		set randomnumber [expr 100*rand()]
		if {$randomnumber < $chance} {
			#hit
			incr summary_d $d
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
	if {[is_in "tsuten-kyaku" [get_skills $u]] && [get_chakra $u] > 25} {
		set s1 [get_speed $u]
		set s2 [get_speed $p]
		set chance [expr 50 - ($s2-$s1)*10]
		set randomnumber [expr 100*rand()]
		if {$randomnumber < $chance} {
			#not need chakra to try strike - only to take damage
			set_chakra $u [expr [get_chakra $u] - 25]
			take_damage $p $summary_d "tsuten-kyaku"
		}
		set addt [expr $interval * 8]
		set i 1
		while {$i <= 7} {
			after [expr $timestart + $tincr] "get_image $tag [file join $mydir images heroes $user tsuten-kyaku $i.gif]"
			set tincr [expr $tincr + $interval]
			incr i
		}
		set tincr [expr $tincr + $interval]
		after [expr $timestart + $tincr] "get_image $tag [file join $mydir images heroes $user jump 3.gif]"
	} else {
		set addt 0
	}
	while {$tincr < [expr 600 + $addt]} {
		after [expr $timestart + $tincr] ".c move $tag2 0 8
.c move $tag 0 10"
		incr tincr 25
	}
	after [expr $timestart + $tincr] "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
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
	if {[is_in "tsuten-kyaku" [get_skills $u]]} {
		set interval [expr $interval / 2]
	}
	.c raise $tag
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 10]
	}	
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
		set nd [take_damage $p $d "shofu"]
		if {$nd > 0} {
			set_speed $p 0
			if {[get_hitpoints $p] > 0} {
				after [expr $t + 900] "set_speed $p $s2
				replace"
			}
			if {[is_in "tsuten-kyaku" [get_skills $u]] && [get_chakra $u] > 25} {
				tech_final-konoha-senpu $u $p $t $interval [expr $d / 2] 0
			} else {
				after [expr $t - 100] "nokout $p"
			}
		}
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
		set nd [take_damage $p $d "hosho"]
		if {$nd > 0} {
			set_speed $p 0
			after [expr $t - 300] "wound_animation $tag2 [get_name $p] fast"
			if {[get_hitpoints $p] > 0} {
				after [expr $t + 100] "set_speed $p $s2
				replace"
			}
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
		set nd [take_damage $p $d "omote-renge"]
		if {$nd > 0} {	
		set_speed $p 0
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 1000] "set_speed $p $s2
			replace"
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
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
}
proc tech_ura-renge {u p {timestart 0} interval d} {
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
				set dx 20
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
				set dx -20
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
#chance is 100%
	set chance 100.0
	if {$randomnumber < $chance} {
		#hit
		set nd [take_damage $p $d "ura-renge"]
		if {$nd > 0} {	
		set_speed $p 0
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 1000] "set_speed $p $s2
			replace"
		}
		after [expr $t - 100] "passive_fly $p 1700"
		set t2 $t
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 1.gif]"
		incr t $interval
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 2.gif]"
		incr t $interval
		after $t ".c move $tag $dx -150"
		incr t $interval
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 3.gif]"
		set i 1
		while {$i <= 6} {
			after $t2 ".c move $tag2 0 -25"
			set t2 [expr $t2 + $interval / 2]
			incr i
		}
		incr t $interval
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 4.gif]"
		incr t $interval
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 5.gif]"
		incr t $interval
		after $t ".c move $tag [expr $dx * 12] 120
		get_image $tag [file join $mydir images heroes $user ura-renge 6.gif]"
		set i 1
		while {$i <= 12} {
			after $t2 ".c move $tag2 $dx 10"
			set t2 [expr $t2 + $interval / 4]
			incr i
		}
	        incr t $interval
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 7.gif]"
		incr t $interval
		after $t ".c move $tag [expr $dx * 3] -120
		get_image $tag [file join $mydir images heroes $user ura-renge 8.gif]"
		incr t $interval
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 9.gif]"
		set i 1 
		while {$i <= 6} {
			after $t2 ".c move $tag2 [expr $dx / 2] -20"
			set t2 [expr $t2 + $interval / 2]
			incr i
		}
		incr t [expr $interval / 2]
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 10.gif]"
		incr t [expr $interval / 2]
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 11.gif]"
		set i 1 
		while {$i <= 2} {
			after $t2 ".c move $tag2 0 20
			.c move $tag 0 20"
			set t2 [expr $t2 + $interval / 2]
			incr i
		}
		incr t [expr $interval * 2]
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 12.gif]"
		incr t [expr $interval / 2]
		after $t ".c move $tag [expr $dx*(-16)] 110
		get_image $tag [file join $mydir images heroes $user ura-renge 13.gif]"
		set i 1 
		while {$i <= 5} {
			after $t2 ".c move $tag2 0 [expr 20 + $ds*10]"
			after [expr $t2 + $interval / 4] ".c move $tag2 0 [expr $ds*10]"
			set t2 [expr $t2 + $interval / 2]
			incr i
		}
		after $t2 "get_image $tag2 [file join $mydir images heroes [get_name $p] wound 3.gif]"
		after $t2 ".c move $tag2 0 -20"
		after [expr $t2 + $interval] ".c move $tag2 0 15"
		after [expr $t2 + $interval*2] ".c move $tag2 0 15"
		set t [expr $t + $interval]
		after $t "get_image $tag [file join $mydir images heroes $user ura-renge 14.gif]"
		}
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
}
proc tech_asakujaku {u r p {timestart 0} d} {
	global mydir enemy
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set x [getx $tag]
	set y [gety $tag]
	#strikes number is (damage - 3 + 4)/ distantion is full
	if {$d > 0} {
		set s [expr $d - 3  + 4]
		set r 1000
		set interval [expr 120 / $s]
	} else {
		set s 0
		set r 1000
		set interval 50
	}
	.c raise $tag
	set_chakra $u [expr [get_chakra $u] - 100]
	set user [get_name $u]
	set t $timestart
	while {$s > 0} {
		set randomnumber [expr 100*rand()]
		set h [expr 3*rand()]
		if {$h < 1} {
			set v 1
		}
		if {$h > 1 && $h < 2} {
			set v 2
		}
		if {$h > 2} {
			set v 3
		}
		set i 1
		while {$i <= 7} {
			set t [expr $t + $interval]
			after $t ".c raise $tag
			get_image $tag [file join $mydir images heroes $user asakujaku $v-$i.gif]"
			incr i
		}
		set t [expr $t + $interval]
		after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
		after [expr $t + 20] ".c create image $x $y -image i_$randomnumber -tag t2_$randomnumber"
		after [expr $t + 40] ".c create image $x $y -image i_$randomnumber -tag t3_$randomnumber"
		after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
		after $t "replace"
		if {$u == "hero"} {
			set e 1
			set min 1000
			set p "enemy0"
			while {$e <= $enemy} {
				if {[dist "heroi" enemy$e] < $min && [get_height enemy$e] == [get_height "heroi"] && [get_location enemy$e] >= [get_location "heroi"]} {
					set min [dist "heroi" enemy$e]
					if {[get_hitpoints enemy$e] > 0} {
						set p "enemy$e"
					} elseif {$p != "enemy0"} {
						
					} else {
						set p "enemy$e"
					}
				} 
				incr e
			}
			get_image i_$randomnumber [file join $mydir images attacks asakujaku 1.gif]
		} else {
			if {[dist $u enemy$e] < $min && [get_height enemy$e] == [get_height "heroi"] && [get_location enemy$e] >= [get_location "heroi"]} {
				set p "hero"
			}
			get_image i_$randomnumber [file join $mydir images attacks asakujaku 2.gif]
		}
		set ta $t
		set s1 [get_speed $u]
		set s2 [get_speed $p]	
		set chance [expr 50 - ($s2-$s1)*10]
		while {$t < [expr $ta + 250]} {
			if {$randomnumber < $chance} {
				after $t "if_delete t_$randomnumber $u
if_delete t2_$randomnumber $u
if_delete t3_$randomnumber $u
.c move t_$randomnumber [expr $r / 25] 0
.c move t2_$randomnumber [expr $r / 25] 2
.c move t3_$randomnumber [expr $r / 25] -2"
			} else {
				after $t ".c move t_$randomnumber [expr $r / 25] 0
.c move t2_$randomnumber [expr $r / 25] 2
.c move t3_$randomnumber [expr $r / 25] -2"
			}
			incr t 10	
		}
		after $t ".c delete t_$randomnumber
.c delete t2_$randomnumber
.c delete t3_$randomnumber"
		set t $ta
		#damage
		if {$randomnumber < $chance} {
			#hit
			set nd [take_damage $p $d "asakujaku"]
			if {$nd > 0 && $s2 > 0 && [get_location $p] == [get_location $u]} {
				set_speed $p 0
				if {[get_hitpoints $p] > 0} {
					after [expr $timestart + 900] "set_speed $p $s2
					replace"
				}
				after [expr $t + 150] "nokout $p"
			}
		}
		incr s -1
	}
}
proc tech_hirudora {u r p {timestart 0} d} {
	global mydir enemy
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set x [getx $tag]
	set y [gety $tag]
	set randomnumber [expr 100*rand()]
	.c raise $tag
	set_chakra $u [expr [get_chakra $u] - 200]
	set user [get_name $u]
	set t $timestart
	set h [expr 3*rand()]
	if {$h < 1} {
		set v 1
	}
	if {$h > 1 && $h < 2} {
		set v 2
	}
	if {$h > 2} {
		set v 3
	}
	set i 1
	while {$i <= 7} {
		set t [expr $t + 50]
		after $t ".c raise $tag
		get_image $tag [file join $mydir images heroes $user hirudora $i.gif]"
		incr i 1
	}
	set t [expr $t + 100]
	get_image c_1 [file join $mydir images attacks hirudora 1.gif]
	get_image c_2 [file join $mydir images attacks hirudora 2.gif]
	get_image c_3 [file join $mydir images attacks hirudora 3.gif]
	get_image c_4 [file join $mydir images attacks hirudora 4.gif]
	get_image c_5 [file join $mydir images attacks hirudora 5.gif]
	get_image c_6 [file join $mydir images attacks hirudora 6.gif]
	get_image c_7 [file join $mydir images attacks hirudora 7.gif]
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	if {$u == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks hirudora main1.gif]
		set i 1
		set c -1
		set dx $x
		set dt $t
		while {$i <= 21} {
			after $dt ".c move t_$randomnumber 50 0"
			if {$c > 0} {
				after $dt ".c create image [expr $dx - 25] [expr $y - 20] -image c_1 -tag tc"
				after $dt ".c create image [expr $dx - 50] [expr $y - 20] -image c_1 -tag tc"
			}
			set dx [expr $dx + 50]
			incr i 1
			incr c 1
			incr dt 50
		}
		after $dt ".c delete t_$randomnumber"
		set c 2
		while {$i <= 27} {	
			after $dt ".c itemconfigure tc -image c_$c"
			incr c 1
			incr i 1
			incr dt 25
		}
		after $dt ".c delete tc"
	} else {
		get_image i_$randomnumber [file join $mydir images attacks hirudora main2.gif]
		set i 1
		set c -1
		set dx $x
		set dt $t
		while {$i <= 21} {
			after $dt ".c move t_$randomnumber -50 0"
			if {$c > 0} {
				after $dt ".c create image [expr $dx + 25] [expr $y - 20] -image c_1 -tag tc"
				after $dt ".c create image [expr $dx + 50] [expr $y - 20] -image c_1 -tag tc"
			}
			set dx [expr $dx - 50]
			incr i 1
			incr c 1
			incr dt 50
		}
		after $dt ".c delete t_$randomnumber"
		set c 2
		while {$i <= 27} {	
			after $dt ".c itemconfigure tc -image c_$c"
			incr c 1
			incr i 1
			incr dt 25
		}
		after $dt ".c delete tc"
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
	set ll [list "hero"]
	set e 1
	while {$e <= $enemy} {
		lappend ll "enemy$e"
		incr e 1
	}
	foreach p $ll {
		if {$p == "hero"} {
			set ptag "heroi"
		} else {
			set ptag $p
		}
		if {[get_height $ptag] == [get_height $tag] && [get_location $ptag] >= [get_location $tag] && $ptag != $tag} {
			set random [expr 100*rand()]
			set s1 [get_speed $u]
			set s2 [get_speed $p]	
			set chance [expr 100 - ($s2-$s1)*10]
			#damage
			if {$random < $chance} {
				#hit
				set nd [take_damage $p $d "hirudora"]
				if {$nd > 0 && $s2 > 0} {
					if {[get_hitpoints $p] > 0} {
						after [expr $t + 1800] "set_speed $p $s2
						replace"
					}
					set dt $t
					set i 1
					while {$i <= 21} {
						after $dt "if_contact_nokout t_$randomnumber $p"
						incr i 1
						incr dt 50
					}
				}
			}
		}
	}
}
#ranged 
#ninjitsu
proc tech_soshoryu {u r p {timestart 0} d} {
	global mydir enemy locations
	if {$u == "hero"} {
		set tag "heroi"damage
		s
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
proc tech_futon-shinku-gyoku {x y r p {timestart 0} d} {
	global mydir effects enemy
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks shinku-gyoku 2.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}

	} else {
		get_image i_$randomnumber [file join $mydir images attacks shinku-gyoku 1.gif]
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	#damage (very mark)
	set s [get_speed $p]
	set chance [expr 100 - $s*5]
	if {$randomnumber > 50} {
	     set k 1
	} else {
	     set k -1
	}
	while {$t < [expr $timestart + 500]} {
		if {$randomnumber < $chance} {
			after $t "if_delete t_$randomnumber $u
.c move t_$randomnumber [expr $r / 25] $k"
		} else {
			after $t ".c move t_$randomnumber [expr $r / 25] 0"
		}
		incr t 20	
	}
	after $t ".c delete t_$randomnumber
	replace"
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "futon-shinku-gyoku"
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
		set nd [take_damage $p $d "futon-zankukyokuha"]
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
		#throws enemy
		if {$nd > 0} {
			if {[get_hitpoints $p] > 0} {
				after [expr $t + 900] "set_speed $p $s
				replace"
			}
			set dt $timestart
			set i 1
			while {$dt <= [expr $timestart + 500]} {
				after $dt "if_contact_nokout t_$randomnumber $p"
				incr dt 20
			}
		}
	}
}
#katon
#futon
proc tech_katon-gokakyu {x y r p {timestart 0} d} {
	global mydir effects enemy
	
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		set tp 2
		get_image i_$randomnumber [file join $mydir images attacks fireball 2-1.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		set_chakra $u [expr [get_chakra $u] - 15]
	} else {
		set tp 1
		get_image i_$randomnumber [file join $mydir images attacks fireball 1-1.gif]
		set_chakra "hero" [expr [get_chakra "hero"] - 15]
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	set s [get_speed $p]
	#normal chances
	set chance [expr 100 - $s*10]
	while {$t < [expr $timestart + 500]} {
		if {$randomnumber < $chance} {
			after $t "if_delete t_$randomnumber $u
.c move t_$randomnumber [expr $r / 25] 0"
		} else {
			after $t ".c move t_$randomnumber [expr $r / 25] 0"
		}
		incr t 20	
	}
	set t $timestart
	get_image i_$randomnumber-1 [file join $mydir images attacks fireball [set tp]-1.gif]
	get_image i_$randomnumber-2 [file join $mydir images attacks fireball [set tp]-2.gif]
	get_image i_$randomnumber-3 [file join $mydir images attacks fireball [set tp]-3.gif]
	get_image i_$randomnumber-4 [file join $mydir images attacks fireball [set tp]-4.gif]
	set k 1
	while {$t < [expr $timestart + 500]} {
		after $t ".c itemconfigure t_$randomnumber -image i_$randomnumber-$k"
		incr k 1
		if {$k > 4} {
			set k 1
		}
		incr t 50
	}
	after $t ".c delete t_$randomnumber
	replace"
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "katon-gokakyu"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
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
		set level [expr $bonus/(20*$enemy) - 1]
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
		set level [expr $bonus/(20*$enemy) - 1]
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
proc tech_hachimon-4 {u} {
	global mydir effects herolevel enemy bonus
	if {$u == "hero"} {
		set tag "heroi"
		set level $herolevel
	} else {
		set tag $u
#not exact
		set level [expr $bonus/(20*$enemy) - 1]
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
	if {[is_in [list "hachimon-3" $u -1] $effects]} {

	} else {
#third gate
		lappend effects [list "hachimon-3" $u -1]
		set_chakra $u [expr [get_chakra $u] - 20]
		set_speed $u [expr [get_speed $u] + 1]
	}
	set_tai $u [expr [get_tai $u] + 1]
	set_hitpoints $u [expr [get_hitpoints $u] + 50]
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
proc tech_hachimon-5 {u} {
	global mydir effects herolevel enemy bonus
	if {$u == "hero"} {
		set tag "heroi"
		set level $herolevel
	} else {
		set tag $u
#not exact
		set level [expr $bonus/(20*$enemy) - 1]
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
	if {[is_in [list "hachimon-3" $u -1] $effects]} {

	} else {
#third gate
		lappend effects [list "hachimon-3" $u -1]
		set_chakra $u [expr [get_chakra $u] - 20]
		set_speed $u [expr [get_speed $u] + 1]
	}
	if {[is_in [list "hachimon-4" $u -1] $effects]} {

	} else {
#fourth gate
		lappend effects [list "hachimon-4" $u -1]
		set_chakra $u [expr [get_chakra $u] - 20]
		set_tai $u [expr [get_tai $u] + 1]
		set_hitpoints $u [expr [get_hitpoints $u] + 50]
	}
	set_chakra $u [expr [get_chakra $u] - 20]
	set_chakra $u [expr [get_chakra $u] + 100]
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
proc tech_hachimon-6 {u} {
	global mydir effects herolevel enemy bonus
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_chakra $u [expr [get_chakra $u] - 25]
	set_gen $u [expr [get_gen $u] + 2]
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
proc tech_hachimon-7 {u} {
	global mydir effects herolevel enemy bonus
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_chakra $u [expr [get_chakra $u] - 25]
	set_speed $u [expr [get_speed $u] + 2]
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
proc tech_hachimon-8 {u} {
	global mydir effects herolevel enemy bonus
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_chakra $u [expr [get_chakra $u] - 50]
	set_tai $u [expr [get_tai $u] + 2]
	set_speed $u [expr [get_speed $u] + 2]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 20} {
		after $t "get_image $tag [file join $mydir images heroes $user hachimon-final $i.gif] run $u"
		incr i
		incr t 50
	}
	after $t "replace"
}
proc tech_kyubi-1 {u} {
	global mydir effects
	set_form $u "onetail"
	lappend effects [list kyubi-1 hero -1]
	lappend effects [list nine-tails hero 1]
}
proc tech_kyubi-2 {u} {
	global mydir effects
	remove_form $u
	set_form $u "twotail"
	lappend effects [list kyubi-2 hero -1]
	lappend effects [list kyubi-1 hero -1]
	lappend effects [list nine-tails hero 1]
	set_tai $u [expr [get_tai $u] + 1]
	set_speed $u [expr [get_speed $u] + 1]
}
proc tech_kyubi-3 {u} {
	global mydir
	remove_form $u
	set_form $u "threetail"
	set_tai $u [expr [get_tai $u] + 1]
	set_speed $u [expr [get_speed $u] + 3]
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
		after 2000 {unblock_battlepanel}
	}
	.c delete kibakufuda_$u
}
proc tech_taju-kage-bunshin {u} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_chakra $u [expr [get_chakra $u] - 50]
	clones_interface $u "create"
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 7} {
		after $t "get_image $tag [file join $mydir images heroes $user kage-bunshin $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
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
proc tech_kage-bunshin {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	lappend effects [list "shadow-clon" $u [get_nin $u]]
	set x [getx $tag]
	set y [gety $tag]
	.c create line $x $y $x $y -tag original_$u
	set_chakra $u [expr [get_chakra $u] - [get_chakra $u]/10]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 7} {
		after $t "get_image $tag [file join $mydir images heroes $user kage-bunshin $i.gif] run $u"
		incr i
		incr t 70
	}
	set i 1
	while {$i <= 6} {
		after $t "get_image $tag [file join $mydir images heroes $user clon-create $i.gif] run $u"
		incr i
		incr t 70
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
	after $t "replace"
}
proc tech_kawarimi {u} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_nin $u 0
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 10]
	}	
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
proc tech_kai {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_nin $u 0
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 10]
	}	
	set x [getx $tag]
	set y [gety $tag]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 5} {
		after $t "get_image $tag [file join $mydir images heroes $user kai $i.gif] run $u"
		incr i
		incr t 70
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
	after $t "replace"
}
