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

pub enum MoveType {
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

enum ClassIds {
	cai_basenpc = 0
	cak47
	cbaseanimating
	cbaseanimatingoverlay
	cbaseattributableitem
	cbasebutton
	cbasecombatcharacter
	cbasecombatweapon
	cbasecsgrenade
	cbasecsgrenadeprojectile
	cbasedoor
	cbaseentity
	cbaseflex
	cbasegrenade
	cbaseparticleentity
	cbaseplayer
	cbasepropdoor
	cbaseteamobjectiveresource
	cbasetempentity
	cbasetoggle
	cbasetrigger
	cbaseviewmodel
	cbasevphysicstrigger
	cbaseweaponworldmodel
	cbeam
	cbeamspotlight
	cbonefollower
	cbrc4target
	cbreachcharge
	cbreachchargeprojectile
	cbreakableprop
	cbreakablesurface
	cbumpmine
	cbumpmineprojectile
	cc4
	ccascadelight
	cchicken
	ccolorcorrection
	ccolorcorrectionvolume
	ccsgamerulesproxy
	ccsplayer
	ccsplayerresource
	ccsragdoll
	ccsteam
	cdangerzone
	cdangerzonecontroller
	cdeagle
	cdecoygrenade
	cdecoyprojectile
	cdrone
	cdronegun
	cdynamiclight
	cdynamicprop
	ceconentity
	ceconwearable
	cembers
	centitydissolve
	centityflame
	centityfreezing
	centityparticletrail
	cenvambientlight
	cenvdetailcontroller
	cenvdofcontroller
	cenvgascanister
	cenvparticlescript
	cenvprojectedtexture
	cenvquadraticbeam
	cenvscreeneffect
	cenvscreenoverlay
	cenvtonemapcontroller
	cenvwind
	cfeplayerdecal
	cfirecrackerblast
	cfiresmoke
	cfiretrail
	cfish
	cfists
	cflashbang
	cfogcontroller
	cfootstepcontrol
	cfunc_dust
	cfunc_lod
	cfuncareaportalwindow
	cfuncbrush
	cfuncconveyor
	cfuncladder
	cfuncmonitor
	cfuncmovelinear
	cfuncoccluder
	cfuncreflectiveglass
	cfuncrotating
	cfuncsmokevolume
	cfunctracktrain
	cgamerulesproxy
	cgrassburn
	chandletest
	chegrenade
	chostage
	chostagecarriableprop
	cincendiarygrenade
	cinferno
	cinfoladderdismount
	cinfomapregion
	cinfooverlayaccessor
	citem_healthshot
	citemcash
	citemdogtags
	cknife
	cknifegg
	clightglow
	cmaterialmodifycontrol
	cmelee
	cmolotovgrenade
	cmolotovprojectile
	cmoviedisplay
	cparadropchopper
	cparticlefire
	cparticleperformancemonitor
	cparticlesystem
	cphysbox
	cphysboxmultiplayer
	cphysicsprop
	cphysicspropmultiplayer
	cphysmagnet
	cphyspropammobox
	cphysproplootcrate
	cphyspropradarjammer
	cphyspropweaponupgrade
	cplantedc4
	cplasma
	cplayerping
	cplayerresource
	cpointcamera
	cpointcommentarynode
	cpointworldtext
	cposecontroller
	cpostprocesscontroller
	cprecipitation
	cprecipitationblocker
	cpredictedviewmodel
	cprop_hallucination
	cpropcounter
	cpropdoorrotating
	cpropjeep
	cpropvehicledriveable
	cragdollmanager
	cragdollprop
	cragdollpropattached
	cropekeyframe
	cscar17
	csceneentity
	csensorgrenade
	csensorgrenadeprojectile
	cshadowcontrol
	cslideshowdisplay
	csmokegrenade
	csmokegrenadeprojectile
	csmokestack
	csnowball
	csnowballpile
	csnowballprojectile
	cspatialentity
	cspotlightend
	csprite
	cspriteoriented
	cspritetrail
	cstatueprop
	csteamjet
	csun
	csunlightshadowcontrol
	csurvivalspawnchopper
	ctablet
	cteam
	cteamplayroundbasedrulesproxy
	ctearmorricochet
	ctebasebeam
	ctebeamentpoint
	ctebeaments
	ctebeamfollow
	ctebeamlaser
	ctebeampoints
	ctebeamring
	ctebeamringpoint
	ctebeamspline
	ctebloodsprite
	ctebloodstream
	ctebreakmodel
	ctebspdecal
	ctebubbles
	ctebubbletrail
	cteclientprojectile
	ctedecal
	ctedust
	ctedynamiclight
	cteeffectdispatch
	cteenergysplash
	cteexplosion
	ctefirebullets
	ctefizz
	ctefootprintdecal
	ctefoundryhelpers
	ctegaussexplosion
	cteglowsprite
	cteimpact
	ctekillplayerattachments
	ctelargefunnel
	ctemetalsparks
	ctemuzzleflash
	cteparticlesystem
	ctephysicsprop
	cteplantbomb
	cteplayeranimevent
	cteplayerdecal
	cteprojecteddecal
	cteradioicon
	cteshattersurface
	cteshowline
	ctesla
	ctesmoke
	ctesparks
	ctesprite
	ctespritespray
	ctest_proxytoggle_networkable
	ctesttraceline
	cteworlddecal
	ctriggerplayermovement
	ctriggersoundoperator
	cvguiscreen
	cvotecontroller
	cwaterbullet
	cwaterlodcontrol
	cweaponaug
	cweaponawp
	cweaponbaseitem
	cweaponbizon
	cweaponcsbase
	cweaponcsbasegun
	cweaponcycler
	cweaponelite
	cweaponfamas
	cweaponfiveseven
	cweapong3sg1
	cweapongalil
	cweapongalilar
	cweaponglock
	cweaponhkp2000
	cweaponm249
	cweaponm3
	cweaponm4a1
	cweaponmac10
	cweaponmag7
	cweaponmp5navy
	cweaponmp7
	cweaponmp9
	cweaponnegev
	cweaponnova
	cweaponp228
	cweaponp250
	cweaponp90
	cweaponsawedoff
	cweaponscar20
	cweaponscout
	cweaponsg550
	cweaponsg552
	cweaponsg556
	cweaponshield
	cweaponssg08
	cweapontaser
	cweapontec9
	cweapontmp
	cweaponump45
	cweaponusp
	cweaponxm1014
	cweaponzonerepulsor
	cworld
	cworldvguitext
	dusttrail
	movieexplosion
	particlesmokegrenade
	rockettrail
	smoketrail
	sporeexplosion
	sporetrail
}

pub struct CCLientClass {
pub:
	create_fn voidptr
	create_event_fn voidptr
	network_name &char
	recvtable_ptr voidptr
	next_ptr voidptr
	class_id ClassIds
}

pub fn (c &CCLientClass) name() string {

	return unsafe { cstring_to_vstring(c.network_name) }
}

pub enum ObserverModes {
	mode_none = 0	// not in spectator mode
	mode_deathcam	// special mode for death cam animation
	mode_freezecam	// zooms to a target and freeze-frames on them
	mode_fixed		// view from a fixed camera position
	mode_in_eye	// follow a player in first person view
	mode_chase		// follow a player in third person view
	mode_poi		// passtime point of interest - game objective big fight anything interesting; added in the middle of the enum due to tons of hard-coded "<roaming" enum compares
	mode_roaming	// free roaming
	num_observer_modes
}
