set_help_text trainer "trainer stuff .. blabla ..
 usage:
  trainer             bla
  trainer <name>          blabla
  trainer <name> all        bla 
  trainer <name> \[<items> ..\]  blabla
  trainer deactivate        bla
 examples:
  trainer frogger all
  trainer circuscharlie 1 2
  trainer pippols lives \"jump shoes\"\
"
set_tabcompletion_proc trainer __tab_trainer
proc __tab_trainer {args} {
	if {[llength $args] == 2} {
		set result [array names ::__trainers]
		lappend result "deactivate"
	} else {
		set result [list]
		set name [lindex $args 1]
		if [info exists ::__trainers($name)] {
			set stuff $::__trainers($name)
			set items [lindex $stuff 0]
			set i 1
			foreach {item_name item_impl} $items {
				lappend result $item_name
				lappend result $i
				incr i
			}
		}
		lappend result "all"
	}
	return $result
}
proc trainer {args} {
	if {[llength $args] > 0} {
		set name [lindex $args 0]
		if {$name != "deactivate"} {
			set requested_items [lrange $args 1 end]
			if ![info exists ::__trainers($name)] {
				error "no trainer for $name."
			}
			set same_trainer [string equal $name $::__active_trainer]
			set items [__trainer_parse_items $name $requested_items]
			if $same_trainer {
				set new_items [list]
				foreach item1 $items item2 $::__trainer_items_active {
					lappend new_items [expr $item1 ^ $item2]
				}
				set ::__trainer_items_active $new_items
			} else {
				__trainer_deactivate
				set ::__active_trainer $name
				set ::__trainer_items_active $items
				__trainer_exec
			}
		} else {
			__trainer_deactivate
			return ""
		}
	}
	__trainer_print
}
proc __trainer_parse_items {name requested_items} {
	set stuff $::__trainers($name)
	set items [lindex $stuff 0]
	set result [list]
	set i 1
	foreach {item_name item_impl} $items {
		set active 0
		if {($requested_items == "all") ||
		  ([lsearch $requested_items $i] != -1) ||
		  ([lsearch $requested_items $item_name] != -1)} {
			set active 1
		}
		lappend result $active
		incr i
	}
	return $result
}
proc __trainer_print {} {
	if {$::__active_trainer == ""} {
		return "no trainer active"
	}
	set result [list]
	set stuff $::__trainers($::__active_trainer)
	set items [lindex $stuff 0]
	lappend result "active trainer: $::__active_trainer"
	set i 1
	foreach {item_name item_impl} $items item_active $::__trainer_items_active {
		set line "$i \["
		if $item_active {
			append line "x"
		} else {
			append line " "
		}
		append line "\] $item_name"
		lappend result $line
		incr i
	}
	join $result \n
}
proc __trainer_exec {} {
	set stuff $::__trainers($::__active_trainer)
	set items [lindex $stuff 0]
	set repeat [lindex $stuff 1]
	foreach {item_name item_impl} $items item_active $::__trainer_items_active {
		if $item_active {
			eval $item_impl
		}
	}
	set ::__trainer_after_id [eval "after $repeat __trainer_exec"]
}
proc __trainer_deactivate {} {
	if ![info exists ::__trainer_after_id] return ;# no trainer active
	after cancel $::__trainer_after_id
	unset ::__trainer_after_id
	set ::__active_trainer ""
}
proc __trainer_deactivate_after_boot {} {
	__trainer_deactivate
	after boot __trainer_deactivate_after_boot
}
__trainer_deactivate_after_boot

proc create_trainer {name repeat items} {
	set ::__trainers($name) [list $items $repeat]
}
proc poke {addr val} {debug write memory $addr $val}
proc peek {addr}   {return [debug read memory $addr]}

proc poke {addr val} {debug write memory $addr $val}
proc peek {addr} {return [debug read memory $addr]}

create_trainer "f1spirit" {time 1} {
	"player 1 always first place" {poke 0xe331 1}
	"all combi's with konami carts" {poke 0xe1de 2}
	"escon" {poke 0xe1fd 1}
	"hyperoff" {poke 0xe1d6 1}
	"maxpoint" {poke 0xe1df 1}
	"player 1 feul" {poke 0xe310 255}
	"player 1 no damage (bitmask)" {poke 0xe328 0}
	"player 2 fuel" {poke 0xe3d0 255}
	"player 2 damage" {poke 0xe3e8 0}
	"player 2 position" {poke 0xe3f1 1}
}

create_trainer "bubble bobble" {time 1} {
	"invincible player 1" {poke 0xdadd 200}
	"invincible player 2" {poke 0xdb6b 100}
	"super bobble" {poke 0xdae8 255}
	"shoot bubbles" {poke 0xdae9 0}
	"shoot fire" {poke 0xdae9 1}
	"extend filled" {#poke 0xdaf4 255}
}

create_trainer "the castle excellent" {time 1} {
	"blue keys" {poke 0xe337 5}
	"red keys" {poke 0xe338 5}
	"purple keys" {poke 0xe339 5}
	"green keys" {poke 0xe33a 5}
	"blue keys" {poke 0xe33b 5}
	"yellow keys" {poke 0xe33c 5}
	"have map" {poke 0xe321 9}
	"have air" {poke 0xe344 255}
	"invincible" {poke 0xe343 255}
	"lives" {poke 0xe336 255}
}

create_trainer "the castle" {time 1} {
	"blue keys" {poke 0xe337 5}
	"red keys" {poke 0xe338 5}
	"purple keys" {poke 0xe339 5}
	"green keys" {poke 0xe33a 5}
	"blue keys" {poke 0xe33b 5}
	"yellow keys" {poke 0xe33c 5}
	"have map" {poke 0xe321 9}
	"have air" {poke 0xe344 255}
	"invincible" {poke 0xe343 255}
	"lives" {poke 0xe336 255}
}

create_trainer "antarctic adventure" {time 60} {
	"time" {poke 0xe0e3 0x11;poke 0xe0e4 0x1}
	"short runs" {poke 0xe0e6 1}
	"difficulty level" {poke 0xe0e0 1}
}

create_trainer "athletic land" {time 0.1} {
	"lives" {poke 0xe050 99}
	"x-pos cabbage" {poke 0xe0e9 1}
	"y-pos cabbage" {poke 0xe0e8 0}
	"bird x-pos" {poke 0xe101 0}
	"bird y-pos" {poke 0xe100 0}
	"stone x-pos" {poke 0xe109 0}
	"stone y-pos" {poke 0xe10a 0}
}

create_trainer "cabbage patch kids" {time 0.1} {
	"lives" {poke 0xe050 99}
	"x-pos cabbage" {poke 0xe0e9 1}
	"y-pos cabbage" {poke 0xe0e8 0}
	"bird x-pos" {poke 0xe101 0}
	"bird y-pos" {poke 0xe100 0}
	"stone x-pos" {poke 0xe109 0}
	"stone y-pos" {poke 0xe10a 0}
}

create_trainer "circus charlie" {time 0.5} {
	"lives" {poke 0xe050 99}
	"hoop/ball" {poke 0xe150 0}
	"monkey 1 x-pos" {poke 0xe1b0 0}
	"monkey 2 x-pos" {poke 0xe170 0}
}

create_trainer "comic bakery" {time 2} {
	"lives" {poke 0xe050 99}
	"beams" {poke 0xe120 99}
	"items done" {poke 0xe060 16}
	"all machines active" {poke 0xe057 112}
	"sleepy beavers" {poke 0xe111 255;poke 0xe113 255;poke 0xe115 255}
}

create_trainer "frogger" {time 2} {
	"lives" {poke 0xe002 99}
	"time" {poke 0xe052 16}
}

create_trainer "pippols" {time 2} {
	"lives" {poke 0xe050 0x99}
	"invincible" {poke 0xe11b 255}
	"running shoes" {poke 0xe1a8 1}
	"jump shoes" {poke 0xe1a9 1}
}

create_trainer "kings valley 1" {time 2} {
	"lives" {poke 0xe050 99}
	"door is always open" {poke 0xe1f2 1;poke 0xe1f3 1}
}

create_trainer "konamis boxing" {time 1} {
	"lives" {poke 0xe218 0}
}

create_trainer "hyper rally" {time 2} {
	"always first place" {poke 0xe05c 1;poke 0xe05b 0}
	"fuel always full" {poke 0xe065 255}
}

create_trainer "magical tree" {time 2} {
	"99 lives" {poke 0xe050 99}
}

create_trainer "mopi ranger" {time 1} {
	"99 lives" {poke 0xe050 99}
	"y-position grey enemy" {poke 0xe160 7}
	"y-position red enemy" {poke 0xe190 7}
	"y-position yellow enemy" {poke 0xe1c0 7}
	"y-position blue enemy" {poke 0xe1f0 7}
	"y-position big razzon" {poke 0xe220 7}
}

create_trainer "qbert" {time 2} {
	"lives" {poke 0xe110 0x99}
	"no enemies" {poke 0xe321 255}
	"always protected" {poke 0xe345 255}
	"infinite time" {poke 0xec51 0x99}
}

create_trainer "road fighter" {time 0.25} {
	"99 lives" {poke 0xe083 220}
	"y-position car 1" {poke 0xe0eb 191}
	"x-position car 1" {poke 0xe0ed 0}
	"y-position car 2" {poke 0xe0fb 191;poke 0xe0fd 0}
}

create_trainer "sky jaguar" {time 2} {
	"99 lives" {poke 0xe050 0x99}
}

create_trainer "super cobra" {time 2} {
	"99 lives" {poke 0xe050 0x99}
	"fuel" {poke 0xe51c 128}
}

create_trainer "time pilot" {time 2} {
	"99 lives" {poke 0xe003 0x99}
}

create_trainer "twinbee" {time 1} {
	"lives player 1" {poke 0xe070 0x99}
	"lives player 2" {poke 0xe073 0x99}
	"speed player 1" {poke 0xe081 3}
	"speed player 2" {poke 0xe082 3}
	"player 1 - single shoot" {poke 0xe083 0}
	"player 1 - double shoot" {poke 0xe083 1}
	"player 1 - options + single shoot" {poke 0xe083 2}
	"player 1 - options + double shoot" {poke 0xe083 3}
	"player 1 - shield + single shoot" {poke 0xe083 4}
	"player 1 - shield + double shoot" {poke 0xe083 5}
	"player 1 - options + shield + single shoot" {poke 0xe083 6}
	"player 1 - options + shield + double shoot" {poke 0xe083 7}
	"player 1 - spread shoot" {poke 0xe083 8}
	"player 1 - options + spread shoot" {poke 0xe083 10}
	"player 1 - shield + spread shoot" {poke 0xe083 12}
	"player 1 - options + shield + spread shoot" {poke 0xe083 14}
	"player 2 - single shoot" {poke 0xe084 0}
	"player 2 - double shoot" {poke 0xe084 1}
	"player 2 - options + single shoot" {poke 0xe084 2}
	"player 2 - options + double shoot" {poke 0xe084 3}
	"player 2 - shield + single shoot" {poke 0xe084 4}
	"player 2 - shield + double shoot" {poke 0xe084 5}
	"player 2 - options + shield + single shoot" {poke 0xe084 6}
	"player 2 - options + shield + double shoot" {poke 0xe084 7}
	"player 2 - spread shoot" {poke 0xe084 8}
	"player 2 - options + spread shoot" {poke 0xe084 10}
	"player 2 - shield + spread shoot" {poke 0xe084 12}
	"player 2 - options + shield + spread shoot" {poke 0xe084 14}
}

create_trainer "yiearkungfu1" {time 5} {
	"power bar" {poke 0xe116 32}
	"kill enemy with one hit" {poke 0xe117 0}
}

create_trainer "dota" {time 2} {
	"full energy" {poke 0xe49c 32;poke 0xe49d 32}
	"full ammo" {poke 0xe49e 10;poke 0xe49f 10}
	"full power shield" {poke 0xe504 10}
	"have wings" {poke 0xe475 3}
	"have always 9 keys" {poke 0xe470 9}
}

create_trainer "gradius 1" {time 0.5} {
	"lives" {poke 0xe060 0x99}
	"speed set to 4" {poke 0xe10b 4}
	"missile" {poke 0xe132 1}
	"double" {poke 0xe133 1}
	"laser" {poke 0xe134 1}
	"option" {poke 0xe135 1;poke 0xe20b 2}
	"shield" {poke 0xe136 2;poke 0xe201 10}
	"shield on" {poke 0xe200 3}
	"shield off" {poke 0xe200 1}
	"always hyper" {poke 0xe202 8}
	"deactivate normal shot" {poke 0xe20c 0}
	"enable double" {poke 0xe20d 2}
	"enable laser" {poke 0xe20e 2}
	"enable missile" {poke 0xe20f 2}
	"enable option 1" {poke 0xe220 1}
	"enable option 2" {poke 0xe240 1}
	"simulate twinbee in slot 2" {poke 0xf0f4 1}
	"use unlimited hyper" {poke 0xe06e 0}
	"use unlimited per stage hyper" {poke 0xe071 0}
}

create_trainer "gradius 1 (scc version)" {time 2} {
	"lives" {poke 0xc060 0x99}
	"speed set to 4" {poke 0xc10b 4}
	"missile" {poke 0xc132 1}
	"double" {poke 0xc133 1}
	"laser" {poke 0xc134 1}
	"option" {poke 0xc135 1;poke 0xc20b 2}
	"shield" {poke 0xc136 2;poke 0xc201 10}
	"shield on" {poke 0xe200 3}
	"shield off" {poke 0xe200 1}
	"always hyper" {poke 0xc202 8}
	"deactivate normal shot" {poke 0xc20c 0}
	"enable double" {poke 0xc20d 2}
	"enable laser" {poke 0xc20e 2}
	"enable missile" {poke 0xc20f 2}
	"enable option 1" {poke 0xc220 1}
	"enable option 2" {poke 0xc240 1}
}

create_trainer "gradius 2" {time 0.5} {
	"lives" {poke 0xe200 0x99}
	"nice colors" {poke 0xe283 14;poke 0xe408 15}
	"shield 0=off 2=on" {poke 0xe400 2}
	"speed set to 5" {poke 0xe402 5}
	"options" {poke 0xe40b 2;poke 0xe410 1;poke 0xe420 1}
	"deactivate normal shot" {poke 0xe430 0}
	"double" {poke 0xe431 2}
	"normal" {poke 0xe432 1}
	"double" {poke 0xe432 2}
	"extended" {poke 0xe432 3}
	"reflex ring" {poke 0xe432 5}
	"fire blaster" {poke 0xe432 6}
	"normal" {poke 0xe433 1}
	"double" {poke 0xe433 2}
	"napalm" {poke 0xe433 3}
	"up laser" {poke 0xe434 2}
	"down laser" {poke 0xe435 2}
	"back beam" {poke 0xe436 2}
	"option ring" {poke 0xe439 3}
	"rotary drill" {poke 0xe439 4}
	"enemy slow" {poke 0xe439 5}
	"vector laser" {poke 0xe439 7}
	"metalion mode" {poke 0xe446 1}
	"q-bert mode" {poke 0xf0f5 1}
	"penguin adventure mode" {poke 0xf0f5 4}
	"the maze of galious mode" {poke 0xf0f5 8}
	"all modes" {poke 0xf0f5 255}
}

create_trainer "gradius 2 (beta)" {time 2} {
	"lives" {poke 0xe200 0x99}
	"nice colors" {poke 0xe283 14;poke 0xe408 15}
	"shield 0=off 2=on" {poke 0xe400 2}
	"speed set to 5" {poke 0xe402 5}
	"options" {poke 0xe40b 2;poke 0xe410 1;poke 0xe420 1}
	"deactivate normal shot" {poke 0xe430 0}
	"double" {poke 0xe431 2}
	"normal" {poke 0xe432 1}
	"double" {poke 0xe432 2}
	"extended" {poke 0xe432 3}
	"reflex ring" {poke 0xe432 5}
	"fire blaster" {poke 0xe432 6}
	"normal" {poke 0xe433 1}
	"double" {poke 0xe433 2}
	"napalm" {poke 0xe433 3}
	"up laser" {poke 0xe434 2}
	"down laser" {poke 0xe435 2}
	"back beam" {poke 0xe436 2}
	"option ring" {poke 0xe439 3}
	"rotary drill" {poke 0xe439 4}
	"enemy slow" {poke 0xe439 5}
}

create_trainer "golvellius 1" {time 1} {
	"max health and full bar" {poke 0xe022 240;poke 0xe03d 240}
	"all items" {poke 0xe01d 7;poke 0xe01f 3;poke 0xe020 6;poke 0xe021 2;poke 0xe03c 1;poke 0xe03f 5}
	"leafs" {poke 0xe0a4 3}
	"max gold" {poke 0xe050 255;poke 0xe051 255}
	"do not get paralyzed when hit by an enemy (after frame)" {poke 0xd01a 0}
	"get all crystals (bitmask)" {poke 0xe05f 255}
}

create_trainer "goonies" {time 1} {
	"vitality" {poke 0xe064 80}
	"experience" {poke 0xe065 80}
	"always have key" {poke 0xe121 1}
	"open door to next stage" {poke 0xe130 7}
	"protected from most enemies" {poke 0xe176 255}
	"protected from water, fire, bats and shoots" {poke 0xe177 255}
	"protected from falling stones" {poke 0xe178 1}
	"extra vitality (1=experience)" {poke 0xe179 4}
	"show hidden items" {poke 0xe2ed 2}
}

create_trainer "thexder 1" {time 2} {
	"energy" {poke 0xf2d4 255;poke 0xf2d6 255}
	"disable killer missiles" {poke 0xf2ec 255}
}

create_trainer "thexder 2" {time 2} {
	"do not loose power while shooting" {poke 0x12d5 255}
	"shield power does not decline" {poke 0x12f8 255}
	"missiles" {poke 0x12e6 99}
	"dart missiles" {poke 0x134e 99}
	"napalm bomb" {poke 0x134f 99}
	"flashers" {poke 0x1350 99}
	"max energy 500" {poke 0x12d8 250}
}

create_trainer "craze" {time 2} {
	"life" {poke 0xc054 20}
	"ammo" {poke 0xc059 80}
	"something" {poke 0xc05a 6}
	"max shot" {poke 0xc064 255}
	"max front shield" {poke 0xc067 255}
	"max back shield" {poke 0xc069 255}
	"max back shield" {poke 0xc069 255}
	"side shield" {poke 0xc06a 255}
	"spikes" {poke 0xc06a 255}
	"thrusters" {poke 0xc06c 255}
	"wings" {poke 0xc06d 255}
}

create_trainer "zombie hunter" {time 1} {
	"exp" {poke 0xc7e6 255;poke 0xc7e7 255}
	"life bar" {poke 0xc7ea 255;poke 0xc7eb 255}
	"max level" {poke 0xc7ee 31}
}

create_trainer "xevious" {time 2} {
	"have all weapons and shield" {poke 0xc005 255}
	"lives" {poke 0xc502 99}
}

create_trainer "parodius" {time 1} {
	"lives" {poke 0xe240 0x99}
	"stage (1-6=normal;7-9=bonus)" {#poke 0xe241 1}
	"more bells" {poke 0xe251 255;poke 0xe253 255;poke 0xe254 255;poke 0xe256 255}
	"full power" {poke 0xe268 4}
	"speed set to 4" {poke 0xe335 4}
	"shield 0=off 2=on" {poke 0xe400 2}
	"shield" {poke 0xe402 2;poke 0xe40a 15;poke 0xeb07 15}
	"option" {poke 0xe40b 2}
	"enable option 1" {poke 0xe410 1}
	"enable option 2" {poke 0xe420 1}
	"disable normal shoot" {poke 0xe430 0}
	"enable double" {poke 0xe431 2}
	"enable laser" {poke 0xe432 2}
	"enable missile " {poke 0xe433 2}
}

create_trainer "salamander" {time 1} {
	"who needs a shield anyway" {poke 0xe202 0}
	"lives player 1" {poke 0xe300 0x99}
	"stage (1-7)" {}
	"1-6 = normal stage" {#poke 0xe301 1}
	"7 = special stage (requires gradius 2 in slot 2)" {#poke 0xe301 1}
	"scroll stop (only for part of stage 1)" {#poke 0xe309 1}
	"all special weapons player 1" {poke 0xe310 7}
}

create_trainer "jackie chan protector" {time 10} {
	"life bar" {poke 0xe024 5}
	"lives" {poke 0xe016 9}
}

create_trainer "zanac" {time 1} {
	"invincible" {poke 0xe305 128;poke 0xe31b 255}
	"super shot" {poke 0xe10f 48}
	"lives" {poke 0xe10a 99}
	"eye 1 power" {poke 0xe559 1}
	"eye 2 power" {poke 0xe569 1}
	"eye 3 power" {poke 0xe579 1}
	"eye 4 power" {poke 0xe589 1}
	"eye 5 power" {poke 0xe599 1}
	"eye 6 power" {poke 0xe5a9 1}
	"eye 7 power" {poke 0xe5b9 1}
	"eye 8 power" {poke 0xe5c9 1}
	"eye 9 power" {poke 0xe5d9 1}
	"eye 10 power" {poke 0xe5e9 1}
	"eye 11 power" {poke 0xe5f9 1}
	"eye 12 power" {poke 0xe619 1}
	"eye 13 power" {poke 0xe629 1}
	"eye 14 power" {poke 0xe639 1}
}

create_trainer "zanac-ex" {time 1} {
	"lives" {poke 0xc012 100}
	"primary weapon max level" {poke 0xc013 4;poke 0xc016 4;poke 0xc03f 3;poke 0xc040 3;poke 0xc104 2;poke 0xc161 2}
	"secondary weapon max level" {poke 0xc041 2}
	"invincible" {poke 0xc405 128}
	"set timer to max" {poke 0xc416 255}
}

create_trainer "mr ghost" {time 10} {
	"life and attacks" {poke 0xc28e 255;poke 0xc3a6 32;poke 0xc01d 255;poke 0xc01e 255}
	"invincible" {poke 0xc291 255}
}

create_trainer "dragon buster" {time 5} {
	"life and attacks" {poke 0xc312 0x99;poke 0xc313 0x5}
	"exp" {poke 0xc2e2 0x99}
}

create_trainer "feedback" {time 2} {
	"missiles" {poke 0xd214 99}
	"life" {poke 0xd213 16}
	"speed" {poke 0xd212 10}
	"invincible" {poke 0xd21b 255}
	"red missile" {poke 0xd17a 255;poke 0xd17e 2}
	"have one red missile ready" {poke 0xd21a 1}
	"keep missile on screen" {poke 0xd10a 255;poke 0xd11a 255;poke 0xd12a 255;poke 0xd13a 255;poke 0xd14a 255;poke 0xd15a 255;poke 0xd16a 255}
}

create_trainer "herzog" {time 2} {
	"own damage" {poke 0xd033 0}
	"base damage" {poke 0xd034 0}
	"max money" {poke 0xd035 255;poke 0xd036 255}
	"lives" {poke 0xd040 99}
	"blow up player 2 base" {poke 0xd087 255}
	"wait off cheat (ctrl-esc-f5)" {poke 0xd1b3 255}
}

create_trainer "xak 1" {time 2} {
	"exp" {poke 0x1c60 255;poke 0x1c61 255}
	"gold" {poke 0x1c62 255;poke 0x1c63 255}
	"life" {poke 0x2377 255}
	"super latok mode" {poke 0x1fd4 1;poke 0x2473 0x44}
	"enchanted sword 1" {poke 0x1c13 99}
	"enchanted sword 2" {poke 0x1c14 99}
	"enchanted sword 3" {poke 0x1c15 99}
	"enchanted sword 4" {poke 0x1c16 99}
	"enchanted sword 5" {poke 0x1c17 99}
	"enchanted sword 6" {poke 0x1c18 99}
	"enchanted armor 1" {poke 0x1c19 99}
	"enchanted armor 2" {poke 0x1c1a 99}
	"enchanted armor 3" {poke 0x1c1b 99}
	"enchanted armor 4" {poke 0x1c1c 99}
	"enchanted armor 5" {poke 0x1c1d 99}
	"enchanted armor 6" {poke 0x1c1e 99}
	"enchanted armor 1" {poke 0x1c1f 99}
	"enchanted armor 2" {poke 0x1c20 99}
	"enchanted armor 3" {poke 0x1c21 99}
	"enchanted armor 4" {poke 0x1c22 99}
	"enchanted armor 5" {poke 0x1c23 99}
	"enchanted armor 6" {poke 0x1c24 99}
	"bread" {poke 0x1c25 99}
	"meat" {poke 0x1c26 99}
	"glasses" {poke 0x1c27 99}
	"arm protector" {poke 0x1c28 99}
	"blue ring" {poke 0x1c29 99}
	"green (evil?) ring" {poke 0x1c2a 99}
	"potion" {poke 0x1c2b 99}
	"wheel" {poke 0x1c2c 99}
	"purple cape" {poke 0x1c2d 99}
	"feather/grass (?)" {poke 0x1c2e 99}
	"light green scroll" {poke 0x1c2f 99}
	"blue scroll" {poke 0x1c30 99}
	"red scroll" {poke 0x1c31 99}
	"green scroll" {poke 0x1c32 99}
	"purple scroll" {poke 0x1c33 99}
	"blue ball" {poke 0x1c34 99}
	"green ball" {poke 0x1c35 99}
	"red ball" {poke 0x1c36 99}
	"red cape" {poke 0x1c37 99}
	"paint bucket (?)" {poke 0x1c38 99}
	"paint boat (?)" {poke 0x1c39 99}
	"water bottle (?)" {poke 0x1c3a 99}
	"yellow key (?)" {poke 0x1c3b 99}
	"blue key (?)" {poke 0x1c3c 99}
	"treasure box" {poke 0x1c3d 99}
	"bunny" {poke 0x1c3e 99}
	"bunny" {poke 0x1c3e 99}
	"necklace with stone" {poke 0x1c3f 99}
	"butterfly broche" {poke 0x1c40 99}
	"purple bottle" {poke 0x1c41 99}
	"thee pot" {poke 0x1c42 99}
	"red key" {poke 0x1c43 99}
	"purple key" {poke 0x1c44 99}
}

create_trainer "sd-snatcher" {time 1} {
	"max out all stats" {poke 0xce82 255;poke 0xce83 255;poke 0xce85 255;poke 0xce86 255;poke 0xce88 255;poke 0xce89 255;poke 0xce8b 255;poke 0xce8c 255}
	"max life" {poke 0xce81 255}
	"money" {poke 0xce8d 255;poke 0xce8e 255}
	"all locations accessible" {poke 0xcdc0 255;poke 0xcdc1 1}
	"junkers" {poke 0xc451 99}
	"newtrits" {poke 0xc459 99}
	"newtrits" {poke 0xc459 99}
	"jyro" {poke 0xc461 99}
	"bomb" {poke 0xc400 2;poke 0xc401 255}
	"dball" {poke 0xc408 2;poke 0xc409 255}
	"rancher" {poke 0xc410 2;poke 0xc411 255}
	"t blaster" {poke 0xc418 2;poke 0xc419 255}
	"g mine" {poke 0xc420 2;poke 0xc421 255}
	"comet" {poke 0xc428 2;poke 0xc429 255}
	"chaf" {poke 0xc430 2;poke 0xc431 255}
	"milkyway" {poke 0xc438 2;poke 0xc439 255}
	"c killer" {poke 0xc440 2;poke 0xc441 255}
	"flare" {poke 0xc448 2;poke 0xc449 255}
	"stingray" {poke 0xc3a8 2;poke 0xc4a9 255}
	"skill for stingray" {poke 0xc3ad 100}
	"ammo for stingray" {poke 0xc3a9 231;poke 0xc3aa 3}
	"f. ball" {poke 0xc3b0 2;poke 0xc4b1 255}
	"skill for f. ball" {poke 0xc3b5 100}
	"ammo for f. ball" {poke 0xc3b1 231;poke 0xc3b2 3}
	"k. sprint" {poke 0xc3b8 2;poke 0xc4b9 255}
	"skill for k. sprint" {poke 0xc3bd 100}
	"ammo for k. sprint" {poke 0xc3b9 231;poke 0xc3ba 3}
	"storm" {poke 0xc3c0 2;poke 0xc4c1 255}
	"skill for storm" {poke 0xc3c5 100}
	"ammo for storm" {poke 0xc3c1 231;poke 0xc3c2 3}
	"k. sprint" {poke 0xc3c8 2;poke 0xc4c9 255}
	"skill for k. sprint" {poke 0xc3cd 100}
	"ammo for k. sprint" {poke 0xc3c9 231;poke 0xc3ca 3}
	"b. hawk" {poke 0xc3d0 2;poke 0xc4d1 255}
	"skill for b. hawk" {poke 0xc3d5 100}
	"ammo for b. hawk" {poke 0xc3d1 231;poke 0xc3d2 3}
	"g. hound" {poke 0xc3d8 2;poke 0xc4d9 255}
	"skill for g. hound" {poke 0xc3dd 100}
	"ammo for g.hound" {poke 0xc3d9 231;poke 0xc3da 3}
	"i. cepter" {poke 0xc3e0 2;poke 0xc4e1 255}
	"skill for i. cepter" {poke 0xc3e5 100}
	"ammo for i. cepter" {poke 0xc3e1 231;poke 0xc3e2 3}
	"s. grade" {poke 0xc3e8 2;poke 0xc4e9 255}
	"skill for s. grade" {poke 0xc3ed 100}
	"ammo for s. grade" {poke 0xc3e9 231;poke 0xc3ea 3}
	"n. point" {poke 0xc3f0 2;poke 0xc4f1 255}
	"skill for n. point" {poke 0xc3f5 100}
	"ammo for n. point" {poke 0xc3f1 231;poke 0xc3f2 3}
	"big 9 matrix" {poke 0xc3f8 2;poke 0xc4f9 255}
	"skill for g. matrix" {poke 0xc3fd 100}
	"ammo for big 9 matrix" {poke 0xc3f9 231;poke 0xc3fa 3}
	"kill little spiders in one blast" {poke 0xc820 0;poke 0xc840 0}
	"max rank" {poke 0xce80 64}
	"max strength level" {poke 0xce84 64}
	"max deference level" {poke 0xce87 64}
	"max speed level" {poke 0xce8a 64}
	"walk trough walls on" {poke 0x92b6 0xc9}
	"walk trough walls off" {poke 0x92b6 0}
}

create_trainer "undeadline" {time 2} {
	"lives" {poke 0xd2a9 2}
	"power" {poke 0xd2a8 255}
	"invincible to monsters" {poke 0xd2b7 255}
	"have knife" {poke 0xd2ab 0}
	"have axe" {poke 0xd2ab 1}
	"have fire" {poke 0xd2ab 2}
	"have ice" {poke 0xd2ab 3}
	"have triple-knife" {poke 0xd2ab 4}
	"have boomerang" {poke 0xd2ab 5}
	"have vortex" {poke 0xd2ab 6}
}

create_trainer "androgynous" {time 1} {
	"shield always on" {poke 0xeca1 255}
	"lives" {poke 0xe01b 255}
	"speed" {poke 0xec2b 16}
	"shot strength" {poke 0xec3b 3}
	"normal shot" {poke 0xec3a 1}
	"big shots" {poke 0xec3a 2}
	"pod with up/down shot" {poke 0xec3a 3}
	"laser" {poke 0xec3a 4}
	"big bouncing balls" {poke 0xec3a 5}
	"backpack" {poke 0xec2c 2}
}

create_trainer "aliens" {time 1} {
	"ripley life" {poke 0x042a 255}
	"ripley ammo" {poke 0x042d 32}
}

create_trainer "aliens2 (msx1)" {time 15} {
	"invincible" {poke 0xe707 255}
	"life bar" {poke 0xe247 16}
	"m40 boms" {poke 0xe28f 250}
	"twin pulse ammo" {poke 0xe28e 250}
}

create_trainer "galaga" {time 2} {
	"lives" {poke 57358 99}
}

create_trainer "girly block" {time 2} {
	"player 1 life" {poke 0xe030 255}
	"player 1 fuel" {poke 0xe031 255}
	"player 1 level" {poke 0xe032 255}
	"player 2 life" {poke 0xe0f0 0}
	"player 2 fuel" {poke 0xe0f1 0}
	"player 2 level" {poke 0xe0f2 0}
}

create_trainer "fantasy zone 1" {time 2} {
	"money" {poke 0xe20d 0x99;poke 0xe20c 0x99;poke 0xe20b 0x99}
}

create_trainer "fantasy zone 2" {time 1} {
	"money" {poke 0xe599 0x99;poke 0xe59a 0x99;poke 0xe59b 0x99}
	"lives" {poke 0xe5ad 0x99}
}

create_trainer "rich and mich" {time 10} {
	"shield" {poke 0xce13 255}
}

create_trainer "super pierot" {time 1} {
	"have ball" {poke 0xe7f0 1}
	"lives" {poke 0xe046 255}
}

create_trainer "magical wizzkid" {time 2} {
	"lives" {poke 0xc00c 255}
	"diamond" {poke 0xc098 200}
	"flask" {poke 0xc096 200}
	"guardian angel" {poke 0xc095 200}
	"fire" {poke 0xc094 200}
	"explosion" {poke 0xc093 200}
	"speed up potion" {poke 0xc092 200}
	"time stopper" {poke 0xc091 200}
	"power shot" {poke 0xc090 200}
	"staff" {poke 0xc08f 200}
}

create_trainer "metalgear 1" {time 1} {
	"power bar" {poke 0xc131 48}
	"handgun in slot 1" {poke 0xc500 1;poke 0xc501 0x99;poke 0xc502 0x9}
	"smg in slot 2" {poke 0xc504 2;poke 0xc505 0x99;poke 0xc506 0x9}
	"grenade launcher in slot 3" {poke 0xc508 3;poke 0xc509 0x99;poke 0xc50a 0x9}
	"rocket launcher in slot 4" {poke 0xc50c 4;poke 0xc50d 0x99;poke 0xc50e 0x9}
	"p-bomb in slot 5" {poke 0xc510 5;poke 0xc511 0x99;poke 0xc512 0x9}
	"l-main in slot 6" {poke 0xc514 6;poke 0xc515 0x99;poke 0xc516 0x9}
	"missile in slot 7" {poke 0xc518 7;poke 0xc519 0x99;poke 0xc51a 0x9}
	"silencer in slot 4" {poke 0xc51c 8}
	"enemies can't hurt you" {poke 0xc199 255}
	"cart 1" {poke 0xc5ad 1;poke 0xc538 14;poke 0xc539 49}
	"cart 2" {poke 0xc5ae 1;poke 0xc53c 15;poke 0xc53d 50}
	"cart 3" {poke 0xc5af 1;poke 0xc540 16;poke 0xc541 51}
	"cart 4" {poke 0xc5b0 1;poke 0xc544 17;poke 0xc545 52}
	"cart 5" {poke 0xc5b1 1;poke 0xc548 18;poke 0xc549 53}
	"cart 6" {poke 0xc5b2 1;poke 0xc54c 19;poke 0xc54d 54}
	"cart 7" {poke 0xc5b3 1;poke 0xc550 20;poke 0xc551 55}
	"cart 8" {poke 0xc5b4 1;poke 0xc554 21;poke 0xc555 56}
	"ratio" {poke 0xc535 0x99;poke 0xc534 22}
	"armor" {poke 0xc558 1}
	"bomb blast suit" {poke 0xc55c 2}
	"flash light" {poke 0xc560 3}
	"goggles" {poke 0xc564 4}
	"gas mask" {poke 0xc568 5}
	"mine detector" {poke 0xc56c 7}
	"antenna" {poke 0xc570 8}
	"parachute" {poke 0xc574 9}
	"scope" {poke 0xc578 10}
	"oxygen" {poke 0xc57c 11}
	"compas" {poke 0xc580 12}
	"antidote" {poke 0xc584 13}
	"uniform" {poke 0xc588 24}
	"box" {poke 0xc58c 25}
	"put a nuclear warhead on your remote missiles 8)" {poke 0xc142 16}
	"active keycard" {poke 0xc135 x}
	"stop destruction timer" {poke 0xc13d 0x99}
	"enemy 1 gone" {poke 0xd005 0}
	"enemy 2 gone" {poke 0xd085 0}
	"enemy 3 gone" {poke 0xd105 0}
	"enemy 4 gone" {poke 0xd185 0}
}

create_trainer "metalgear 2" {time 2} {
	"life bar" {poke 0xca53 32}
	"get gun" {poke 0xd600 1;poke 0xd601 0x99;poke 0xd602 0x9}
	"get sub machine gun" {poke 0xd604 1;poke 0xd605 0x99;poke 0xd606 0x9}
	"get grenades" {poke 0xd608 1;poke 0xd609 0x99;poke 0xd60a 0x9}
	"get surface to air missiles" {poke 0xd610 1;poke 0xd611 0x99;poke 0xd612 0x9}
	"get remote missiles" {poke 0xd614 1;poke 0xd615 0x99;poke 0xd616 0x9}
	"get c4 explosives" {poke 0xd618 1;poke 0xd619 0x99;poke 0xd61a 0x9}
	"get landmines" {poke 0xd61c 1;poke 0xd61d 0x99;poke 0xd61e 0x9}
	"get camouflage" {poke 0xd620 1;poke 0xd621 0x99;poke 0xd622 0x9}
	"get gas grenade" {poke 0xd624 1;poke 0xd625 0x99;poke 0xd626 0x9}
	"get remote mice" {poke 0xd628 1;poke 0xd629 0x99;poke 0xd630 0x9}
	"get zippo" {poke 0xd634 1;poke 0xd635 1}
	"get silencer" {poke 0xd62c 1;poke 0xd62d 1}
	"do not sink into the swamp" {poke 0xcb29 32}
	"invisible until an alert is triggered" {poke 0xca3c 1}
	"set avoiding time to 0" {poke 0xd42b 0}
	"open path trough jungle" {poke 0xd430 2}
}

create_trainer "usas" {time 1} {
	"money" {poke 49753 0x99;poke 49754 0x99}
	"live for cles" {poke 0xc2d5 255}
	"cles's stars for speed" {poke 0xc2d1 4}
	"cles's stars for jumping" {poke 0xc2d2 2}
	"cles's mood happy" {poke 0xc2b6 0}
	"cles's mood normal" {poke 0xc2b6 1}
	"cles's mood sad" {poke 0xc2b6 2}
	"cles's mood angry" {poke 0xc2b6 3}
	"live for wit" {poke 0xc2b5 255}
	"wit's stars for speed" {poke 0xc2b1 4}
	"wit's stars for jumping" {poke 0xc2b2 2}
	"wit's unlimited air walk" {poke 0xc266 255}
	"wit's mood happy" {poke 0xc2d6 0}
	"wit's mood normal" {poke 0xc2d6 1}
	"wit's mood sad" {poke 0xc2d6 2}
	"wit's mood angry" {poke 0xc2d6 3}
	"all combi's with konami carts" {poke 0xc205 255}
	"invincible player" {poke 0xc256 1}
	"free wit" {poke 0xc2b0 0}
	"free cless" {poke 0xc2d0 0}
	"vitality rate 1 coin" {poke 0xc2b8 1;poke 0xc2b9 0}
	"vitality rate 1 coin" {poke 0xc2ba 1;poke 0xc2bb 0}
	"speed rate 1 coin" {poke 0xc2bc 1;poke 0xc2bd 0}
	"speed rate 1 coin" {poke 0xc2d8 1;poke 0xc2d9 0}
	"jump rate 1 coin" {poke 0xc2da 1;poke 0xc2db 0}
	"jump rate 1 coin" {poke 0xc2dc 1;poke 0xc2dd 0}
	"big door open" {poke 0xe328 1}
}

create_trainer "aleste 1" {time 1} {
	"lives" {poke 0xc010 98}
	"invincible" {poke 0xc810 255}
	"maxed up normal shot" {poke 0xc012 8}
	"maxed up special shot" {poke 0xc019 3}
	"scroll speed slow" {poke 0xc4ad 16}
	"scroll speed normal" {poke 0xc4ad 32}
	"scroll speed fast" {poke 0xc4ad 64}
	"scroll speed insane" {poke 0xc4ad 128}
	"scroll speed turbo" {poke 0xc4ad 255}
	"always keep weapon on 99" {poke 0xc01b 99}
}

create_trainer "aleste 2" {time 1} {
	"lives" {poke 0xc840 99}
	"invincible" {poke 0xbc18 255}
	"weapon has no time limit" {poke 0xc84d 255}
	"have weapon 1" {poke 0xc84a 1}
	"have weapon 2" {poke 0xc84a 2}
	"have weapon 3" {poke 0xc84a 3}
	"have weapon 4" {poke 0xc84a 4}
	"have weapon 5" {poke 0xc84a 5}
	"have weapon 6" {poke 0xc84a 6}
	"have weapon 7" {poke 0xc84a 7}
	"have weapon 8" {poke 0xc84a 8}
	"full power on weapons" {poke 0xc84f 5;poke 0xc84e 50}
}

create_trainer "testament" {time 1} {
	"lives" {poke 0x59d7 144}
	"hand grenades" {poke 0x59de 32}
	"map" {poke 0x59e3 1}
	"strong bullets" {poke 0x59d9 255}
	"shield" {poke 0x59dd 1}
}

create_trainer "ashiguine 3" {time 1} {
	"life" {poke 0xc0da 210}
}

create_trainer "ashiguine 2" {time 2} {
	"life" {poke 0xc016 255}
	"keys" {poke 0xc022 99}
	"enemy power" {poke 0xc052 1;poke 0xc062 1;poke 0xc072 1;poke 0xc082 1;poke 0xc092 1}
}

create_trainer "familice parodic 1" {time 2} {
	"lives" {poke 0xe003 99}
	"eggs" {poke 0xe025 255}
	"invincible" {poke 0xe30e 255}
	"full weapons" {poke 0xe050 4;poke 0xe051 4;poke 0xe052 4;
			poke 0xe053 4;poke 0xe054 4;poke 0xe055 4;
			poke 0xe056 4;poke 0xe057 4;poke 0xe058 4;poke 0xe059 4}
}

create_trainer "mon mon monster" {time 2} {
	"rocks" {poke 0xe038 99}
	"lives" {poke 0xe02c 10}
	"invincible" {poke 0xe31e 255}
	"white power bolt shot" {poke 0xe02d 1}
	"rotating shots" {poke 0xe02e 1}
}

create_trainer "maze of galious" {time 1} {
	"arrows" {poke 0xe046 0x99;poke 0xe047 0x9}
	"coin" {poke 0xe048 0x99;poke 0xe049 0x9}
	"keys" {poke 0xe04a 0x99;poke 0xe04b 0x9}
	"vitality popolon" {poke 0xe056 255;poke 0xe057 255}
	"aphrodite" {poke 0xe053 255;poke 0xe052 255}
	"max exp" {poke 0xe051 1;poke 0xe055 1}
	"bible (ctrl) uses left" {poke 0xe531 255}
	"zeus cheat" {poke 0xe027 1}
	"active weapon - nothing" {poke 0xe510 0}
	"active weapon - arrow" {poke 0xe510 1}
	"active weapon � ceramic arrow" {poke 0xe510 2}
	"active weapon - fire" {poke 0xe510 3}
	"active weapon - rolling fire" {poke 0xe510 4}
	"active weapon - mine" {poke 0xe510 5}
	"active weapon - magnifying glass" {poke 0xe510 1}
	"all combo's with konami carts" {poke 0xf0f8 255}
	"arrows" {poke 0xe070 1}
	"ceramic arrows" {poke 0xe071 1}
	"rolling fire" {poke 0xe072 1}
	"fire" {poke 0xe073 1}
	"mine" {poke 0xe074 255}
	"magnifying glass" {poke 0xe075 1}
	"zeus cheat" {poke 0xe027 1}
	"necklace" {poke 0xe07c 1}
	"crown" {poke 0xe07d 1}
	"helm" {poke 0xe07e 1}
	"oar" {poke 0xe07f 1}
	"boots" {poke 0xe080 1}
	"decorative doll" {poke 0xe081 1}
	"robe" {poke 0xe082 1}
	"bell" {poke 0xe083 1}
	"halo" {poke 0xe084 1}
	"candle" {poke 0xe085 1}
	"armor" {poke 0xe086 1}
	"carpet" {poke 0xe087 1}
	"helmet" {poke 0xe088 1}
	"lamp" {poke 0xe089 1}
	"vase" {poke 0xe08a 1}
	"pendant" {poke 0xe08b 1}
	"earrings" {poke 0xe08c 1}
	"bracelet" {poke 0xe08d 1}
	"ring" {poke 0xe08e 1}
	"bible" {poke 0xe08f 1}
	"harp" {poke 0xe090 1}
	"triangle" {poke 0xe091 1}
	"trumpet shell" {poke 0xe092 1}
	"pitcher" {poke 0xe093 1}
	"sabre" {poke 0xe094 1}
	"dagger" {poke 0xe095 1}
	"feather" {poke 0xe096 1}
	"shield" {poke 0xe097 3}
	"bread and water" {poke 0xe098 1}
	"salt" {poke 0xe099 1}
	"cross" {poke 0xe07a 1}
	"use bible until kingdom come" {poke 0xe531 1}
	"screen stays frozen for as long as you are in that screen" {poke 0xe0d6 64}
	"world 10 location set @ start (0 = middle tower 1 = right tower 2 = left tower 3 = start)" {poke 0xe06e 3;poke 0xe06d 0x01}
	"world 1 items" {poke 0xe063 0xf0}
	"world 2 items" {poke 0xe064 0xf0}
	"world 3 items" {poke 0xe065 0xf0}
	"world 4 items" {poke 0xe066 0xf0}
	"world 5 items" {poke 0xe067 0xf0}
	"world 6 items" {poke 0xe068 0xf0}
	"world 7 items" {poke 0xe069 0xf0}
	"world 8 items" {poke 0xe06a 0xf0}
	"world 9 items" {poke 0xe06b 0xf0}
	"world 10 items" {poke 0xe06c 0xe0} 
	"invulnerable" {poke 0xe518 1}
}

create_trainer "vampire killer" {time 1} {
	"lives" {poke 0xc410 0x99}
	"hearts" {poke 0xc417 0x99}
	"power" {poke 0xc415 32}
	"invisible to enemies" {poke 0xc43a 255}
	"invincible" {poke 0xc42d 255}
	"always have the white key" {poke 0xc701 255}
	"always have small key" {poke 0xc700 1}
	"always have map" {poke 0xc70f 3}
	"regular whip" {poke 0xc416 0}
	"chain whip" {poke 0xc416 1}
	"knifes" {poke 0xc416 2}
	"axe" {poke 0xc416 3}
	"blue cross" {poke 0xc416 4}
	"holy water" {poke 0xc416 5}
	"game master combo" {poke 0xe600 255}
}

create_trainer "super laydock mission striker" {time 2} {
	"power player 1" {poke 0xe2f3 255}
	"power player 2" {poke 0xe2fb 255}
	"all weapons player 1" {poke 0xe480 255}
	"all weapons player 2" {poke 0xe481 255}
	"infinite docking" {poke 0xe37c 200}
}

create_trainer "super laydock 2" {time 2} {
	"power" {poke 0x6817 255}
}

create_trainer "american truck" {frame} {
	"disable collisions" {poke 0xf29a 255;poke 0xf2a7 0}
}

create_trainer "guardic" {time 60} {
	"lives" {poke 0xe027 255}
	"power" {poke 0xe019 255}
	"have shield" {poke 0xe00c 1}
	"speed" {poke 0xe00f 6}
	"wave" {poke 0xe00a 4}
}

create_trainer "laydock" {time 2} {
	"power player 1" {poke 0xa168 0x99;poke 0xa169 0x99}
	"power player 2" {poke 0xa179 0x99;poke 0xa17a 0x99}
}

create_trainer "spacemanbow" {time 1} {
	"stage (0-8)" {#poke 0xca10 0}
	"invincible" {poke 0xca53 03;poke 0xca54 03}
	"option 1" {poke 0xcac0 2;poke 0xcac1 3;poke 0xcad8 253}
	"option 2" {poke 0xcae0 2;poke 0xcae1 3;poke 0xcaf8 2}
	"speed (1-4)" {poke 0xcb01 2}
	"power bar" {poke 0xcb08 16}
	"lives" {poke 0xcb0f 0x99}
	"missile" {poke 0xcb48 128;poke 0xcb49 3}
	"enable option 1" {poke 0xcb51 1}
	"option 1 shoots backwards" {poke 0xcb50 6}
	"option 1 shoots upwards" {poke 0xcb50 7}
	"option 1 shoots forwards" {poke 0xcb50 8}
	"enable option 2" {poke 0xcb59 1}
	"option 2 shoots backwards" {poke 0xcb58 4}
	"option 2 shoots downwards" {poke 0xcb58 3}
	"option 2 shoots forwards" {poke 0xcb58 2}
}

create_trainer "fantasm soldier 1" {time 2} {
	"life" {poke 0xf064 255}
	"max sword" {poke 0xf294 3}
}

create_trainer "fantasm soldier 2" {time 2} {
	"life" {poke 0xf937 255}
	"invincible" {poke 0xf976 255}
	"pearls" {poke 0xf969 99}
	"shot strength" {poke 0xf977 4}
}

create_trainer "dir-deaf" {time 2} {
	"life" {poke 0xb9ca 64}
	"weapon 2" {poke 0xb8b0 1}
	"weapon 3" {poke 0xb8b1 1}
	"weapon 4" {poke 0xb8b2 1}
	"weapon 5" {poke 0xb8b3 1}
	"weapon 6" {poke 0xb8b4 1}
	"weapon 57" {poke 0xb8b35 1}
	"weapon 58" {poke 0xb8b6 1}
	"life container 1" {poke 0xb8bb 255}
	"life container 2" {poke 0xb8bc 255}
	"defense 1" {poke 0xb8b7 1}
	"defense 2" {poke 0xb8b8 1}
	"defense 3" {poke 0xb8b9 1}
	"defense 4" {poke 0xb8ba 1}
	"card1" {poke 0xb8bf 1}
	"card2" {poke 0xb8c0 1}
	"card3" {poke 0xb8c1 1}
	"card4" {poke 0xb8c2 1}
	"card5" {poke 0xb8c3 1}
	"card6" {poke 0xb8c4 1}
	"card7" {poke 0xb8c5 1}
	"card8" {poke 0xb8c6 1}
}

create_trainer "super cooks" {time 10} {
	"life" {poke 0xcfa1 0x00;poke 0xcfa2 0x02}
	"max hearts" {poke 0xcf9d 0x00;poke 0xcf9e 0x02}
	"dish" {poke 0xcfac 0x99;poke 0xcfad 0x99}
}

create_trainer "golvellius 2" {time 10} {
	"life" {poke 0xcba1 0x00;poke 0xcba2 0x02}
	"max hearts" {poke 0xcb9d 0x00;poke 0xcb9e 0x02}
	"find" {poke 0xcbac 0x99;poke 0xcbad 0x99}
	"iron sword" {poke 0xcb01 1}
	"bronze sword" {poke 0xcb02 1}
	"gold sword" {poke 0xcb03 1}
	"water boots" {poke 0xcb04 1}
	"air boots" {poke 0xcb05 1}
	"scepter" {poke 0xcb06 1}
	"iron shield" {poke 0xcb07 1}
	"bronze shield" {poke 0xcb08 1}
	"gold ring" {poke 0xcb09 1}
	"harp" {poke 0xcb0a 1}
	"heart pendant" {poke 0xcb0b 1}
	"candle" {poke 0xcb0c 1}
	"mirror" {poke 0xcb0d 1}
	"silver ring" {poke 0xcb0e 1}
	"blue potion" {poke 0xcb0f 1}
	"blue diamond" {poke 0xcb10 1}
	"silver broche" {poke 0xcb11 1}
	"fruit" {poke 0xcb12 1}
	"fairy" {poke 0xcb13 1}
	"necklace" {poke 0xcb14 1}
	"golden lost ring" {poke 0xcb15 1}
	"document to get first sword" {poke 0xcb16 1}
	"key" {poke 0xcb17 1}
	"herb" {poke 0xcb18 1}
}

create_trainer "starquake" {time 10} {
	"lives" {poke 0x4061 64}
	"life" {poke 0x4062 128}
	"steps" {poke 0x4063 128}
	"fire" {poke 0x4064 128}
}

create_trainer "gryzor" {time 3} {
	"power bar" {poke 0xe2c9 32}
	"invincible" {poke 0xe31e 200}
	"normal gun" {poke 0xe032 0}
	"laser gun" {poke 0xe032 1}
	"rotating gun" {poke 0xe032 2}
	"machine gun" {poke 0xe032 3}
	"circling gun" {poke 0xe032 4}
	"2 way gun" {poke 0xe032 5}
	"4 way gun" {poke 0xe032 6}
	"4 fragment gun" {poke 0xe032 7}
	"underground stages get easier" {poke 0xe50b 200}
	"end bosses and underground stages get easier" {poke 0xe50b 200;poke 0xe51b 200;poke 0xe52b 200;poke 0xe53b 200;poke 0xe54b 200;poke 0xe55b 200;poke 0xe56b 200;poke 0xe57b 200;poke 0xe58b 200}
}

create_trainer "rastan saga" {time 2} {
	"life bar" {poke 0xd91c 160}
	"get fire sword" {poke 0xd919 3}
	"weapon expiration timer" {poke 0xd91a 255}
}

create_trainer "outrun" {time 2} {
	"time" {poke 0xc093 99}
}

create_trainer "ys 1" {time 2} {
	"life" {poke 0xcfc3 255}
	"money" {poke 0xcfc9 255;poke 0xcfca 255}
	"exp" {poke 0xcfc7 255;poke 0xcfc8 255}
	"all swords" {poke 0xcfd9 31}
	"all shields" {poke 0xcfdb 31}
	"all armor" {poke 0xcfdd 31}
	"all items" {poke 0xcfdf 31}
	"all rings" {poke 0xcfe1 31}
	"all books" {poke 0xcfe3 255}
	"all special items" {poke 0xcfe4 255;poke 0xcfe5 255}
}

create_trainer "ys 2" {time 2} {
	"exp max" {poke 0x0102 255;poke 0x0103 255}
	"gold max" {poke 0x0196 255;poke 0x0197 255}
	"power meter" {poke 0x018c 255}
	"magic meter" {poke 0x0104 255}
}

create_trainer "penguin adventure" {time 15} {
	"shoes" {poke 0xe160 1}
	"propeller" {poke 0xe161 1}
	"gun" {poke 0xe162 1}
	"lightning helmet" {poke 0xe163 3}
	"helmet" {poke 0xe164 3}
	"protective vest" {poke 0xe165 3}
	"bell" {poke 0xe166 1}
	"silver ring" {poke 0xe167 1}
	"bracelet" {poke 0xe168 1}
	"red pendant" {poke 0xe169 1}
	"spectacles" {poke 0xe16a 2}
	"torch" {poke 0xe16b 3}
	"pass" {poke 0xe16c 1}
	"blue boots" {poke 0xe16d 1}
	"red shoes for extra grip" {poke 0xe16e 1}
	"feather" {poke 0xe16f 1}
	"secret items" {poke 0xe170 1;poke 0xe171 1;poke 0xe172 1}
	"invincible" {poke 0xe1f1 1;poke 0xe089 0x99}
	"lives" {poke 0xe090 0x99}
	"poke time never runs out" {poke 0xe08b 0x00;poke 0xe08c 0x3}
	"pause counter (good ending i have been told)" {poke 0xe0de 1}
	"noriko cheat" {poke 0xf0f7 254}
	"kill dragon with one shot" {poke 0xe53c 19}
	"get 8 dancing penguins" {poke 0xe0dd 8}
}

create_trainer "stone of wisdom" {time 2} {
	"life" {poke 0xe044 55}
	"power" {poke 0xe042 55}
	"intelligence" {poke 0xe040 55}
}

create_trainer "blow-up" {time 2} {
	"'cosmic' cheat active f1 to place bombs f5 to blow yourself up" {poke 0x403b 1}
}

create_trainer "arsene lupin 3" {time 2} {
	"life" {poke 0xe18e 40;poke 0xe18f 40}
	"bullet" {poke 0xe16f 0x99}
	"missile and rings" {poke 0xe1ca 1;poke 0xe1cd 3;poke 0xe269 14}
}

create_trainer "arsene lupin 2" {time 1} {
	"power" {poke 0xc07f 200}
	"invincible (makes game unplayable)" {poke 0xc09b 255}
}

create_trainer "arsenelupin 3 (missile)" {time 5} {
	"invincible" {poke 0xccce 1;poke 0xcccf 255}
	"time" {poke 0xcf23 59}
}

create_trainer "super runner" {time 5} {
	"invincible" {poke 0xccce 1;poke 0xcccf 255}
	"time" {poke 0xcf23 59}
}

create_trainer "xyz" {time 5} {
	"power" {poke 0xe060 0x99}
	"something else" {poke 0xe061 0x99}
	"dunno" {poke 0xe062 0x99}
}

create_trainer "dragonslayer 4 (msx2)" {time 1} {
	"life" {poke 0xc067 109}
	"magic" {poke 0xc068 109}
	"money" {poke 0xc069 109}
	"keys" {poke 0xc06a 109}
	"wings" {poke 0xc06f 99}
	"armor" {poke 0xc070 99}
	"pick axe" {poke 0xc071 99}
	"the glove" {poke 0xc072 99}
	"spear hook" {poke 0xc073 99}
	"spike shoes" {poke 0xc074 99}
	"spring shoes" {poke 0xc075 99}
	"master key" {poke 0xc076 99}
	"helmet" {poke 0xc077 99}
	"scepter" {poke 0xc078 99}
	"dragon shield" {poke 0xc079 99}
	"life potion" {poke 0xc07a 99}
	"magic potion" {poke 0xc07b 99}
	"red globe" {poke 0xc07c 99}
	"crown" {poke 0xc07d 1}
	"sword" {poke 0xc07e 99}
	"invincible" {poke 0xc08b 255}
	"jump high" {poke 0xc06b 40}
	"strong weapons" {poke 0xc06c 255}
	"walk trough air" {poke 0xc08c 2}
	"kill enemies with body" {poke 0xc08d 2}
	"shoot far" {poke 0xc06e 40}
	"walk faster" {poke 0xc08e 255}
	"put in slot 1 : pick axe" {poke 0xc060 2}
	"put in slot 2 : harpoon" {poke 0xc061 4}
	"put in slot 3 : crown" {poke 0xc062 14}
	"in game player (try different values)" {poke 0xc050 0}
}

create_trainer "dragonslayer4 (msx1)" {time 1} {
	"life" {poke 0xe093 100}
	"magic" {poke 0xe094 100}
	"money" {poke 0xe095 100}
	"keys" {poke 0xe096 100}
	"wings" {poke 0xe09b 99}
	"armor" {poke 0xe09c 99}
	"pick axe" {poke 0xe09d 99}
	"the glove" {poke 0xe09e 99}
	"spear hook" {poke 0xe09f 99}
	"spike shoes" {poke 0xe0a0 99}
	"spring shoes" {poke 0xe0a1 99}
	"master key" {poke 0xe0a2 99}
	"helmet" {poke 0xe0a3 99}
	"scepter" {poke 0xe0a4 99}
	"dragon shield" {poke 0xe0a5 99}
	"life potion" {poke 0xe0a6 99}
	"magic potion" {poke 0xe0a7 99}
	"red globe" {poke 0xe0a8 99}
	"crown" {poke 0xe0a9 1}
	"sword" {poke 0xe0aa 99}
	"jump high" {poke 0xe097 40}
	"strong weapons" {poke 0xe098 99}
}

create_trainer "druid" {time 2} {
	"ammo 1" {poke 0xc024 99}
	"ammo 2" {poke 0xc025 99}
	"ammo 3" {poke 0xc026 99}
	"key" {poke 0xc027 99}
	"timer" {poke 0xc028 99}
	"golem" {poke 0xc029 99}
	"death" {poke 0xc02a 99}
}

create_trainer "eggerland 1" {time 1} {
	"bullets" {poke 0xc811 0x99}
	"lives" {poke 0xd0d0 0x99}
	"door is always open" {poke 0xd1f2 0}
	"blocks collected" {poke 0xd1f4 1}
	"time in special stages" {poke 0xc81d 255}
	"stage number 1" {poke 0xc81b 1}
	"stage number 2" {poke 0xc81b 2}
	"stage number 3" {poke 0xc81b 3}
	"stage number 4" {poke 0xc81b 4}
	"stage number 5" {poke 0xc81b 5}
	"stage number 6" {poke 0xc81b 6}
	"stage number 7" {poke 0xc81b 7}
	"stage number 8" {poke 0xc81b 8}
}

create_trainer "eggerland 2" {time 1} {
	"shots always active" {poke 0xeb8a 97}
	"lives" {poke 0xeb89 97}
	"timer in special stages" {poke 0xec56 99}
	"containers left" {poke 0xeb88 0}
	"stay alive" {poke 0xeb94 0}
}

create_trainer "wonder boy" {time 2} {
	"power" {poke 0xe0b3 32}
	"lives" {poke 0xe0b2 10}
	"invincible" {poke 0xe0a9 255}
}

create_trainer "crossblaim" {time 0.25} {
	"money 999999" {poke 0xeebb 0x99;poke 0xeebc 0x99;poke 0xeebd 0x99}
	"power" {poke 0xead4 255}
	"engine 1" {poke 0xeeab 255}
	"engine 2" {poke 0xeeac 255}
	"engine 3" {poke 0xeead 255}
	"power container 1" {poke 0xeeae 250}
	"power container 2" {poke 0xeeaf 250}
	"big laser gun" {poke 0xeea2 255}
	"big laser gun 2" {poke 0xeea3 255}
	"bullet for gun (#1)" {poke 0xeeb6 255}
	"bullet for bazooka (#1)" {poke 0xeeb8 255}
	"hand grenades" {poke 0xeea6 255}
	"darts" {poke 0xeea7 255}
	"all keys" {poke 0xeeb0 1;poke 0xeeb1 1;poke 0xeeb2 1;poke 0xeeb3 1;poke 0xeeb4 1}
}

create_trainer "knightmare" {time 0.25} {
	"lives" {poke 0xe060 0x99}
	"invisible" {poke 0xe60c 2}
	"red hot" {poke 0xe60c 3}
	"timer" {poke 0xe60e 0x99}
	"nuclear arrows;)" {poke 0xe609 13}
	"enemy 1 y-pos" {poke 0xe103 210}
	"enemy 2 y-pos" {poke 0xe113 210}
	"enemy 3 y-pos" {poke 0xe123 210}
	"enemy 4 y-pos" {poke 0xe143 210}
	"enemy 5 y-pos" {poke 0xe163 210}
	"end boss dies easily" {poke 0xe034 0}
}

create_trainer "quinpl" {time 1} {
	"timer" {poke 0xe231 0x99;poke 0xe233 0x99}
	"black pin" {poke 0xe020 0x9}
	"white pin" {poke 0xe021 0x9}
	"red pin" {poke 0xe022 0x9}
	"blue pin" {poke 0xe023 0x9}
	"duck" {poke 0xe024 0x9}
}

create_trainer "nyancle racing" {time 1} {
	"time" {poke 0xd213 255}
	"candy" {poke 0xd215 255}
	"damage" {poke 0xd217 0;poke 0xd21e 0}
	"invincible" {poke 0xd73e 255}
}

create_trainer "kings valley 2" {time 2} {
	"festival cheat" {poke 0xe255 1}
	"try again" {poke 0xe217 1}
	"door always opens" {poke 0xe2f5 0}
	"stage 1" {poke 0xe242 1}
	"stage 10" {poke 0xe242 10}
	"stage 20" {poke 0xe242 20}
	"stage 30" {poke 0xe242 30}
	"stage 40" {poke 0xe242 40}
	"stage 50" {poke 0xe242 50}
	"lives" {poke 0xe240 0x99}
}

create_trainer "malayanohibou" {time 2} {
	"life" {poke 0xccd3 15}
	"money" {poke 0xccd4 255;poke 0xccd5 255}
	"have fires" {poke 0xcd74 99}
	"have keys" {poke 0xcd75 99}
	"have bombs" {poke 0xcd76 99}
	"have potions" {poke 0xcd77 99}
	"enable fire shooting" {poke 0xcd25 31}
	"lives" {poke 0xccf3 255}
}

create_trainer "ninjakun" {time 1} {
	"lives" {poke 0xcb37 99}
	"protection scrolls" {poke 0xcb2e 255}
	"time" {poke 0xcb35 99}
}

create_trainer "project a2" {time 1} {
	"power" {poke 0xc476 100}
}

create_trainer "return of jelda" {time 1} {
	"power" {poke 0xc725 100}
	"damage" {poke 0xc724 0}
}

create_trainer "scramble formation" {time 1} {
	"help planes" {poke 0xc102 5}
	"lives" {poke 0xc101 0x99}
}

create_trainer "chuka taisen" {time 1} {
	"fire power" {poke 0xa67f 7}
	"alternative firepower" {poke 0xa681 11}
	"lives" {poke 0xa685 99}
	"invincible" {poke 0xa683 1}
}

create_trainer "goemon" {time 2} {
	"lives" {poke 0xc260 0x99}
	"power" {poke 0xc481 255}
	"a lot of money" {poke 0xc265 255;poke 0xc266 255}
	"have money cases" {poke 0xc279 3}
	"have candle" {poke 0xc278 1}
	"have food" {poke 0xc277 5}
	"have helmet" {poke 0xc276 5}
	"have umbrella" {poke 0xc275 5}
	"have 'shower gel'" {poke 0xc274 5}
	"have tent" {poke 0xc273 5}
	"have helmet" {poke 0xc272 5}
	"have catapult" {poke 0xc271 1}
	"have shoes x3" {poke 0xc270 3}
	"cart combo�s" {poke 0xef00 255}
	"invincible" {poke 0xc4a7 255}
}

create_trainer "garryuuo" {time 1} {
	"invincible" {poke 0xe0b7 255}
	"extra invincible" {poke 0xe06d 8}
}

create_trainer "family boxing" {time 1} {
	"power" {poke 0xc008 0;poke 0xc010 0;poke 0xc04e 28;poke 0xc04f 28}
}

create_trainer "king kong 2" {time 2} {
	"life" {poke 0xc129 0x99}
	"days passed" {poke 0xc128 0x00;poke 0xc127 0x00}
	"days exp" {poke 0xc12b 0x99;poke 0xc12c 0x99}
	"level" {poke 0xc12e 0x99}
	"money" {poke 0xc135 0x99;poke 0xc136 0x99}
	"knife" {poke 0xc2a0 1;poke 0xc340 255}
	"club" {poke 0xc2a2 2;poke 0xc341 255}
	"stones" {poke 0xc2a4 8;poke 0xc347 0x99}
	"boomerang" {poke 0xc2a6 10;poke 0xc349 0x99}
	"vortex" {poke 0xc2c0 34;poke 0xc2c1 255;poke 0xc361 255}
}

create_trainer "ikari warriors" {time 2} {
	"rapid fire" {poke 0xc418 0}
	"player 1 primary weapon nothing" {poke 0xc41d 0}
	"player 1 primary weapon regular" {poke 0xc41d 1}
	"player 1 primary weapon 3 way shot (not deadly)" {poke 0xc41d 2}
	"player 1 primary weapon 7 way shot (not deadly)" {poke 0xc41d 3}
	"player 1 primary weapon red bullets" {poke 0xc41d 4}
	"player 1 primary weapon regular tank bullets" {poke 0xc41d 5}
	"player 1 primary weapon high explosive tank bullets" {poke 0xc41d 6}
	"player 1 primary weapon hand grenades " {poke 0xc41d 7}
	"player 1 primary weapon high explosive hand grenades" {poke 0xc41d 8}
	"player 2 primary weapon nothing" {poke 0xc43d 0}
	"player 2 primary weapon regular" {poke 0xc43d 1}
	"player 2 primary weapon 3 way shot (not deadly)" {poke 0xc43d 2}
	"player 2 primary weapon 7 way shot (not deadly)" {poke 0xc43d 3}
	"player 2 primary weapon red bullets" {poke 0xc43d 4}
	"player 2 primary weapon regular tank bullets" {poke 0xc43d 5}
	"player 2 primary weapon high explosive tank bullets" {poke 0xc43d 6}
	"player 2 primary weapon hand grenades " {poke 0xc43d 7}
	"player 2 primary weapon high explosive hand grenades " {poke 0xc43d 8}
	"player 1 secondary weapon nothing" {poke 0xc41e 0}
	"player 1 secondary weapon regular" {poke 0xc41e 1}
	"player 1 secondary weapon 3 way shot (not deadly)" {poke 0xc41e 2}
	"player 1 secondary weapon 7 way shot (not deadly)" {poke 0xc41e 3}
	"player 1 secondary weapon red bullets" {poke 0xc41e 4}
	"player 1 secondary weapon regular tank bullets" {poke 0xc41e 5}
	"player 1 secondary weapon high explosive tank bullets" {poke 0xc41e 6}
	"player 1 secondary weapon hand grenades " {poke 0xc41e 7}
	"player 1 secondary weapon high explosive hand grenades" {poke 0xc41e 8}
	"player 2 secondary weapon nothing" {poke 0xc43e 0}
	"player 2 secondary weapon regular" {poke 0xc43e 1}
	"player 2 secondary weapon 3 way shot (not deadly)" {poke 0xc43e 2}
	"player 2 secondary weapon 7 way shot (not deadly)" {poke 0xc43e 3}
	"player 2 secondary weapon red bullets" {poke 0xc43e 4}
	"player 2 secondary weapon regular tank bullets" {poke 0xc43e 5}
	"player 2 secondary weapon high explosive tank bullets" {poke 0xc43e 6}
	"player 2 secondary weapon hand grenades " {poke 0xc43e 7}
	"player 2 secondary weapon high explosive hand grenades" {poke 0xc43e 8}
	"lives player 1" {poke 0xc415 99}
	"lives player 2" {poke 0xc435 99}
}

create_trainer "firebird" {time 2} {
	"ilovehinotori" {poke 0xc4e2 1}
	"turbo" {poke 0xc850 3}
	"autoshot" {poke 0xc85c 2;poke 0xc4e1 2}
	"99 lives" {poke 0xc160 0x99}
	"200 money" {poke 0xc845 200}
	"shoes" {poke 0xc850 3}
	"bug (red beetle?)" {poke 0xc85c 9}
	"compass" {poke 0xc884 1}
	"packages" {poke 0xc870 9}
	"scrolls" {poke 0xc874 9}
	"leaflets (?)" {poke 0xc878 9}
	"top 1st last stone" {poke 0xc88c 1}
	"top 2nd last stone" {poke 0xc890 1}
	"top 3th last stone" {poke 0xc894 1}
	"top 4th last stone" {poke 0xc898 1}
	"top 5th last stone" {poke 0xc89c 1}
	"top last stone" {poke 0xc8a0 1}
	"1st middle stone" {poke 0xc8bc 1}
	"2nd middle stone" {poke 0xc8c0 1}
	"3rd middle stone" {poke 0xc8c4 1}
	"4rd middle stone" {poke 0xc8c8 1}
	"5th middle stone" {poke 0xc8cc 1}
	"lower first stone" {poke 0xc8a4 1}
	"lower second stone" {poke 0xc8a8 1}
	"lower third stone" {poke 0xc8ac 1}
	"lower fourth stone" {poke 0xc8b0 1}
	"lower fifth stone" {poke 0xc8b4 1}
	"lower sixth stone" {poke 0xc8b8 1}
	"first main stone" {poke 0xc8dc 1}
	"second main stone" {poke 0xc8e0 1}
	"third main stone" {poke 0xc8e4 1}
	"fourth main stone" {poke 0xc8e8 1}
	"fifth main stone" {poke 0xc8ec 1}
	"combo with game master" {poke 0xc110 1}
}

create_trainer "rambo" {time 2} {
	"life" {poke 0xe811 24}
	"arrows" {poke 0xe813 10}
	"machine gun" {poke 0xe814 10}
	"hand grenades" {poke 0xe815 10}
	"bazooka" {poke 0xe816 10}
	"food" {poke 0xe812 6;poke 0xe817 24}
	"activate all weapons" {poke 0xe80e 255}
}

create_trainer "higemaru" {time 1} {
	"999900 points" {poke 0xe515 0x99;poke 0xe516 0x99}
	"enemies to kill before entering the gate to a boss" {poke 0xe539 0}
	"get all keys" {poke 0xe517 255}
	"get all items" {poke 0xe519 255;poke 0xe51a 255}
	"untouchable" {poke 0xe026 255}
}

create_trainer "bombaman" {time 2} {
	"lives" {poke 0x226b 9}
	"amount of bombs you can place" {poke 0x1fec 2}
	"bomb power (increase the value at your own risk :p)" {poke 0x1fee 5}
	"increase the detonation time" {poke 0x1dc5 3}
	"time" {poke 0x18a2 58}
}

create_trainer "psycho world" {time 2} {
	"life" {poke 0xa120 100}
	"esp" {poke 0xa122 100}
	"power mode" {poke 0xd40d 0}
	"normal mode" {poke 0xd40d 2}
	"max up mode" {poke 0xd40d 3}
	"extra mode" {poke 0xd40d 5}
	"unlimited power ups in power mode (push 1 trough 9)" {poke 0xd401 255}
	"get all weapons" {poke 0xa212 255}
	"normal shot power up" {poke 0xa213 9}
	"ice shot power up" {poke 0xa214 5}
	"fire power up" {poke 0xa215 5}
	"sonic shot power up" {poke 0xa216 5}
}

create_trainer "strategic mars" {time 1} {
	"money maxed out" {poke 0xc33e 255;poke 0xc33f 255}
	"energy" {poke 0xc1bc 14}
	"shield" {poke 0xc1bb 14}
}

create_trainer "gallforce" {time 2} {
	"20 hits" {poke 0xccee 15;poke 0xccec 15}
	"all galls" {poke 0xc447 255;poke 0xcb12 7}
}

create_trainer "beam rider" {time 5} {
	"unlimited bombs" {poke 0xe22c 99}
	"lives" {poke 0xe223 12}
}

create_trainer "happy fret" {time 1} {
	"unlimited power" {poke 0xbea0 41}
}

create_trainer "come on picot" {time 2} {
	"jean lives" {poke 0xe008 4}
	"jean power" {poke 0xeb70 100}
	"picot power" {poke 0xec43 250}
}

create_trainer "hero" {time 5} {
	"unlimited power/time" {poke 0xc174 100}
	"unlimited bombs" {poke 0xc032 3}
	"unlimited lives" {poke 0xc031 4}
}

create_trainer "past finder" {time 10} {
	"keep radiation low" {poke 0xe126 1}
	"lives" {poke 0xe004 10}
}

create_trainer "terramex" {time 10} {
	"unlimited lives" {poke 0x5b94 25}
}

create_trainer "eindeloos" {time 0.5} {
	"unlimited lives" {poke 0x9c91 99}
	"big enemy 1 y-pos" {poke 0x9486 200}
	"big enemy 2 y-pos" {poke 0x9482 200}
	"big enemy 3 y-pos" {poke 0x948a 200}
}

create_trainer "mobile planet" {time 1} {
	"invisible" {poke 0xe33a 1}
	"stars" {poke 0xe054 0x99}
	"lives" {poke 0xe001 0x99}
}

create_trainer "hole in one special" {time 2} {
	"always have hole in one (very lame )" {poke 0xc0da 1}
}

create_trainer "woody poco" {time 2} {
	"power" {poke 0xe777 251;poke 0xe778 255;poke 0xe779 251;poke 0xe77a 255}
	"money" {poke 0xe77f 255;poke 0xe780 255}
	"shot" {poke 0xe7b9 255;poke 0xe7ba 255}
}

create_trainer "super rambo special" {time 2} {
	"power" {poke 0xc155 255}
	"handgun bullets" {poke 0xc165 255}
	"arrows" {poke 0xc166 255}
	"shotgun bullets" {poke 0xc167 255}
	"explosive arrows" {poke 0xc168 255}
	"hand grenades" {poke 0xc169 255}
	"bazooka" {poke 0xc16a 255}
	"flowers" {poke 0xc16c 255}
	"keys" {poke 0xc16b 255}
	"summon sidekick" {poke 0xc218 1}
	"prevent the sidekick from screaming and moaning" {poke 0xc216 255;poke 0xc225 255}
}

create_trainer "super triton" {time 1} {
	"exp" {poke 0xd023 255}
	"life" {poke 0xd024 255}
	"red life" {poke 0xd025 255}
}

create_trainer "triton" {time 1} {
	"exp" {poke 0xe43b 100}
	"life" {poke 0xe439 99}
	"magic balls" {poke 0xe43c 99}
}

create_trainer "afterburner" {time 10} {
	"missiles" {poke 0x5e23 255}
	"lives" {poke 0x5e4e 100}
}

create_trainer "irem karate" {time 10} {
	"power" {poke 0xecad 255}
	"time" {poke 0xecc6 0x2}
}

create_trainer "rambo 3" {time 2} {
	"life" {poke 60ee 0}
}

create_trainer "yie-ar kungfu 2" {time 5} {
	"power player 1" {poke 0xe100 32}
	"invincible for bosses" {poke 0xe29e 255}
	"lives" {poke 0xe055 0x99}
	"kill enemy with one hit" {poke 0xe102 1}
}

create_trainer "ashiguine 1" {time 2} {
	"energy" {poke 0xe030 255}
}

create_trainer "pineapplin" {time 0.1} {
	"lives" {poke 0xcc66 99}
	"energy" {poke 0xcc62 255;poke 0xcc64 255}
	"level" {poke 0xc023 9;poke 0xc024 9;poke 0xc025 9}
	"bat x-y-pos" {poke 0xe020 1;poke 0xe020 0}
	"turtle x-y-pos" {poke 0xe030 1;poke 0xe031 0}
	"snake x-y-pos" {poke 0xe040 1;poke 0xe041 0}
	"bridge always closed (just walk to the next stage)" {poke 0xe250 5}
}

create_trainer "godzilla" {time 2} {
	"lives" {poke 0xe30f 101}
	"energy" {poke 0xe336 255}
}

create_trainer "back to the future" {time 0.1} {
	"lives" {poke 0xf235 99}
	"time" {poke 0xf232 13}
	"always have green boy" {poke 0xf273 2;poke 0xf274 115}
	"always have girl" {poke 0xf27d 2;poke 0xf27e 115}
	"enemy 1 y-x-pos " {poke 0xf102 200;poke 0xf103 255}
	"enemy 2 y-x-pos " {poke 0xf109 200;poke 0xf110 255}
	"enemy 3 y-x-pos " {poke 0xf11c 200;poke 0xf11d 255}
	"enemy 4 y-x-pos " {poke 0xf129 200;poke 0xf12a 255}
	"enemy 5 y-x-pos " {poke 0xf136 200;poke 0xf137 255}
	"enemy 5 y-x-pos " {poke 0xf150 200;poke 0xf151 255}
}

create_trainer "bomberman special" {time 10} {
	"bomb strength" {poke 0xd015 255}
	"max bombs" {poke 0xd014 8}
	"lives" {poke 0xd00e 99}
	"time" {poke 0xd020 199}
	"detonate bombs pushing z" {poke 0xd018 1}
	"walk faster" {poke 0xd00b 5;poke 0xd016 2}
	"walk trough bombs" {poke 0xd017 1}
	"invulnerable" {poke 0xd01b 255}
}

create_trainer "bomber king" {time 10} {
	"energy" {poke 0xc5c1 236}
	"stuff" {poke 0xc0b2 1;poke 0xc0c4 1;poke 0xc56b 1;poke 0xc571 1}
}

create_trainer "gularve" {time 10} {
	"energy" {poke 0xe2ad 255}
	"weapon number" {poke 0xe2a7 8}
}

create_trainer "xak 2" {time 10} {
	"max life" {poke 0x6dfe 255;poke 0x6dff 255}
	"money" {poke 0x6e14 255;poke 0x6e15 255}
}

create_trainer "bozos big adventure" {time 1} {
	"life" {poke 0x5544 100}
}

create_trainer "alife m36" {time 1} {
	"life" {poke 0xc527 99;poke 0xd3c2 99}
}

create_trainer "dragonslayer 6" {time 60} {
	"gold" {poke 0x208c 255;poke 0x208d 255;poke 0x208e 255}
	"life selios" {poke 0x2304 0x0f;poke 0x2305 0x27}
	"max life selios" {poke 0x2306 0x0f;poke 0x2307 0x27}
	"magic selios" {poke 0x2308 0x0f;poke 0x2309 0x27}
	"max magic selios" {poke 0x230a 0x0f;poke 0x230b 0x27}
	"experience selios (max exp)" {poke 0x230c 255;poke 0x230d 255;poke 0x230e 255}
	"experience runan (max exp)" {poke 0x234c 255;poke 0x234d 255;poke 0x234e 255}
	"life runan" {poke 0x2344 0x0f;poke 0x2345 0x27}
	"max life runan" {poke 0x2346 0x0f;poke 0x2347 0x27}
	"magic runan" {poke 0x2348 0x0f;poke 0x2349 0x27}
	"max magic runan" {poke 0x234a 0x0f;poke 0x234b 0x27}
	"life ro" {poke 0x2384 0x0f;poke 0x2385 0x27}
	"max life ro" {poke 0x2386 0x0f;poke 0x2387 0x27}
	"experience ro (max exp)" {poke 0x238c 255;poke 0x238d 255;poke 0x238e 255}
	"magic ro" {poke 0x2388 0x0f;poke 0x2389 0x27}
	"max magic ro" {poke 0x238a 0x0f;poke 0x238b 0x27}
	"life gale" {poke 0x23c4 0x0f;poke 0x23c5 0x27}
	"max life gale" {poke 0x23c6 0x0f;poke 0x23c7 0x27}
	"experience gale (max exp)" {poke 0x23cc 255;poke 0x23cd 255;poke 0x23ce 255}
	"magic gale" {poke 0x23c8 0x0f;poke 0x23c9 0x27}
	"max magic gale" {poke 0x23ca 0x0f;poke 0x23cb 0x27}
}

create_trainer "ys 3" {time 10} {
	"swords" {poke 0x7fa3 255}
	"armor" {poke 0x7fa5 255}
	"shields" {poke 0x7fa7 255}
	"rings" {poke 0x7fa9 255}
	"items" {poke 0x7fab 255}
	"ring power" {poke 0x7ead 255}
	"experience" {poke 0x7fa0 255;poke 0x7fa1 255}
	"gold" {poke 0x7f9e 255;poke 0x7f9f 255}
	"life" {poke 0x7f97 255}
}

create_trainer "catboy" {time 1} {
	"big cat" {poke 0xe31d 255}
	"lives" {poke 0xe00b 0x99}
}

create_trainer "bastard" {time 1} {
	"money" {poke 0xb5f6 255}
	"life" {poke 0xb608 255}
}

create_trainer "aleste gaiden" {frame} {
	"lives" {poke 0xd080 99}
	"invincible" {poke 0xc930 27}
	"option 1" {poke 0xc820 255;poke 0xc822 172;poke 0xc823 76;poke 0xc832 14}
	"option 2" {poke 0xc840 255;poke 0xc842 93;poke 0xc843 77;poke 0xc852 14}
}

create_trainer "pacmania" {time 5} {
	"unknown pokes (mandatory though)" {poke 0x9f2d 255;poke 0xc953 255}
	"blue ghost 1" {poke 0xcd60 255}
	"blue ghost 2" {poke 0xcd74 255}
	"blue ghost 3" {poke 0xcd88 255}
	"blue ghost 4" {poke 0xcd9c 255}
	"blue ghost 5" {poke 0xcdb0 255}
	"blue ghost 6" {poke 0xcdc4 255}
	"blue ghost 7" {poke 0xcdd8 255}
	"blue ghost 8" {poke 0xcdec 255}
}

create_trainer "pacman" {time 1} {
	"ghost 1" {poke 0xe230 1}
	"ghost 2" {poke 0xe250 1}
	"ghost 3" {poke 0xe270 1}
	"ghost 4" {poke 0xe290 1}
}

create_trainer "r-type" {time 1} {
	"invincible" {poke 0xe703 1}
	"missile" {poke 0xea24 1}
	"pods" {poke 0xea29 2;poke 0xea2f 2}
}

create_trainer "buck rodgers" {time 1} {
	"time" {poke 0xf172 100}
	"lives" {poke 0xf16e 255}
	"go trough on portal for next level" {poke 0xf171 1}
}

create_trainer "arkanoid 1" {time 0.1} {
	"always fire" {poke 0xe551 1}
	"99 lives" {poke 0xe01d 99}
	"ball above bat" {poke 0xe0f6 [expr {[peek 0xe0ce]+16}]}
	"normal ball speed" {poke 0xe255 12}
	"magnetic ball" {poke 0xe324 1}
	"long bat" {poke 0xe0d7 4;poke 0xe0d8 14;poke 0xe0db 12;poke 0xe0dc 8;poke 0xe321 2;poke 0xe550 2}
	"open door to next round" {poke 0xe326 1}
	"round (0-32)" {#poke 0xe01b 0}
}

create_trainer "arkanoid 2" {time 0.1} {
	"always fire" {poke 0xc789 3}
	"all destroying ball" {poke 0xe2e6 1}
	"infinitive lives" {poke 0xc78a 6}
	"ball always above bat" {poke 0xc021 [peek 0xc786]} 
�prevent ball from going over the edge� {if {[peek 0xc020] >183} {poke 0xc020 0}}
}

create_trainer "inspector-z" {time 1} {
	"infinitive lives" {poke 0xe001 0x99}
	"bombs" {poke 0xe054 0x99}
	"coins" {poke 0xe055 0x99}
	"stay in state" {poke 0xfca2 255}
	"blink yellow" {poke 0xe31a 2}
}

create_trainer "1942" {time 1} {
	"infinitive lives" {poke 0xed2f 9}
	"infinitive loops" {poke 0xee81 9}
	"get big shot and become invincible" {poke 0xee83 255}
	"stage" {#poke 0xed20 x}
}

create_trainer "boulderdash 1" {frame} {
	"exit is always open" {poke 0xd9b0 1}
	"lives" {poke 0xd98f 255}
	"invulnerable" {poke 0xd83c 0}
}

create_trainer "kikikaikai" {time 2} {
	"max shot" {poke 0xc070 9}
	"lives" {poke 0xc025 255}
}

create_trainer "feud" {time 2} {
	"life full" {poke 0x5885 40}
	"burdock" {poke 0x58d5 7}
	"ragwort" {poke 0x58d6 7}
	"toadflax" {poke 0x58d7 7}
	"bones" {poke 0x58d8 7}
	"mad sage" {poke 0x58d9 7}
	"bog bean" {poke 0x58da 7}
	"catsear" {poke 0x58db 7}
	"hemlock" {poke 0x58dc 7}
	"skullcap" {poke 0x58dd 7}
	"feverfew" {poke 0x58de 7}
	"mouse tail" {poke 0x58df 7}
	"knap weed" {poke 0x58e0 7}
	"concoctions" {poke 0x58e1 7}
}

create_trainer "jp winkle" {time 2} {
	"lives" {poke 0xe007 0x98}
	"bible" {poke 0xe098 0x98}
	"invincible" {poke 0xe0ab 255}
	"keys" {poke 0xe032 0x98}
	"wings" {poke 0xe0af 255}
	"axe" {poke 0xe0b0 30;poke 0xe0bc 255}
	"hammer" {poke 0xe0b1 20;poke 0xe0bd 255}
	"blue lamp" {poke 0xe0ae 255}
	"red lamp" {poke 0xe0ad 255}
	"cross" {poke 0xe0ac 255}
}

create_trainer "jack the nipper coconut" {time 1} {
	"lives" {poke 0x8834 9}
	"invincible" {poke 0x881d 60}
	"do not die while falling" {poke 0x8826 0}
}

create_trainer "jack the nipper" {time 1} {
	"power bar" {poke 0x2c56 0}
}

create_trainer "jetset willy" {time 0.5} {
	"lives" {poke 0xf25d 17}
	"y-pos enemy 1" {poke 0xf14b 170}
	"y-pos enemy 2" {poke 0xf154 170}
	"y-pos enemy 3" {poke 0xf15d 170}
	"y-pos enemy 4" {poke 0xf166 170}
	"y-pos enemy 5" {poke 0xf16f 170}
	"y-pos enemy 6" {poke 0xf181 170}
	"y-pos enemy 7" {poke 0xf178 170}
}

create_trainer "dig-dug" {time 1} {
	"lives" {poke 0xe700 2}
}

create_trainer "elevator action" {time 1} {
	"lives" {poke 0xc08a 99}
}

create_trainer "tank battalion" {time 1} {
	"next level after one kill" {poke 0xe04c 1}
	"lives" {poke 0xe04d 0x99}
}

create_trainer "dynamite dan" {time 5} {
	"lives" {poke 0x01f2 9}
}

create_trainer "raid on bungling bay" {time 1} {
	"energy" {poke 0xe0f5 0}
	"bombs" {poke 0xe037 9}
}

create_trainer "final justice" {time 1} {
	"energy" {poke 0xe411 100}
}

create_trainer "frontline" {time 1} {
	"lives" {poke 0xc001 255}
}

create_trainer "superboy 3" {time 1} {
	"grow big" {poke 0xe190 255}
	"invincible" {poke 0xe177 255}
	"time" {poke 0xe18c 25}
}

create_trainer "zaxxon" {time 2} {
	"fuel" {poke 0xe176 16}
	"lives" {poke 0xe00b 6}
}

create_trainer "car fighter" {time 30} {
	"fuel" {poke 0xe080 9;poke 0xe081 9;poke 0xe082 9}
	"bombs" {poke 0xe30c 0x99}
}

create_trainer "aramo" {time 1} {
	"exp" {poke 0xc01c 255}
	"power" {poke 0xc02b 255}
	"knife" {poke 0xc052 255}
	"axe" {poke 0xc053 255}
	"sword" {poke 0xc054 255}
	"shield a" {poke 0xc055 255}
	"shield b" {poke 0xc056 255}
	"armor a" {poke 0xc057 255}
	"armor b" {poke 0xc058 255}
	"ring" {poke 0xc059 255}
	"lamp" {poke 0xc05a 255}
	"jump boots" {poke 0xc05b 255}
	"turbo belt" {poke 0xc05c 255}
	"jet boots" {poke 0xc05d 255}
	"pendant" {poke 0xc05e 255}
	"bracelet" {poke 0xc05f 255}
	"blaster" {poke 0xc060 255}
	"gun" {poke 0xc061 255}
	"fire gun" {poke 0xc062 255}
	"key" {poke 0xc063 255}
	"bottle" {poke 0xc064 255}
	"potion" {poke 0xc065 255}
	"medicine" {poke 0xc066 255}
}

create_trainer "hydlide 1 (msx1)" {time 1} {
	"level up after killing one enemy" {poke 0xe004 100}
	"power" {poke 0xe002 100}
}

create_trainer "hydlide1 (msx2)" {time 1} {
	"level up after killing one enemy" {poke 0xa7be 100}
	"power" {poke 0xa7bc 100}
	"stats max" {poke 0xa7bd 100;poke 0xa7bf 9;poke 0xa7c3 100}
	"sword" {poke 0xa7ce 255}
	"shield" {poke 0xa7cf 255}
	"lamp" {poke 0xa7d0 255}
	"cross" {poke 0xa7d1 255}
	"water can" {poke 0xa7d2 255}
	"tea pot" {poke 0xa7d3 255}
	"key" {poke 0xa7d4 255}
	"blue crystal" {poke 0xa7d5 255}
	"pink crystal " {poke 0xa7d6 255}
	"green crystal " {poke 0xa7d7 255}
	"fairy 1" {poke 0xa7d8 255}
	"fairy 2" {poke 0xa7d9 255}
	"fairy 3" {poke 0xa7da 255}
}

create_trainer "decathlon" {frame} {
	"top speed" {poke 0xe190 255}
}

create_trainer "kings knight" {frame} {
	"top speed" {poke 0xef44 255}
}

create_trainer "anaza" {time 1} {
	"power" {poke 0xc016 32}
	"credit" {poke 0xc01e 0x99;poke 0xc01d 0x99}
}

create_trainer "hydlide 3" {time 2} {
	"current power" {poke 0xd01a 255}
	"max life" {poke 0xd018 255;poke 0xd020 255}
	"magic points" {poke 0xd022 255;poke 0xd023 255;poke 0xd024 255;poke 0xd025 255}
	"charm" {poke 0xd036 255}
	"exp" {poke 0xd039 255;poke 0xd03a 255;poke 0xd03b 255}
	"attack points" {poke 0xd029 255;poke 0xd02a 255}
	"armor class" {poke 0xd02b 255;poke 0xd02c 255}
	"agility" {poke 0xd02d 255;poke 0xd02e 255}
	"intelligence" {poke 0xd032 255}
	"dexterity" {poke 0xd030 255}
	"luck" {poke 0xd034 255}
	"mind force" {poke 0xd038 255}
	"gold" {#poke 0xd087 255}
	"unknown" {poke 0xd019 255;poke 0xd01b 255;poke 0xd03d 255;poke 0xd0a9 255}
}

create_trainer "deep forest" {time 2} {
	"power" {poke 0xeb1a 255}
	"money" {poke 0xeb1b 99;poke 0xeb1c 99}
	"untouchable" {poke 0xea0e 255}
	"jump higher" {poke 0xea0d 255;poke 0xea0f 255;poke 0xea08 255}
}

create_trainer "volguard" {time 1} {
	"power" {poke 0xe392 255}
}

create_trainer "gyrodine" {time 1} {
	"get parachute when hit" {poke 0xe5e4 250}
	"lives" {poke 0xe5e0 10}
}

create_trainer "leonidas" {time 1} {
	"homing shot" {poke 0xe32e 6}
	"hearts" {poke 0xe054 0x99;poke 0xe055 0x99}
	"air" {poke 0xe057 64}
	"shot" {poke 0xe058 64}
	"invincible (partly)" {poke 0xe33a 4;poke 0xe33b 60}
	"lives" {poke 0xe001 0x99}
	"invincible" {poke 0xe03a 255}
}

create_trainer "skygaldo" {time 1} {
	"super explosives and full power" {poke 0xf327 255}
}

create_trainer "starsoldier" {time 1} {
	"get a more powerful shot" {#poke 0xce84 3}
	"invincible" {poke 0xcf20 255}
}

create_trainer "ninjakage" {time 1} {
	"shot power up (try 1 trough 7 as a value)" {poke 0xe542 4}
	"unlimited magic" {poke 0xe547 255}
	"lives" {poke 0xe532 99}
}

create_trainer "fire rescue" {time 1} {
	"always have water" {poke 0xe62e 1}
}

create_trainer "pooyan" {time 2} {
	"shoot one wolf (very lame )" {poke 0xe006 1}
}

create_trainer "sparkie" {time 2} {
	"do not explode when the fuse is on fire" {poke 0xe005 0}
}

create_trainer "polar star" {time 1} {
	"do not explode when hit" {poke 0x9d61 128}
	"missile is always ready" {poke 0x9d44 1}
}

create_trainer "aufwiedersehen monty" {time 1} {
	"lives" {poke 0x8431 255}
	"fly without a ticket (activate only when playing the game!)" {poke 0x9387 0}
	"invincible to monsters" {poke 0x8456 1}
}

create_trainer "death wish 3" {time 1} {
	"shotgun ammo" {poke 0xa478 99}
	"bazooka ammo" {poke 0xa47b 99}
	"pistol ammo" {poke 0xa479 99}
	"sub machine gun" {poke 0xa47a 99}
	"invincible" {poke 0x5b91 1}
}

create_trainer "desolator" {time 1} {
	"shield" {poke 0x8d05 255}
	"energy" {poke 0x8d06 255}
	"lives" {poke 0x8cec 101}
}

create_trainer "gutt blaster" {time 1} {
	"cosmic cheat" {poke 0x4038 1}
	"2 way shot (to change choose value 0-3)" {poke 0x6a96 3}
}

create_trainer "starwars" {time 1} {
	"left base ammo" {poke 0x5bd8 10}
	"middle base ammo" {poke 0x5bd9 10}
	"right base ammo" {poke 0x5bda 10}
}

create_trainer "space camp" {time 1} {
	"left base ammo" {poke 0x5bd8 10}
}

create_trainer "hydefos" {time 1} {
	"power" {poke 0xc11c 255}
	"hydefos control" {poke 0xc040 255}
	"speed" {poke 0xc106 16}
	"lives" {poke 0xd404 100}
	"power" {poke 0xc118 100}
}

create_trainer "ninjayoumakor" {time 1} {
	"damage" {poke 0xd46d 0}
}

create_trainer "silviana" {time 1} {
	"power" {poke 0x8c9d 255}
	"gold" {poke 0x8ca1 255;poke 0x8ca2 255}
}

create_trainer "exoide" {time 1} {
	"power" {poke 0xe1d3 100}
	"lives" {poke 0xe00b 0x99}
	"invincible red" {poke 0xe30d 255}
	"invincible green" {poke 0xe33e 255}
	"silver color ship" {poke 0xe313 15}
}

create_trainer "the seus" {time 1} {
	"power" {poke 0xede3 0x9;poke 0xede2 0x99}
	"time" {poke 0xeddc 0x02}
}

create_trainer "monsters fair" {time 1} {
	"power" {poke 0xd7e2 50}
	"give motha some balls" {poke 0xd7cb 99}
	"mothas" {poke 0xd81c 9}
}

create_trainer "jagur" {time 1} {
	"power" {poke 0xec00 99}
	"money" {poke 0xe020 255;poke 0xe021 127}
}

create_trainer "heaven" {time 1} {
	"life" {poke 0xe038 0x99;poke 0xe039 0x99}
	"defend" {poke 0xe03a 0x99;poke 0xe03b 0x99}
	"attack" {poke 0xe03c 0x99;poke 0xe03d 0x99}
	"money" {poke 0xe03e 0x99;poke 0xe03f 0x99}
}

create_trainer "digital devil" {time 1} {
	"life" {poke 0xd271 255}
}

create_trainer "gradius 3" {time 0.5} {
	"lives" {poke 0xe360 0x99}
	"stage (1-11)" {#poke 0xe361 1}
	"only for stage 4" {#poke 0xe363 0}
	"set speed to 4" {poke 0xe36d 4}
	"all weapons and upgrades (find)" {poke 0xe36f 7}
	"choose option (1-3)" {poke 0xe37e 3}
	"choose shield (1-2)" {poke 0xe37f 2}
	"choose vixen (0-3)" {poke 0xe380 3}
	"red map" {poke 0xe393 1}
	"blue map" {poke 0xe394 1}
	"green map" {poke 0xe395 1}
	"space fighter shield" {poke 0xe396 1}
	"extra sensory device " {poke 0xe397 1}
	"activate hard" {poke 0xe39b 0;poke 0xe39d 1}
	"activate find" {poke 0xe39c 1}
	"activate good" {poke 0xe39d 2}
	"activate expand" {poke 0xe39e 1}
	"shield on 1=off 3=on" {poke 0xe600 3}
	"options" {poke 0xe608 2;poke 0xe610 1;poke 0xe620 2}
	"shoot or laser (1-12)" {}
	"normal shot" {poke 0xe630 1}
	"back shot" {poke 0xe630 2}
	"up shot" {poke 0xe630 3}
	"down shot" {poke 0xe630 4}
	"shot 1 laser" {poke 0xe630 5}
	"shot 1 meteor laser" {poke 0xe630 6}
	"shot 1 screw laser" {poke 0xe630 7}
	"shot 1 extended blaster" {poke 0xe630 8}
	"shot 1 vector laser" {poke 0xe630 9}
	"shot 1 ripple laser" {poke 0xe630 10}
	"shot 1 fire blaster" {poke 0xe630 11}
	"shot 1 big fire blaster" {poke 0xe630 12}
	"shot 2 normal beam" {poke 0xe631 1}
	"shot 2 tail beam" {poke 0xe631 2}
	"shot 2 up double" {poke 0xe631 3}
	"shot 2 down double" {poke 0xe631 4}
	"shot 2 up laser" {poke 0xe631 13}
	"shot 2 down laser" {poke 0xe631 14}
	"normal missile" {poke 0xe632 16}
	"photon missile" {poke 0xe632 17}
	"napalm missile" {poke 0xe632 18}
	"guided missile" {poke 0xe632 19}
	"hawkwind missile" {poke 0xe632 20}
	"double way missile (with vixen=3)" {poke 0xe642 16}
	"x-pos enemy" {poke 0xe806 0}
	"x-pos enemy" {poke 0xe846 0}
	"x-pos enemy" {poke 0xe886 0}
	"x-pos enemy" {poke 0xe8c6 0}
	"x-pos enemy" {poke 0xe906 0}
	"x-pos enemy" {poke 0xe946 0}
	"x-pos enemy" {poke 0xe986 0}
	"x-pos enemy" {poke 0xe9c6 0}
}

create_trainer "alien8" {time 1} {
	"counter to 9999" {poke 0xd83a 136;poke 0xd839 136;poke 0xd838 136;poke 0xd837 136}
	"lives" {poke 0xd81b 10}
}

create_trainer "strange loop" {time 1} {
	"patches" {poke 0xc48f 99}
	"charges" {poke 0xc48d 99;poke 0xc48e 99}
}

create_trainer "batman" {time 1} {
	"lives" {poke 0x19dc 0x99}
	"shield" {poke 0x19db 0x99}
	"jump" {poke 0x19da 0x99}
	"electric bolt" {poke 0x19d9 0x99}
	"get all items" {poke 0x19d8 255}
}

create_trainer "head over heals" {time 1} {
	"lives player 1" {poke 0x2242 0x99}
	"shield player 1" {poke 0x2240 0x99}
	"electric bolt player 1" {poke 0x223d 0x99}
	"ammo player 1" {poke 0x2243 0x99}
	"lives player 2" {poke 0x2241 0x99}
	"shield player 2" {poke 0x223f 0x99}
	"jump player 2" {poke 0x223e 0x99}
}

create_trainer "nightshade" {time 1} {
	"power" {poke 0xd04f 3}
}

create_trainer "highway star" {time 1} {
	"power" {poke 0xe20d 255;poke 0xe20e 5}
	"cars" {poke 0xe211 0x0b}
}

create_trainer "pitfall1" {time 1} {
	"power" {poke 0xe1d6 9;poke 0xe1d7 9;poke 0xe1d8 9;poke 0xe1d9 9;poke 0xe1da 9;poke 0xe1db 9}
	"lives" {poke 0xe012 255}
}

create_trainer "gunfright" {time 1} {
	"lives" {poke 0xd05e 3}
	"bullets" {poke 0xd05d 5}
	"money" {poke 0xd052 99}
	"invincible (player disappears)" {poke 0xd078 1}
}

create_trainer "knightlore" {time 1} {
	"lives" {poke 0xd81b 9}
	"days spend" {poke 0xd81a 0}
}

create_trainer "pitfall2" {time 1} {
	"power (89abcd)" {poke 0xe058 9;poke 0xe059 9;poke 0xe05a 9;poke 0xe05b 9;poke 0xe05c 9;poke 0xe05d 9}
}

create_trainer "predator" {time 1} {
	"power" {poke 0xc207 255}
	"mines" {poke 0xc230 9;poke 0xc231 9}
	"hand grenade" {poke 0xc235 9;poke 0xc236 9}
	"bullet" {poke 0xc232 9;poke 0xc233 9;poke 0xc234 9}
}

create_trainer "runemaster1" {time 1} {
	"money" {poke 0x61e2 0x0f;poke 0x61e3 0x27}
	"player 1 power" {poke 0x61dc 255}
}

create_trainer "masters of the universe" {time 1} {
	"power" {poke 0xcb01 90}
	"time" {poke 0xd23c 9;poke 0xd23e 9;poke 0xd23f 9}
	"have all cords" {poke 0xccd4 255}
	"lives" {poke 0xa4e3 9}
}

create_trainer "thing bounces back" {time 1} {
	"oil level" {poke 0x8e4e 180}
}

create_trainer "bounder" {time 10} {
	"lives" {poke 0x96f 101}
}

create_trainer "fruity frank" {time 10} {
	"lives" {poke 0x4144 4}
}

create_trainer "batman the movie" {time 1} {
	"life" {poke 0x613d 255}
	"time" {poke 0x5dac 58;poke 0x5daa 58}
}

create_trainer "venom strikes back" {time 1} {
	"lives" {poke 0x2bb1 255;poke 0x2bb2 255}
	"power slot 1 filled with penetrator" {poke 0x2c33 1;poke 0x2c34 0x99}
	"power slot 2 filled with lifter" {poke 0x2c38 6;poke 0x2c39 0x99}
	"power slot 3 filled with jack rabbit" {poke 0x2c3d 5;poke 0x2c3e 0x99}
}

create_trainer "ale-hop" {time 10} {
	"mood (stay happy)" {poke 0xdb68 4}
	"time" {poke 0xdb5d 9;poke 0xdb5e 9;poke 0xdb5f 1}
}

create_trainer "police academy 1" {time 1} {
	"65535 bullets" {poke 0x4d39 255;poke 0x4d3a 255}
}

create_trainer "police academy 2" {time 1} {
	"health" {poke 0xc006 0}
	"mistakes" {poke 0xc007 0}
	"bullets" {poke 0xc003 255}
}

create_trainer "tt racer" {time 1} {
	"temp" {poke 0x5ad9 255}
}

create_trainer "humphrey" {time 10} {
	"lives" {poke 0x6797 9}
}

create_trainer "arkos 1" {time 10} {
	"lives" {poke 0x5bf2 10}
}

create_trainer "arkos 2" {time 10} {
	"lives" {poke 0x5bf2 10}
}

create_trainer "arkos 3" {time 10} {
	"lives" {poke 0x5bf2 10}
}

create_trainer "after the war 1" {time 1} {
	"power" {poke 0xba9a 16}
}

create_trainer "satan 1" {time 1} {
	"power unlimited" {poke 0x8462 0}
	"some gauge" {poke 0xc88f 100}
}

create_trainer "indiana jones and the last crusade" {time 1} {
	"power" {poke 0x7ac0 255}
	"whip" {poke 0x7abe 10}
	"lives" {poke 0x7ac1 9}
}

create_trainer "indiana jones and the temple of doom" {time 1} {
	"lives" {poke 0xc234 59}
}

create_trainer "corsarios 1" {time 1} {
	"power" {poke 0x96f2 99}
}

create_trainer "corsarios 2" {time 1} {
	"power" {poke 0x979b 9}
}

create_trainer "green beret" {time 1} {
	"lives" {poke 0xf120 57}
	"have bazooka" {poke 0xf0c3 4}
}

create_trainer "disc warrior" {time 1} {
	"power" {poke 0x8513 255}
}

create_trainer "eidelon" {time 1} {
	"power" {poke 0x012f 16}
}

create_trainer "hard boiled" {time 1} {
	"power" {poke 0xd047 32}
}

create_trainer "battle chopper" {time 1} {
	"power" {poke 0x8335 0}
}

create_trainer "tnt" {time 1} {
	"lives (bootleg version)" {poke 0x7074 100}
	"ammo (bootleg version)" {poke 0x4894 255}
	"lives" {poke 0x320e 255}
	"ammo" {poke 0x489d 255}
}

create_trainer "goody" {time 10} {
	"invincible" {poke 0xaeaf 8}
}

create_trainer "alpha-roid" {time 1} {
	"enemy dies after one kick" {poke 0xe8f7 0;poke 0xeb0e 231}
	"invincible (in space)" {poke 0xe399 4}
	"lives" {poke 0xe3a2 98}
}

create_trainer "operation wolf" {time 2} {
	"invincible" {poke 0x9ae9 0}
	"grenades" {poke 0x9ae6 9}
	"bullets" {poke 0xa316 32}
	"mag" {poke 0x9ae7 9}
}

create_trainer "teenage ninja mutant hero turtles" {time 1} {
	"invincible" {poke 0x5f66 16}
}

create_trainer "blade lords" {time 1} {
	"lives" {poke 0x0430 0x99}
	"invincible" {poke 0x0429 255}
	"have blades" {poke 0x0424 255}
}

create_trainer "chiller" {time 1} {
	"power" {poke 0x9ab8 25;poke 0x9ab9 0}
}

create_trainer "crusader" {time 1} {
	"power" {poke 0xe491 255}
	"get sword" {poke 0xe471 1}
}

create_trainer "dokidoki penguin land" {time 1} {
	"eggs" {poke 0xe111 100}
}

create_trainer "pegasus" {time 1} {
	"power" {poke 0xc006 43}
	"stage (change value to get that stage)" {#poke 0xc007 1}
	"big pegasus" {poke 0xc009 4}
}

create_trainer "avenger" {time 1} {
	"green sun" {poke 0xbdf8 255}
	"red sun" {poke 0xbdf9 255}
	"do not die" {poke 0xbdfa 0}
	"shuriken" {poke 0xacd5 255}
	"keys" {poke 0xacd3 255}
}

create_trainer "randar 3" {time 1} {
	"life player 1" {poke 0xd014 0x3;poke 0xd015 0xe7}
	"magic player 1" {poke 0xd016 0x3;poke 0xd017 0xe7}
	"life mick" {poke 0xd074 0x3;poke 0xd075 0xe7}
	"magic mick" {poke 0xd076 0x3;poke 0xd077 0xe7}
	"money" {poke 0xd185 254;poke 0xd186 255;poke 0xd187 255}
}

create_trainer "batten no dai bouken" {time 1} {
	"power" {poke 0xe2ed 128}
}

create_trainer "leather skirts" {time 1} {
	"energy" {poke 0xb406 255}
}

create_trainer "black cyclone" {frame} {
	"lives" {poke 0xd15a 8}
	"power" {poke 0xd13e 255}
}

create_trainer "casanova" {time 1} {
	"lives" {poke 0xb489 255}
}

create_trainer "chubby gristle" {time 1} {
	"lives" {poke 0x7532 255}
}

create_trainer "darwin 4078" {time 1} {
	"max weapons" {poke 0xe8e6 144;poke 0xe8f0 135;poke 0xe9bb 144}
}

create_trainer "demonia" {time 1} {
	"max weapons" {poke 0x806c 255}
}

create_trainer "jaws" {time 1} {
	"max hits" {poke 0x84a7 128}
	"invincible" {poke 0x84a5 255}
	"time" {poke 0x806c 255}
	"lives" {poke 0x8078 0x99}
}

create_trainer "joe blade" {time 1} {
	"max hits" {poke 0x8d97 128}
	"let enemies think you are one of them" {poke 0x8dbe 1}
	"ammo" {poke 0x8d98 255}
	"keys" {poke 0x8d8e 57;poke 0x8d8f 57}
	"bombs" {poke 0x8d90 57;poke 0x8d91 57}
	"bomb defusing timer" {poke 0x8dc0 41}
}

create_trainer "dr archie" {time 1} {
	"life" {poke 0xd3c8 64}
	"gold" {poke 0x404 0x99;poke 0x405 0x99;poke 0x406 0x99}
	"exp" {poke 0xd3c9 60}
}

create_trainer "ghostbusters" {time 0.10} {
	"lives" {poke 0xefa8 0x99;poke 0xefa9 0x99}
	"tries to get past the mars mellow man" {poke 0xf13a 255}
	"fast time" {poke 0xefe9 0x99}
	"ghost x-position" {poke 0xf0ed 128}
	"ghost y-position" {poke 0xf0ee 160}
}

create_trainer "replicart" {time 1} {
	"this trainer has been made with bifi's ips patch he deserves the credit :)" {poke 0xc0ad 1;poke 0xc20c 33;poke 0xc4b8 1;poke 0xc4bb 255;poke 0xf1a3 255;poke 0xf1a4 255;poke 0xf1a5 255;poke 0xf1a6 255;poke 0xf1a9 5;poke 0xfbf5 31;poke 0xfbf7 28;poke 0xfbf8 31}
	"freeze time before crystal moves" {poke 0xc182 53;poke 0xc181 53}
}

create_trainer "dass" {time 1} {
	"special power" {poke 0xaea1 162}
	"invincible" {poke 0x9abb 255}
	"lives" {poke 0xae51 4}
}

create_trainer "mirai" {time 1} {
	"special power" {poke 0xaea1 162}
}

create_trainer "sonyc" {time 1} {
	"99 rings... hooray :p" {poke 0xd311 0x99}
}

create_trainer "brother adventure" {time 1} {
	"3 lives" {poke 0xe812 3}
}

create_trainer "tensairab biandai funsen" {time 10} {
	"lives" {poke 0xec23 255}
	"timer" {poke 0xec27 255}
}

create_trainer "mad rider" {time 1} {
	"timer" {poke 0xc510 59}
	"full speed" {poke 0xc577 255}
}

create_trainer "castle of blackburn" {time 10} {
	"lives" {poke 0xda32 99}
	"unlimited swords" {poke 0xda2c 99}
	"invincible" {poke 0xda0e 255}
}

create_trainer "daiva 5" {time 1} {
	"battle ships in stock" {poke 0xd0b8 99}
	"o.m in stock" {poke 0xd0cc 98}
	"missile ships in stock" {poke 0xd0d6 97}
	"cruisers in stock" {poke 0xd0c2 99}
	"damage on planets" {poke 0x950a 0;poke 0x950b 0}
	"stop timer on planets" {poke 0x94ee 0}
	"money" {poke 0xd7ab 255;poke 0xd7ac 255}
}

create_trainer "daiva 4" {time 10} {
	"all kind of ships in stock" {poke 0xc4ee 99;poke 0xc4ef 99;poke 0xc4f0 99;poke 0xc4f1 99}
	"life on planet" {poke 0xd408 255}
}

create_trainer "pennant race 1" {time 1} {
	"3 out (both teams)" {poke 0xe19a 3}
	"player 2 always 0 points (end total)" {poke 0xe196 0}
	"always have 2 strikes" {poke 0xe198 2}
	"inf gold" {poke 0x1c96 255;poke 0x1c97 255}
	"0 fatigue" {poke 0x1c3c 0}
}

create_trainer "princess maker" {time 1} {
	"infinite gold" {poke 0x1c96 255;poke 0x1c97 255}
	"0 fatigue" {poke 0x1c3c 0}
}

create_trainer "magunam" {time 1} {
	"ammo" {poke 0xe048 255}
	"trigger timer" {poke 0xe062 4}
	"lives" {poke 0xe043 9}
}

create_trainer "mashou no yakata gabalin" {time 1} {
	"invincible" {poke 0xc0b8 255}
}

create_trainer "ice world" {time 10} {
	"lives" {poke 0xe00b 5}
}

create_trainer "manes" {time 10} {
	"lives" {poke 0xdb93 5}
}

create_trainer "issunhoushi no donnamondai" {frame} {
	"power" {poke 0xe1b5 64}
	"invincible" {poke 0xe03a 255}
}

create_trainer "scarlet 7" {time 1} {
	"power" {poke 0xe106 10}
}

create_trainer "zoom 909" {time 1} {
	"fuel" {poke 0xe021 0}
}

create_trainer "final fantasy" {time 1} {
	"gold" {poke 0xc255 255;poke 0xc256 255}
	"life player 1" {poke 0xc00a 99;poke 0xc008 255;poke 0xc009 255}
	"life player 2" {poke 0xc04a 99;poke 0xc048 255;poke 0xc049 255}
	"life player 3" {poke 0xc08a 99;poke 0xc088 255;poke 0xc089 255}
	"life player 4" {poke 0xc0ca 99;poke 0xc0c8 255;poke 0xc0c9 255}
}

create_trainer "breaker" {frame} {
	"balls" {poke 0x953d 99}
	"ball under bat" {poke 0x922a [expr {[peek 0x9236]+8}]}
	"ball at same height as 2nd bat" {poke 0x922c [expr {[peek 0x9237]-40}]}
}

create_trainer "bosconian" {time 1} {
	"life bar" {poke 0xe00d 99}
	"'attack' alarm doesn't sound (makes it harder)" {poke 0xe810 0}
}

create_trainer "zaider" {time 1} {
	"damage bar" {poke 0xe1dc 0}
	"psyco-g1 ammo" {poke 0xe09b 255}
	"psyco-g2 ammo" {poke 0xe09c 255}
	"psyco-g3 ammo" {poke 0xe09d 255}
	"zaider damage" {poke 0xe0b5 0}
}

create_trainer "fray" {time 1} {
	"life bar full" {poke 0x2010 200}
	"money 65535" {poke 0x2289 255;poke 0x228a 255}
	"auto big shot (hold c to hold)" {poke 0x2286 49}
	"scepter 1" {poke 0x2295 2}
	"scepter 2" {poke 0x2296 2}
	"scepter 3" {poke 0x2297 2}
	"scepter 4" {poke 0x2298 2}
	"scepter 5" {poke 0x2299 2}
	"scepter 6" {poke 0x229a 2}
	"scepter 7" {poke 0x229b 2}
	"scepter 8" {poke 0x229c 2}
	"medium shield" {poke 0x229e 1}
	"iron shield" {poke 0x229f 1}
	"big iron shield" {poke 0x22a0 1}
	"gold shield" {poke 0x22a1 1}
	"slice of bread" {poke 0x22a2 99}
	"slice of bacon" {poke 0x22a3 99}
	"bottle" {poke 0x22a4 99}
	"scroll 1" {poke 0x22a5 99}
	"scroll 2" {poke 0x22a6 99}
	"scroll 3" {poke 0x22a7 99}
	"scroll 4" {poke 0x22a8 99}
	"scroll 5" {poke 0x22a9 99}
	"scroll 6" {poke 0x22aa 99}
	"scroll 7" {poke 0x22ab 99}
	"scroll 8" {poke 0x22ac 99}
	"scroll 9" {poke 0x22ad 99}
	"scroll 10" {poke 0x22ae 99}
	"scroll 11" {poke 0x22af 99}
}

create_trainer "xzr 1" {time 1} {
	"exp max" {poke 0xd000 255;poke 0xd001 255;poke 0xd002 255}
	"life" {poke 0xd018 255}
	"invincible" {poke 0xd0ac 255}
	"max money" {poke 0xd035 255;poke 0xd036 255;poke 0xd037 255}
}

create_trainer "xzr 2" {time 1} {
	"max money" {poke 0xd180 255;poke 0xd181 255;poke 0xd182 255}
	"life" {poke 0xd0a0 255}
	"exp" {poke 0xd0a8 255;poke 0xd0a9 255}
}

create_trainer "robocop" {time 1} {
	"power" {poke 0x75bb 100;poke 0x7746 255}
	"lives" {poke 0x7752 99}
}

create_trainer "familice parodic 2" {time 1} {
	"lives" {poke 0xc008 9}
}

create_trainer "borfesu" {time 0.25} {
	"life" {poke 0xe37c 255}
	"staff" {poke 0xe09f 1}
	"bow" {poke 0xe0a0 1}
	"whirlwind" {poke 0xe0a1 1}
	"boomerang" {poke 0xe0a2 1}
	"keltic cross" {poke 0xe0a3 1}
	"sword" {poke 0xe0a4 1}
	"scepter" {poke 0xe0a5 1}
	"ball" {poke 0xe0a6 1}
	"statue" {poke 0xe0a7 1}
	"space suit" {poke 0xe0a8 1}
	"key" {poke 0xe0a9 1}
	"pot" {poke 0xe0aa 1}
	"kettle" {poke 0xe0ab 1}
	"bottle" {poke 0xe0ac 1}
	"vase" {poke 0xe0ad 1}
	"money" {poke 0xe043 255;poke 0xe044 255}
	"exp" {poke 0xe045 200;poke 0xe046 255}
	"containers" {poke 0xe01a 250}
	"invincible" {poke 0xe37d 201}
}

create_trainer "alcazar" {frame} {
	"power" {poke 0xf082 127;poke 0xf209 1}
}

create_trainer "saimazoom" {time 1} {
	"lives" {poke 0xd9cf 9}
	"water" {poke 0xd9d8 0x99;poke 0xd9d9 0x99}
	"remove time limit" {poke 0xd9d1 0}
	"slot 1" {#poke 0xd9e8 102}
	"slot 2" {poke 0xd9e9 102}
	"slot 3" {poke 0xd9ea 103}
	"slot 4" {poke 0xd9eb 106}
	"toggle trough items" {
		# 100 = bag
		# 101 = water bottle
		# 102 = knife*
		# 103 = pick axe*
		# 104 = key*
		# 105 = kano*
		# 106 = gun*
		# 107 = nothing
		if {[peek 0xd9e8] < 100} {poke 0xd9e8 100}
		poke 0xd9e8 [expr [peek 0xd9e8]+1]
		if {[peek 0xd9e8] > 106} {poke 0xd9e8 100}
	}
}

create_trainer "the cure" {time 1} {
	"power" {poke 0xdae6 64}
	"invincible" {poke 0xdadf 4}
	"get yellow key" {poke 0xdae0 1}
	"get white key" {poke 0xdae1 1}
	"kill enemy with one hit (end boss 3 caution!)" {poke 0xdb8d 1}
	"hearts" {poke 0xdd44 0x99}
	"next stage (-1)" {#poke 0xdd46 1}
	"optional weapon - holy water" {poke 0xdae5 1}
	"optional weapon - daggers" {poke 0xdae5 2}
	"sand of time" {poke 0xdae4 1}
}

create_trainer "universe unknown" {frame} {
	"power" {poke 0xee55 128;poke 0xee54 255}
	"lives" {poke 0xf2c4 233}
}

create_trainer "caverns of titan" {frame} {
	"oxygen" {poke 0xd4e4 255}
	"walking speed" {poke 0xd6dc 1}
}

create_trainer "seikema 2 special" {time 10} {
	"life" {poke 0xe060 255;poke 0xe061 255}
	"money" {poke 0xe062 255}
	"weapon (try 0-5)" {poke 0xe048 5}
}

create_trainer "moai no hibou" {time 1} {
	"pillars" {poke 0xe30e 255}
	"life" {poke 0xe00b 10}
}

create_trainer "kinnikuman" {time 1} {
	"life player 1" {poke 0xf002 255}
}

create_trainer "poppaq the fish" {time 1} {
	"life player 1" {poke 0xe122 0}
}

create_trainer "space invader" {time 1} {
	"lives (for the space invader (1984) (taito) version" {poke 0xe046 4}
}

create_trainer "megamitensho" {time 1} {
	"power bar" {poke 0xd271 255}
	"other bar" {poke 0xd272 255}
	"disks" {poke 0xd6bb 99}
}

create_trainer "ink" {time 1} {
	"infinite lives" {poke 0x700c 5}
}

create_trainer "penguin kun wars1" {time 1} {
	"enemy stuck in one position" {poke 0xd020 15}
	"enemy k.o" {poke 0xd026 255}
}

create_trainer "penguin kun wars2" {time 1} {
	"enemy k.o after being hit" {poke 0xb126 255;poke 0xb146 255;poke 0xb166 255}
}

create_trainer "seiken acho" {time 1} {
	"power" {poke 0xecad 255}
	"time" {poke 0xecc6 0x2}
}

create_trainer "dorodon" {time 1} {
	"kill all enemies" {poke 0xc9fb 1;poke 0xc9fc 255}
	"lives" {poke 0xc6f3 5}
}

create_trainer "mr chin" {time 1} {
	"lives" {poke 0xe101 8}
}

create_trainer "laptick 2" {time 1} {
	"lives" {poke 0xe018 10}
	"always have an exit" {poke 0xe020 7}
}

create_trainer "kings balloon" {time 60} {
	"lives" {poke 0xe490 255}
}

create_trainer "grogs revenge" {time 30} {
	"stones collected" {poke 0xe089 255;poke 0xe08a 255}
	"tires left" {poke 0xe08b 5}
}

create_trainer "actman" {time 1} {
	"lives player 1" {poke 0xe2a7 6}
	"lives player 2" {poke 0xe2a8 6}
	"viewing mode" {poke 0xe2a9 8}
	"sword" {poke 0xe1b4 1}
	"axe" {poke 0xe1b4 2}
	"only one bear" {poke 0xe247 1}
	"only one bird" {poke 0xe248 1}
	"only one fish" {poke 0xe249 1}
	"only one red monster" {poke 0xe24a 1}
	"only one snake" {poke 0xe24b 1}
	"only one blue monster" {poke 0xe24c 1}
	"bonus infinite time" {poke 0xe1e9 20}
}

create_trainer "shout match" {time 1} {
	"power" {poke 0xc001 128}
}

create_trainer "cosmo explorer" {time 1} {
	"fuel" {poke 0xdaa9 255}
	"power" {poke 0xdac1 0}
	"photon torpedoes" {poke 0xdaa7 99}
}

create_trainer "funky mouse" {time 1} {
	"lives" {poke 0xe211 1}
}

create_trainer "knither special" {time 1} {
	"life meter" {poke 0xf060 9;poke 0xf061 9;poke 0xf062 9;poke 0xf063 9}
	"small keys" {poke 0xf056 9}
	"fireballs (bombs)" {poke 0xf050 9}
	"thunder sword" {poke 0xf051 9}
	"fire wave" {poke 0xf053 9}
	"big key (makes the game boring)" {poke 0xf057 9}
	"cracker" {poke 0xf052 99}
}

create_trainer "warp warp" {time 1} {
	"lives" {poke 0xe089 99}
}

create_trainer "iga ninpouten 1" {time 1} {
	"lives" {poke 0xe00b 99}
	"time" {poke 0xe080 9}
}

create_trainer "iga ninpouten 2" {time 1} {
	"lives" {poke 0xe00b 0x99}
}

create_trainer "sinbad" {time 1} {
	"power" {poke 0xead7 14}
	"lives" {poke 0xeae3 6}
}

create_trainer "star blazer" {time 1} {
	"bombs" {poke 0xe415 99}
	"lives" {poke 0xe409 99}
}

create_trainer "trail blazer" {time 1} {
	"jumps left in arcade mode" {poke 0x8721 9}
	"time on cb:a9 (leave this value alone, it checks for s)" {poke 0x866c 4;poke 0x866b 4}
}

create_trainer "vampire" {time 1} {
	"power" {poke 0x9491 99}
	"lives" {poke 0x9493 8}
}

create_trainer "pachipro densetsu" {time 1} {
	"money" {poke 0xe230 0x99;poke 0xe22f 0x99;poke 0xe22e 0x99;poke 0xe22d 0x99}
}

create_trainer "indian no bouken" {time 1} {
	"lives" {poke 0xe60e 255}
	"boomerang" {poke 0xe610 99}
}

create_trainer "shalom" {time 1} {
	"power" {poke 0xe3f6 255}
}

create_trainer "dragon quest 2" {time 1} {
	"hp" {poke 0xe63b 255;poke 0xe63c 255}
	"magic" {poke 0xe63d 255}
	"gold" {poke 0xe624 255;poke 0xe625 255}
	"max exp" {poke 0xe633 255;poke 0xe634 255;poke 0xe635 255}
	"max hp" {poke 0xe630 255;poke 0xe631 255}
	"max stats" {poke 0xe636 255;poke 0xe637 255;poke 0xe638 255;poke 0xe639 255}
	"level" {#poke 0xe63e 22}
}

create_trainer "break in" {frame} {
	"thanks mars2000you" {poke 0x7d9e 5}
	"infinite lives" {poke 0x7d9e 5}
	"always fire" {poke 0x85d5 90}
	"long bat" {poke 0x85d6 16}
	"open room 2" {poke 0x85ff 28;poke 0x8600 28;poke 0x8601 28;poke 0x8602 28}
	"open room 3" {poke 0x871f 28;poke 0x8720 28;poke 0x8721 28;poke 0x8722 28}
	"open room 4" {poke 0x883f 28;poke 0x8840 28;poke 0x8841 28;poke 0x8842 28}
	"frozen guardian" {poke 0x8a7b 0}
	"invisible guardian (hard game !)" {poke 0x8a83 0}
}

create_trainer "hyper sports 1" {time 1} {
	"always qualify" {poke 0xe05a 9;poke 0xe059 0x99}
}

create_trainer "hyper sports 2" {time 1} {
	"always qualify" {poke 0xe088 0x99;poke 0xe089 0x99}
	"always full power" {poke 0xe101 255}
	"unlimited arrows" {poke 0x111 8}
	"freezes time" {poke 0xe1a6 15}
}

create_trainer "hyper sports 3" {frame} {
	"freeze time" {poke 0xe0d0 0}
	"top speed cycling" {poke 0xe0ad 255}
	"top speed long jump" {poke 0xe121 255}
}

create_trainer "hyper olympics 1" {time 1} {
	"sprint time" {poke 0xe0a5 0;poke 0xe0a9 0}
}

create_trainer "hyper olympics 2" {time 1} {
	"sprint time" {poke 0xe0a5 0;poke 0xe0a9 0}
}

create_trainer "gp-world" {time 1} {
	"time" {poke 0xe1cb 0}
	"round (1-9)" {#poke 0xe005 1}
	"level (1-3)" {#poke 0xe00f 1}
}

create_trainer "deep dungeon 1" {time 1} {
	"life" {poke 0xc157 255;poke 0xc158 255}
	"max gold" {poke 0xc160 255;poke 0xc161 255}
	"max exp" {poke 0xc159 255;poke 0xc15a 255}
}

create_trainer "deep dungeon 2" {time 1} {
	"life" {poke 0xc17e 255;poke 0xc17f 255}
	"max gold" {poke 0xc18a 255;poke 0xc18b 255}
	"max level" {poke 0xc17d 99}
	"max ap" {poke 0xc185 255}
	"max ac" {poke 0xc182 255}
	"max ag" {poke 0xc184 255}
	"max luck" {poke 0xc189 255}
}

create_trainer "nsub" {time 1} {
	"lives" {poke 0xc13b 3}
	"round (0-99)" {#poke 0xc142 1}
}

create_trainer "kobashi" {time 1} {
	"infinite power player 1" {poke 0xd448 50}
	"infinite power player 2 or computer 1" {poke 0xd454 50}
	"infinite power computer 2" {poke 0xd460 50}
}

create_trainer "guru logic (msx1)" {time 1} {
	"infinite time" {poke 0xc1e2 0}
	"level (0-17)" {#poke 0xc1f2 0}
}

create_trainer "guru logic (msx2)" {frame} {
	"infinite time" {poke 0xa68c 17}
	"level (0-4)" {#poke 0x9bc5 0;poke 0xcc00 0}
}

create_trainer "the munsters" {time 1} {
	"power" {poke 0xaa7a 255}
}

create_trainer "ballout 1" {time 60} {
	"time" {poke 0xaa40 99}
}

create_trainer "ballout 2" {time 60} {
	"time" {poke 0x9aa6 99}
}

create_trainer "ballout special" {time 60} {
	"time" {poke 0x9560 99}
}

create_trainer "bank buster" {time 0.1} {
	"lives" {poke 0x63fd 99}
	"ball above bat" {poke 0x4b01 peek}
}

create_trainer "exterlien" {time 1} {
	"power" {poke 0x9e2d 0x0f;poke 0x9e2e 0x27}
	"exp" {poke 0x9e33 0xff;poke 0x9e34 0xff}
}

create_trainer "legendly knight" {time 1} {
	"power" {poke 0xd07b 0x1;poke 0xd07c 0x20}
	"invincible" {poke 0xd083 255}
	"short sword" {poke 0xe301 1}
	"fire arrow" {poke 0xe302 1}
	"bible" {poke 0xe303 1}
	"magic crystal" {poke 0xe304 1}
	"thunder" {poke 0xe305 1}
	"holy water" {poke 0xe306 1}
	"glasses" {poke 0xe307 1}
	"ring" {poke 0xe308 1}
	"rollers" {poke 0xe309 1}
	"armor" {poke 0xe30a 1}
	"diving suit" {poke 0xe30b 1}
	"key" {poke 0xe30c 1}
	"kill end boss with one shot" {poke 0xd08c 1}
}

create_trainer "chopper 2" {time 1} {
	"damage" {poke 0x6a9e 0;poke 0x6aa2 0}
	"heat seeking missile" {poke 0x6397 9}
	"tracking missile" {poke 0x6398 9}
	"machine gun" {poke 0x6399 232;poke 0x639a 3}
}

create_trainer "ita express" {time 1} {
	"lives" {poke 0xe308 3}
}

create_trainer "sammyu densetsu" {time 15} {
	"lives" {poke 0xe016 9}
	"power" {poke 0xe024 5}
}

create_trainer "hydlide 2" {time 1} {
	"start points" {poke 0xf10b 0x99}
	"life max" {poke 0xe01d 0x99}
	"strength max" {poke 0xe022 0x99}
	"magic max" {poke 0xe025 0x99}
}

create_trainer "zukkoke yajikita onmitsudoutyuu" {time 1} {
	"life" {poke 0xe060 0x99}
	"something" {poke 0xe061 0x99}
	"something else" {poke 0xe062 0x99}
	"something" {poke 0xe063 0x99;poke 0xe065 0x99}
	"something" {poke 0xe064 0x9}
	"item 1-8" {poke 0xe066 0x9;poke 0xe067 0x9;poke 0xe068 0x9;poke 0xe069 0x9;poke 0xe06a 0x9;poke 0xe06b 0x9;poke 0xe06c 0x9;poke 0xe06d 0x9}
}

create_trainer "namco f1 racing" {time 1} {
	"start points" {poke 0xc701 11}
	"damage" {poke 0xc828 255}
	"fuel" {poke 0xc828 255}
}

create_trainer "final zone" {time 1} {
	"power" {poke 0xe024 255}
	"ammo" {poke 0xe11c 255}
	"grenades" {poke 0xe11b 255}
}

create_trainer "zambeze" {time 1} {
	"get lives" {poke 0xc025 8}
	"get leafs" {poke 0xc011 1;poke 0xc012 1;poke 0xc013 1;poke 0xc014 1;poke 0xc015 1;poke 0xc016 1;poke 0xc017 1}
}

create_trainer "pumpkin adventure 3" {time 1} {
	"money" {poke 0xd4a8 0x99;poke 0xd4a9 0x99;poke 0xd4aa 0x99;poke 0xd4ab 0x99}
	"key card white" {poke 0xd47b 1}
	"key" {poke 0xd47c 1}
	"crow bar" {poke 0xd47d 1}
	"key card green" {poke 0xd47e 1}
	"scroll" {poke 0xd47f 1}
	"key" {poke 0xd480 1}
	"gas can" {poke 0xd481 1}
	"marble" {poke 0xd482 1}
	"suit" {poke 0xd483 1}
	"keycard red" {poke 0xd484 1}
	"soup bowl" {poke 0xd485 1}
	"necklace" {poke 0xd486 1}
	"gloves" {poke 0xd487 1}
	"key" {poke 0xd488 1}
	"mirror" {poke 0xd489 1}
	"cross" {poke 0xd48a 1}
	"marble 2" {poke 0xd48b 1}
	"key" {poke 0xd48c 1}
	"marble 3" {poke 0xd48d 1}
	"green opal" {poke 0xd48e 1}
	"red opal" {poke 0xd48f 1}
	"blue opal" {poke 0xd490 1}
	"orange opal" {poke 0xd491 1}
	"black opal" {poke 0xd492 1}
	"black key" {poke 0xd493 1}
	"blue key" {poke 0xd494 1}
	"orange key" {poke 0xd495 1}
	"troche" {poke 0xd496 1}
	"weed key" {poke 0xd497 1}
	"butterfly" {poke 0xd498 1}
	"male insect" {poke 0xd499 1}
	"female insect" {poke 0xd49a 1}
	"key" {poke 0xd49b 1}
	"necklace" {poke 0xd49c 1}
	"book" {poke 0xd49d 1}
	"marble" {poke 0xd49e 1}
	"white keycard 2" {poke 0xd49f 1}
	"space suit" {poke 0xd4a0 1}
	"mirror 2" {poke 0xd4a1 1}
	"cane" {poke 0xd4a2 1}
	"red scrolls" {poke 0xd4a3 1}
	"gold cross" {poke 0xd4a4 1}
	"silver cross" {poke 0xd4a5 1}
	"match" {poke 0xd4a6 1}
	"wallet" {poke 0xd4a7 1}
	"steve life" {poke 0xd5ba 0x99;poke 0xd5bb 0x99}
	"jeff max exp" {poke 0xd5bc 0x99;poke 0xd5bd 0x99}
	"jeff mp" {poke 0xd5be 0x99;poke 0xd5bf 0x99}
	"jeff max mp" {poke 0xd5c0 0x99;poke 0xd5c1 0x99}
	"jeff experience" {poke 0xd5c2 0x99;poke 0xd5c3 0x99;poke 0xd5c4 0x99}
	"jeff max experience" {poke 0xd5c5 0x00;poke 0xd5c6 0x00;poke 0xd5c7 0x01}
	"level" {poke 0xd5c8 0x99}
	"defense" {poke 0xd5c9 0x99;poke 0xd5ca 0x99}
	"max defense" {poke 0xd5cb 0x99;poke 0xd5cc 0x99}
	"weapon" {poke 0xd5cd 0x9}
	"bishop life" {poke 0xd5f3 0x99;poke 0xd5f4 0x99}
	"jeff max exp" {poke 0xd5f5 0x99;poke 0xd5f6 0x99}
	"jeff mp" {poke 0xd5f7 0x99;poke 0xd5f8 0x99}
	"jeff max mp" {poke 0xd5f9 0x99;poke 0xd5fa 0x99}
	"jeff experience" {poke 0xd5fb 0x99;poke 0xd5fc 0x99;poke 0xd5fd 0x99}
	"jeff max experience" {poke 0xd5fe 0x00;poke 0xd5ff 0x00;poke 0xd600 0x01}
	"level" {poke 0xd601 0x99}
	"defense" {poke 0xd602 0x99;poke 0xd603 0x99}
	"max defense" {poke 0xd604 0x99;poke 0xd605 0x99}
	"weapon" {poke 0xd606 0x9}
	"damien life" {poke 0xd62c 0x99;poke 0xd62d 0x99}
	"jeff max exp" {poke 0xd62e 0x99;poke 0xd62f 0x99}
	"jeff mp" {poke 0xd630 0x99;poke 0xd631 0x99}
	"jeff max mp" {poke 0xd632 0x99;poke 0xd633 0x99}
	"jeff experience" {poke 0xd634 0x99;poke 0xd635 0x99;poke 0xd636 0x99}
	"jeff max experience" {poke 0xd637 0x00;poke 0xd638 0x00;poke 0xd639 0x01}
	"level" {poke 0xd63a 0x99}
	"defense" {poke 0xd63b 0x99;poke 0xd63c 0x99}
	"max defense" {poke 0xd63d 0x99;poke 0xd63e 0x99}
	"weapon" {poke 0xd63f 0x9}
	"jeff life" {poke 0xd665 0x99;poke 0xd666 0x99}
	"jeff max exp" {poke 0xd667 0x99;poke 0xd668 0x99}
	"jeff mp" {poke 0xd669 0x99;poke 0xd66a 0x99}
	"jeff max mp" {poke 0xd66b 0x99;poke 0xd66c 0x99}
	"jeff experience" {poke 0xd66d 0x99;poke 0xd66e 0x99;poke 0xd66f 0x99}
	"jeff max experience" {poke 0xd670 0x00;poke 0xd671 0x00;poke 0xd672 0x01}
	"level" {poke 0xd673 0x99}
	"defense" {poke 0xd674 0x99;poke 0xd675 0x99}
	"max defense" {poke 0xd676 0x99;poke 0xd677 0x99}
	"weapon" {poke 0xd678 0x9}
}

create_trainer "blue warrior" {time 1} {
	"lives" {poke 0xaacb 8}
	"shot (1=normal, 2=fire, 3=electric)" {poke 0xaacd 2}
}

create_trainer "fairy" {time 5} {
	"lives" {poke 0xdf04 5}
}

create_trainer "mappy" {time 5} {
	"lives" {poke 0xe043 11}
}

create_trainer "warroid" {time 10} {
	"power player 1" {poke 0xc58b 255}
	"power player 2" {poke 0xc5ab 1}
}

create_trainer "xyzlogic" {time 10} {
	"lives" {poke 0xe418 100}
}

create_trainer "stepper" {time 5} {
	"lives" {poke 0xe901 99}
	"have shot" {poke 0xe904 1}
}

create_trainer "exerion 1" {time 1} {
	"lives player 1" {poke 0xe108 3}
	"lives player 2" {poke 0xe109 3}
	"always charge player 1" {poke 0xe120 153}
	"always charge player 2" {poke 0xe122 153}
}

create_trainer "exerion 2" {time 1} {
	"lives player 1" {poke 0xe108 3}
	"lives player 2" {poke 0xe109 3}
	"always charge player 1" {poke 0xe120 153}
	"always charge player 2" {poke 0xe122 153}
}

create_trainer "swing" {time 5} {
	"lives" {poke 0xe30f 100}
}

create_trainer "david 2" {time 5} {
	"lives" {poke 0xe194 255}
}

create_trainer "telebunnie" {time 1} {
	"lives" {poke 0xe064 255}
	"snake y-position" {poke 0xe018 0}
}

create_trainer "sofia" {time 5} {
	"hearts" {poke 0xe6eb 5}
	"invincible (except lava and water)" {poke 0xe6ed 255}
}

create_trainer "boggy 84" {time 5} {
	"lives" {poke 0xe693 4}
}

create_trainer "riseout" {time 5} {
	"lives" {poke 0xec06 255}
	"red man x-position" {poke 0xed11 255}
	"red man y-position" {poke 0xed12 191}
}

create_trainer "danger x4" {time 1} {
	"lives" {poke 0xd018 10}
	"mice left " {poke 0xd026 1}
}

create_trainer "the fairy land story" {time 5} {
	"lives" {poke 0xe1c0 0x99}
}

create_trainer "psychic soldier 2" {time 5} {
	"power" {poke 0xf07a 255;poke 0xf07b 255}
	"fire power" {poke 0xf07e 255;poke 0xf07f 255}
}

create_trainer "pipi" {time 1} {
	"invincible" {poke 0xd623 1}
	"invincible timer" {poke 0xd654 255}
	"exit always active" {poke 0xd710 2}
	"time" {poke 0xd716 20}
	"lives" {poke 0xd478 11}
}

create_trainer "zexaslimited" {time 60} {
	"invincible" {poke 0xeecf 100}
}

create_trainer "bank panic" {time 1} {
	"lives player 1" {poke 0xf587 2}
	"extra time player 1" {poke 0xf5b0 119}
	"lives player 2" {poke 0xf5bf 2}
	"extra time player 2" {poke 0xf5e3 119}
	"level (1-9;16-24;...)" {#poke 0xf586 1}
}

create_trainer "bombjack (msx1)" {time 1} {
	"lives player 1" {poke 0xc061 4}
	"more points player 1" {poke 0xc063 4}
	"lives player 2" {poke 0xc084 4}
	"more points player 2" {poke 0xc086 4}
	"only one frozen enemy" {poke 0xc010 55}
	"round (1-50)" {#poke 0xc064 1}
}

create_trainer "bomb jack (msx2)" {time 1} {
	"lives" {poke 0x483a 52}
	"more points" {poke 0x7d2a 3}
	"invincible" {poke 0x7d4a 1}
	"round (1-80)" {#poke 0x7d20 1}
}

create_trainer "bomb jack (msx2 - promo)" {time 1} {
	"lives" {poke 0x46b9 52}
	"more points" {poke 0x6a89 3}
	"invincible" {poke 0x6aa9 1}
	"round (1-5)" {#poke 0x6a7f 1}
}

create_trainer "chack�n�pop" {time 1} {
	"lives" {poke 0xe06f 3}
	"no monsters" {poke 0xe00d 255;poke 0xe012 255;poke 0xe017 255;poke 0xe01c 255;poke 0xe021 255;poke 0xe026 255;poke 0xe02b 255;poke 0xe030 255;poke 0xe035 255;poke 0xe03a 255}
	"infinite time" {poke 0xe06b 0}
	"maze (1-8)" {#poke 0xe06d 1}
}

create_trainer "chop lifter" {time 1} {
	"lives" {poke 0xe24d 0}
	"only tanks" {poke 0xe27b 0}
}

create_trainer "congo bongo" {time 1} {
	"lives" {poke 0xf34b 3}
	"infinite time (to use when the game begins)" {poke 0xf365 0}
}

create_trainer "tower of drauga" {time 1} {
	"lives" {poke 0xe9ef 5}
	"always have key" {poke 0xea0e 1}
	"infinite time" {poke 0xea05 128}
	"pick axe" {poke 0xeb64 1;poke 0xea0d 250}
}

create_trainer "rally" {time 1} {
	"fuel" {poke 0xe039 64}
	"lives" {poke 0xe035 5}
}

create_trainer "star force" {time 1} {
	"lives" {poke 0xe405 100}
}

create_trainer "future knight" {time 1} {
	"lives" {poke 0xb4ce 231}
	"weapon (25-dart/23 beam/24 fireball)" {poke 0x8075 24}
}

create_trainer "astro blaster" {time 1} {
	"lives" {poke 0x0575 3}
}

create_trainer "galaxian" {time 1} {
	"lives" {poke 0xe071 9}
}

create_trainer "donkey kong" {time 1} {
	"lives" {poke 0x94ed 9}
}

create_trainer "exterminator" {time 1} {
	"lives" {poke 0x4505 58}
}

create_trainer "the untouchables" {time 1} {
	"power" {poke 0x70de 255}
}

create_trainer "barunba" {time 1} {
	"energy" {poke 0x6989 6}
	"shot (experiment with the value 1-4)" {poke 0x699a 4}
}

create_trainer "tertis bps" {time 1} {
	"next block always bar" {poke 0xd28a 1}
}

create_trainer "magnar" {time 1} {
	"live (255 is game over)" {poke 0xca7f 250}
}

create_trainer "double dragon 2" {time 1} {
	"power player 1" {poke 0x4079 15}
	"time" {poke 0x2918 0x99}
}

create_trainer "cannonball" {time 1} {
	"lives" {poke 0xe331 9}
}

create_trainer "zenji" {time 1} {
	"lives" {poke 0xe1b1 0x99}
}

create_trainer "legendly nine gems" {time 1} {
	"power" {poke 0xb39a 0x99;poke 0xb399 0x99}
	"gold" {poke 0xb39b 0x99;poke 0xb39c 0x99}
	"magic card" {poke 0xb441 255}
	"book" {poke 0xb442 255}
	"candle" {poke 0xb443 225}
	"whool (?)" {poke 0xb444 225}
	"drums" {poke 0xb445 255}
	"shell" {poke 0xb446 255}
	"blue vase" {poke 0xb447 255}
	"red vase" {poke 0xb448 255}
	"hat" {poke 0xb449 255}
	"red botle" {poke 0xb44a 255}
	"yellow liquid" {poke 0xb44b 255}
	"red liquid" {poke 0xb44c 255}
	"key" {poke 0xb44d 3}
}

create_trainer "break-out adventure" {time 1} {
	"power" {poke 0x873e 12}
	"lives" {poke 0x863d 5}
}

create_trainer "vaxol" {time 1} {
	"power" {poke 0xc148 255}
}

create_trainer "game over part 1" {time 1} {
	"lives" {poke 0xd9bb 11}
	"power" {poke 0xda1b 255}
	"second shot" {poke 0xd9bf 100}
}

create_trainer "game over part 2" {time 1} {
	"lives" {poke 0xd9bf 12}
	"power" {poke 0xda27 255}
	"second shot" {poke 0xd9c3 100}
}

create_trainer "flash splash" {time 1} {
	"lives -- this trainer might not work 100%" {poke 0xe000 255}
	"power" {poke 0xe008 64}
	"invincible" {poke 0xe001 0;poke 0xe009 255}
}

create_trainer "river raid" {time 1} {
	"fuel" {poke 0xe178 172}
	"lives" {poke 0xe135 0x99}
}

create_trainer "drainer" {time 1} {
	"lives" {poke 0xec97 99}
	"discs" {poke 0xc4c7 3}
}

create_trainer "moon patrol" {time 1} {
	"lives" {poke 0xf920 4}
}

create_trainer "eric and the floaters" {time 1} {
	"lives" {poke 0xe30f 13}
}

create_trainer "bokosuka wars" {time 1} {
	"power (only works when selecting the commander on game start)" {poke 0xd77e 0}
}

create_trainer "haunted house" {time 1} {
	"lives" {poke 0x4028 6}
	"always have keys" {poke 0x747e 2}
	"always have shot (f1)" {poke 0x747f 4}
	"time" {poke 0x402c 0x9;poke 0x402d 0x9;poke 0x402e 0x9}
}

create_trainer "ghost busters 2 - phase1" {time 1} {
	"ammo" {poke 0x6189 99}
	"rope strength" {poke 0x6185 0}
	"courage" {poke 0x6180 0}
}

create_trainer "flicky" {time 1} {
	"lives" {poke 0xe0ee 3}
	"round (1-40)" {#poke 0xe0e7 1;#poke 0xe0e8 1}
}

create_trainer "girls garden" {time 1} {
	"honey (water)" {poke 0xc00e 5}
	"love (lives)" {poke 0xc00f 3}
	"flowers (very easy !)" {poke 0xc0be 10}
}

create_trainer "gulkave" {time 10} {
	"energy" {poke 0xe2ad 255}
	"weapon (0-16)" {poke 0xe2a7 8}
	"lives" {poke 0xe2c5 6}
}

create_trainer "hangon" {time 1} {
	"time" {poke 0xe04c 100}
	"course (0-8)" {#poke 0xe029 0}
	"level (0-2)" {#poke 0xe00e 0}
}

create_trainer "hustlechumy" {time 1} {
	"lives" {poke 0xe153 9}
	"infinite time" {poke 0xe1d7 90;poke 0xe1d9 0}
	"level (1-99;0)" {#poke 0xe106 1}
}

create_trainer "3d bomberman" {time 1} {
	"lives" {poke 0xe80f 3}
}

create_trainer "demon crystal" {time 1} {
	"bombs" {poke 0xf007 9;poke 0xf008 9}
	"lives" {poke 0xf009 9;poke 0xf00a 9}
	"keys" {poke 0xf005 9;poke 0xf006 9}
	"time" {poke 0xf00b 9;poke 0xf00c 9;poke 0xf00d 9}
}

create_trainer "negrooli panda" {time 1} {
	"power" {poke 0xe2ed 99}
}

create_trainer "ninja princess" {time 1} {
	"lives" {poke 0xe047 99}
	"partially invincible" {poke 0xe200 0;poke 0xe343 0}
}

create_trainer "hype" {time 1} {
	"programmers mode (try b/l/numbers/function keys)" {poke 0xc00d 255}
	"invincible" {poke 0xc00a 255}
}

create_trainer "illusion city" {time 1} {
	"money" {poke 0xc268 255;poke 0xc267 255}
	"level tien ren" {poke 0xc277 99}
	"exp tien ren" {poke 0xc275 255;poke 0xc274 255}
	"hp tien ren" {poke 0xc282 231;poke 0xc283 3}
	"extended offense tien ren" {poke 0xc288 231;poke 0xc289 3}
	"extended defense tien ren" {poke 0xc285 231;poke 0xc286 3}
	"tien extended ren agility" {poke 0xc27b 99}
	"level mei hong" {poke 0xc29f 99}
	"exp mei hong" {poke 0xc29d 255;poke 0xc29c 255}
	"hp mei hong" {poke 0xf636 231;poke 0xf637 3}
	"extended offence mei hong" {poke 0xc2b0 231;poke 0xc2b1 3}
	"extended defende mei hong" {poke 0xc2ad 231;poke 0xc2ac 3}
	"extended agility mei hong" {poke 0xc2a3 99}
	"exp old man" {poke 0xc2ed 255;poke 0xc2ec 255}
	"level old man" {poke 0xc2ef 99}
	"exp kash" {poke 0xc33d 255;poke 0xc33c 255}
	"defense" {poke 0xc34d 255}
}

create_trainer "stratos" {time 3} {
	"exit always open" {poke 0xe042 0}
	"time" {poke 0xe052 99}
	"bombs" {poke 0xe053 99}
	"hearts" {poke 0xe054 99}
}

create_trainer "tvirus" {time 1} {
	"power" {poke 0xc044 255}
}

create_trainer "sasa" {time 1} {
	"shots" {poke 0xe07f 255}
	"power" {poke 0xe06f 255}
	"lives" {poke 0xe005 5}
}

create_trainer "moon sweeper" {time 1} {
	"lives" {poke 0xe136 255}
	"invincible" {poke 0xe170 255}
}

create_trainer "konamis soccer" {time 1} {
	"score team 1" {poke 0xe0f5 0x99}
	"score team 2" {poke 0xe0f6 0}
}

create_trainer "konamis golf" {time 1} {
	"shots" {poke 0xe106 1}
}

create_trainer "blagger" {time 1} {
	"lives" {poke 0x9233 0x99}
	"air" {poke 0x9a85 255}
}

create_trainer "chuckie egg" {time 1} {
	"lives" {poke 0xb21d 5}
}

create_trainer "addicata ball" {time 1} {
	"lives" {poke 0x0616 10}
	"ammo" {poke 0x0619 64}
	"fuel" {poke 0x0617 64}
	"shooting ability" {poke 0x061a 2;poke 0x061e 1}
	"flying ability" {poke 0x618 3;poke 0x61b 2}
	"floor" {poke 0x0aeb 8;poke 0x0aec 8;poke 0x0aed 8;poke 0x0aee 8;poke 0x0aef 8;poke 0x0af0 8;poke 0x0af1 8;poke 0x0af2 8;poke 0x0af3 8;poke 0x0af4 8;poke 0x0af5 8;poke 0x0af6 8;poke 0x0af7 8;poke 0x0af8 8}
}

create_trainer "dog fighter" {time 1} {
	"fuel" {poke 0xe33e 255;poke 0xe33f 255}
	"shot" {poke 0xe340 255}
	"lives" {poke 0xe304 4}
}

create_trainer "hunch back" {time 0.5} {
	"lives" {poke 0x9114 6}
	"y-pos ball 1 " {poke 0x9c72 100}
	"y-pos ball 2" {poke 0x9c76 100}
	"y-pos wall crawler" {poke 0x9c92 120}
	"guardian 1" {poke 0x90ba 10}
	"guardian 2" {poke 0x90be 10}
	"guardian 3" {poke 0x90c2 10}
	"arrow 1" {poke 0x9c6a 100}
	"arrow 2" {poke 0x9c6e 100}
}

create_trainer "anaza" {time 1} {
	"power" {poke 0xc016 16}
	"speed" {poke 0xc03d 4}
	"fire super shot" {poke 0xc03b 6}
	"monolis" {poke 0xc020 8}
}

create_trainer "chase hq" {time 10} {
	"time" {poke 0xa17e 0x99}
	"turbo" {poke 0xa170 5}
}

create_trainer "wizards lair" {time 1} {
	"power" {poke 0x9e2e 255}
	"ammo" {poke 0x9e2f 255}
	"key" {poke 0x9e2b 99}
	"golden ring" {poke 0x9e2c 99}
	"diamond" {poke 0x9e2d 99}
	"lives" {poke 0x9e31 99}
	"invincible" {poke 0x7c1e 99}
	"gold" {poke 0x9e30 255}
	"walk fast" {poke 0x7c1f 255}
	"endless color" {poke 0x7c1d 143;poke 0x7c09 4;poke 0xbc06 4}
}

set ::__active_trainer ""

#--eof--
