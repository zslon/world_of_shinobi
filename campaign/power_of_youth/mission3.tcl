#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 3
set heroname "lee"
set herolevel 1
set ai_type "normal"
autosave 1 3
breefing
proc slide_1 {} {
	global locations bonus
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	scenery_message {Forward!!!}
	genin_sound_armmaster 1000 520
}
proc slide_2 {} {
	global locations
	phon 2
	set locations [list 1 1 1 1]
	genin_sound 1000 520 1 1 2 1
	medpack 950 520
}
proc slide_3 {} {
	global locations
	phon 3
	set locations [list 3 3 3 -3]
	genin_sound 1000 320
	genin_sound 700 420 1 1 2 1
	scenery_message {Enemy camp!}
}
proc slide_4 {} {
	global locations
	phon 4
	set locations [list -3 -3 -3 -3]
	genin_sound 700 320
}
proc slide_5 {} {
	global locations
	phon 5
	set locations [list 3 1 1 1]
	genin_sound 400 520 1 1 2 1
	medpack 50 520
}
proc slide_6 {} {
	global locations ai_type
	set ai_type "high"
	phon 6
	set locations [list 1 1 1 1]
	genin_sound_armmaster 1000 520 1 1 2 4 {"raiko-kenka"}
}
proc slide_7 {} {
	global locations ai_type
	set ai_type "normal"
	phon 7
	set locations [list 3 3 3 1]
	green_table 650 320
	genin_sound_armmaster 1000 520 1 1 2 4 {"kuchiese-meisu"}
	scenery_message {Battle pills}
}
proc slide_8 {} {
	global locations ai_type
	set ai_type "special"
	set locations [list 3 1 1 1]
	phon 8
	ten_ten 100 320 {"raiko-kenka"}
	might_guy 1000 520 {"shofu"}
}
proc special_tenten_ai {n tech p} {
	bonus_tech_ai 1
}
proc special_gui_ai {n tech p} {
	victory
}
proc victory_special {} {
	after 1000 {move enemy1 "right"}
}
