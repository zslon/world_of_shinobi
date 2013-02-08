#!/usr/bin/wish8.5
source [file join $mydir utils shinobi.tcl]
source [file join $mydir utils buttons.tcl]
global missionnumber heroname herolevel ai_type
set missionnumber 5
set heroname "lee"
set herolevel 2
set ai_type "normal"
autosave 1 5
breefing
proc slide_1 {} {
	global locations bonus
	set bonus 0
	phon 1
	set locations [list 1 1 1 1]
	genin_sound 1000 520 2 2 2 1 {"futon-zankuha" "kawarimi"}
}
proc slide_2 {} {
	global locations
	phon 2
	set locations [list 1 1 1 1]
	genin_sound 1000 520 2 2 2 1 {"futon-zankuha" "kawarimi"}
	genin_sound 700 520 2 1 2 2
}
proc slide_3 {} {
	global locations ai_type
	set ai_type "high"
	phon 3
	set locations [list 2 -2 -2 -2]
	genin_sound_armmaster 1000 420 1 1 2 4 {"raiko-kenka" "soshoryu"}
}
proc slide_4 {} {
	global locations ai_type
	set ai_type "normal"
	phon 4
	set locations [list 3 3 3 3]
	genin_sound 1000 420 2 1 2 1 {"futon-zankuha" "kawarimi"}
	genin_sound 1000 320 2 1 2 1 {"futon-zankuha" "kawarimi"}
	genin_sound 1000 520 2 1 2 1 {"futon-zankuha" "kawarimi"}
}
proc slide_5 {} {
	global locations
	phon 5
	set locations [list 3 1 1 1]
	genin_sound 400 520
	medpack 50 520
}
proc slide_6 {} {
	global locations ai_type
	set ai_type "high"
	phon 6
	set locations [list 1 1 1 1]
	genin_sound_armmaster 1000 520 1 1 2 4 {"raiko-kenka" "soshoryu"}
	genin_sound_armmaster 700 520 1 1 2 4 {"kuchiese-meisu"}
}
proc slide_7 {} {
	global locations ai_type
	phon 7
	set locations [list 1 1 1 1]
	green_table 950 520
	genin_sound_armmaster 700 520 2 2 2 4 {"raiko-kenka" "futon-zankuha" "kawarimi"}
}
proc slide_8 {} {
	global locations ai_type effects
	set locations [list 1 3 2 3]
	phon 8
	lappend effects [list "shadow-clon" enemy1 -1]
	chunin_sound 1000 320 3 3 3 3 {"futon-zankukyokuha" "hosho" "shoshitsu" "kawarimi"}
	kubakufuda_trap 350
	kubakufuda_trap 650
}
proc slide_9 {} {
	set ai_type "special"
	set locations [list 3 1 1 1]
	phon 9
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
