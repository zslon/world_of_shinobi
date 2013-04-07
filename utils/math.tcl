#mathworking
proc is_in {e l} {
	foreach a $l {
		if {$a == $e} {
			return 1
			break
		}
	} 
	return 0
}
proc object_in {ox oy x y w h} {
	set h [expr $h / 2]
	set w [expr $w / 2]
	if {$ox > [expr $x - $w] && $ox < [expr $x + $w] && $oy > [expr $y - $h] && $oy < [expr $y + $h]} {
		return 1
	} else {
		return 0
	}
}
proc no_more_enemy {} {
	global enemy
	set e 1
	set en $enemy
	while {$e <= $enemy} {
		if {[get_name enemy$enemy] == "trapmap"} {
			incr en -1
		}
		incr e 1
	}
	if {$en < 1} {
		return 1
	} else {
		return 0
	}
}
#skills list working
proc list_info {l ex ey x y {status "skill"} {par ""}} {
	global skills accessskills tai gen nin
	if {$par != ""} {
		global [set par]
	} else {
		set par "a"
		set a 0
	}
	set par2 "b"
	set b 0
	foreach j $l {
		if {$j == "naruto-nisen-rendan" || $j == "naruto-yonsen-rendan"} {
			set b $nin
		}
		if {[is_in $j $skills] && [object_in $ex $ey $x $y 45 45]} {
		skillinfo [enciclopedia $j "name" [set $par] [set $par2]] $j [enciclopedia $j "damage" [set $par] [set $par2]] [enciclopedia $j "number" [set $par] [set $par2]]
		}
		if {[is_in $j $accessskills] && [object_in $ex $ey $x $y 45 45]} {
		if {$status == "no skill"} {
			skillinfo [enciclopedia $j "name" [set $par] [set $par2]] $j [enciclopedia $j "damage" [set $par] [set $par2]] [enciclopedia $j "number" [set $par] [set $par2]]
		} else {
			skillinfo [enciclopedia $j "name" [set $par] [set $par2]] $j [enciclopedia $j "damage" [set $par] [set $par2]] [enciclopedia $j "number" [set $par] [set $par2]] 1
		}
		}
		if {!([is_in $j $accessskills]) && !([is_in $j $skills]) && [object_in $ex $ey $x $y 45 45]} {
			skillinfo [enciclopedia $j "name" [set $par] [set $par2]] $j 0 0 -1
		}
		incr y 50
	}
}
proc list_placing {l x y} {
	global skills
	foreach j $l {
		if {[is_in $j $skills]} {
			.c create image $x $y -image skill_$j -tag skills
		}
		incr y 50
	}
}
#file working
proc addskill {} {
	global campdir newskill
	source [file join $campdir personstat.tcl]
	lappend skills $newskill
	set f [open [file join $campdir personstat.tcl] w]
	puts $f "set level $level"
	puts $f "set tai $tai"
	puts $f "set gen $gen"
	puts $f "set nin $nin"
	puts $f "set speed $speed"
	puts $f "set skills \{$skills\}" 
	close $f 
}
proc autosave {camp number} {
	global mydir
	source [file join $mydir gamestat.tcl]
	set camp_[set camp]_mission $number
	set f [open [file join $mydir gamestat.tcl] w]
	puts $f "set regim $regim"
	puts $f "set camp_0_person \{$camp_0_person\}"
	puts $f "set camp_1_person \{$camp_1_person\}"
	puts $f "set camp_2_person \{$camp_2_person\}"
	puts $f "set camp_0_mission $camp_0_mission"
	puts $f "set camp_1_mission $camp_1_mission" 
	puts $f "set camp_2_mission $camp_2_mission" 
	close $f 
}
proc levelup {t n g s} {
	global campdir herolevel
	source [file join $campdir personstat.tcl]
	if {$herolevel == $level} {
		incr level 1
		incr tai $t
		incr nin $n
		incr gen $g
		incr speed $s
		set f [open [file join $campdir personstat.tcl] w]
		puts $f "set level $level"
		puts $f "set tai $tai"
		puts $f "set gen $gen"
		puts $f "set nin $nin"
		puts $f "set speed $speed"
		puts $f "set skills \{$skills\}" 
		close $f 
	}
	incr herolevel 1
}
proc remove_progress {name} {
	global mydir
	source [file join $mydir campaign $name personstat.tcl]
	set skills [lreplace $skills 2 [expr [llength $skills] - 1]]
	set level 1
	if {$name == "power_of_youth"} {
		set tai 3
		set gen 1
		set nin 1
		set speed 2
	}
	set f [open [file join $mydir campaign $name personstat.tcl] w]
	puts $f "set level $level"
	puts $f "set tai $tai"
	puts $f "set gen $gen"
	puts $f "set nin $nin"
	puts $f "set speed $speed"
	puts $f "set skills \{$skills\}" 
	close $f 	
}
