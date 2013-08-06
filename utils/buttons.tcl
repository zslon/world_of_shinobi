button .right -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 0} {
		if {[getx "heroi"] < 900} {
			set l [get_location "hero"]
			set h [get_height "hero"]
			set e 1
			while {$e <= $enemy} {
				set tl [get_location enemy$e]
				set th [get_height enemy$e]
				if {$tl == $l && $th == $h} {
					set e 999
				}
				incr e 1
			}
			set l [expr $l + 1] 
			if {$l < 4} {
				set p [lindex $locations $l]
				if {(abs($p) <= $h || $p > 0) && $e != 1000 && $lever == 0} {
					end_turn "run" 0
					move "hero" "right"
				}
			}
		} else {
			set h [get_height "hero"]
			if {[no_more_enemy] && ($h == [lindex $locations 3] || -$h == [lindex $locations 3]) && $lever == 0} {
				end_turn "run"
				move "hero" "right"
				after 1000 {
				next_slide
				}
			}
		}
	}
}
button .left -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 0} {
		if {[getx "heroi"] > 100} {
			set l [get_location "hero"]
			set h [get_height "hero"]
			set l [expr $l - 1] 
			set p [lindex $locations $l]
			if {abs($p) <= $h || $p > 0} {
				set e 1
				set l [list]
				while {$e <= $enemy} {
					set tl [get_location enemy$e]
					set th [get_height enemy$e]
					if {$tl == $l && $th == $h} {
						set l [melee_tech_ai $e]
						set e 999
					}
					incr e
				}
				if {$e != 1000 && [llength $l] != 0 && $lever == 0} {
					if {[is_melee [lindex $l 0]] && [lindex $l 0] != "attack"} {
						#have`nt time to run!
						end_turn
					} else {
						end_turn "run" 1	
						move "hero" "left"
					}
				} elseif {$lever == 0} {
					move "hero" "left"
					end_turn "run" 1
				}
			}
		}
	}
}	
button .jump -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 0} {
		set l [get_location "hero"]
		set h [get_height "hero"]
		set e 1
		while {$e <= $enemy} {
			set tl [get_location enemy$e]
			set th [get_height enemy$e]
			if {$tl == $l && $th == $h} {
				set e 999
			}
			incr e
		}
		if {$e != 1000 && $lever == 0} {
			move "hero" "up"
			if {$h < [lindex $locations $l]} {
				end_turn "run" 2
			} else {
				end_turn
			}
		} elseif {$lever == 0} {
			end_turn
		}
	}
}
button .stand -state disabled -command {
	if {$lever == 0 && [get_hitpoints "hero"] > 0} {
		set l [get_location hero]
		set h [get_height hero]
		set hl [expr ($h * 10) + $l]
		if {[is_in [list "suiton-suiro-user" "hero" $hl] $effects]} {
			set_nin hero 0
		}
		end_turn 
	}
}
proc block_battlepanel {} {
	global hero_ancof skills enemy
	set hero_ancof 0
	set e 1
	while {$e <= $enemy} {
		global enemy[set e]_ancof
		set enemy[set e]_ancof 0
		incr e
	}
	catch {
		.right configure -state disabled
		.left configure -state disabled
		.jump configure -state disabled
		.stand configure -state disabled
		foreach s $skills {
			if {[enciclopedia $s chakra] != 0} {
				.button_$s configure -state disabled
			}
		}
	}
}
proc unblock_battlepanel {} {
	global hero_ancof skills enemy effects
	set n 0
	set q 1
	if {[is_in [list "endgame" "hero" 0] $effects]} {
		set q 0
	}
	while {$n <= 5} {
		set q [expr $q * !([is_in [list "suiken" "hero" $n] $effects])]
		incr n
	}
	if {$q} {
		if {$hero_ancof == 0} {
			set hero_ancof 1
			stand_animation "heroi" [get_name "hero"]
		}
		set e 1
		while {$e <= $enemy} {
			global enemy[set e]_ancof
			set enemy[set e]_ancof 1
			incr e
		}
		catch {
			.right configure -state normal
			.left configure -state normal
			.jump configure -state normal
			.stand configure -state normal
			foreach s $skills {
				if {[enciclopedia $s chakra] != 0} {
					.button_$s configure -state normal
				}
			}
		}
	}
}
proc next_slide {} {
	global slide effects bonus enemy hero_ancof
	set bonus 0
	set xxx [getx original_hero]
	set yyy [gety original_hero]
	set y [gety "heroi"]
	if {$xxx > 0 && $xxx < 2000} {
		.c move original_hero [expr 50 - $xxx] [expr $y - $yyy]
	}
	set slide [expr $slide + 1]
	set i 0
	foreach e $effects {
		set do [lindex $e 0]
		set owner [lindex $e 1]
		effect $do $owner "remove" "nextslide"
		incr i
	}
	set effects [lreplace $effects 0 [expr [llength $effects] - 1]]
	set h [get_hitpoints "hero"]
	set c [get_chakra "hero"]
	set e 1
	while {$e <= 3} {
		.c delete enemy$e
		incr e 1
	}
	set enemy 0
	.c delete heroi
	.c delete panel
	.c delete medic
	.c delete green_medic
	.c delete yellow_medic
	slide_$slide
	major_hero 50 $y
	set_hitpoints "hero" $h
	set_chakra "hero" $c
	set hero_ancof 0
	create_battlepanel
}
#skills
#Rock 
button .button_suiken -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 24 && !([is_in "hachimon-1" $used]) && !([is_in "suiken" $used])} {
		tech_suiken "hero"
		lappend effects [list "suiken" "hero" 5]
		lappend used "suiken"
		replace
		end_turn "suiken"
	} elseif {[is_in "hachimon-1" $used]} {
		suiken_not_message
	} elseif {[get_chakra "hero"] < 25} {
		no_chakra_message
	}
}
button .button_hachimon-1 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 19 && !([is_in "hachimon-1" $used])} {
		tech_hachimon-1 "hero"
		lappend effects [list "hachimon-1" "hero" -1]
		lappend used "hachimon-1"
		replace
		end_turn "hachimon-1"
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 20} {
		no_chakra_message
	}
}
button .button_hachimon-2 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] > 39 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] > 19)) && !([is_in "hachimon-2" $used])} {
		tech_hachimon-2 "hero"
		lappend effects [list "hachimon-2" "hero" -1]
		if {[is_in "hachimon-1" $used]} {
		} else {
			lappend used "hachimon-1"
		}
		lappend used "hachimon-2"
		replace
		end_turn "hachimon-2"
	} elseif {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] < 40 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] < 20))} {
		no_chakra_message
	}
}
button .button_hachimon-3 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] > 59 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] > 39) || ([is_in "hachimon-2" $used] && [get_chakra "hero"] > 19)) && !([is_in "hachimon-3" $used])} {
		tech_hachimon-3 "hero"
		lappend effects [list "hachimon-3" "hero" -1]
		if {[is_in "hachimon-1" $used]} {
		} else {
			lappend used "hachimon-1"
		}
		if {[is_in "hachimon-2" $used]} {
		} else {
			lappend used "hachimon-2"
		}
		lappend used "hachimon-3"
		replace
		end_turn "hachimon-3"
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 60 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] < 40) || ([is_in "hachimon-2" $used] && [get_chakra "hero"] < 20)} {
		no_chakra_message
	}
}
button .button_hachimon-4 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && (([get_chakra "hero"] > 79 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] > 59) || ([is_in "hachimon-2" $used] && [get_chakra "hero"] > 39) || ([is_in "hachimon-3" $used] && [get_chakra "hero"] > 19)) && !([is_in "hachimon-4" $used]))} {
		tech_hachimon-4 "hero"
		lappend effects [list "hachimon-4" "hero" -1]
		if {[is_in "hachimon-1" $used]} {
		} else {
			lappend used "hachimon-1"
		}
		if {[is_in "hachimon-2" $used]} {
		} else {
			lappend used "hachimon-2"
		}
		if {[is_in "hachimon-3" $used]} {
		} else {
			lappend used "hachimon-3"
		}
		lappend used "hachimon-4"
		replace
		end_turn "hachimon-4"
	} elseif {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] < 80 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] < 60) || ([is_in "hachimon-2" $used] && [get_chakra "hero"] < 40) || ([is_in "hachimon-3" $used] && [get_chakra "hero"] < 20))} {
		no_chakra_message
	}
}
button .button_hachimon-5 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && (([get_chakra "hero"] > 99 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] > 79) || ([is_in "hachimon-2" $used] && [get_chakra "hero"] > 59) || ([is_in "hachimon-3" $used] && [get_chakra "hero"] > 39) || ([is_in "hachimon-4" $used] && [get_chakra "hero"] > 19)) && !([is_in "hachimon-5" $used]))} {
		tech_hachimon-5 "hero"
		lappend effects [list "hachimon-5" "hero" -1]
		if {[is_in "hachimon-1" $used]} {
		} else {
			lappend used "hachimon-1"
		}
		if {[is_in "hachimon-2" $used]} {
		} else {
			lappend used "hachimon-2"
		}
		if {[is_in "hachimon-3" $used]} {
		} else {
			lappend used "hachimon-3"
		}
		if {[is_in "hachimon-4" $used]} {
		} else {
			lappend used "hachimon-4"
		}
		lappend used "hachimon-5"
		replace
		end_turn "hachimon-5"
	} elseif {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] < 100 || ([is_in "hachimon-1" $used] && [get_chakra "hero"] < 80) || ([is_in "hachimon-2" $used] && [get_chakra "hero"] < 60) || ([is_in "hachimon-3" $used] && [get_chakra "hero"] < 40) || ([is_in "hachimon-4" $used] && [get_chakra "hero"] < 20))} {
		no_chakra_message
	}
}
button .button_hachimon-6 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] > 24) && ([is_in "hachimon-5" $used]) && !([is_in "hachimon-6" $used])} {
		tech_hachimon-6 "hero"
		lappend effects [list "hachimon-6" "hero" -1]
		lappend used "hachimon-6"
		replace
		end_turn "hachimon-6"
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 25} {
		no_chakra_message
	} elseif {[get_hitpoints "hero"] > 0 && ![is_in "hachimon-5" $used]} {
		hachimon_6_not_message
	}
}
button .button_hachimon-7 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] > 24) && ([is_in "hachimon-6" $used]) && !([is_in "hachimon-7" $used])} {
		tech_hachimon-7 "hero"
		lappend effects [list "hachimon-7" "hero" -1]
		lappend used "hachimon-7"
		replace
		end_turn "hachimon-7"
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 25} {
		no_chakra_message
	} elseif {[get_hitpoints "hero"] > 0 && ![is_in "hachimon-6" $used]} {
		hachimon_7_not_message
	}
}
button .button_hachimon-8 -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && ([get_chakra "hero"] > 49)  && ([is_in "hachimon-7" $used]) && !([is_in "hachimon-8" $used])} {
		hachimon_8_really_message
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 50} {
		no_chakra_message
	} elseif {[get_hitpoints "hero"] > 0 && ![is_in "hachimon-6" $used]} {
		hachimon_8_not_message
	}
}
button .button_shofu -state disabled -command {
	set q 0
	set l [get_location "hero"]
	set h [get_height "hero"]
	set e 1
	while {$e <= $enemy} {
		if {([get_location enemy$e] == $l) && ([get_height enemy$e] == $h)} {
			set q $e
			break
		}
		incr e
	}
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 9 && ($q > 0)} {
		end_turn "shofu" [get_tai "hero"]
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 10} {
		no_chakra_message
	}
}
button .button_omote-renge -state disabled -command {
	set q 0
	set l [get_location "hero"]
	set h [get_height "hero"]
	set e 1
	while {$e <= $enemy} {
		if {[get_hitpoints "hero"] > 0 && ([get_location enemy$e] == $l) && ([get_height enemy$e] == $h)} {
			set q $e
			break
		}
		incr e
	}
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 24 && ($q > 0) && [is_in "hachimon-1" $used]} {
		end_turn "omote-renge" [get_tai "hero"]
	} elseif {[get_hitpoints "hero"] > 0 && ![is_in "hachimon-1" $used]} {
		omote_not_message
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 25} {
		no_chakra_message
	}
}
button .button_ura-renge -state disabled -command {
	set q 0
	set l [get_location "hero"]
	set h [get_height "hero"]
	set e 1
	while {$e <= $enemy} {
		if {([get_location enemy$e] == $l) && ([get_height enemy$e] == $h)} {
			set q $e
			break
		}
		incr e
	}
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 24 && ($q > 0) && [is_in "hachimon-3" $used]} {
		end_turn "ura-renge" [get_tai "hero"]
	} elseif {[get_hitpoints "hero"] > 0 && ![is_in "hachimon-3" $used]} {
		ura_not_message
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 25} {
		no_chakra_message
	}
}
button .button_asakujaku -state disabled -command {
	set q 0
	set l [get_location "hero"]
	set h [get_height "hero"]
	set e 1
	while {$e <= $enemy} {
		if {([get_location enemy$e] >= $l) && ([get_height enemy$e] == $h)} {
			set q $e
			break
		}
		incr e
	}
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 99 && ($q > 0) && [is_in "hachimon-6" $used]} {
		end_turn "asakujaku" [get_tai "hero"]
	} elseif {[get_hitpoints "hero"] > 0 && ![is_in "hachimon-6" $used]} {
		asakujaku_not_message
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 100} {
		no_chakra_message
	}
}
button .button_hirudora -state disabled -command {
	set q 0
	set l [get_location "hero"]
	set h [get_height "hero"]
	set e 1
	while {$e <= $enemy} {
		if {([get_location enemy$e] >= $l) && ([get_height enemy$e] == $h)} {
			set q $e
			break
		}
		incr e
	}
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 199 && ($q > 0) && [is_in "hachimon-7" $used]} {
		end_turn "hirudora" [get_tai "hero"]
	} elseif {[get_hitpoints "hero"] > 0 && ![is_in "hachimon-7" $used]} {
		asakujaku_not_message
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 200} {
		no_chakra_message
	}
}
#Naruto
button .button_taju-kage-bunshin -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 49 && !([is_in "taju-kage-bunshin" $used]) && ![is_in [list "kyubi-1" "hero" -1] $effects]} {
		lappend effects [list "taju-kage-bunshin" "hero" [expr [get_nin "hero"] * 2]]
		tech_taju-kage-bunshin "hero"
		lappend used "taju-kage-bunshin"
		replace
		end_turn "taju-kage-bunshin"
	} elseif {[get_hitpoints "hero"] > 0 && [is_in [list "kyubi-1" "hero" -1] $effects]} {
		no_clones_in_kyubi_mode
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 50} {
		no_chakra_message
	}
}
button .button_kage-bunshin -state disabled -command {
	set q 0
	set l [get_location "hero"]
	set h [get_height "hero"]
	set e 1
	while {$e <= $enemy} {
		if {([get_location enemy$e] == $l) && ([get_height enemy$e] == $h)} {
			set q $e
			break
		}
		incr e
	}
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 9 && !([is_in "kage-bunshin" $used]) && ![is_in [list "kyubi-1" "hero" -1] $effects] && $q == 0} {
		tech_kage-bunshin "hero"
		lappend effects [list "kage-bunshin" "hero" [get_nin "hero"]]
		lappend used "kage-bunshin"
		replace
		end_turn "kage-bunshin"
	} elseif {[get_hitpoints "hero"] > 0 && [is_in [list "kyubi-1" "hero" -1] $effects]} {
		no_clones_in_kyubi_mode
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 10} {
		no_chakra_message
	}
}
button .button_kawarimi -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 9} {
		lappend effects [list "kawarimi" "hero" 1]
		end_turn "kawarimi"
		tech_kawarimi "hero"
		replace
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 10} {
		no_chakra_message
	}
}
button .button_kai -state disabled -command {
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 9} {
		end_turn "kai"
		tech_kai "hero"
		replace
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 10} {
		no_chakra_message
	}
}
button .button_futon-shinku-gyoku -state disabled -command {
	set q 0
	set l [get_location "hero"]
	set h [get_height "hero"]
	set e 1
	while {$e <= $enemy} {
		if {([get_location enemy$e] >= $l) && ([get_height enemy$e] == $h)} {
			set q $e
			break
		}
		
		incr e
	}
	if {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] > 19 && ($q > 0)} {
		end_turn "futon-shinku-gyoku" [get_nin "hero"]
	} elseif {[get_hitpoints "hero"] > 0 && [get_chakra "hero"] < 20} {
		no_chakra_message
	}
}
