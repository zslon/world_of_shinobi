#!/usr/bin/wish8.5
#directory
catch {
set mydir [file normalize [file dirname $argv0]]
}
#window
wm geometry . 1024x576
wm maxsize . 1024 576
wm minsize . 1024 576
wm title . {World of Shinobi}
canvas .z -height 576 -width 1024 -bg black
#menu phone image
image create photo menuimage -file [file join $mydir images transparent intro.gif]
.z create image 512 288 -image menuimage -tag phon
update
#math
source [file join $mydir utils math.tcl]
#menupacker
proc menupack {number name} {
	global mydir but_$number
	set but_$number $name
	.$name configure -state normal
	if {$name == "back"} {
		set name "quit"
	}
	if {$name == "lee_c"} {
		set name "lee"
	}
	if {$name == "naruto_c"} {
		set name "naruto"
	}
	if {$name == "sasuke_c"} {
		set name "sasuke"
	}
	if {$name == "itachi_c"} {
		set name "itachi"
	}
	image create photo menu_$number -file [file join $mydir images transparent menu $name-1.gif]
	.z delete menu_$number
	.z create image 700 [expr 150 + $number * 125] -image menu_$number -tag menu_$number
	set n 2
	while {$n <= 13} {
		after [expr 400 + 75 * ($n - 1)] "image create photo menu_$number -file [file join $mydir images transparent menu $name-$n.gif]"
		incr n
	}
}
proc menuunpack {number name} {
	global mydir
	set n 12
	.$name configure -state disabled
	if {$name == "back"} {
		set name "quit"
	}
	if {$name == "lee_c"} {
		set name "lee"
	}
	if {$name == "naruto_c"} {
		set name "naruto"
	}
	if {$name == "sasuke_c"} {
		set name "sasuke"
	}
	if {$name == "itachi_c"} {
		set name "itachi"
	}
	while {$n >= 1} {
		after [expr 900 - 75 * ($n - 1)] "image create photo menu_$number -file [file join $mydir images transparent menu $name-$n.gif]"
		incr n -1
	}	
}
#getcord of click

bind .z <ButtonPress> {
	set n 0
	while {$n <= 3} {
		if {[object_in %x %y 713 [expr 150 + $n * 125] 494 90] && [set but_$n] != ""} {
			.[set but_$n] invoke
		}
		incr n
	}
}

#transparent portraits
image create photo portrait_naruto -file [file join $mydir images transparent naruto-portrait.gif]
image create photo portrait_sasuke -file [file join $mydir images transparent sasuke-portrait.gif]
image create photo portrait_itachi -file [file join $mydir images transparent itachi-portrait.gif]
image create photo portrait_lee -file [file join $mydir images transparent lee-portrait.gif]
bind .z <Motion> {
	if {$but_3 == "back"} {
		set n 0
		set f 0
		while {$n <= 2} {
			if {[object_in %x %y 713 [expr 150 + $n * 125] 494 90] && [set but_[set n]] != ""} {
				set nam [set but_[set n]]
				if {[set but_[set n]] == "naruto_c"} {
					set nam "naruto"
				}
				if {[set but_[set n]] == "sasuke_c"} {
					set nam "sasuke"
				}
				if {[set but_[set n]] == "itachi_c"} {
					set nam "itachi"
				}
				if {[set but_[set n]] == "lee_c"} {
					set nam "lee"
				}
				.z create image 306 416 -image portrait_[set nam] -tag transparent_portrait
				set f 1
			}
			incr n
		}
		if {$f == 0} {
			.z delete transparent_portrait
		}
	}	
}

#pack
pack .z -side top
#buttons
set but_0 "naruto"
set but_1 "new"
set but_2 "continue"
set but_3 "quit"
button .lee -state disabled -command {new_campaign "power_of_youth" 1}
button .naruto -state disabled -command {new_campaign "tale_of_fearless_ninja" 0}
button .sasuke -state disabled -command {new_campaign "sasuke" 1}
button .itachi -state disabled -command {new_campaign "itachi" 2}
button .lee_c -state disabled -command {continue_campaign "power_of_youth" 1}
button .naruto_c -state disabled -command {continue_campaign "tale_of_fearless_ninja" 0}
button .sasuke_c -state disabled -command {continue_campaign "sasuke" 1}
button .itachi_c -state disabled -command {continue_campaign "itachi" 2}
button .new -state disabled -command {
	menuunpack 1 "new"
	menuunpack 2 "continue"
	menuunpack 3 "quit"
	set but_0 ""
	set but_1 ""
	set but_2 ""
	set but_3 ""
	if {$regim == "learning"} {
		after 1000 {
			menupack 1 "lee"
			menupack 3 "back"
		}
	} elseif {$regim == "normal"} {

		after 1000 {
			menupack 0 "naruto"
			menupack 1 "sasuke"
			menupack 3 "back"
		}
	} elseif {$regim == "advanced"} {
		after 1000 {
			menupack 0 "naruto"
			menupack 1 "sasuke"
			menupack 2 "itachi"
			menupack 3 "back"
		}
	}
}
button .continue -state disabled -command {
	menuunpack 1 "new"
	menuunpack 2 "continue"
	menuunpack 3 "quit"
	set n 0
	set but_0 ""
	set but_1 ""
	set but_2 ""
	set but_3 ""
	while {$n < 3} {
		if {[set camp_[set n]_mission] == 0} {
			after 1000 {set but_[set n] ""}
		} else {
			after 1000 "menupack $n [set camp_[set n]_person]_c"
		}
		incr n
	}
	after 1000 {menupack 3 "back"}
}
button .quit -state disabled -command {exit}
button .back -state disabled -command {
	.z delete transparent_portrait
	set n 0
	while {$n <= 3} {
		if {[set but_[set n]] != ""} {
			menuunpack $n [set but_[set n]]
		}
		incr n
	}
	after 1000 {
		.z delete menu_0
		menupack 1 "new"
		menupack 2 "continue"
		menupack 3 "quit"
	}
}
menupack 1 "new"
menupack 2 "continue"
menupack 3 "quit"
proc clear {} {
	destroy .z .back .quit .continue .new .lee .naruto .sasuke .itachi .lee_c .naruto_c .sasuke_c .itachi_c
}
#game statistic
global camp_0_mission camp_1_mission camp_2_mission m ar regim
set m 1
set ar 0
source [file join $mydir gamestat.tcl]
proc new_campaign {name num} {
	global mydir camp_[set num]_mission
	proc subproc {} "
		remove_progress $name
		global m ar
		set m 1
		set ar 0
		clear
		source [file join $mydir campaign $name start.tcl]
		destroy .w
	"
	if {[set camp_[set num]_mission] > 1} {
		image create photo warning -file [file join $mydir images transparent menu message.gif]
		catch {
			destroy .w
		}
		toplevel .w
		wm title .w {Warning!}
		wm geometry .w 400x300
		wm maxsize .w 400 300
		wm minsize .w 400 300
		canvas .w.z -height 300 -width 400 -bg black
		.w.z create image 200 150 -image warning -tag infa
		pack .w.z -side top
		bind .w.z <ButtonPress> {
			if {[object_in %x %y 320 272 125 25]} {
				.back invoke
				destroy .w
			}	
			if {[object_in %x %y 124 272 125 25]} {
				subproc
			}			
		}	
	} else {
	global m ar
	set m 1
	set ar 0
	clear
	source [file join $mydir campaign $name start.tcl]
	}
}
proc continue_campaign {name num} {
	global mydir camp_[set num]_mission
	global m ar
	set m [set camp_[set num]_mission]
	set ar 0
	clear
	source [file join $mydir campaign $name start.tcl]
}
