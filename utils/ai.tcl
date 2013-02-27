proc hero_ai_agressive {} {
	global enemy hero_ancof
	set e 1
	set d 3000
	set n 1
	while {$e <= $enemy} {
		if {[dist "heroi" enemy$e] < $d} {
			set d [dist "heroi" enemy$e]
			set n $e
		}
		incr e
	}
	if {$enemy == 0} {
		if {[get_speed "hero"] > 0} {
			mov_ai "hero" "out"
		}
	} else {
		#n is closet enemy
		if {[get_speed "hero"] > 0 && [dist "heroi" enemy$n] > 0} {
			mov_ai "hero" enemy$n
		} elseif {[dist "heroi" enemy$n] < 0 && [get_speed "hero"] > 0 } {
			mov_ai "hero" "out"
		}
	}
}
proc dist {from to} {
	set x1 [getx $from]
	set y1 [gety $from]
	set x2 [getx $to]
	set y2 [gety $to]
	if {$x1 > 0 && $x1 < 1500 && $x2 > 0 && $x2 < 1500 && $y1 > 0 && $y1 < 800 && $y2 > 0 && $y2 < 1500} {
		return [expr abs($y2 - $y1) + abs($x2 - $x1)]
	} else {
		return -1
	}
}
proc mov_ai {who to} {
	global locations
	if {$to == "out"} {
		set l1 [get_location $who]
		set h1 [get_height $who]
		if {$l1 == 3} {
			move "hero" "right"
			end_turn "run" 0
			after 1000 {
				next_slide
			}
		}
		if {([lindex $locations [expr $l1 + 1]] == $h1) || ([lindex $locations [expr $l1 + 1]] == -$h1) || ([lindex $locations [expr $l1 + 1]] > 0)} {
			move "hero" "right"
			end_turn "run" 0
		} else {
			if {(([lindex $locations $l1] != $h1) || ([lindex $locations $l1] != -$h1))} {
				move "hero" "up"
				end_turn "run" 2
			} elseif {([lindex $locations [expr $l1 - 1]] == $h1) || ([lindex $locations [expr $l1 - 1]] == -$h1)} {
				move "hero" "left"
				end_turn "run" 1
			} else {
				end_turn
			}
		}
	} else {
		set k 0
		set l1 [get_location $who]
		set h1 [get_height $who]
		set l2 [get_location $to]
		set h2 [get_height $to]
		if {$l1 < $l2} {
			if {([lindex $locations [expr $l1 + 1]] == $h1) || ([lindex $locations [expr $l1 + 1]] == -$h1) || ([lindex $locations [expr $l1 + 1]] > 0)} {
				move $who "right"
				set k 0
			} else {
				if {($h1 < $h2) && (([lindex $locations $l1] != $h1) || ([lindex $locations $l1] != -$h1))} {
					move $who "up"
					set k 2 
				} elseif {([lindex $locations [expr $l1 - 1]] == $h1) || ([lindex $locations [expr $l1 - 1]] == -$h1)} {
					move $who "left"
					set k 1
				} else {
				}
			}
		}
		if {$l1 == $l2} {
			if {$h1 == $h2} {
				set k -1
			} elseif {([lindex $locations $l1] != $h1) && ([lindex $locations $l1] != -$h1)} {
				move $who "up"		
				set k 2
			} else {
				if {($l1 < $l2) && (([lindex $locations [expr $l1 + 1]] == $h1) || ([lindex $locations [expr $l1 + 1]] == -$h1))} {
					move $who "right"
					set k 0
				} elseif {([lindex $locations [expr $l1 - 1]] == $h1) || ([lindex $locations [expr $l1 - 1]] == -$h1)} {
					move $who "left"
					set k 1
				} else {
				}
			}
		}
		if {$l1 > $l2} {
			if {([lindex $locations [expr $l1 - 1]] == $h1) || ([lindex $locations [expr $l1 - 1]] == -$h1) || ([lindex $locations [expr $l1 - 1]] > 0)} {
				move $who "left"
				set k 1
			} else {
				if {($h1 < $h2) && (([lindex $locations $l1] != $h1) || ([lindex $locations $l1] != -$h1))} {
					move $who "up"
					set k 2
				} elseif {([lindex $locations [expr $l1 + 1]] == $h1) || ([lindex $locations [expr $l1 + 1]] == -$h1)} {
					move $who "right"
					set k 0
				} else {
				}
			}
		}
		if {$who == "hero"} {
			if {$k < 0} {
				end_turn
			} else {
				end_turn "run" $k
			}
		} 
	}
}
proc major_ai {tech p} {
	global ai_type enemy effects
	if {![is_in [list "endgame" "hero" 0] $effects]} {
		set e 1
		while {$e <= $enemy} {
			set n [get_name enemy$e]
			set c [get_chakra enemy$e]
			if {$c > 0} {
				.c move enemy$e [expr -10*($enemy - 2)] 0
				if {$ai_type == "special"} {
					special_[set n]_ai $e $tech $p
				}
				if {$ai_type == "normal"} {
					if {[is_bonus $tech]} {
						set tech "none"
						set p 0
					}
					standart_ai $e $tech $p
				}
				if {$ai_type == "high"} {
					if {[is_bonus $tech]} {
						set l [bonus_tech_ai $e]
					} else {
						standart_ai $e $tech $p
					}
				}
				.c move enemy$e [expr 10*($enemy - 2)] 0
			}
			incr e
		}
	}
}
proc standart_ai {num tech p} {
	set en [get_nin enemy$num]
	set et [get_tai enemy$num]
	set es [get_speed enemy$num]
	set on [get_nin hero]
	if {$on < 1} {
		set on 1
		set tech "busy"
	}
	set ot [get_tai hero]
	set os [get_speed hero]
	set emkof [expr sqrt($et*$es)]
	set erkof [expr sqrt($en*$es*$es)]
	set omkof [expr sqrt($ot*$os)]
	set orkof [expr sqrt($on*$os*$os)]
	set l {}
	if {$tech == "busy"} {
		if {[get_height hero] == [get_height enemy$num] && [get_location hero] == [get_location enemy$num]} {
			set l [melee_tech_ai $num]
		} else {
			if {[get_height hero] == [get_height enemy$num] && [get_location hero] < [get_location enemy$num]} {
				set l [ranged_tech_ai $num]
			} else {
				mov_ai enemy$num "hero"
			}	
		}
	} elseif {[expr $emkof - $omkof] > [expr $erkof - $orkof]} {
	#melee battle is recommended
		if {[get_height hero] == [get_height enemy$num] && [get_location hero] == [get_location enemy$num]} {
			set l [melee_tech_ai $num]
		} else {
			if {$tech == "run" && $p != 2} {
				if {[dist "heroi" enemy$num] > 360} {
					mov_ai enemy$num "hero"
				} else {
					set l [bonus_tech_ai $num]
				}
			} else {
				mov_ai enemy$num "hero"
			}
		}
	} else {
	#ranged battle is recommended
		if {[get_height hero] == [get_height enemy$num] && [get_location hero] != [get_location enemy$num]} {
			if {$tech == "run"} {
				if {[dist "heroi" enemy$num] > 360 && [get_location hero] < [get_location enemy$num]} {
					set l [ranged_tech_ai $num]
				} else {
					bonus_tech_ai $num
				}
			} else {
				if {[get_location hero] < [get_location enemy$num]} {
					set l [ranged_tech_ai $num]
				} else {
					mov_ai enemy$num "hero"
				} 
			}
		} else {
			if {[get_height hero] == [get_height enemy$num]} {
				if {[is_melee $tech]} {
					#have`nt time to run
					set t 0
				} else {
					set t [try_retreat $num]
				}
				if {$t == 0} {
					set l [melee_tech_ai $num]
				}
			} else {
				if {abs([get_height hero] - [get_height enemy$num]) == 1} {
					set l [bonus_tech_ai $num]
				} else {
					mov_ai enemy$num "hero"
				}
			}
		}		
	}
	if {[llength $l] == 0 && $tech != "run" && $tech != "none" && $tech != "busy"} {
		if {[is_ranged $tech] && [get_height hero] == [get_height enemy$num]} {
			ranged_tech "hero" enemy$num $tech $p "none" 0
		} elseif {[is_melee $tech] && [get_height hero] == [get_height enemy$num] && [get_location hero] == [get_location enemy$num]} {
			melee_tech "hero" enemy$num $tech $p "attack" [get_tai enemy$num]
		}
	}
	if {[lindex $l 0] == "kunai" || [lindex $l 0] == "attack"} {
		set tmo 1000
	} else {
		set tmo 0
	}
	if {[llength $l] != 0 && $tech == "busy"} {
		if {[is_ranged [lindex $l 0]]} {
			after $tmo "ranged_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
		} elseif {[is_melee [lindex $l 0]]} {
			after $tmo "melee_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
		}
	} elseif {[llength $l] != 0 && $tech != "run" && $tech != "none"} {
		if {[is_ranged [lindex $l 0]] && [is_ranged $tech]} {
			ranged_tech "hero" enemy$num $tech $p [lindex $l 0] [lindex $l 1]
		} elseif {[is_ranged [lindex $l 0]] && ![is_ranged $tech]} {
			if {[dist "heroi" enemy$num] < 360} {
				ranged_tech enemy$num "hero" [lindex $l 0] [lindex $l 1] "none" 0
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
			if {[is_melee [lindex $l 0]] && [lindex $l 0] != "attack"} {
				after $tmo "melee_tech enemy$num hero [lindex $l 0] [lindex $l 1] none 0"
			} elseif {[is_melee [lindex $l 0]]} {
				after $tmo "ranged_tech enemy$num hero kunai [get_speed enemy$num] none 0"
			}
		}
	}
}
proc bonus_tech_ai {num} {
	global bonuslist effects 
	set priory $bonuslist
	set l [get_skills enemy$num]
	set c [get_chakra enemy$num]
	set t 0
	set i 1
	foreach p $priory {
		if {[is_in $p $l] && ![is_in [list $p enemy$num -1] $effects]} {
			if {$c > [enciclopedia $p "chakra"]} {
				set t $i
				break
			}
		}
		incr i
	}
	if {$t == 0} {
		if {[get_height hero] == [get_height enemy$num] && [dist "heroi" enemy$num] < 360 && [dist "heroi" enemy$num] > 60 && [get_location hero] < [get_location enemy$num]} {
			return [list "kunai" [get_speed enemy$num]]
		} elseif {[get_height hero] == [get_height enemy$num] && [dist "heroi" enemy$num] < 60} {
			return [list "attack" [get_tai enemy$num]]
		} else {
			mov_ai enemy$num "hero"
			return [list]
		}		
	} else {
		incr t -1
		if {[lindex $priory $t] == "kawarimi" && ([get_height hero] > [get_height enemy$num] || ([get_height hero] < [get_height enemy$num] && [get_location hero] != [get_location enemy$num]))} {
			mov_ai enemy$num "hero"
		} else {
		tech_[lindex $priory $t] enemy$num
		lappend effects [list [lindex $priory $t] enemy$num [enciclopedia [lindex $priory $t] "number"]]
		replace
		}
		return [list]
	}
}
proc melee_tech_ai {num} {
	global meleelist
	set priory $meleelist
	set l [get_skills enemy$num]
	set c [get_chakra enemy$num]
	set t 0
	set i 1
	foreach p $priory {
		if {[is_in $p $l]} {
			if {$c > [enciclopedia $p "chakra"]} {
				set t $i
				break
			}
		}
		incr i
	}
	if {$t == 0} {
		if {[get_height hero] == [get_height enemy$num] && [dist "heroi" enemy$num] < 60} {
			return [list "attack" [get_tai enemy$num]]
		} else {
			return [list]
		}
	} else {
		incr t -1
		if {[is_ninjitsu [lindex $priory $t]]} {
			return [list [lindex $priory $t] [get_nin enemy$num]]
		}
		if {[is_taijitsu [lindex $priory $t]]} {
			return [list [lindex $priory $t] [get_tai enemy$num]]
		}
		if {[is_genjitsu [lindex $priory $t]]} {
			return [list [lindex $priory $t] [get_gen enemy$num]]
		}
	}
}
proc ranged_tech_ai {num} {
	global rangedlist
	#hirudora and asakujaku is in both lists
	set priory $rangedlist
	set l [get_skills enemy$num]
	set c [get_chakra enemy$num]
	set t 0
	set i 1
	foreach p $priory {
		if {[is_in $p $l]} {
			if {$c > [enciclopedia $p "chakra"]} {
				set t $i
				break
			}
		}
		incr i
	}
	if {$t == 0} {
		if {[get_height hero] == [get_height enemy$num] && [dist "heroi" enemy$num] < 360 && [dist "heroi" enemy$num] > 60 && [get_location hero] < [get_location enemy$num]} {
			return [list "kunai" [get_speed enemy$num]]
		} elseif {[get_height hero] == [get_height enemy$num] && [dist "heroi" enemy$num] < 60} {
			return [list "attack" [get_tai enemy$num]]
		} else {
			mov_ai enemy$num "hero"
			return [list]
		}			
	} else {
		incr t -1
		puts "[lindex $priory $t] technic!"
		if {[is_ninjitsu [lindex $priory $t]]} {
			return [list [lindex $priory $t] [get_nin enemy$num]]
		}
		if {[is_taijitsu [lindex $priory $t]]} {
			return [list [lindex $priory $t] [get_tai enemy$num]]
		}
		if {[is_genjitsu [lindex $priory $t]]} {
			return [list [lindex $priory $t] [get_gen enemy$num]]
		}
	}
}
proc have_in {loc h} {
	global enemy
	set e 1
	set r 0
	while {$e <= $enemy} {
		if {[get_location enemy$e] == $loc && [get_height enemy$e] == $h} {
			set r 1
		}
		incr e
	}
	return $r
}
proc try_retreat {num} {
	global locations
	set l1 [get_location enemy$num]
	set h1 [get_height enemy$num]
	set l2 [get_location hero]
	set h2 [get_height hero]
	if {$h1 == $h2} {
		if {$l1 < $l2 && $l1 > 0} {
			set l [lindex $locations [expr $l1 - 1]]
			if {(abs($l) == $h1 || ($l>0) || ($h1 > abs($l))) && ![have_in [expr $l1 - 1] $h1]} {
				move enemy$num "left"
				return 1
			}
		} elseif {$l1 >= $l2 && $l1 < 3} {
			set l [lindex $locations [expr $l1 + 1]]
			if {(abs($l) == $h1 || ($l>0) || ($h1 > abs($l))) && ![have_in [expr $l1 + 1] $h1]} {
				move enemy$num "right"
				return 1
			}
		} else {
			set l [lindex $locations $l1]
			if {$l1 != $l2 && $l > $h1 && ![have_in $l1 [expr $h1 + 1]]} {
				move enemy$num "up"
				return 1
			} else {
				return 0
			}
		}
	} else {
		if {$l1 < $l2 && $l1 > 0} {
			set l [lindex $locations [expr $l1 - 1]]
			if {(abs($l) == $h1 || ($l>0) || ($h1 > abs($l))) ![have_in [expr $l1 - 1] $h1]} {
				move enemy$num "left"
				return 1
			}
		} elseif {$l1 >= $l2 && $l1 < 3} {
			set l [lindex $locations [expr $l1 + 1]]
			if {(abs($l) == $h1 || ($l>0) || ($h1 > abs($l))) ![have_in [expr $l1 + 1] $h1]} {
				move enemy$num "right"
				return 1
			}
		} else {
			set l [lindex $locations $l1]
			if {$l1 != $l2 && $l > $h1 && ![have_in $l1 [expr $h1 + 1]]} {
				move enemy$num "up"
				return 1
			} else {
				if {$l1 < $l2} {
					set l [lindex $locations [expr $l1 + 1]]
					if {(abs($l) == $h1 || ($l>0) || ($h1 > abs($l))) && ![have_in [expr $l1 + 1] $h1]} {
						move enemy$num "right"
						return 1
					}
				} else {
					set l [lindex $locations [expr $l1 - 1]]
					if {(abs($l) == $h1 || ($l>0) || ($h1 > abs($l))) && ![have_in [expr $l1 + 1] $h1]} {
						move enemy$num "left"
						return 1
					}
				}
			}
		}
	}
	return 0
}
