#imageworking
global meleelist rangedlist bonuslist ninjitsu taijitsu genjitsu allbuttonskills kunaijitsu
set allbuttonskills [list "suiken" "hachimon-1" "hachimon-2" "hachimon-3" "hachimon-4" "hachimon-5" "hachimon-6" "hachimon-7" "hachimon-8" "shofu" "omote-renge"]
set meleelist [list "hirudora" "asakujaku" "ura-renge" "omote-renge" "shofu"]
set rangedlist [list "hirudora" "asakujaku" "sogu-tensasai" "futon-zankukyokuha" "sofusha-san-no-tachi" "soshoryu" "futon-zankuha"]
set bonuslist [list "hachimon-8" "hachimon-7" "hachimon-6" "tengoku-no-kuchiese" "kuchiese-ninkame" "hachimon-5" "hachimon-4" "hachimon-3" "soshuga" "kuchiese-meisu" "kibakufuda" "hachimon-2" "suiken" "hachimon-1" "kuchiese-kusarigama" "raiko-kenka" "kage-bunshin" "kawarimi" "kai"]
set ninjitsu [list "tengoku-no-kuchiese" "kuchiese-ninkame" "sogu-tensasai" "futon-zankukyokuha" "sofusha-san-no-tachi" "soshoryu" "futon-zankuha" "kage-bunshin"]
set taijitsu [list "hirudora" "asakujaku" "ura-renge" "omote-renge" "shofu"]
set genjitsu [list "kawarimi" "kai"]
set physicjitsu [list "hirudora" "asakujaku" "tsuten-kyaku" "ura-renge" "omote-renge" "soshuga" "kuchiese-meisu" "kuchiese-kusarigama" "hosho" "shoshitsu" "konoha-senpu" "shofu" "kubakufuda" "attack"]
set kunaijitsu [list "sogu-tensasai" "sofusha-san-no-tachi" "soshoryu" "raiko-kenka" "kunai"]
set futonjitsu [list "futon-zankukyokuha" "futon-zankuha"]
proc enciclopedia_search {testskill testobj skill name damage number chakra} {
	if {$testskill == $skill} {
		return [set [set testobj]]
	} else {
		return "null"
	}
}
proc enciclopedia {skill obj {par "0"}} {
	set cyclo [list]
	lappend cyclo [list "attack" "Shinobi attack" [expr 3 + $par] [expr 2 + ($par/2)] 0]
	lappend cyclo [list "kunai" "Throw Kunai" 5 $par 0]
	lappend cyclo [list "suiken" "Suiken" 0 5 25]
	lappend cyclo [list "hachimon-1" "Kaimon" 0 -1 20]
	lappend cyclo [list "hachimon-2" "Kyumon" 0 -1 40]
	lappend cyclo [list "hachimon-3" "Seimon" 0 -1 60]
	lappend cyclo [list "hachimon-4" "Shomon" 0 -1 80]
	lappend cyclo [list "hachimon-5" "Tomon" 0 -1 100]
	lappend cyclo [list "hachimon-6" "Keimon" 0 -1 25]
	lappend cyclo [list "hachimon-7" "Kyomon" 0 -1 25]
	lappend cyclo [list "hachimon-8" "Shimon" 0 -1 50]
	lappend cyclo [list "konoha-senpu" "Konoha Senpu" 0 0 0]
	lappend cyclo [list "konoha-senpu" "Shoshitsu" 0 0 0]
	lappend cyclo [list "shofu" "Shofu" [expr 3 + $par] 1 10]
	lappend cyclo [list "konoha-dai-senpu" "Konoha Dai Senpu" 0 0 0]
	lappend cyclo [list "omote-renge" "Omote Renge" [expr 3*(3+$par)*(2+$par/2)/2] 1 25]
	lappend cyclo [list "ura-renge" "Ura Renge" [expr 3*(3+$par)*(2+$par/2)/2] 1 25]
	lappend cyclo [list "konoha-goriki-senpu" "Konoha Goriki Senpu" 0 0 0]
	lappend cyclo [list "tsuten-kyaku" "Tsuten Kyaku" 0 0 0]
	lappend cyclo [list "asakujaku" "Asakujaku" [expr 3 + $par] [expr 4 + $par] 100]
	lappend cyclo [list "konoha-congoriki-senpu" "Geki Konoha Congoriki Senpu" 0 0 0]
	lappend cyclo [list "hirudora" "Hirudora" [expr (3+$par)*(4+$par)] 1 200]
	lappend cyclo [list "kawarimi" "Kawarimi no Jitsu" 0 1 10]
	lappend cyclo [list "kage-bunshin" "Kage Bunsin no Jitsu" 0 $par 5]
	lappend cyclo [list "futon-zankuha" "Futon: Zankuha" [expr 7*$par] 1 15]
	lappend cyclo [list "futon-zankukyokuha" "Futon: Zankukyokuha" [expr 10*$par] 1 25]
	lappend cyclo [list "raiko-kenka" "Kuchiese: Raiko Kenka" 0 -1 15]
	lappend cyclo [list "kuchiese-kusarigama" "Kuchiese: Kusarigama" 0 -1 15]
	lappend cyclo [list "kuchiese-meisu" "Kuchiese: Meisu" 0 -1 25]
	lappend cyclo [list "soshuga" "Soshuga" 0 -1 25]
	lappend cyclo [list "soshoryu" "Soshoryu" [expr 10*$par] 1 25]
	lappend cyclo [list "sofusha-san-no-tachi" "Sofusha San no Tachi" 7 $par 10]
	lappend cyclo [list "sogu-tensasai" "Sogu: Tensasai" [expr 15*$par] 1 50]
	lappend cyclo [list "kuchiese-ninkame" "Kuchiese: Ninkame" [expr $par*3] 0 75]
	lappend cyclo [list "tengoku-no-kuchiese" "Tengoku no Kuchiese" 0 0 75]
	lappend cyclo [list "kai" "Kai" $par 1 10]
	lappend cyclo [list "kubakufuda" "Kibakufuda" 50 1 0]
	lappend cyclo [list "kibakufuda" "Kibakufuda" 0 2 10]
	foreach el $cyclo {
		set r [enciclopedia_search $skill $obj [lindex $el 0] [lindex $el 1] [lindex $el 2] [lindex $el 3] [lindex $el 4]]
		if {$r != "null"} {
			break
		}
	}
	return $r
}
proc is_melee {tech} {
	global meleelist
	set l $meleelist
	lappend l "attack"
	return [is_in $tech $l]
}
proc is_ranged {tech} {
	global rangedlist
	set l $rangedlist
	lappend l "kunai"
	return [is_in $tech $l]
}
proc is_bonus {tech} {
	global bonuslist
	return [is_in $tech $bonuslist]
}
proc is_ninjitsu {tech} {
	global ninjitsu
	return [is_in $tech $ninjitsu]
}
proc is_genjitsu {tech} {
	global genjitsu
	return [is_in $tech $genjitsu]
}
proc is_taijitsu {tech} {
	global taijitsu
	return [is_in $tech $taijitsu]
}
proc is_kunai_based {tech} {
	global kunaijitsu
	return [is_in $tech $kunaijitsu]
}
proc have_special_animate {tech} {
#range tech, with have special animate
	return [is_in $tech [list "hirudora" "asakujaku" "sogu-tensasai" "soshoryu"]]
}
proc is_high {name} {
#hero height for kunai technics
	return [is_in [get_name $name] [list "gui" "chunin-sound"]]
}
