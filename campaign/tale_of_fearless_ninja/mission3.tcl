#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 3
set heroname "naruto"
set herolevel 1
set ai_type "normal"
autosave 0 3
breefing
proc slide_1 {} {
	global locations bonus skills 
	lappend skills "kyubi-enabled"
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	genin_robber 1000 520
	scenery_message {Mist}
}
proc slide_2 {} {
	global locations
	phon 2
	set locations [list 1 1 1 1]
	genin_robber 1000 520 1 1 1 1 {}
	genin_robber 700 520 1 1 1 1 {}
}
proc slide_3 {} {
	global locations
	phon 3
	set locations [list 3 -3 1 1]
	genin_robber 1000 520
	kubakufuda_trap 350
	medpack 350 320
}
proc slide_4 {} {
	global locations ai_type etap
	phon 4 
	set locations [list 1 2 -2 -2]
	kunai_trap 350
	kubakufuda_trap 650
	kubakufuda_trap 950
	yellow_table 950 420
}
proc slide_5 {} {
	global locations bonus ai_type
	set ai_type "high"
	phon 5
	set locations [list 2 2 2 2]
	genin_mist_watermaster 1000 420 2 3 1 1 {"suiton-suika" "suiton-kirigakure"} 
	scenery_message {Kirigakure Ninja}
}
proc slide_6 {} {
	global locations bonus ai_type effects
	set ai_type "special"
	phon 6
	set locations [list 2 2 2 -3]
	lappend effects [list "water-clon" enemy1 -1]
	genin_mist_watermaster 700 420 2 3 1 1 {}
	kubakufuda_trap 1000
	set_chakra enemy2 5
}
proc special_genin-mist-watermaster_ai {n tech p} {
	standart_ai $n $tech $p
}
proc special_trap_ai {n tech p} {
	global enemy
	if {$enemy > 1} {
	} else {
		rolic "naruto_in_a_bridge"
	}
}
proc animation_naruto_in_a_bridge {} {
	hatake_kakashi 1000 1000 {}
	catch {
		destroy .s
	}
	replic "naruto-2" 2000
	after 2050 {teleport enemy2 100 420
	replic "kakashi-1" 2500}
	after 4600 {victory}
}
proc special_kakashi_ai {n tech p} {
}
proc victory_special {} {
	global skills
	set skills [lreplace $skills [lsearch $skills kyubi-enabled] [lsearch $skills kyubi-enabled]]
	.c raise panel
}
