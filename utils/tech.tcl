#effects
global effects used
set effects [list]
set used [list]
proc effect_work {} {
	global effects lever enemy
	set i 0
	puts "new...."
	foreach e $effects {
		set do [lindex $e 0]
		set owner [lindex $e 1]
		set t [lindex $e 2]
		if {$t < -1000 || $t > 1000} {
			set effects [lreplace $effects $i $i]
			incr i
		} else {
		puts "$t $do $owner"
			if {$t > 0 && $i < [llength $effects]} {
				lset effects $i [list $do $owner [expr $t - 1]]
			} else {
			}
			effect $do $owner "do"
			if {$t == 0} {
				if {[llength $effects] > $i} {
					set effects [lreplace $effects $i $i]
					effect $do $owner "remove"
				}
			} else {	
				set k [expr $enemy + 1]
				while {$k < 5} {
					if {$owner == "enemy$k" && [llength $effects] > $i} {
						set effects [lreplace $effects $i $i]
						incr i -1
					}
					incr k 1
				}
				incr i
			}
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
		if {$name == "sharingan-1"} {
			if {[get_chakra $owner] > 5} {
				set_chakra $owner [expr [get_chakra $owner] - 5]
			} else {
				effect "sharingan-1" $owner "remove"
				effect "sharingan-2" $owner "remove"
				effect "sharingan-3" $owner "remove"
			}
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
			if {($name == "kyubi-5" && ![is_in "hakke-fuin-shiki" [get_skills $owner]]) || ($name == "kyubi-6")} {
				if {[get_chakra $owner] > 20} {
					hero_ai_fox 8
				}
			}
			if {(($name == "kyubi-4" && ![is_in "hakke-fuin-shiki" [get_skills $owner]]) || $name == "kyubi-5") && $herolevel == 3} {
				if {[get_chakra $owner] > 20} {
					hero_ai_fox 6
				}
			}
			if {(($name == "kyubi-3" && ![is_in "hakke-fuin-shiki" [get_skills $owner]]) || $name == "kyubi-4") && $herolevel == 2} {
				if {[get_chakra $owner] > 20} {
					hero_ai_fox 4
				}
			}
			if {(($name == "kyubi-2" && ![is_in "hakke-fuin-shiki" [get_skills $owner]]) || $name == "kyubi-3") && $herolevel == 1} {
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
		if {$name == "suiton-suiro" || $name == "hyoton-makyo-hyosho"} {
			set i 0
			set id 10
			foreach e $effects {
				set do [lindex $e 0]
				set holder [lindex $e 1]
				set t [lindex $e 2]
				if {$do == $name && $holder == $owner} {
					lset effects $i [list $do $owner [expr $t + 1]]
					set id [expr $t + 1]
				}
				incr i
			}
			if {[getx suira-$id] > 0 && [getx suira-$id] < 2000} {
				if {$name == "hyoton-makyo-hyosho"} {
					set sss [get_speed $owner]
					set randomnumber [expr rand()*100]
					set chance [expr 100 - 5*$sss]
					if {$randomnumber < $chance} {
						take_damage $owner 10 "hyoton-makyo-hyosho"
					}						
				} else {
					take_damage $owner 5 "suiton-suiro"
				}
			} else {
				effect $name $owner "remove"
			}
		}
		if {$name == "suiton-suiro-user" || $name == "hyoton-makyo-hyosho-user"} {
			set i 0
			set id 10
			foreach e $effects {
				set do [lindex $e 0]
				set holder [lindex $e 1]
				set t [lindex $e 2]
				if {$do == $name && $holder == $owner} {
					lset effects $i [list $do $owner [expr $t + 1]]
					set id [expr $t + 1]
				}
				incr i
			}
			if {[getx "suira-$id"] > 0 && [getx "suira-$id"] < 2000} {
				if {[get_location $owner] == [expr $id % 10] && [get_height $owner] == [expr $id / 10]} {
					if {[get_chakra $owner] > 10} {
						if {![is_in [list "kyubi-1" $owner -1] $effects]} {
							set_chakra $owner [expr [get_chakra $owner] - 10]
						}
						if {$name == "suiton-suiro-user"} {
							suiro_end_anim $owner
						} else {
							makyo-hyosho_zalp $owner "suira-$id"
						}
					} else {
						remove_suiro $owner
						effect $name $owner "remove"
					}
				} else {
					remove_suiro $owner
					effect $name $owner "remove"
				}
			} else {
				effect $name $owner "remove"
			}
		}
	}
	if {$what == "remove"} {
		if {$name == "taju-kage-bunshin"} {
			if {$owner == "hero"} {
				set tag "heroi"
			} else {
				set tag $owner
			}
			set ic 1
			while {$ic <= 20} {
				after 1500 ".c delete clon-$ic-$tag"
				incr ic 1
			}
		}
		if {$name == "tsuiga-no-jutsu"} {
			if {$owner == "hero"} {
				set tag "heroi"
			} else {
				set tag $owner
			}
			.c delete dogs$tag
		}
		if {$name == "katon-haisekisho"} {
			.c delete ash_$owner
		}
		if {$name == "suiton-kirigakure"} {
			.c delete mist
		}
		if {$name == "kibakufuda"} {
			detonation $owner
		}
		if {$name == "suiken"} {
			set_speed $owner [expr [get_speed $owner] - 2]
		}
		if {$name == "shadow-clon" || $name == "water-clon"} {
			set x [getx original_$owner]
			set y [gety original_$owner]
			if {$x > 0 && $x < 1024 && $y > 0 && $y < 600} {
				block_battlepanel
				if {$name == "shadow-clon"} {
					clon-pufff $owner [get_name $owner]
					clones_interface $owner "remove_all"
					after 1100 "teleport $owner $x $y
					effect kage-bunshin $owner remove
					replace"
				}
				if {$name == "water-clon"} {
					clon-pufff $owner [get_name $owner] "water"
					clones_interface $owner "remove_all"
					after 1100 "teleport $owner $x $y
					effect suiton-mizu-bunshin $owner remove
					replace"
				}
				.c delete original_$owner
				after 2000 {unblock_battlepanel}
			} else {
				clon_message
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
				set trns 2
				while {$trns >= 0} {
					if {[is_in [list "nine-tails" $owner $trns] $effects]} {
						set it [lsearch $effects [list "nine-tails" $owner $trns]]
						set effects [lreplace $effects $it $it]
					}
					incr trns -1					
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
		if {$name == "sharingan-1"} {
		}
		if {$name == "sharingan-2"} {
			set_tai $owner [expr [get_tai $owner] - 1]
		}
		if {$name == "sharingan-3"} {
			set_gen $owner [expr [get_gen $owner] - 1]
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
		set i 0
		foreach e $effects {
			set do [lindex $e 0]
			set holder [lindex $e 1]
			set t [lindex $e 2]
			if {$do == $name && $holder == $owner} {
				if {$i < [llength $effects]} {
					set effects [lreplace $effects $i $i]
					incr i -1
				}
			}
			incr i
		}
	}
}
proc take_damage {p d t {tim 0}} {
	global effects dclones herolevel skills
	#damage minimizaton
	if {[if_domu $p] && ![is_raiton_based $t]} {
		incr d -5
		puts "doton-domu absorbed 5 points of damage. $d points inflicted"
	}
	if {[get_hitpoints $p] > 0 && $d > 0} {
		set_hitpoints $p [expr [get_hitpoints $p] - $d]
		if {[clones_interface $p "get_number"] > 0} {
			if {$t == "hirudora" || $t == "futon-rasensuriken" || $t == "futon-kiryu-ranbu" || $t == "futon-kazekiri" || $t == "futon-rasengan" || $t == "suiton-daibakufu" || $t == "katon-haisekisho"} {
				#save damage and remove all clones
				after 500 "clones_interface $p remove_all" 
			} elseif {$t == "soshoryu" || $t == "sogu-tensasai" || $t == "futon-shinkuha" || $t == "naruto-nisen-rendan" || $t == "naruto-yonsen-rendan" || $t == "katon-ryuka"} {
				#remove all clones and remove damage
				set_hitpoints $p [expr [get_hitpoints $p] + $d]
				set d 0
				after 500 "clones_interface $p remove_all"
			} elseif {$t == "hyoton-makyo-hyosho"} {
				after 200 "clones_interface $p remove_all"
				set_hitpoints $p [expr [get_hitpoints $p] + $d]
				set d 0
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
			set ex 0
			while {$k <= 10} {
				if {[is_in [list "shadow-clon" $p $k] $effects] || [is_in [list "water-clon" $p $k] $effects]} {
					set dclones 1
					if {[is_in [list "shadow-clon" $p $k] $effects]} {
						after 900 "effect shadow-clon $p remove"
					} elseif {[is_in [list "water-clon" $p $k] $effects]} {
						after 900 "effect water-clon $p remove"
					}
					if {$k >= 0} {
						set u 0
						set i -1
						foreach s $effects {
							if {$s == [list "shadow-clon" $p $k] || $s == [list "water-clon" $p $k] } {
								set i $u
							}
							incr u
						} 
						if {$i >= 0} {
							set effects [lreplace $effects $i $i]
						}
					}
					set ex 1
				}
				if {[is_in [list "kage-bunshin" $p $k] $effects] || [is_in [list "suiton-mizu-bunshin" $p $k] $effects]} {
					#remove damage
					set_hitpoints $p [expr [get_hitpoints $p] + $d]
					set d 0
					set ex 1
				}
				incr k 1
			}
			if {$ex == 1} {
			} elseif {$d >= [get_hitpoints $p]} {
				#critical damage (above 50%)
				if {[is_in "nine-tails" [get_skills $p]] && [is_in "kyubi-enabled" $skills]} {
					#Nine Tails
					#first_tail - hitpoint and chakra regenerate
					set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
					if {[get_hitpoints $p] < 0} {
						set d [expr -1*[get_hitpoints $p]]
					} else {
						set d 1
					}
					set_hitpoints $p [expr 50*($herolevel + 1)]
					set_chakra $p [expr 75*$herolevel + ($herolevel/3)*75 + ($herolevel/4)*225]
					if {[get_hitpoints $p] < $d && $herolevel > 3} {
					} elseif {[expr [get_hitpoints $p] / 2] < $d && $herolevel > 2} {
					} elseif {[expr [get_hitpoints $p] / 2] < $d && $herolevel > 1} {
					} else {
						lappend effects [list "nine-tails" $p 2]
						lappend effects [list "kyubi-1" $p -1]
						set_form $p "onetail"
						if {$d > 1 && $d < [get_hitpoints $p]} {
							set_hitpoints $p [expr 50*($herolevel + 1) - $d]
						}
					}
				} elseif {[is_in "one-tails" [get_skills $p]] && [is_in "shukaku-enabled" $skills]} {
				#One Tails
				} elseif {[is_in "suiton-suika" [get_skills $p]] && [get_hitpoints $p] <= 0 && ([get_chakra $p] > 10 || [is_in [list "suiton-suika" $p 1] $effects]) && ![is_suiton_based $t] && ![is_doton_based $t] && ![is_futon_based $t] && ![is_raiton_based $t]} {
					#Suika no Jutsu - remove damage
					set_hitpoints $p [expr [get_hitpoints $p] + $d]
					set d 0
					if {$p == "hero" && ![is_in [list "suiton-suika" $p 1] $effects]} {
						suika_no_jutsu "heroi" [get_name $p]
						set_chakra $p [expr [get_chakra $p] - 10]
						lappend effects [list "suiton-suika" $p 1]	
						set ss [get_speed $p]
						set_speed $p 0
						if {$ss > 0} {
							after 300 "set_speed $p $ss"
						}
						
					} elseif {![is_in [list "suiton-suika" $p 1] $effects]} {
						suika_no_jutsu $p [get_name $p]
						set_chakra $p [expr [get_chakra $p] - 10]
						lappend effects [list "suiton-suika" $p 1]
						set ss [get_speed $p]
						set_speed $p 0
						if {$ss > 0} {
							after 300 "set_speed $p $ss"
						}
					}
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "kunai"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_shihohappo {u p {timestart 0} interval d num} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set t $timestart
	after $t "clones_interface $u surikens-$num"
	#damage
	set s [get_speed $p]
	set chance [expr 100 - $s*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "futon-reppusho" [get_skills $u]]} {
		set d [expr $d + 2]
	}
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "raiko-kenka"
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit (have more chances, and more damage then kunai, but not many shoots)
		take_damage $p $d "raiko-kenka"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_bunshin-no-henge {x y r p {timestart 0} d {type "little"}} {
	global mydir effects
	if {$p == "hero"} {
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra $u [expr [get_chakra $u] - 10]
		}
	} else {
		if {[is_in [list "kyubi-1" "hero" -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 10]
		}
		set u "hero"
	}
	set randomnumber [expr 100*rand()]
	get_image i_[set randomnumber]_1 [file join $mydir images attacks fuma-suriken 1.gif]
	get_image i_[set randomnumber]_2 [file join $mydir images attacks fuma-suriken 2.gif]
	get_image i_[set randomnumber]_3 [file join $mydir images attacks fuma-suriken 3.gif]
	#damage (very mark)
	set s [get_speed $p]
	set chance [expr 100 - $s*5]
	set t $timestart
	set c 2
	while {$t < [expr $timestart + 200]} {
		after $t ".c itemconfigure t_$randomnumber -image i_[set randomnumber]_$c"
		incr c 1
		if {$c == 4} {
			set c 1
		}
		incr t 50	
	}
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	set dam 0
	if {$randomnumber < $chance} {
		#hit
		set dam [take_damage $p $d "bunshin-no-henge"]
		if {[get_hitpoints $p] > 0} {
			after [expr $t + 900] "set_speed $p $s
replace"
		}
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
	set t $timestart
	after $t ".c create image $x $y -image i_[set randomnumber]_1 -tag t_$randomnumber"
	if {$type == "big"} {
		after $t " .c move t_$randomnumber 0 -20"
	}
	while {$t < [expr $timestart + 200]} {
		if {$dam > 0} {
			after $t "if_contact_clon_suriken t_$randomnumber $u $p
.c move t_$randomnumber [expr $r / 10] 0"
		} else {
			after $t ".c move t_$randomnumber [expr $r / 10] 0"
		}
		incr t 10	
	}
	after $t ".c delete t_$randomnumber
	replace"
}
proc if_contact_clon_suriken {tag user purpose} {
	global enemy mydir
	if {$purpose == "hero"} {
		set ptag "heroi"
	} else {
		set ptag $purpose
	}
	set name [get_name $user]
	set x [getx $tag]
	set y [gety $tag]
	if {[object_in $x $y [getx $ptag] [gety $ptag] 50 200]} {
		if {[get_speed $purpose] > 0} {
			set_speed $purpose 0
			nokout $purpose
			.c delete $tag
			get_image clon$tag [file join $mydir images heroes $name bunshin-no-henge 5.gif]
			.c create image $x $y -image clon$tag -tag clon$tag
			after 100 "get_image clon$tag [file join $mydir images heroes $name bunshin-no-henge 6.gif]"
			after 200 "get_image clon$tag [file join $mydir images heroes $name bunshin-no-henge 7.gif]"
			after 300 "get_image clon$tag [file join $mydir images heroes $name bunshin-no-henge 8.gif]"
			after 400 "get_image clon$tag [file join $mydir images heroes $name bunshin-no-henge 9.gif]"
			after 500 "get_image clon$tag [file join $mydir images heroes $name bunshin-no-henge 10.gif]"
			after 600 ".c delete clon$tag"
		}
	}
}
proc tech_senbon {x y r p {timestart 0} d {type "little"}} {
	global mydir effects
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks senbon 2.gif]
	} else {
		get_image i_$randomnumber [file join $mydir images attacks senbon 1.gif]
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
	#very mark
	set chance [expr 100 - $s*5]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "kunai"
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set randomnumber [expr 100*rand()]
	set t $timestart
	after $t "clones_interface $u attack-$num"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 75 - ($s2-$s1)*5]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "attack"
	}
}
proc tech_attack {u p {timestart 0} interval d} {
	global mydir effects
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
	if {[if_domu $u]} {
		incr d 1
	}
	set chance [expr 50 - ($s2-$s1)*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}	
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "attack"
	}
}
proc tech_meisu {u p {timestart 0} interval d} {
	global mydir effects
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "kuchiese-meisu"
	}
}
proc tech_nunchaka {u p {timestart 0} interval d} {
	global mydir effects
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#decrease enemy taijitsu by 1
		take_damage $p $d "soshuga"
	}
}
proc tech_konoha-senpu {u p {timestart 0} interval d {type "begin"} {strikes 0}} {
	global mydir effects
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
	if {[if_domu $u]} {
		incr d 1
	}
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	global mydir locations effects
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
	if {[if_domu $u]} {
		incr d 1
	}
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
		set hi [get_height $p]
		set hi [expr -1*$hi]
		if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
			set chance [expr $chance - 20]
		}
		if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
			set chance [expr $chance + 20]
		}
		if {[if_kokoni_arazu $p $u]} {
			set chance [expr $chance - 20]
		}
		if {[is_in [list "sharingan-1" $u -1] $effects]} {
			set chance [expr $chance + 20]
		}
		if {[is_in [list "sharingan-2" $p -1] $effects]} {
			set chance [expr $chance - 20]
		}
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
proc tech_naruto-rendan-prev {u p {timestart 0} interval d {strikes 0}} {
	global mydir effects
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
get_image $tag [file join $mydir images heroes $user attack 3-$i.gif]"
		incr i
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]
	replace"
	#damage
	if {[if_domu $u]} {
		incr d 1
	}
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		set nd [take_damage $p $d "konoha-senpu"]
		if {$nd > 0} {
			set_speed $p 0
			set_speed $u 0 
			after [expr $t + 500] "set_speed $u $s1
			replace"
			if {[get_hitpoints $p] > 0} {
				after [expr $t + 500] "set_speed $p $s2
				replace"
			}
			set strikes [expr [clones_interface $u "get_number"]/2 + [clones_interface $u "get_number"]%2]
			if {$strikes > 0} {
				tech_naruto-rendan $u $p $t $interval $d $strikes
			}
		}
	}
}
proc tech_naruto-rendan {u p {timestart 0} interval d strikes} {
	global mydir locations effects
	if {$u == "hero"} {
		set tag "heroi"
		set tag2 $p
	} else {
		set tag $u
		set tag2 "heroi"
	}
	set sx [getx $tag2]
	.c raise $tag
	set user [get_name $u]
	set purpose [get_name $p]
	set t $timestart
	if {[if_domu $u]} {
		incr d 1
	}
	set summary_d [expr $d * 2]
	set c_strikes 1
	set clones [clones_interface $u "get_number"]
	after $t ".c move $tag2 0 -10"
	after [expr $t + $interval] ".c move $tag2 0 -10"
	after [expr $t + $interval*2] ".c move $tag2 0 -10"
	after [expr $t + $interval*3] ".c move $tag2 0 -10"
	set t [expr $t + $interval*3]
	set sy -40
	while {$strikes > 0} {
		if {$c_strikes <= $clones} {
			set tak "clon-$c_strikes-$tag"
		} else {
			set c_strikes 1
			set tak "clon-$c_strikes-$tag"
		}
		if {$strikes % 2 == 0} {
			set ki 1
		} else {
			set ki 2
		}
		set i 1
		while {$i <= 6} {
			set t [expr $t + $interval]
			if {[is_in "tsuten-kyaku" [get_skills $u]] && $t > 300} {
				#stop animate - tsuten kyaku

			} else {
				after $t ".c raise $tak
				get_image $tak [file join $mydir images heroes $user naruto-rendan $ki-$i.gif]"
				if {$i == 2} {
					set ix [getx $tak]
					set iy [gety $tak]
					if {$ki == 1} {
						set jx [expr $sx - 20]
					} else {
						set jx [expr $sx + 20]
					}
					after $t ".c move $tak [expr $jx - $ix] $sy"
				}
				if {$i == 3} {
					after $t ".c move $tag2 0 -20"
					incr sy -20
				}
			}
			incr i 1
		}
		after $t ".c move $tak [expr $ix - $jx] [expr -1*($sy+20)]"
		set t [expr $t + $interval]
		after $t "get_image $tak [file join $mydir images heroes $user stand 1.gif]"
		set s1 [get_speed $u]
		set s2 [get_speed $p]
		set chance [expr 50 - ($s2-$s1)*10]
		set hi [get_height $p]
		set hi [expr -1*$hi]
		if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
			set chance [expr $chance - 20]
		}
		if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
			set chance [expr $chance + 20]
		}
		if {[if_kokoni_arazu $p $u]} {
			set chance [expr $chance - 20]
		}
		if {[is_in [list "sharingan-1" $u -1] $effects]} {
			set chance [expr $chance + 20]
		}
		if {[is_in [list "sharingan-2" $p -1] $effects]} {
			set chance [expr $chance - 20]
		}
		set randomnumber [expr 100*rand()]
		if {$randomnumber < $chance} {
			#hit
			incr summary_d $d
			take_damage $p $d "konoha-senpu"
		}
		incr strikes -1
		incr c_strikes 1
	}
	set tincr 300
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
	set yincr [expr -1*($sy / 15)]
	set yaddincr [expr -1*($sy % 15)]
	while {$tincr < [expr 600 + $addt]} {
		after [expr $timestart + $tincr] ".c move $tag2 0 $yincr"
		incr tincr 20
	}
	after [expr $timestart + $tincr] ".c move $tag2 0 $yaddincr"
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
	global mydir effects
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
	if {[if_domu $u]} {
		incr d 1
	}
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 50 - ($s2-$s1)*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	global mydir effects
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[if_domu $u]} {
		incr d 1
	}
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "shoshitsu"
	}
}
proc tech_hosho {u p {timestart 0} interval d} {
	global mydir effects
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[if_domu $u]} {
		incr d 1
	}
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		set chance [expr $chance - 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {[is_in "bunshin-taiatari" [get_skills $u]] && [clones_interface $u "get_number"] > 0} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	global mydir enemy locations effects
	if {$u == "hero"} {
		set tag "heroi"damage
		s
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 25]
	}
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
			set hi [get_height $purpose]
			set hi [expr -1*$hi]
			if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
				set miss_chance [expr $miss_chance + 20]
			}
			if {[is_in [list "sharingan-2" $purpose -1] $effects]} {
				set miss_chance [expr $miss_chance + 20]
			}
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
	global mydir enemy locations effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 50]
	}
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
			set hi [get_height $purpose]
			set hi [expr -1*$hi]
			if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
				set miss_chance [expr $miss_chance + 20]
			}
			if {[is_in [list "sharingan-2" $purpose -1] $effects]} {
				set miss_chance [expr $miss_chance + 20]
			}
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
		set tp 2
		get_image i_$randomnumber [file join $mydir images attacks zankuha 2-1.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
			set_chakra $u [expr [get_chakra $u] - 15]
		}
	} else {
		set tp 1
		get_image i_$randomnumber [file join $mydir images attacks zankuha 1-1.gif]
		if {[is_in [list "kyubi-1" "hero" -1] $effects]} {
		} else {
			set_chakra "hero" [expr [get_chakra "hero"] - 15]
		}
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	#damage (very mark)
	set s [get_speed $p]
	set chance [expr 100 - $s*5]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	set t $timestart
	get_image i_$randomnumber-1 [file join $mydir images attacks zankuha [set tp]-1.gif]
	get_image i_$randomnumber-2 [file join $mydir images attacks zankuha [set tp]-2.gif]
	get_image i_$randomnumber-3 [file join $mydir images attacks zankuha [set tp]-3.gif]
	get_image i_$randomnumber-4 [file join $mydir images attacks zankuha [set tp]-4.gif]
	set k 1
	while {$t < [expr $timestart + 500]} {
		after $t ".c itemconfigure t_$randomnumber -image i_$randomnumber-$k"
		incr k 1
		if {$k > 4} {
			set k 1
		}
		incr t 50
	}
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
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber > 50} {
	     set k 1
	} else {
	     set k -1
	}
	if {[is_high $u]} {
		after $t " .c move t_$randomnumber 0 -20"
		incr k 1
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
		set tp 2
		get_image i_$randomnumber [file join $mydir images attacks zankukyokuha 2-1.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra $u [expr [get_chakra $u] - 25]
		}
	} else {
		set tp 1
		get_image i_$randomnumber [file join $mydir images attacks zankukyokuha 1-1.gif]
		if {[is_in [list "kyubi-1" "hero" -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 25]
		}
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	#damage (very very mark - minimal chance is 70% vs naruto in fox-mode)
	set s [get_speed $p]
	set chance [expr 100 - $s*3]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	set t $timestart
	get_image i_$randomnumber-1 [file join $mydir images attacks zankukyokuha [set tp]-1.gif]
	get_image i_$randomnumber-2 [file join $mydir images attacks zankukyokuha [set tp]-2.gif]
	get_image i_$randomnumber-3 [file join $mydir images attacks zankukyokuha [set tp]-3.gif]
	get_image i_$randomnumber-4 [file join $mydir images attacks zankukyokuha [set tp]-4.gif]
	set k 1
	while {$t < [expr $timestart + 500]} {
		after $t ".c itemconfigure t_$randomnumber -image i_$randomnumber-$k"
		incr k 1
		if {$k > 4} {
			set k 1
		}
		incr t 75
	}
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
proc tech_futon-shinku-dai-gyoku {x y r p {timestart 0} d} {
	global mydir effects enemy
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks shinku-dai-gyoku 2.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
			set_chakra $u [expr [get_chakra $u] - 35]
		}
	} else {
		get_image i_$randomnumber [file join $mydir images attacks shinku-dai-gyoku 1.gif]
		if {[is_in [list "kyubi-1" "hero" -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 35]
		}
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	#damage (mark)
	set s [get_speed $p]
	set chance [expr 100 - $s*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_high $u]} {
		after $t " .c move t_$randomnumber 0 -20"
	}
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
		take_damage $p $d "futon-shinku-dai-gyoku"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_futon-shinkuha {x y r p {timestart 0} d} {
	global mydir effects enemy
	if {$p == "hero"} {
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
			set_chakra $u [expr [get_chakra $u] - 25]
		}
	} else {
		if {[is_in [list "kyubi-1" "hero" -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 25]
		}
		set u "hero"
	}
	set t $timestart
	set enemylist [list hero]
	set e 1
	while {$e <= $enemy} {
		lappend enemylist enemy$e
		incr e 1
	}
	set c 1
	while {$c <= 12} {
		get_image shinkuha_[set u]_[set c] [file join $mydir images attacks shinkuha $c.gif]
		after $t ".c itemconfigure shinkuha_$u -image shinkuha_[set u]_[set c]"
		incr t 50
		incr c 1
	}
	after $timestart ".c create image $x $y -tag shinkuha_$u -image shinkuha_[set u]_1"
	after $t ".c delete shinkuha_$u
	replace"
	foreach en $enemylist {
		if {([expr abs([get_location $en] - [get_location $u])] == 1 && !([expr abs([get_height $en] - [get_height $u])] == 1)) || (![expr abs([get_location $en] - [get_location $u])] == 1 && ([expr abs([get_height $en] - [get_height $u])] == 1))} {
			puts "$en is under attack!"
			#damage (mark)
			set randomnumber [expr 100*rand()]
			set s [get_speed $p]
			set chance [expr 100 - $s*10]
			if {$randomnumber < $chance} {
				#hit
				take_damage $p $d "futon-shinkuha"
				if {[get_chakra $p] == 0} {
					set_hitpoints $p 0
				}
			}
		}
	}
}
#katon
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
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra $u [expr [get_chakra $u] - 15]
		}
	} else {
		set tp 1
		get_image i_$randomnumber [file join $mydir images attacks fireball 1-1.gif]
		if {[is_in [list "kyubi-1" "hero" -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 15]
		}
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	set s [get_speed $p]
	#normal chances
	set chance [expr 100 - $s*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	if {[is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		haisekisho_boom $d $hi $u $timestart
		after [expr $timestart + 200] ".c delete t_$randomnumber"
	} elseif {$randomnumber < $chance} {
		#hit
		take_damage $p $d "katon-gokakyu"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_katon-housenka {x y r p {timestart 0} d} {
	global mydir effects enemy
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		get_image i_$randomnumber [file join $mydir images attacks housenka 2.gif]
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}

	} else {
		get_image i_$randomnumber [file join $mydir images attacks housenka 1.gif]
		set u "hero"
	}
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	#damage (very mark)
	set s [get_speed $p]
	set chance [expr 100 - $s*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
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
	if {[is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		haisekisho_boom $d $hi $u $timestart
		after [expr $timestart + 200] ".c delete t_$randomnumber"
	} elseif {$randomnumber < $chance} {
		#hit
		take_damage $p $d "katon-housenka"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_katon-ryuka {u p {timestart 0} interval d} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	.c raise $tag
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 20]
	}	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user katon-ryuka $i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
	#damage
	set ll [list "hero"]
	set e 1
	while {$e <= $enemy} {
		lappend ll "enemy$e"
		incr e 1
	}
	foreach pur $ll {
		if {$pur != $u && [get_height $pur] == [get_height $u] && [get_location $u] == [get_location $pur]} {
			set s1 [get_speed $u]
			set s2 [get_speed $pur]	
			set chance [expr 100 - ($s2-$s1)*10]
			set hi [get_height $pur]
			set hi [expr -1*$hi]
			if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $pur]]} {
				set chance [expr $chance - 20]
			}
			if {[if_kokoni_arazu $pur $u]} {
				set chance [expr $chance - 20]
			}
			if {[is_in [list "sharingan-1" $u -1] $effects]} {
				set chance [expr $chance + 20]
			}
			if {[is_in [list "sharingan-2" $pur -1] $effects]} {
				set chance [expr $chance - 20]
			}
			if {$randomnumber < $chance} {
				#hit	
				take_damage $pur $d "katon-ryuka"
			}
		}
	}
}
proc tech_katon-endan {x y r p {timestart 0} d} {
	global mydir effects enemy
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		set tp 2
		set dx -100
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		set tag2 "heroi"
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra $u [expr [get_chakra $u] - 25]
		}
	} else {
		set tp 1
		set dx 100
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 25]
		}
		set u "hero"
		set tag2 $p
	}
	get_image i_$randomnumber-1 [file join $mydir images attacks endan [set tp]-1.gif]
	get_image i_$randomnumber-2 [file join $mydir images attacks endan [set tp]-2.gif]
	get_image i_$randomnumber-3 [file join $mydir images attacks endan [set tp]-3.gif]
	get_image i_$randomnumber-4 [file join $mydir images attacks endan [set tp]-4.gif]
	set t $timestart
	set ox [getx $tag2]
	while {[expr $ox + 60] < $x || [expr $ox - 60] > $x} {
		set x [expr $x + $dx]
		set t [expr $t + 20]
		after $t ".c create image $x $y -image i_$randomnumber-1 -tag t_$randomnumber-$x"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_$randomnumber-$x -image i_$randomnumber-2"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_$randomnumber-$x -image i_$randomnumber-3"
		after [expr $t + 20] ".c itemconfigure t_$randomnumber-$x -image i_$randomnumber-4"
		after [expr $timestart + 600] ".c delete t_$randomnumber-$x"
	}
	set x [expr $x + $dx]
	set t [expr $t + 20]
	after $t ".c create image $x $y -image i_$randomnumber-1 -tag t_$randomnumber"
	after [expr $timestart + 600] ".c delete t_$randomnumber"
	set s [get_speed $p]
	#low chances
	set chance [expr 100 - $s*15]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	after [expr $timestart + 600] "
	replace"
	if {[is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		haisekisho_boom $d $hi $u $timestart
		after [expr $timestart + 200] ".c delete t_$randomnumber"
	} elseif {$randomnumber < $chance} {
		#hit
		take_damage $p $d "katon-endan"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_katon-haisekisho {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
	set_chakra $u [expr [get_chakra $u] - 25]
	}	
	set user [get_name $u]
	set c 1
	while {$c <= 10} {
		get_image ash_$u-$c [file join $mydir images attacks haisekisho $c.gif] 
		incr c
	}
	set t 100
	set y [gety $tag]
	after $t ".c create image 512 $y -image ash_$u-1 -tag ash_$u"
	set i 1
	while {$i <= 10} {
		after $t "get_image $tag [file join $mydir images heroes $user katon-haisekisho $i.gif] run $u"
		after $t ".c itemconfigure ash_$u -image ash_$u-$i"
		incr i
		incr t 100
	}
	after $t "replace"
} 
proc haisekisho_boom {d h u timestart} {
	global mydir effects enemy
	set ll [list "hero"]
	set e 1
	while {$e <= $enemy} {
		lappend ll "enemy$e"
		incr e 1
	}
	set h [expr -1*$h]
	set c 11
	while {$c <= 18} {
		get_image ash-boom_$c [file join $mydir images attacks haisekisho $c.gif] 
		incr c 1
	}
	foreach user $ll {
		set y [gety ash_$user]
		if {$y < [expr 700 - 100*$h] && $y > [expr 600 - 100*$h]} {
			set t $timestart
			set c 11
			while {$c <= 18} {
				if {$c > 15} {
					incr t 50
				}
				incr t 50
				after $t ".c itemconfigure ash_$user -image ash-boom_$c"
				incr c 1
			}
			after [expr $timestart + 650] "effect katon-haisekisho $user remove"
		}
	}
	set i 0
	foreach ef $effects {
		set do [lindex $ef 0]
		set holder [lindex $ef 1]
		set t [lindex $ef 2]
		if {$do == "katon-haisekisho" && $t == [expr -1*$h]} {
			if {$i < [llength $effects]} {
				set effects [lreplace $effects $i $i]
				incr i -1
			}
		}
		incr i
	}
	foreach p $ll {
		if {$p != $u && [get_height $p] == $h} {
			take_damage $p $d "katon-haisekisho"
			if {[get_chakra $p] == 0} {
				set_hitpoints $p 0
			}
		}
	}
}
#suiton
proc tech_suiton-suika {u} {
	global mydir effects
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
		after $t "get_image $tag [file join $mydir images heroes $user suiton-suika $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
} 
proc tech_suiton-suika {u} {
	global mydir effects
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
		after $t "get_image $tag [file join $mydir images heroes $user suiton-suika $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
} 
proc tech_suiton-kirigakure {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
	set_chakra $u [expr [get_chakra $u] - 15]
	}	
	set user [get_name $u]
	set c 1
	while {$c <= 10} {
		get_image mist$c [file join $mydir images attacks kirigakure $c.gif] 
		incr c
	}
	set t 100
	after $t ".c create image 512 288 -image mist1 -tag mist"
	set i 1
	while {$i <= 10} {
		after $t "get_image $tag [file join $mydir images heroes $user suiton-kirigakure $i.gif] run $u"
		after $t ".c itemconfigure mist -image mist$i"
		incr i
		incr t 100
	}
	after $t "replace"
} 
proc tech_suiton-mizurappa {x y r p {timestart 0} d} {
	global mydir effects enemy
	
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		set tp 2
		set dx -100
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		set tag2 "heroi"
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra $u [expr [get_chakra $u] - 10]
		}
	} else {
		set tp 1
		set dx 100
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 10]
		}
		set u "hero"
		set tag2 $p
	}
	get_image i_$randomnumber-1 [file join $mydir images attacks mizurappa [set tp]-1.gif]
	get_image i_$randomnumber-2 [file join $mydir images attacks mizurappa [set tp]-2.gif]
	get_image i_$randomnumber-3 [file join $mydir images attacks mizurappa [set tp]-3.gif]
	get_image i_$randomnumber-4 [file join $mydir images attacks mizurappa [set tp]-4.gif]
	set t $timestart
	set ox [getx $tag2]
	while {[expr $ox + 60] < $x || [expr $ox - 60] > $x} {
		set x [expr $x + $dx]
		set t [expr $t + 20]
		after $t ".c create image $x $y -image i_$randomnumber-1 -tag t_$randomnumber-$x"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_$randomnumber-$x -image i_$randomnumber-2"
		set t [expr $t + 20]
		after $t ".c itemconfigure t_$randomnumber-$x -image i_$randomnumber-3"
		after [expr $t + 20] ".c itemconfigure t_$randomnumber-$x -image i_$randomnumber-4"
		after [expr $timestart + 600] ".c delete t_$randomnumber-$x"
	}
	set x [expr $x + $dx]
	set t [expr $t + 20]
	after $t ".c create image $x $y -image i_$randomnumber-1 -tag t_$randomnumber"
	after [expr $timestart + 600] ".c delete t_$randomnumber"
	set s [get_speed $p]
	#low chances
	set chance [expr 100 - $s*15]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	after [expr $timestart + 600] "
	replace"
	if {$randomnumber < $chance} {
		#hit
		take_damage $p $d "suiton-mizurappa"
		if {[get_chakra $p] == 0} {
			set_hitpoints $p 0
		}
	}
}
proc tech_suiton-mizu-bunshin {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set not 0
	set tun -1
	while {$tun <= 20} {
		if {[is_in [list "shadow-clon" $u $tun] $effects]} {
			set not 1
		} 
		if {[is_in [list "water-clon" $u $tun] $effects]} {
			set not 1
		}
		if {[is_in [list "earth-clon" $u $tun] $effects]} {
			set not 1
		}
		if {[is_in [list "wood-clon" $u $tun] $effects]} {
			set not 1
		}
		incr tun 1
	}
	if {$not == 0} {
		lappend effects [list "water-clon" $u [expr [get_nin $u] * 2]]
		set x [getx $tag]
		set y [gety $tag]
		.c create line $x $y $x $y -tag original_$u
		set_chakra $u [expr [get_chakra $u] - 20]
		set user [get_name $u]
		set t 100
		set i 1
		while {$i <= 7} {
			after $t "get_image $tag [file join $mydir images heroes $user suiton-mizu-bunshin $i.gif] run $u"
			incr i
			incr t 70
		}
		set i 1
		while {$i <= 6} {
			after $t "get_image $tag [file join $mydir images heroes $user suiton-clone $i.gif] run $u"
			incr i 1
			incr t 70
		}
		after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
		after $t "replace"
	}
}
proc tech_suiton-suiro {u p {timestart 0} interval d} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	.c raise $tag	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
                get_image $tag [file join $mydir images heroes $user suiton-suiro $i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
	#damage
	set s1 [get_speed $p]	
        #very mark
	set chance [expr 100 - $s1*5]
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		set nd [take_damage $p $d "suiton-suiro"]
		if {$nd > 0} {
			set_speed $p 0
			after [expr $t + 900] "set_speed $p $s1
			replace"
			set h [get_height $u]
			set l [get_location $u]
			set hl [expr ($h * 10) + $l]
			lappend effects [list "suiton-suiro" $p $hl]
			lappend effects [list "suiton-suiro-user" $u $hl]
			after $timestart "create_suiro $p $hl"
		}
	}
}
proc tech_suiton-baku-suishoha {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
	set_chakra $u [expr [get_chakra $u] - 30]	
	}
	set user [get_name $u]
	set c 1
	while {$c <= 10} {
		get_image wave$c [file join $mydir images attacks baku-suishoha $c.gif] 
		incr c
	}
	set t 100
	set x [getx $u]
	set i 1
	while {$i <= 10} {
		after $t "get_image $tag [file join $mydir images heroes $user suiton-baku-suishoha $i.gif] run $u"
		incr i
		incr t 100
	}
	after 500 ".c create image $x 526 -image wave1 -tag wave"
	set t 600
	set i 1
	while {$i <= 10} {
		after $t ".c itemconfigure wave -image wave$i"
		incr i
		incr t 100
	}

	after $t "replace"
}
proc tech_suiton-suijinheki {u r p {timestart 0} d} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
		set dx 50
	} else {
		set tag $u
		set dx -50
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 50]
	}	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 10} {
		set t [expr $t + 100]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user suiton-suijinheki $i.gif] run $u"
		incr i
	}
	after 1800 ".c raise $tag
get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
	set t [expr $timestart + 300]
	set i 2
	set x [getx $tag]
	get_image wall$tag [file join $mydir images attacks suijinheki 1.gif]
	after $t ".c create image [expr $x + $dx] 426 -image wall$tag -tag wall$tag"
	while {$t <= 1800} {
		set t [expr $t + 100]
		after $t ".c raise $tag
get_image wall$tag [file join $mydir images attacks suijinheki $i.gif] run $u"
		if {$i < 10} {
			incr i
		} else {
			if {$i == 10} {
				set i 7
			}
		}
	}
	after $t ".c delete wall$tag"
}
proc tech_suiton-daibakufu {u r p {timestart 0} d} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 70]
	}	
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 12} {
		set t [expr $t + 100]
		after $t ".c raise daibakufu$u
get_image $tag [file join $mydir images heroes $user suiton-daibakufu $i.gif] run $u"
		incr i
	}
	after [expr $timestart + 1300] "
get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
	set e 1
	while {$e <= $enemy} {
		lappend enemylist enemy$e
		incr e
	}
	lappend enemylist "hero"
	set h [get_height $u]
	foreach purpose $enemylist {
		set randomnumber [expr 100*rand()]
		if {[get_height $purpose] == 1 && $purpose != $u} {
			set s1 [get_speed $purpose]
			set chance [expr 100 - $s1*10]
			if {$randomnumber < $chance} {
				set nd [take_damage $purpose $d "suiton-daibakufu"]
				after $t "replace"
			}
		}
	}
	set c 1
	while {$c <= 12} {
		get_image bakufu$c [file join $mydir images attacks daibakufu $c.gif] 
		incr c
	}
	after $timestart ".c create image 512 520 -image bakufu1 -tag daibakufu$u"
	set t $timestart
	set i 1
	while {$i <= 12} {
		after $t ".c itemconfigure daibakufu$u -image bakufu$i"
		incr i
		incr t 100
	}
	after $t ".c delete daibakufu$u
	replace"
}
proc tech_suiton-suiryudan {u r p {timestart 0} d} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
		set wx 0
		set dx 20
		set tp 1
		set vx -150
	} else {
		set tag $u
		set wx 1025
		set dx -20
		set tp 2
		set vx 1175
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 100]
	}	
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 18} {
		set t [expr $t + 100]
		after $t ".c raise daibakufu$u
get_image $tag [file join $mydir images heroes $user suiton-suiryudan $i.gif] run $u"
		incr i
	}
	after [expr $timestart + 1900] "
get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
	set e 1
	while {$e <= $enemy} {
		lappend enemylist enemy$e
		incr e
	}
	lappend enemylist "hero"
	set h [get_height $u]
	set randomnumber [expr 100*rand()]
	foreach purpose $enemylist {
		set randomnumbera [expr 100*rand()]
		if {[get_height $purpose] == [get_height $u] && $purpose != $u} {
			set s1 [get_speed $purpose]
			set chance [expr 100 - $s1*10]
			if {$randomnumbera < $chance} {
				set nd [take_damage $purpose $d "suiton-daibakufu"]
				if {$nd > 0 && $s1 > 0} {
					if {[get_hitpoints $p] > 0} {
						after [expr $timestart + 1800] "set_speed $purpose $s1
						replace"
					}
					set dt $timestart
					while {$dt <= 1800} {
						after $dt "if_contact_nokout t_$randomnumber $p"
						incr dt 20
					}
				}
			}
		}
	}
	set t $timestart
	set i 2
	set x [getx $tag]
	set y [gety $tag]
	get_image wall$tag [file join $mydir images attacks suijinheki 1.gif]
	after $t ".c create image $wx 426 -image wall$tag -tag wall$tag"
	while {$t <= 1800} {
		set t [expr $t + 100]
		after $t ".c raise wall$tag
get_image wall$tag [file join $mydir images attacks suijinheki $i.gif] run $u"
		if {$i < 10} {
			incr i
		} else {
			if {$i == 10} {
				set i 7
			}
		}
	}
	after $t ".c delete wall$tag"
	set t [expr $timestart + 500]
	get_image i_$randomnumber-1 [file join $mydir images attacks suiryudan [set tp]-1.gif]
	get_image i_$randomnumber-2 [file join $mydir images attacks suiryudan [set tp]-2.gif]
	get_image i_$randomnumber-3 [file join $mydir images attacks suiryudan [set tp]-3.gif]
	get_image i_$randomnumber-4 [file join $mydir images attacks suiryudan [set tp]-4.gif]
	.c create image $vx $y -image i_$randomnumber-1 -tag t_$randomnumber
	set k 1
	while {$t < 1500} {
		after $t ".c move t_$randomnumber $dx 0
.c itemconfigure t_$randomnumber -image i_$randomnumber-$k"
		incr k 1
		if {$k > 4} {
			set k 1
		}
		incr t 20
	}
	after $t ".c delete t_$randomnumber
	replace"
}
#Doton
proc tech_doton-moguragakure {x y r p {timestart 0} d} {
	global mydir effects enemy
	set randomnumber [expr 100*rand()]
	if {$p == "hero"} {
		set tp 2
		set dx -100
		set e 1
		while {$e <= $enemy} {
			if {[getx enemy$e] == $x && [gety enemy$e] == $y} {
				set u "enemy$e"
			}
			incr e
		}
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra $u [expr [get_chakra $u] - 10]
		}
		set tag $u
	} else {
		set tp 1
		set dx 100
		if {[is_in [list "kyubi-1" $u -1] $effects]} {
		} else {
		set_chakra "hero" [expr [get_chakra "hero"] - 10]
		}
		set u "hero"
		set tag "heroi"
	}
	set t $timestart 
	set s1 [get_speed $u]
	set s2 [get_speed $p]
	set d [expr [get_tai $u] + 3]
	if {[if_domu $u]} {
		incr d 1
	}
	set chance [expr 50 - ($s2-$s1)*10]
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	set user [get_name $u]
	after [expr $t + 500] "get_image $tag [file join $mydir images heroes $user doton-moguragakure 5.gif]"
	after [expr $t + 600] "get_image $tag [file join $mydir images heroes empty.gif]"
	if {$randomnumber < $chance} {
		after 1000 "attack_of_mole $u $p $d hit"
	} else {
		after 1000 "attack_of_mole $u $p $d miss"
	}
}
proc attack_of_mole {u p d r} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set user [get_name $u]
	if {[get_height $u] == [get_height $p] && [get_location $u] == [get_location $p]} {
		#fail
		set t 100
		set i 11
		while {$i <= 15} {
			after $t "get_image $tag [file join $mydir images heroes $user kawarimi $i.gif]"	
			incr t 100
			incr i 
		}
	} else {
		set dl [expr [get_location $p] - [get_location $u]]
		set dh [expr [get_height $p] - [get_height $u]]
		.c move $tag [expr $dl * 300] [expr $dh * 100]
		set t 100
		set i 6
		while {$i <= 10} {
			after $t "get_image $tag [file join $mydir images heroes $user doton-moguragakure $i.gif]"	
			incr t 100
			incr i 
		}		
		if {$r == "hit"} {
			set nd [take_damage $p $d "doton-moguragakure"]
			if {$nd > 0} {
				set ss [get_speed $p]
				set_speed $p 0
				after 300 "nokout $p"
				if {$ss > 0} {
					after 900 "set_speed $p $ss"
				}
			}
		}
	}
}
proc tech_doton-doryu-heki {u r p {timestart 0} d} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
		set dx 50
	} else {
		set tag $u
		set dx -50
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 30]
	}	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 10} {
		set t [expr $t + 100]
		after $t "
get_image $tag [file join $mydir images heroes $user doton-doryu-heki $i.gif] run $u"
		incr i
	}
	after 1900 ".c raise $tag
get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
	set t [expr $timestart + 300]
	set i 2
	set x [getx $tag]
	get_image wall$tag [file join $mydir images attacks doryu-heki 1.gif]
	after $t ".c create image [expr $x + $dx] 410 -image wall$tag -tag wall$tag"
	while {$t <= 1800} {
		set t [expr $t + 100]
		after $t ".c raise wall$tag
get_image wall$tag [file join $mydir images attacks doryu-heki $i.gif] run $u"
		if {$i < 10} {
			incr i
		} else {
			set i 10
		}
	}
	after $t ".c delete wall$tag"
}
proc tech_doton-tsuiga {u} {
	global mydir enemy effects
	if {$u == "hero"} {
		set tag "heroi"
		set e 1
		set p "none"
		set d 5000000
		while {$e <= $enemy} {
			if {$d > [dist $tag enemy$e]} {
				set d [dist $tag enemy$e]
				set p "enemy$e"
			}
			incr e
		}
		set tag2 $p
	} else {
		set tag $u
		set p "hero"
		set tag2 "heroi"
	}
	set i 0
	set_chakra $u [expr [get_chakra $u] - 20]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 9} {
		after $t "get_image $tag [file join $mydir images heroes $user kuchiese $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "get_image $tag [file join $mydir images heroes $user kuchiese doton-tsuiga.gif]"
	after [expr $t + 100] "get_image $tag [file join $mydir images heroes $user kuchiese doton-tsuiga.gif]"
	after $t "replace"
	if {$p != "none"} {
		set nin [get_nin $u]
		set tai [get_tai $p]
		if {$tai == 0} {
			set turns [expr $nin*2 + 1]
		} else {
			set turns [expr $nin/$tai + 1]
		}
		set f "no"
		set ts 0
		while {$ts <= 10} {
			if {[is_in [list "tsuiga-no-jutsu" $p $ts] $effects]} {
				set f "yes"
				lset effects [lsearch $effects [list "tsuiga-no-jutsu" $p $ts]] [list "tsuiga-no-jutsu" $p $turns]
				break
			}
			incr ts
		}
		if {$f == "no"} {
			lappend effects [list "tsuiga-no-jutsu" $p $turns]
		}
		set t 900
		set x [getx $tag2]
		set y [gety $tag2]
		after $t "get_image dogs$tag [file join $mydir images attacks tsuiga-no-jutsu 1.gif]"
		get_image dogs$tag [file join $mydir images heroes empty.gif]
		.c create image [getx $tag2] [gety $tag2] -image dogs$tag -tag dogs$tag2
		.c addtag $tag2 withtag dogs$tag2
		set i 1
		while {$i <= 5} {
			after $t "get_image dogs$tag [file join $mydir images attacks tsuiga-no-jutsu $i.gif]"
			incr i
			incr t 100
		}
	}
}
proc tech_doton-domu {u} {
	global mydir enemy effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set n 0
	#remove old effect
	foreach e $effects {
		set do [lindex $e 0]
		set holder [lindex $e 1]
		set t [lindex $e 2]
		if {$do == "doton-domu" && $holder == $u} {
			set effects [lreplace $effects $n $n]
			incr n -1
		}
		incr n 1
	}
	set_chakra $u [expr [get_chakra $u] - 20]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 8} {
		after $t "get_image $tag [file join $mydir images heroes $user doton-domu $i.gif] run $u"
		incr i
		incr t 50
	}
	after $t "replace"
}
proc if_domu {u} {
	global effects
	set r 0
	foreach e $effects {
		set do [lindex $e 0]
		set holder [lindex $e 1]
		set t [lindex $e 2]
		if {$do == "doton-domu" && $holder == $u && $t > 0} {
			set r 1
		}
	}
	return $r
}
#Raiton
proc tech_raiton-chidori {u p {timestart 0} interval d} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	.c raise $tag
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 30]
	}	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 10} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user raiton-chidori $i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t "attack-chidori $u $p $interval"
	after $t "replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 75 - ($s2-$s1)*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		set nd [take_damage $p $d "raiton-chidori"]
		if {$nd > 0} {
			set_speed $p 0
			if {[get_hitpoints $p] > 0} {
				after 100 "set_speed $p $s2"
			}
		}
	}
}
proc tech_raiton-raikiri {u p {timestart 0} interval d} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	.c raise $tag
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 50]
	}	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 10} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user raiton-chidori $i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t "attack-chidori $u $p $interval"
	after $t "replace"
	#damage
	set s1 [get_speed $u]
	set s2 [get_speed $p]	
	set chance [expr 75 - ($s2-$s1)*10]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {([is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]) && [is_in "sairento-kiringu" [get_skills $p]]} {
		
		set chance [expr $chance - 20]
	}
	if {[is_in [list "sharingan-1" $u -1] $effects]} {
		set chance [expr $chance + 20]
	}
	if {[is_in [list "sharingan-2" $p -1] $effects]} {
		set chance [expr $chance - 20]
	}
	if {[if_kokoni_arazu $p $u]} {
		set chance [expr $chance - 20]
	}
	if {$randomnumber < $chance} {
		#hit
		set nd [take_damage $p $d "raiton-chidori"]
		if {$nd > 0} {
			set_speed $p 0
			if {[get_hitpoints $p] > 0} {
				after 100 "set_speed $p $s2"
			}
		}
	}
}
proc attack-chidori {u p interval} {
	global mydir
	set user [get_name $u]
	if {$u == "hero"} {
		set tag "heroi"
		set tag2 $p
	} else {
		set tag $u
		set tag2 "heroi"
	}
	.c raise $tag 
	if {[expr abs([getx $tag] - [getx $tag2])] < 100} {
		set t 0
		set i 15
		while {$i <= 20} {
			set t [expr $t + $interval]
			after $t ".c raise $tag
			get_image $tag [file join $mydir images heroes $user raiton-chidori $i.gif]"
			incr i
		}
	} else {
		if {[expr abs([getx $tag] - [getx $tag2])] < 400} {
			set d [expr 300*(([getx $tag2] - [getx $tag])/abs([getx $tag2] - [getx $tag]))]
		} else {
			set d [expr 600*(([getx $tag2] - [getx $tag])/abs([getx $tag2] - [getx $tag]))]
		}
		set dx [expr $d/10]
		set t 0
		set i 11
		while {$i <= 20} {
			set t [expr $t + $interval]
			after $t ".c raise $tag
			get_image $tag [file join $mydir images heroes $user raiton-chidori $i.gif]
			.c move $tag $dx 0"
			incr i
		}
		after [expr $t + $interval] "get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u
		replace"
	}
}
#Hyoton
proc tech_hyoton-korikyo {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 10]
	}	
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 3} {
		after $t "get_image $tag [file join $mydir images heroes $user hyoton-korikyo $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
	after $t "hyoton_teleport $tag [get_name $u]"
} 
proc tech_hyoton-sensatsu-suisho {u p {timestart 0} interval d} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
		set tag2 $p
	} else {
		set tag $u
		set tag2 "heroi"
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 15]
	}	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 5} {
		set t [expr $t + $interval]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user hyoton-sensatsu-suisho $i.gif] run $u"
		incr i
	}
	set t [expr $t + $interval]
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]
	replace"
	set x [getx $tag2]
	set y [gety $tag2]
	get_image i_$randomnumber [file join $mydir images attacks sensatsu-suisho 1.gif]
	set t $timestart
	after $t ".c create image $x $y -image i_$randomnumber -tag t_$randomnumber"
	set i 2
	while {$i <= 7} {
		set t [expr $t + $interval]
		after $t ".c raise t_$randomnumber
get_image i_$randomnumber [file join $mydir images attacks sensatsu-suisho $i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t ".c delete t_$randomnumber"
	#damage (mark how senbon)
	set s2 [get_speed $p]	
	set chance [expr 100 - $s2*5]
	set hi [get_height $p]
	set hi [expr -1*$hi]
	if {[is_in [list "suiton-kirigakure" "field" -1] $effects] || [is_in [list "katon-haisekisho" "field" $hi] $effects]} {
		set chance [expr $chance - 20]
	}

	if {$randomnumber < $chance} {
		take_damage $p $d "hyoton-sensatsu-suisho"
	}
}
proc tech_hyoton-koridomu {u r p {timestart 0} d} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 10]
	}	
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 15} {
		set t [expr $t + 120]
		after $t ".c raise $tag
get_image $tag [file join $mydir images heroes $user hyoton-koridomu $i.gif] run $u"
		incr i
	}
	after [expr $t + 100] ".c raise $tag
get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
}
proc tech_hyoton-makyo-hyosho {u p {timestart 0} interval d} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	.c raise $tag
	set randomnumber [expr 100*rand()]
	set user [get_name $u]
	set t $timestart
	set i 1
	while {$i <= 3} {
		set t [expr $t + $interval * 2]
		after $t ".c raise $tag
                get_image $tag [file join $mydir images heroes $user hyoton-makyo-hyosho $i.gif]"
		incr i
	}
	set t [expr $t + $interval]
	after $t "get_image $tag [file join $mydir images heroes $user hyoton-makyo-hyosho 3.gif]"
	after $t "replace"
	#damage
	set n1 [get_nin $u]	
        #very mark
	set chance [expr 90 + $n1*2]
	if {$randomnumber < $chance} {
		#no fail
		set enemylist [list]
		set e 1
		while {$e <= $enemy} {
			lappend enemylist enemy$e
			incr e
		}
		lappend enemylist "hero"
		set h [get_height $u]
		set l [get_location $u]
		set hl [expr ($h * 10) + $l]
		foreach purpose $enemylist {
			if {[get_height $purpose] == $h && [get_location $purpose] == $l && $purpose != $u} {
				set s1 [get_speed $purpose]
				set nd [take_damage $purpose $d "hyoton-makyo-hyosho"]
				set_speed $purpose 0
				after [expr $t + 900] "set_speed $purpose $s1
				replace"
				lappend effects [list "hyoton-makyo-hyosho" $p $hl]
			}
		}
		lappend effects [list "hyoton-makyo-hyosho-user" $u $hl]
		after $timestart "create_makyo-hyosho $p $hl"
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
proc tech_sharingan-1 {u} {
	global mydir
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set_chakra $u [expr [get_chakra $u] - 10]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 10} {
		after $t "get_image $tag [file join $mydir images heroes $user sharingan 1-$i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
}
proc tech_sharingan-2 {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	#sharingan 1 tomoe
	lappend effects [list "sharingan-1" $u -1]
	set_tai $u [expr [get_tai $u] + 1]
	set_chakra $u [expr [get_chakra $u] - 10]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 10} {
		after $t "get_image $tag [file join $mydir images heroes $user sharingan 2-$i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
}
proc tech_sharingan-3 {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	#sharingan 1 and 2 tomoe
	lappend effects [list "sharingan-1" $u -1]
	lappend effects [list "sharingan-2" $u -1]
	set_tai $u [expr [get_tai $u] + 1]
	#3 tomoe
	set_gen $u [expr [get_gen $u] + 1]
	set_chakra $u [expr [get_chakra $u] - 10]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 10} {
		after $t "get_image $tag [file join $mydir images heroes $user sharingan 3-$i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
}
proc tech_sharingan-full {u} {
	global mydir effects 
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set sk [get_skills $u]
	if {[is_in "sharingan-3" $sk]} {
		tech_sharingan-3 $u
		lappend effects [list "sharingan-3" $u -1]
	} elseif {[is_in "sharingan-2" $sk]} {
		tech_sharingan-2 $u
		lappend effects [list "sharingan-2" $u -1]
	} elseif {[is_in "sharingan-1" $sk]} {
		tech_sharingan-1 $u
		lappend effects [list "sharingan-1" $u -1]
	}
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
proc tech_kage-bunshin {u} {
	global mydir effects
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set not 0
	set tun -1
	while {$tun <= 10} {
		if {[is_in [list "shadow-clon" $u $tun] $effects]} {
			set not 1
		} 
		if {[is_in [list "water-clon" $u $tun] $effects]} {
			set not 1
		}
		if {[is_in [list "earth-clon" $u $tun] $effects]} {
			set not 1
		}
		if {[is_in [list "wood-clon" $u $tun] $effects]} {
			set not 1
		}
		incr tun 1
	}
	if {$not == 0} {
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
}
proc tech_kawarimi {u} {
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
	if {[is_in [list "kyubi-1" $u -1] $effects]} {
	} else {
		set_chakra $u [expr [get_chakra $u] - 10]
	}	
	set x [getx $tag]
	set y [gety $tag]
	set user [get_name $u]
	set g [get_gen $u]
	set t 100
	set i 1
	while {$i <= 5} {
		after $t "get_image $tag [file join $mydir images heroes $user kai $i.gif] run $u"
		incr i
		incr t 70
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif] run $u"
	after $t "replace"
	set j 0
	foreach ef $effects {
		set do [lindex $ef 0]
		set owner [lindex $ef 1]
		set t [lindex $ef 2]
		if {$owner == $u && $t > 0 && ($do == "kokoni-arazu-victim" || $do == "magen-narakumi")} {
			set t1 [expr $t - $g]
			if {$t1 > 0} {
				lset effects $j [list $do $owner $t1]
			} else {
				if {[llength $effects] > $j} {
					set effects [lreplace $effects $j $j]
					effect $do $owner "remove"
					incr j -1
				}
			}
			
		}
		incr j 1
	} 
}
proc tech_kokoni-arazu {u} {
	global mydir effects enemy
	if {$u == "hero"} {
		set tag "heroi"
	} else {
		set tag $u
	}
	set ll [list "hero"]
	set e 1
	while {$e <= $enemy} {
		lappend ll "enemy$e"
		incr e 1
	}
	set_chakra $u [expr [get_chakra $u] - 20]	
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 12} {
		after $t "get_image $tag [file join $mydir images heroes $user kokoni-arazu $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "replace"
	foreach p $ll {
		if {$p != $u} {
			set gu [get_gen $u]
			set gp [get_gen $p]
			if {$gp == 0} {
				set gp 1
			}
			set turns [expr $gu / $gp]
			if {$turns > 0} {
				lappend effects [list "kokoni-arazu-victim" $p $turns]
			}
		}
	}
} 
proc if_kokoni_arazu {u p} {
	global effects
	set a1 0
	set a2 0
	foreach e $effects {
		set do [lindex $e 0]
		set holder [lindex $e 1]
		set t [lindex $e 2]
		if {$do == "kokoni-arazu" && $holder == $u} {
			set a1 1
		}
		if {$do == "kokoni-arazu-victim" && $holder == $p} {
			set a2 1
		}
	}
	if {$a1 == 1 && $a2 == 1} {
		return 1
	} else {
		return 0
	}
}
proc tech_narakumi {u} {
	global mydir enemy effects
	if {$u == "hero"} {
		set tag "heroi"
		set e 1
		set p "none"
		set d 5000000
		while {$e <= $enemy} {
			if {$d > [dist $tag enemy$e]} {
				set d [dist $tag enemy$e]
				set p "enemy$e"
			}
			incr e
		}
		set tag2 $p
	} else {
		set tag $u
		set p "hero"
		set tag2 "heroi"
	}
	set i 0
	set_chakra $u [expr [get_chakra $u] - 20]
	set user [get_name $u]
	set t 100
	set i 1
	while {$i <= 10} {
		after $t "get_image $tag [file join $mydir images heroes $user narakumi $i.gif] run $u"
		incr i
		incr t 100
	}
	after $t "get_image $tag [file join $mydir images heroes $user stand 1.gif]"
	after $t "replace"
	if {$p != "none"} {
		set gen1 [get_gen $u]
		set gen2 [get_gen $p]
		if {$gen2 == 0} {
			set turns [expr $gen1 + 1]
		} else {
			set turns [expr $gen1/$gen2 + 1]
		}
		set f "no"
		set ts 0
		while {$ts <= 10} {
			if {[is_in [list "magen-narakumi" $p $ts] $effects]} {
				set f "yes"
				lset effects [lsearch $effects [list "magen-narakumi" $p $ts]] [list "magen-narakumi" $p $turns]
				break
			}
			incr ts
		}
		if {$f == "no"} {
			lappend effects [list "magen-narakumi" $p $turns]
		}
		set t 900
		set x [getx $tag2]
		set y [gety $tag2]
		after $t "get_image narakumi [file join $mydir images attacks narakumi 1.gif]"
		get_image narakumi [file join $mydir images heroes empty.gif]
		.c create image [getx $tag2] [gety $tag2] -image narakumi -tag narakumi
		.c addtag $tag2 withtag narakumi
		set i 1
		while {$i <= 10} {
			after $t "get_image narakumi [file join $mydir images attacks narakumi $i.gif]"
			incr i
			incr t 50
		}
		after $t ".c delete narakumi"
	}
}
