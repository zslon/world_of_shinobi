#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 2
set heroname "lee"
set herolevel 1
set ai_type "normal"
autosave 1 2
breefing
proc slide_1 {} {
	global locations bonus
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	scenery_message {Forward!!!}
	genin_robber 1000 520
}
proc slide_2 {} {
	global locations
	phon 2
	set locations [list 1 3 -2 1]
	genin_robber 700 420
	medpack 350 320
	scenery_message {Medpack}
}
proc slide_3 {} {
	global locations
	phon 3
	set locations [list 1 1 3 1]
	genin_robber 700 320
	kunai_trap 950
}
proc slide_4 {} {
	global locations
	phon 4
	set locations [list 1 1 1 1]
	genin_robber 400 520 1 1 1 1
	scenery_message {Strong and weak enemy}
}
proc slide_5 {} {
	global locations
	phon 5
	set locations [list 3 3 2 3]
	genin_robber 1000 320 3 1 1 1
}
proc slide_6 {} {
	global locations
	phon 6
	set locations [list 3 3 1 1]
	medpack 50 420
	genin_robber_armmaster 1000 520
}
proc slide_7 {} {
	global locations ai_type
	set ai_type "special"
	phon 7
	set locations [list 1 1 1 1]
	might_guy 1000 520 {"shofu"}
}
proc special_gui_ai {n tech p} {
	victory
}
proc victory_special {} {
	after 1000 {move enemy1 "left"}
}
