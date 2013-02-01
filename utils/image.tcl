#imageworking
set leeskillist [list "konoha-senpu" "shofu" "konoha-dai-senpu" "omote-renge" "ura-renge" "konoha-goriki-senpu" "tsuten-kyaku" "asakujaku" "hirudora" "konoha-congoriki-senpu" "suiken" "hachimon-1" "hachimon-2" "hachimon-3" "hachimon-4" "hachimon-5" "hachimon-6" "hachimon-7" "hachimon-8"]
foreach s $leeskillist {
	image create photo skill_$s -file [file join $mydir images skills lee $s.gif]
}
image create photo cross -file [file join $mydir images skills cross.gif]
image create photo aceptbutton -file [file join $mydir images skills acept.gif]
proc create_skillpanel {} {
	global mydir
	image create photo emptyskillpanel -file [file join $mydir images skills standart.gif]
	.c create image 512 288 -image emptyskillpanel -tag phon
	.c create image 225 200 -image individualpanel -tag skills
	.c create image 600 310 -image accesspanel -tag skills
}
proc skillmessage {} {
	global mydir
	image create photo mess -file [file join $mydir images skills information message.gif]
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
	image create photo win -file [file join $mydir images win.gif]
	.c create image 512 288 -image win
}
proc skillinfo {title image {dam 0} {much 0} {access 0}} {
	global mydir campdir newskill
	set newskill $image
	image create photo infa -file [file join $mydir images skills information $image.gif]
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
		image create photo infa -file [file join $mydir images skills information $image-n.gif]
	}
	
}
proc breefing {} {
	global campdir missionnumber slide enemy
	set slide 1
	set enemy 0
	image create photo phonimage -file [file join $campdir breefings $missionnumber.gif]
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
	image create photo mess -file [file join $campdir messages $missionnumber-$slide.gif]
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
proc phon {number} {
	global campdir missionnumber
	image create photo phonimage -file [file join $campdir land $missionnumber-$number.gif]
}
proc create_battlepanel {} {
	global heroname mydir enemy slide skills
	image create photo battlepanel -file [file join $mydir images skills battlepanel.gif]
	image create photo heroportrait -file [file join $mydir images heroes $heroname face.gif]
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
			image create photo face$e -file [file join $mydir images heroes [get_name enemy$e] face.gif]
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
	if {$slide == 1} {
		unblock_battlepanel
	}
}
proc click_in_game {ex ey} {
	global mydir skills
	if {[object_in $ex $ey 625 25 50 50]} {
		exec [file join $mydir menu.tcl] &
		exit
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
			image create photo face$e -file [file join $mydir images heroes [get_name enemy$e] face.gif]
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
			image create photo heroi -file [file join $mydir images heroes $im stand $hero_ancof.gif]
			after 150 "stand_animation $tag $im $s"			
		} else {
			image create photo heroi -file [file join $mydir images heroes $im stand 1.gif]
		}
	} else {
		global [set tag]_ancof
		if {[set [set tag]_ancof]} {
			set [set tag]_ancof [expr [set [set tag]_ancof] + 1]
			if {[set [set tag]_ancof] == 5} {
				set [set tag]_ancof 1
			}
			image create photo [set tag] -file [file join $mydir images heroes $im stand [set [set tag]_ancof].gif]
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
	image create photo $tag -file [file join $mydir images heroes $im block 1.gif]	
	after 100 "image create photo $tag -file [file join $mydir images heroes $im block 2.gif]"
	after 200 "image create photo $tag -file [file join $mydir images heroes $im block 3.gif]"
	after 800 "image create photo $tag -file [file join $mydir images heroes $im block 4.gif]"
	after 900 "image create photo $tag -file [file join $mydir images heroes $im stand 1.gif]"
}
proc wound_animation {tag im} {
	global mydir hero_ancof
	if {$tag == "heroi"} {
		set hero_ancof 0
	} else {
		global [set tag]_ancof
		set [set tag]_ancof 0
	}
	set i 1
	set t 0
	while {$t < 800} {
		after $t "image create photo $tag -file [file join $mydir images heroes $im wound $i.gif]"
		incr t 100
		incr i
	}
}
proc concentrate_chakra {tag im} {
	global mydir hero_ancof
	set hero_ancof 0
	set t 0
	set i 1
	while {$t < 1000} {
		after $t "image create photo $tag -file [file join $mydir images heroes $im chakra $i.gif]"	
		incr t 100
		incr i 
	}
}
proc die {class} {
	global mydir hero_ancof
	if {$class == "hero"} {
		set tag "heroi"
		set hero_ancof 0
		after 2000 "
			exec [file join $mydir menu.tcl] &
			exit
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
				after $t "image create photo [set tag] -file [file join $mydir images heroes $im wound $i.gif]"
			}
			incr t 100
			incr i
		}
		after 2000 {unblock_battlepanel}
		after 2000 ".c delete $tag"
	}
}
proc teleport {im num} {
	global enemy herolevel mydir bonus
	set tag "enemy$num"
	set_hitpoints enemy$num 0
	block_battlepanel
	set t 0
	set i 1
	while {$t <= 500} {
		if {$im != "trap"} {
			after $t "image create photo [set tag] -file [file join $mydir images heroes $im teleport $i.gif]"
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
	image create photo image_$r -file [file join $mydir images attacks $image t0.gif]
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
	after 50 "image create photo image_$r -file [file join $mydir images attacks $image t$d.gif]"
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
					after 600 ".c move $tag 300 0"
				}
			}
		} else {
			if {$h < [lindex $locations $l]} {
				after 600 ".c move $tag 0 -100"
			} else {
				after 600 ".c move $tag 300 0"
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
					after 600 ".c move $tag -300 0"
				}
			}
		} else {
			if {$h < [lindex $locations $l]} {
				after 600 ".c move $tag 0 -100"
			} else {
				after 600 ".c move $tag -300 0"
			}
		}
	}
	set t 100
	set i 6
	while {$t <= 1000} {
		after $t "image create photo $tag -file [file join $mydir images heroes $im kawarimi $i.gif]"	
		incr t 100
		incr i 
	}
}
#heroes
proc rock_lee {x y} {
	global mydir hero_ancof
	set hero_ancof 1
	image create photo heroi -file [file join $mydir images heroes lee stand 1.gif]
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
	image create photo heroi -file [file join $mydir images heroes lee-adult stand 1.gif]
	.c create image $x $y -image heroi -tag heroi
	.c raise heroi
}
proc lee-adult_3 {x y} {
	chunin_rock_lee $x $y
}
#enemy
proc lumber {x y} {
	global mydir enemy
	image create photo enemy$enemy -file [file join $mydir images heroes lumber stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
}
proc genin_from_robber {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	image create photo enemy$enemy -file [file join $mydir images heroes genin-robber stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-robber" $slide
}
proc genin_from_sound {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	image create photo enemy$enemy -file [file join $mydir images heroes genin-sound stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-sound" $slide
}
proc genin_armmaster_from_robber {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	image create photo enemy$enemy -file [file join $mydir images heroes genin-robber-armmaster stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-robber-armmaster" $slide
}
proc genin_armmaster_from_sound {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	image create photo enemy$enemy -file [file join $mydir images heroes genin-sound-armmaster stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "genin-sound-armmaster" $slide
}
#personal
proc genin_tenten {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	image create photo enemy$enemy -file [file join $mydir images heroes tenten stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "tenten" $slide
}
proc chunin_tenten {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	image create photo enemy$enemy -file [file join $mydir images heroes tenten-adult stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "tenten-adult" $slide
}
proc jonin_might_guy {x y} {
	global mydir enemy slide
	global enemy[set enemy]_ancof
	set enemy[set enemy]_ancof 1
	image create photo enemy$enemy -file [file join $mydir images heroes gui stand 1.gif]
	.c create image $x $y -image enemy$enemy -tag enemy$enemy
	.c raise enemy$enemy
	stand_animation enemy$enemy "gui" $slide
}
#tech
proc suiken_not_message {} {
	global mydir
	image create photo no_mess -file [file join $mydir images skills information suiken_not.gif]
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
	image create photo no_mess -file [file join $mydir images skills information omote_not.gif]
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
proc no_chakra_message {} {
	global mydir
	image create photo no_mess -file [file join $mydir images skills information no_chakra.gif]
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
proc gen_minus {num} {
	global mydir
	image create photo min -file [file join $mydir images heroes minus.gif]
	.c create image 725 [expr 26 + 51*($num-1)] -image min -tag panelenemy$num
	.c raise panelenemy$num
}
proc gen_plus {num} {
	global mydir
	image create photo plus -file [file join $mydir images heroes plus.gif]
	.c create image 725 [expr 26 + 51*($num-1)] -image plus -tag panelenemy$num
	.c raise panelenemy$num
}
