#imageworking
global meleelist rangedlist bonuslist ninjitsu taijitsu genjitsu allbuttonskills kunaijitsu
set allbuttonskills [list "suiken" "hachimon-1" "hachimon-2" "hachimon-3" "hachimon-4" "hachimon-5" "hachimon-6" "hachimon-7" "hachimon-8" "shofu" "omote-renge" "ura-renge" "asakujaku" "hirudora" "taju-kage-bunshin"]
set meleelist [list "hirudora" "rasen-cho-tarengan" "naruto-yonsen-rendan" "asakujaku" "odama-rasengan" "futon-rasengan" "rasengan" "naruto-nisen-rendan" "ura-renge" "omote-renge" "shofu"]
set rangedlist [list "futon-rasensuriken" "hirudora" "futon-kiryu-ranbu" "asakujaku" "futon-shinku-renpa" "futon-kazekiri" "sogu-tensasai" "futon-zankukyokuha" "futon-shinkuha" "futon-shinku-dai-gyoku" "sofusha-san-no-tachi" "soshoryu" "futon-shinku-gyoku" "bunshin-no-henge" "futon-zankuha"]
set bonuslist [list "sennin-mode" "hachimon-8" "hachimon-7" "hachimon-6" "kuchiese-gamabunta" "kuchiese-yatai-kuzushi" "tengoku-no-kuchiese" "kuchiese-ninkame" "hachimon-5" "hachimon-4" "hachimon-3" "soshuga" "kuchiese-meisu" "kibakufuda" "hachimon-2" "taju-kage-bunshin" "suiken" "hachimon-1" "kuchiese-kusarigama" "raiko-kenka" "kage-bunshin" "kawarimi" "kai"]
set ninjitsu [list "futon-rasensuriken" "rasen-cho-tarengan" "futon-kiryu-ranbu" "kuchiese-gamabunta" "kuchiese-yatai-kuzushi" "tengoku-no-kuchiese" "kuchiese-ninkame" "odama-rasengan" "futon-rasengan" "futon-shinku-renpa" "futon-kazekiri" "sogu-tensasai" "rasengan" "futon-zankukyokuha" "futon-shinkuha" "futon-shinku-dai-gyoku" "sofusha-san-no-tachi" "soshoryu" "taju-kage-bunshin" "futon-shinku-gyoku" "futon-zankuha" "kage-bunshin"]
set taijitsu [list "hirudora" "naruto-yonsen-rendan" "asakujaku" "naruto-nisen-rendan" "ura-renge" "omote-renge" "shofu"]
set genjitsu [list "kawarimi" "kai"]
set physicjitsu [list "hirudora" "naruto-yonsen-rendan" "asakujaku" "naruto-nisen-rendan" "tsuten-kyaku" "ura-renge" "omote-renge" "naruto-rendan" "soshuga" "kuchiese-meisu" "kuchiese-kusarigama" "hosho" "shoshitsu" "konoha-senpu" "shofu" "kubakufuda" "attack"]
set kunaijitsu [list "sogu-tensasai" "sofusha-san-no-tachi" "soshoryu" "bunshin-no-henge" "shihohappo-suriken" "raiko-kenka" "kunai"]
set futonjitsu [list "futon-rasensuriken" "futon-kiryu-ranbu" "futon-rasengan" "futon-shinku-renpa" "futon-kazekiri" "futon-zankukyokuha" "futon-shinkuha" "futon-shinku-dai-gyoku" "futon-shinku-gyoku" "futon-zankuha"]
proc enciclopedia_search {testskill testobj skill name damage number chakra} {
	if {$testskill == $skill} {
		return [set [set testobj]]
	} else {
		return "null"
	}
}
proc enciclopedia {skill obj {par "0"} {par2 0}} {
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
	lappend cyclo [list "nine-tails" "Kyubi no Koromo" 0 2 0]
	lappend cyclo [list "taju-kage-bunshin" "Taju Kage Bunsin no Jutsu" 0 [expr $par * 2] 50]
	lappend cyclo [list "shihohappo-suriken" "Shihohappo Suriken" 0 -1 0]	
	lappend cyclo [list "bunshin-no-henge" "Bunshin no Henge no Jutsu" 0 1 10]
	lappend cyclo [list "rasengan" "Rasengan" [expr (3+$par)*(4+$par)] 1 50]	
	lappend cyclo [list "odama-rasengan" "Odama Rasengan" [expr 3*(3+$par)*(4+$par)/2] 1 100]
	lappend cyclo [list "rasen-cho-tarengan" "Rasen Cho Tarengan" [expr (3+$par)*(4+$par)] $par 200]
	lappend cyclo [list "sennin-mode" "Sennin Mode" 0 -1 60]
	lappend cyclo [list "konoha-senpu" "Konoha Senpu" 0 0 0]
	lappend cyclo [list "shofu" "Shofu" [expr 3 + $par] 1 10]
	lappend cyclo [list "konoha-dai-senpu" "Konoha Dai Senpu" 0 0 0]
	lappend cyclo [list "omote-renge" "Omote Renge" [expr 3*(3+$par)*(2+$par/2)/2] 1 25]
	lappend cyclo [list "ura-renge" "Ura Renge" [expr 3*(3+$par)*(2+$par/2)/2] 1 25]
	lappend cyclo [list "konoha-goriki-senpu" "Konoha Goriki Senpu" 0 0 0]
	lappend cyclo [list "tsuten-kyaku" "Tsuten Kyaku" 0 0 0]
	lappend cyclo [list "asakujaku" "Asakujaku" [expr 3 + $par] [expr 4 + $par] 100]
	lappend cyclo [list "konoha-congoriki-senpu" "Geki Konoha Congoriki Senpu" 0 0 0]
	lappend cyclo [list "hirudora" "Hirudora" [expr (3+$par)*(4+$par)] 1 200]
	lappend cyclo [list "bunshin-taiatari" "Bunshin Taiatari" 0 0 0]
	lappend cyclo [list "naruto-rendan" "Uzumaki Naruto Rendan" 0 0 0]
	lappend cyclo [list "naruto-nisen-rendan" "Uzumaki Naruto Nisen Rendan" [expr 2*(3+$par)*(2+$par/2+$par2)] 1 100]
	lappend cyclo [list "naruto-yonsen-rendan" "Uzumaki Naruto Yonsen Rendan" [expr 3*(3+$par)*(2+$par/2+$par2)] 1 150]
	lappend cyclo [list "shoshitsu" "Shoshitsu" 0 0 0]
	lappend cyclo [list "hosho" "Hosho" 0 0 0]
	lappend cyclo [list "kawarimi" "Kawarimi no Jutsu" 0 1 10]
	lappend cyclo [list "kage-bunshin" "Kage Bunsin no Jutsu" 0 $par 5]
	lappend cyclo [list "futon-zankuha" "Futon: Zankuha" [expr 7*$par] 1 15]
	lappend cyclo [list "futon-zankukyokuha" "Futon: Zankukyokuha" [expr 10*$par] 1 25]
	lappend cyclo [list "futon-shinku-gyoku" "Futon: Shinku Gyoku" 10 $par 15]
	lappend cyclo [list "futon-hien" "Hien" 0 0 0]
	lappend cyclo [list "futon-shinku-dai-gyoku" "Futon: Shinku Dai Gyoku" [expr 20*$par] 1 30]
	lappend cyclo [list "futon-shinkuha" "Futon: Shinkuha" [expr 10*$par] 1 25]
	lappend cyclo [list "futon-reppusho" "Futon: Reppusho" 0 0 0]
	lappend cyclo [list "futon-shinku-renpa" "Futon: Shinku Renpa" [expr 30*$par] 1 60]
	lappend cyclo [list "futon-rasengan" "Futon: Rasengan" [expr (3+$par)*(4+$par)] 1 50]
	lappend cyclo [list "futon-kazekiri" "Futon: Kazekiri no Jutsu" [expr 15*$par] 1 50]
	lappend cyclo [list "futon-kiryu-ranbu" "Futon: Kiryu Ranbu" [expr 15*$par] 1 75]
	lappend cyclo [list "futon-rasensuriken" "Futon: Rasensuriken" [expr 40*$par] 1 150]
	lappend cyclo [list "raiko-kenka" "Kuchiese: Raiko Kenka" 0 -1 15]
	lappend cyclo [list "kuchiese-kusarigama" "Kuchiese: Kusarigama" 0 -1 15]
	lappend cyclo [list "kuchiese-meisu" "Kuchiese: Meisu" 0 -1 25]
	lappend cyclo [list "soshuga" "Soshuga" 0 -1 25]
	lappend cyclo [list "soshoryu" "Soshoryu" [expr 10*$par] 1 25]
	lappend cyclo [list "sofusha-san-no-tachi" "Sofusha San no Tachi" 7 $par 10]
	lappend cyclo [list "sogu-tensasai" "Sogu: Tensasai" [expr 15*$par] 1 50]
	lappend cyclo [list "kuchiese-ninkame" "Kuchiese: Ninkame" [expr $par*3] 0 75]
	lappend cyclo [list "tengoku-no-kuchiese" "Tengoku no Kuchiese" 0 0 75]
	lappend cyclo [list "kuchiese-gamabunta" "Kuchiese: Gamabunta" [expr $par*3] 0 75]
	lappend cyclo [list "kuchiese-yatai-kuzushi" "Kuchiese: Yatai Kuzushi no Jutsu" 0 0 100]
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
