#imageworking
proc get_image {im from {class "norm"} {tag "hero"}} {
	if {$class == "run"} {
		if {[get_speed $tag] > 0} {
			image create photo $im -file $from
		}
	} else {
		image create photo $im -file $from
	} 
}
set leeskillist [list "konoha-senpu" "shofu" "konoha-dai-senpu" "omote-renge" "ura-renge" "konoha-goriki-senpu" "tsuten-kyaku" "asakujaku" "hirudora" "konoha-congoriki-senpu" "suiken" "hachimon-1" "hachimon-2" "hachimon-3" "hachimon-4" "hachimon-5" "hachimon-6" "hachimon-7" "hachimon-8"]
foreach s $leeskillist {
	get_image skill_$s [file join $mydir images skills lee $s.gif]
}
set tentenskillist [list "kawarimi" "kuchiese-kusarigama" "soshuga" "raiko-kenka" "kuchiese-meisu" "soshoryu"]
foreach s $tentenskillist {
	get_image skill_$s [file join $mydir images skills tenten $s.gif]
}
set guiskillist [list "kai" "kibakufuda" "kage-bunshin" "kuchiese-ninkame" "tengoku-no-kuchiese"]
foreach s $guiskillist {
	get_image skill_$s [file join $mydir images skills gui $s.gif]
}
get_image cross [file join $mydir images skills cross.gif]
get_image aceptbutton [file join $mydir images skills acept.gif]
proc create_skillpanel {} {
	global mydir
	get_image emptyskillpanel [file join $mydir images skills standart.gif]
	.c create image 512 288 -image emptyskillpanel -tag phon
	.c create image 225 200 -image individualpanel -tag skills
	.c create image 600 310 -image accesspanel -tag skills
}
proc skillmessage {} {
	global mydir
	get_image mess [file join $mydir images skills information message.gif]
	catch {
		destroy .m
	}
	toplevel .m
	wm title .m {Choose new skill!}
	wm geometry .m 400x300
	wm maxsize .m 400 300
	wm minsize .m 400 300
	canvas .m.c -height 300 -width 400 -bg black
	.m.c create image 200 150 -image mess -tag infa
	pack .m.c -side top
	bind .m.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .m
		}			
	}	
}
proc victory_image {} {
	global mydir 
	get_image win [file join $mydir images win.gif]
	.c create image 512 288 -image win
}
proc skillinfo {title image {dam 0} {much 0} {access 0}} {
	global mydir campdir newskill
	set newskill $image
	get_image infa [file join $mydir images skills information $image.gif]
	catch {
		destroy .i
	}
	toplevel .i
	wm title .i $title
	wm geometry .i 400x300
	wm maxsize .i 400 300
	wm minsize .i 400 300
	canvas .i.c -height 300 -width 400 -bg black
	.i.c create image 200 150 -image infa -tag infa
	pack .i.c -side top
	if {$dam != 0} {
		.i.c create text 317 10 -text $dam -tag infa
		.i.c create text 337 10 -text $much -tag infa
	}
	if {$access > 0} {
		.i.c create image 335 40 -image aceptbutton -tag infa
		bind .i.c <ButtonPress> {
			if {[object_in %x %y 320 272 125 25]} {
				destroy .i
			}
			if {[object_in %x %y 335 40 125 25]} {
				addskill
				.c delete phon
				.c delete skills
				begin
				destroy .i
			}			
		}
	} else {
		bind .i.c <ButtonPress> {
			if {[object_in %x %y 320 272 125 25]} {
				destroy .i
			}
		}
	}	
	if {$access < 0} {
		get_image infa [file join $mydir images skills information $image-n.gif]
	}
	
}
proc breefing {} {
	global campdir missionnumber slide enemy
	set slide 1
	set enemy 0
	get_image phonimage [file join $campdir breefings $missionnumber.gif]
	.c create image 512 288 -image phonimage -tag phon
	bind .c <ButtonPress> {
		if {[object_in %x %y 800 50 200 70]} {
			slide_1
			major_hero 50 520
			create_battlepanel
		}
	}
}
proc scenery_message {str} {
	global campdir missionnumber slide
	catch {
		destroy .m
	}
	get_image mess [file join $campdir messages $missionnumber-$slide.gif]
	toplevel .m
	wm title .m $str
	wm geometry .m 400x300
	wm maxsize .m 400 300
	wm minsize .m 400 300
	canvas .m.c -height 300 -width 400 -bg black
	.m.c create image 200 150 -image mess -tag infa
	pack .m.c -side top
	bind .m.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .m
		}			
	}	
}
proc replic {name {t 2000}} {
	global campdir missionnumber
	get_image rep [file join $campdir messages $missionnumber-$name.gif]
	.c create image 512 225 -image rep -tag rep
	after $t ".c delete rep"
}
proc phon {number} {
	global campdir missionnumber
	get_image phonimage [file join $campdir land $missionnumber-$number.gif]
}
proc create_battlepanel {} {
	global heroname mydir enemy slide skills
	get_image battlepanel [file join $mydir images skills battlepanel.gif]
	get_image heroportrait [file join $mydir images heroes $heroname face.gif]
	.c create image 512 100 -image battlepanel -tag panel
	.c create image 26 26 -image heroportrait -tag panel
	.c create text 175 12 -text [get_hitpoints "hero"] -tag stat
	.c create text 175 37 -text [get_chakra "hero"] -tag stat
	.c create text 200 67 -text [get_tai "hero"] -tag stat
	.c create text 200 100 -text [get_nin "hero"] -tag stat
	.c create text 200 131 -text [get_gen "hero"] -tag stat
	.c create text 200 162 -text [get_speed "hero"] -tag stat
	create_hitpoints "hero"
	create_chakra "hero"
	set e 1
	while {$e <= $enemy} {
		if {[get_name enemy$e] != "trap"} {
			get_image face$e [file join $mydir images heroes [get_name enemy$e] face.gif]
			.c create image 679 [expr 26 + 51*($e-1)] -image face$e -tag stat
			create_hitpoints enemy$e
			create_chakra enemy$e
		}
		incr e
	}
	set x 275
	set y 75
	foreach s $skills {
		if {[enciclopedia $s chakra] != 0} {
			.c create image $x $y -image skill_$s -tag panel
			incr x 45
		}
		if {$x > 550} {
			set x 275
			incr y 45
		}
	}
	bind .c <ButtonPress> {
		click_in_game %x %y
	}
	bind . <Right> {
		.right invoke
	}
	bind . <Left> {
		.left invoke
	}
	bind . <Up> {
		.jump invoke
	}
	bind . <space> {
		.stand invoke
	}
	if {$slide == 1} {
		unblock_battlepanel
	}
}
proc click_in_game {ex ey} {
	global mydir skills
	if {[object_in $ex $ey 625 25 50 50]} {
		clear
		pack forget .c 
		source [file join $mydir menu.tcl]
	}
	if {[object_in $ex $ey 525 25 50 50]} {
		.stand invoke
	}
	if {[object_in $ex $ey 470 25 50 50]} {
		.right invoke
	}
	if {[object_in $ex $ey 415 25 50 50]} {
		.jump invoke
	}
	if {[object_in $ex $ey 360 25 50 50]} {
		.left invoke
	}	
	set x 275
	set y 75
	foreach s $skills {
		if {[enciclopedia $s chakra] != 0} {
			if {[object_in $ex $ey $x $y 45 45]} {
				.button_$s invoke
			}
			incr x 45
		}
		if {$x > 550} {
			set x 275
			incr y 45
		}
	}
}
proc create_hitpoints {class} {
	global [set class] enemy
	set h [lindex [set [set class]] 1]
	if {$class == "hero"} {
		set x 51
		set y 0
	} else {
		set e 1
		while {$e <= $enemy} {
			if {$class == "enemy$e"} {
				break
			}
			incr e
		}
		set x 705
		set y [expr ($e - 1) * 52]
	}
	if {$h < 0} {
	} elseif {$h < 101} {
	#red pointline
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr ($h % 101) + $x] [expr $y + 25] [expr ($h % 101) + $x]  [expr $y + 1] -fill red -tag hit_panel
	}
	if {$h > 100 && $h < 201} {
		#green pointline
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr 101 + $x] [expr $y + 25] [expr 101 + $x]  [expr $y + 1] -fill red -tag hit_panel
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr ($h % 101) + $x] [expr $y + 25] [expr ($h % 101) + $x]  [expr $y + 1] -fill green -tag hit_panel
	}
	if {$h > 200} {
		#darkgreen pointline
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr 101 + $x] [expr $y + 25] [expr 101 + $x]  [expr $y + 1] -fill green -tag hit_panel
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr ($h % 101) + $x] [expr $y + 25] [expr ($h % 101) + $x]  [expr $y + 1] -fill darkgreen -tag hit_panel
	}
}
proc create_chakra {class} {
	global [set class] enemy
	set c [lindex [set [set class]] 2]
	if {$class == "hero"} {
		set x 51
		set y 25
	} else {
		set e 1
		while {$e <= $enemy} {
			if {$class == "enemy$e"} {
				break
			}
			incr e
		}
		set x 705
		set y [expr 25 + ($e - 1) * 52]
	}
		#cyan pointline
		if {$c < 101} {
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr ($c % 101) + $x] [expr $y + 25] [expr ($c % 101) + $x]  [expr $y + 1] -fill cyan -tag chakra_panel
		}
		if {$c > 100 && $c < 201} {
		#blue pointline
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr 101 + $x] [expr $y + 25] [expr 101 + $x]  [expr $y + 1] -fill cyan -tag chakra_panel
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr ($c % 101) + $x] [expr $y + 25] [expr ($c % 101) + $x]  [expr $y + 1] -fill blue -tag chakra_panel
		}
		if {$c > 200 && $c < 401} {
		#violet pointline
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr 101 + $x] [expr $y + 25] [expr 101 + $x]  [expr $y + 1] -fill blue -tag chakra_panel
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr ($c % 201)/2 + $x] [expr $y + 25] [expr ($c % 201)/2 + $x]  [expr $y + 1] -fill violet -tag chakra_panel
		}
		if {$c > 400} {
		#magenta pointline
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr 101 + $x] [expr $y + 25] [expr 101 + $x]  [expr $y + 1] -fill violet -tag chakra_panel
		.c create polygon [expr $x + 1] [expr $y + 1] [expr $x + 1] [expr $y + 25] [expr ($c % 401)/4 + $x] [expr $y + 25] [expr ($c % 401)/4 + $x]  [expr $y + 1] -fill magenta -tag chakra_panel
		}
}
proc replace {} {
	global enemy mydir skills used
	.c delete cross
	.c delete hit_panel
	.c delete chakra_panel
	.c delete stat
	.c create text 175 12 -text [get_hitpoints "hero"] -tag stat
	.c create text 175 37 -text [get_chakra "hero"] -tag stat
	.c create text 200 67 -text [get_tai "hero"] -tag stat
	.c create text 200 100 -text [get_nin "hero"] -tag stat
	.c create text 200 131 -text [get_gen "hero"] -tag stat
	.c create text 200 162 -text [get_speed "hero"] -tag stat
	create_hitpoints "hero"
	create_chakra "hero"
	set e 1
	while {$e <= $enemy} {
		if {[get_name enemy$e] != "trap"} {
			create_hitpoints enemy$e
			create_chakra enemy$e
			get_image face$e [file join $mydir images heroes [get_name enemy$e] face.gif]
			.c create image 679 [expr 26 + 51*($e-1)] -image face$e -tag stat
			.c raise panelenemy$e
		}
		incr e
	}
	set x 275
	set y 75
	foreach s $skills {
		if {[is_in $s $used]} {
			.c create image $x $y -image cross -tag cross 
		}
		if {[enciclopedia $s chakra] != 0} {
			incr x 45
		}
		if {$x > 550} {
			set x 275
			incr y 45
		}
	}
}
proc stand_animation {tag im {s 0}} {
	global hero_ancof mydir slide
	if {$tag == "heroi"} {
		if {$hero_ancof} {
			set hero_ancof [expr $hero_ancof + 1]
			if {$hero_ancof == 5} {
				set hero_ancof 1
			}
			get_image heroi [file join $mydir images heroes $im stand $hero_ancof.gif]
			after 150 "stand_animation $tag $im $s"			
		} else {
			get_image heroi [file join $mydir images heroes $im stand 1.gif]
		}
	} else {
		global [set tag]_ancof
		if {[set [set tag]_ancof]} {
			set [set tag]_ancof [expr [set [set tag]_ancof] + 1]
			if {[set [set tag]_ancof] == 5} {
				set [set tag]_ancof 1
			}
			get_image [set tag] [file join $mydir images heroes $im stand [set [set tag]_ancof].gif]
			if {$s == $slide} {
				after 150 "stand_animation $tag $im $s"	
			}		
		} else {
			if {[get_hitpoints $tag] > 0 && $s == $slide} {
				after 150 "stand_animation $tag $im $s"
			}
		}
	}
}
proc block_animation {tag im} {
	global mydir hero_ancof
	set hero_ancof 0
	get_image $tag [file join $mydir images heroes $im block 1.gif]	
	after 100 "get_image $tag [file join $mydir images heroes $im block 2.gif]"
	after 200 "get_image $tag [file join $mydir images heroes $im block 3.gif]"
	after 800 "get_image $tag [file join $mydir images heroes $im block 4.gif]"
	after 900 "get_image $tag [file join $mydir images heroes $im stand 1.gif]"
}
proc wound_animation {tag im {type "normal"}} {
	global mydir hero_ancof
	if {$tag == "heroi"} {
		set hero_ancof 0
	} else {
		global [set tag]_ancof
		set [set tag]_ancof 0
	}
	set i 1
	set t 0
	while {$t < 800 && ($type != "fast" || $t < 400)} {
		after $t "get_image $tag [file join $mydir images heroes $im wound $i.gif]"
		if {$type == "fast"} {
			incr t 50
		} else {
			incr t 100
		}
		incr i
	}
}
proc concentrate_chakra {tag im} {
	global mydir hero_ancof
	set t 0
	set i 1
	while {$t < 1000} {
		after $t "get_image $tag [file join $mydir images heroes $im chakra $i.gif]"	
		incr t 100
		incr i 
	}
}
proc clon-pufff {tag im} {
	global mydir
	set t 100
	set i 1
	while {$t < 1000} {
		if {$i < 8} {
			after $t "get_image $tag [file join $mydir images heroes $im clon-pufff $i.gif] run $tag"	
		} else {
			after $t "get_image $tag [file join $mydir images heroes $im clon-pufff $i.gif]"
		}
		incr t 100
		incr i 1
	}
}
proc die {class} {
	global mydir hero_ancof
	if {$class == "hero"} {
		set tag "heroi"
		set hero_ancof 0
		after 2000 "
			clear
			pack forget .c 
			source [file join $mydir menu.tcl]
		"
	} else {
		set tag $class
		set [set class]_ancof 0
	}
	if {[get_name $class] == "trap"} {
		.c delete $tag
	} else {
		block_battlepanel
		set t 0
		set i 1
		set im [get_name $class]
		while {$t < 700} {
			if {$im != "trap"} {
				after $t "get_image [set tag] [file join $mydir images heroes $im wound $i.gif]"
			}
			incr t 100
			incr i
		}
		after 2000 {unblock_battlepanel}
		after 2000 ".c delete $tag"
	}
}
proc teleport_out {im num} {
	global enemy herolevel mydir bonus
	set tag "enemy$num"
	set_hitpoints enemy$num 0
	block_battlepanel
	set t 0
	set i 1
	while {$t <= 500} {
		if {$im != "trap"} {
			after $t "get_image [set tag] [file join $mydir images heroes $im teleport $i.gif]"
		}
		incr t 100
		incr i
	}
	after $t {unblock_battlepanel}
	after $t ".c delete $tag
	.c delete panel$tag"
	if {$num != $enemy} {
#last enemy to empty place
		set enemy$num [set enemy$enemy]
		after $t ".c addtag enemy$num withtag enemy$enemy
		.c dtag enemy$enemy
		.c itemconfigure enemy$num  -image enemy$num
		enemy$num copy enemy$enemy"
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
proc traectory {x y vector image user} {
	global mydir
	set r [expr rand()*100]
	get_image image_$r [file join $mydir images attacks $image t0.gif]
	.c create image $x $y -image image_$r -tag tag_$r

	set ax 0
	set ay 0
	if {abs($vector) < 9} {
		set d [expr ($vector/abs($vector))*((abs($vector) / 3) + 1)]
		set ax [expr 10 * $vector]
		set ay 10
	}
	#vector 10 is 90
	if {abs($vector) == 10} {
		set d [expr 4*($vector/abs($vector))]
		set ax 45
		set ay 0
	}
	after 50 "get_image image_$r [file join $mydir images attacks $image t$d.gif]"
	set t 100
	while {$t <= 550} {
		after $t "if_delete tag_$r $user
		.c move tag_$r $ax $ay"
		incr t 20
	}
	after 650 ".c delete tag_$r"
}
proc if_delete {tag owner} {
	global enemy
	if {$owner == "hero"} {
		set e 1
		while {$e <= $enemy} {
			if {[object_in [getx $tag] [gety $tag] [getx enemy$e] [gety enemy$e] 50 50]} {
				.c delete $tag
			}
			incr e 1
		}
	} else {
		if {[object_in [getx $tag] [gety $tag] [getx "heroi"] [gety "heroi"] 50 50]} {
			.c delete $tag
		}
	}
	if {[gety $tag] > 550} {
		.c delete $tag
	}
}
proc kawarimi_teleport {tag im} {
	global locations mydir
	if {$tag == "heroi"} {
		set l [get_location "hero"]
		set h [get_height "hero"]
		if {$l > 0} {
			set le [lindex $locations [expr $l - 1]]
			if {abs($le) == $h || ($h < $le)} {
				after 600 ".c move $tag -300 0"
			} elseif {$le < $h} {
				set d [expr ($h - $le) * 100]
				after 600 ".c move $tag -300 $d"
			} else {
				if {$h < [lindex $locations $l]} {
					after 600 ".c move $tag 0 -100"
				} else {
					set le [lindex $locations [expr $l + 1]]
					if {abs($le) == $h || ($h < $le)} {
						after 600 ".c move $tag 300 0"
					} else {
						set d [expr ($h - $le) * 100]
						after 600 ".c move $tag 300 $d"
					}
				}
			}
		} else {
			if {$h < [lindex $locations $l]} {
				after 600 ".c move $tag 0 -100"
			} else {
				set le [lindex $locations [expr $l + 1]]
				if {abs($le) == $h || ($h < $le)} {
					after 600 ".c move $tag 300 0"
				} else {
					set d [expr ($h - $le) * 100]
					after 600 ".c move $tag 300 $d"
				}
			}
		}
	} else {
		set l [get_location $tag]
		set h [get_height $tag]
		if {$l < 3} {
			set le [lindex $locations [expr $l + 1]]
			if {abs($le) == $h || ($h < $le)} {
				after 600 ".c move $tag 300 0"
			} elseif {$le < $h} {
				set d [expr ($h - $le) * 100]
				after 600 ".c move $tag 300 $d"
			} else {
				if {$h < [lindex $locations $l]} {
					after 600 ".c move $tag 0 -100"
				} else {
					set le [lindex $locations [expr $l - 1]]
					if {abs($le) == $h || ($h < $le)} {
						after 600 ".c move $tag -300 0"
					} else {
						set d [expr ($h - $le) * 100]
						after 600 ".c move $tag -300 $d"
					}
				}
			}
		} else {
			if {$h < [lindex $locations $l]} {
				after 600 ".c move $tag 0 -100"
			} else {
				set le [lindex $locations [expr $l - 1]]
				if {abs($le) == $h || ($h < $le)} {
					after 600 ".c move $tag -300 0"
				} else {
					set d [expr ($h - $le) * 100]
					after 600 ".c move $tag -300 $d"
				}
			}
		}
	}
	set t 100
	set i 6
	while {$t <= 1000} {
		after $t "get_image $tag [file join $mydir images heroes $im kawarimi $i.gif]"	
		incr t 100
		incr i 
	}
}
proc teleport {who x y} {
	if {$who == "hero"} {
		set tag "heroi"
	} else {
		set tag $who
	}
	set xx [getx $tag]
	set yy [gety $tag]
	after 100 ".c move $tag [expr $x - $xx] [expr $y - $yy]"
	set im [get_name $who]
	set t 100
	set i 11
	while {$i <= 15} {
		after $t "get_image $tag [file join $mydir images heroes $im kawarimi $i.gif]"	
		incr t 100
		incr i 
	}
}
#heroes
proc rock_lee {x y} {
	global mydir hero_ancof
	set hero_ancof 1
	get_image heroi [file join $mydir images heroes lee stand 1.gif]
	.c create image $x $y -image heroi -tag heroi
	.c raise heroi
}
proc lee_1 {x y} {
	rock_lee $x $y
}
proc lee_2 {x y} {
	rock_lee $x $y
}
proc chunin_rock_lee {x y} {
	global mydir hero_ancof
	set hero_ancof 1
	get_image heroi [file join $mydir images heroes lee-adult stand 1.gif]
	.c create image $x $y -image heroi -tag heroi
	.c raise heroi
}
proc lee-adult_3 {x y} {
	chunin_rock_lee $x $y
}
#enemy
proc lumber {x y} {
	global mydir enemy
	get_image enemy$enemy [file join $mydir images heroes lumber stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
}
proc genin_from_robber {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes genin-robber stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-robber" $slide
}
proc genin_from_sound {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes genin-sound stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-sound" $slide
}
proc genin_armmaster_from_robber {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes genin-robber-armmaster stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-robber-armmaster" $slide
}
proc genin_armmaster_from_sound {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes genin-sound-armmaster stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-sound-armmaster" $slide
}
proc chunin_from_sound {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes chunin-sound stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "chunin-sound" $slide
}
#personal
proc genin_tenten {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes tenten stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "tenten" $slide
}
proc chunin_tenten {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes tenten-adult stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "tenten-adult" $slide
}
proc jonin_might_guy {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	get_image enemy$enemy [file join $mydir images heroes gui stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "gui" $slide
}
#tech
proc suiken_not_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information suiken_not.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You can`t use Suiken!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc omote_not_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information omote_not.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You can`t use Omote Renge!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc ura_not_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information ura_not.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You can`t use Ura Renge!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc hachimon_6_not_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information hachimon_6_not.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You can`t release Sixth Sky Gate!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc hachimon_7_not_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information hachimon_7_not.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You can`t release Seventh Sky Gate!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc hachimon_8_not_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information hachimon_8_not.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You can`t release Eighth Sky Gate!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc asakujaku_not_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information asakujaku_not.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You can`t use Asakujaku!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc hachimon_8_really_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information hachimon_8_really.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {Do you really want to do it?}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 83 272 125 25]} {
			tech_hachimon-8 "hero"
			lappend effects [list "hachimon-8" "hero" -1]
			lappend used "hachimon-8"
			replace
			end_turn "hachimon-8"
			destroy .s
		}	
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}		
	}	
}
proc no_chakra_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information no_chakra.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {You have`nt chakra!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc clon_message {} {
	global mydir
	get_image no_mess [file join $mydir images skills information clon_was.gif]
	catch {
		destroy .s
	}
	toplevel .s
	wm title .s {It`s was a shadow clone!}
	wm geometry .s 400x300
	wm maxsize .s 400 300
	wm minsize .s 400 300
	canvas .s.c -height 300 -width 400 -bg black
	.s.c create image 200 150 -image no_mess -tag infa
	pack .s.c -side top
	bind .s.c <ButtonPress> {
		if {[object_in %x %y 320 272 125 25]} {
			destroy .s
		}			
	}	
}
proc gen_minus {num} {
	global mydir
	get_image min [file join $mydir images heroes minus.gif]
	.c create image 725 [expr 26 + 51*($num-1)] -image min -tag panelenemy$num
	.c raise panelenemy$num
}
proc gen_plus {num} {
	global mydir
	get_image plus [file join $mydir images heroes plus.gif]
	.c create image 725 [expr 26 + 51*($num-1)] -image plus -tag panelenemy$num
	.c raise panelenemy$num
}
proc rolic {name} {
	global enemy skills
	block_battlepanel
	destroy .jump
	button .jump -state disabled -command {}
	destroy .right
	button .right -state disabled -command {}
	destroy .left
	button .left -state disabled -command {}
	destroy .stand
	button .stand -state disabled -command {}
	foreach s $skills {
		if {[enciclopedia $s chakra] != 0} {
			destroy .button_$s
			button .button_$s -state disabled -command {}
		}
	}
	set e 1
	while {$e <= $enemy} {
		set_speed "enemy$e" 0
		incr e
	}
	set_speed "hero" 0
	replace
	animation_$name
}
proc end_panel {h1 h2 h3} {
	global campdir
	.c delete all
	get_image endpanel [file join $campdir end.gif]
	.c create image 512 289 -image endpanel -tag endpanel
	set n1 [lindex $h1 0]
	set x 476
	set y 87
	foreach n $h1 {
		if {$n != $n1} {
			.c create image $x $y -image skill_$n -tag endpanel
			incr x 50
			if {$x > 900} {
				set x 476
				incr y 50
			}
		}
	}
	set n2 [lindex $h2 0]
	set x 476
	set y 243
	foreach n $h2 {
		if {$n != $n2} {
			.c create image $x $y -image skill_$n -tag endpanel
			incr x 50
			if {$x > 900} {
				set x 476
				incr y 50
			}
		}
	}
	set n3 [lindex $h3 0]
	set x 476
	set y 400
	foreach n $h3 {
		if {$n != $n3} {
			.c create image $x $y -image skill_$n -tag endpanel
			incr x 50
			if {$x > 900} {
				set x 476
				incr y 50
			}
		}
	}
	bind .c <ButtonPress> "
		click_end %x %y {$h1} {$h2} {$h3}
	"
}
proc click_end {ex ey h1 h2 h3} {
	global mydir
	set n1 [lindex $h1 0]
	set x 476
	set y 87
	foreach n $h1 {
		if {$n != $n1} {
			if {[object_in $ex $ey $x $y 50 50]} {
				if {[is_ninjitsu $n]} {
					set par [get_nin $n1]
				} elseif {[is_genjitsu $n]} {
					set par [get_gen $n1]
				} elseif {[is_taijitsu $n]} {
					set par [get_tai $n1]
				} else {	
					set par 0
				}
 				skillinfo [enciclopedia $n "name" $par] $n [enciclopedia $n "damage" $par] [enciclopedia $n "number" $par]
			}
			incr x 50
			if {$x > 900} {
				set x 476
				incr y 50
			}
		}
	}
	set n2 [lindex $h2 0]
	set x 476
	set y 243
	foreach n $h2 {
		if {$n != $n2} {
			if {[object_in $ex $ey $x $y 50 50]} {
				if {[is_ninjitsu $n]} {
					set par [get_nin $n2]
				} elseif {[is_genjitsu $n]} {
					set par [get_gen $n2]
				} elseif {[is_taijitsu $n]} {
					set par [get_tai $n2]
				} else {	
					set par 0
				}
 				skillinfo [enciclopedia $n "name" $par] $n [enciclopedia $n "damage" $par] [enciclopedia $n "number" $par]
			}
			incr x 50
			if {$x > 900} {
				set x 476
				incr y 50
			}
		}
	}
	set n3 [lindex $h3 0]
	set x 476
	set y 400
	foreach n $h3 {
		if {$n != $n3} {
			if {[object_in $ex $ey $x $y 50 50]} {
				if {[is_ninjitsu $n]} {
					set par [get_nin $n3]
				} elseif {[is_genjitsu $n]} {
					set par [get_gen $n3]
				} elseif {[is_taijitsu $n]} {
					set par [get_tai $n3]
				} else {	
					set par 0
				}
 				skillinfo [enciclopedia $n "name" $par] $n [enciclopedia $n "damage" $par] [enciclopedia $n "number" $par]
			}
			incr x 50
			if {$x > 900} {
				set x 476
				incr y 50
			}
		}
	}
	if {[object_in $ex $ey 817 537 125 25]} {
		clear
		pack forget .c 
		source [file join $mydir menu.tcl]
	}
}
