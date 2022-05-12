module valve


#flag -I @VMODROOT/golphook/c

#include "reg.h"

fn C.load_this(voidptr)


pub enum ItemDefinitionIndex {
    weapon_invalid = -1
    weapon_deagle = 1
    weapon_elite
    weapon_fiveseven
    weapon_glock
    weapon_ak47 = 7
    weapon_aug
    weapon_awp
    weapon_famas
    weapon_g3sg1
    weapon_galilar = 13
    weapon_m249
    weapon_m4a1 = 16
    weapon_mac10
    weapon_p90 = 19
    weapon_mp5 = 23
    weapon_ump45
    weapon_xm1014
    weapon_bizon
    weapon_mag7
    weapon_negev
    weapon_sawedoff
    weapon_tec9
    weapon_taser
    weapon_hkp2000
    weapon_mp7
    weapon_mp9
    weapon_nova
    weapon_p250
    weapon_shield
    weapon_scar20
    weapon_sg556
    weapon_ssg08
    weapon_knifegg
    weapon_knife
    weapon_flashbang
    weapon_hegrenade
    weapon_smokegrenade
    weapon_molotov
    weapon_decoy
    weapon_incgrenade
    weapon_c4
    weapon_healthshot = 57
    weapon_knife_t = 59
    weapon_m4a1_silencer
    weapon_usp_silencer
    weapon_cz75a = 63
    weapon_revolver
    weapon_tagrenade = 68
    weapon_fists
    weapon_breachcharge
    weapon_tablet = 72
    weapon_melee = 74
    weapon_axe
    weapon_hammer
    weapon_spanner = 78
    weapon_knife_ghost = 80
    weapon_firebomb
    weapon_diversion
    weapon_frag_grenade
    weapon_snowball
    weapon_bumpmine
    weapon_bayonet = 500
    weapon_knife_flip = 505
    weapon_knife_gut
    weapon_knife_karambit
    weapon_knife_m9_bayonet
    weapon_knife_tactical
    weapon_knife_falchion = 512
    weapon_knife_survival_bowie = 514
    weapon_knife_butterfly
    weapon_knife_push
    weapon_knife_ursus = 519
    weapon_knife_gypsy_jackknife
    weapon_knife_stiletto = 522
    weapon_knife_widowmaker
    glove_studded_bloodhound = 5027
    glove_t_side = 5028
    glove_ct_side = 5029
    glove_sporty = 5030
    glove_slick = 5031
    glove_leather_wrap = 5032
    glove_motorcycle = 5033
    glove_specialist = 5034
    glove_hydra = 5035
}

pub enum Teams {
	no_team = 0
	specs
	terrorists
	counter_terrorists
}

pub enum LifeState {
	alive = 0
	dying
	dead
	respawnable
	discard_body
}

enum MoveType {
	movetype_none = 0
	movetype_isometric
	movetype_walk
	movetype_step
	movetype_fly
	movetype_flygravity
	movetype_vphysics
	movetype_push
	movetype_noclip
	movetype_ladder
	movetype_observer
}

pub enum WeaponType {
	unknown = -1
	knife
	pistol
	submachinegun
	rifle
	shotgun
	sniper_rifle
	machinegun
	c4
	taser
	grenade
	healthshot = 11
}

pub enum HitGroup {
	invalid = -1
    generic
    head
    chest
    stomach
    left_arm
    right_arm
    left_leg
    right_leg
    gear = 10
}
