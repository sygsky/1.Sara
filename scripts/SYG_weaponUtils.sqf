/**
 * Module to handle weapons
 *
 */

#include "x_setup.sqf"
 
#define arg(x) (_this select (x))
#define argopt(num,val) if ( count _this <= num ) then {val} else { arg(num) }
#define RAR(ARR) (ARR select (floor (random (count ARR ))))
#define RANDOM_ARR_ITEM(ARR) (ARR select (floor (random (count ARR ))))

#define MAG_STD 0
#define MAG_STD_SD 1
#define MAG_SNP 2
#define MAG_SNP_STD_SD 3
#define MAG_TRC 4

if ( isNil "SYG_WEAPON_UTILS_COMPILED" ) then  // generate some static information
{
	SYG_WEAPON_UTILS_COMPILED = true;
	SYG_handleMags = compile preprocessFileLineNumbers "scripts\SYG_handleMagazine.sqf";

// СПЕЦГРУППА
//##############################################################################
//	SYG_SPECOPS_WEST = ["ACE_SoldierWSniper2_A","ACE_USMC8541A1A","ACE_SoldierWMAT_USSF_ST_BDUL","ACE_SoldierWAA","ACE_SoldierWB_USSF_ST_BDUL","ACE_SoldierW_Spotter_A","ACE_SoldierWMedic_A","ACE_SoldierWAT2_A"];

// ДЕСАНТ НА БАЗУ
//##############################################################################
//	SYG_SABOTAGE_WEST = ["ACE_SquadLeaderW_A","ACE_SoldierWDemo_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWDemo_USSF_LRSD","ACE_SoldierWDemo_USSF_ST"];
	

// Ordinal infantry in towns
//	SYG_BASIC_WEST = ["ACE_SoldierWMG_A","ACE_SoldierWAR_A","ACE_SoldierWSniper_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWAT2_A","ACE_SoldierWMedic_A","ACE_SoldierWG","ACE_SoldierW_HMG","ACE_SoldierW_HMGAG","ACE_SoldierWMiner","ACE_SoldierWB_A","ACE_SoldierW_HMGAB"];	
	
	SYG_MINE_LIST = ["ACE_Pipebomb","ACE_TimeBomb","ACE_Mine","ACE_MineE","ACE_Claymore_M","PipeBomb","TimeBomb","Mine","MineE"];
	
	SNIPER_WEAPON_LIST_WEST = ["ACE_M21", "M24", "m107", "ACE_Mk12SPR", "ACE_SCAR_H_Sniper", "ACE_HK417_Leu","ACE_HK417_Leu_SD"];
	SNIPER_WEAPON_LIST_EAST = ["ksvk", "SVD", "aks74pso", "ACE_VSS"];
	SNIPER_WEAPON_LIST = SNIPER_WEAPON_LIST_WEST + SNIPER_WEAPON_LIST_EST;
	
	MG_WEAPON_LIST_WEST = ["M240", "M249", "M60"];
	MG_WEAPON_LIST_EAST = ["PK","ACE_RPK74","ACE_RPK47"];
	MG_WEAPON_LIST = MG_WEAPON_LIST_WEST + MG_WEAPON_LIST_EAST;
	
	SMG_WEAPON_LIST = ["MP5SD", "AKS74U"]; // All base classes for SMG/Short Muzzle Guns
	
	LAUNCHER_WEAPON_LIST = ["Launcher"];

	LONG_MUZZLE_WEAPON_LIST = [ "ksvk", "SVD", "ACE_M21", "M24", "ACE_M14", "m107"] + MG_WEAPON_LIST;
	
	//================================================
	
	SYG_STD_MEDICAL_SET = [ ["ACE_Bandage",2], ["ACE_Morphine"] , ["ACE_Epinephrine"] ];
	SYG_MEDIC_SET = [ ["ACE_Bandage",4], ["ACE_Morphine",2], ["ACE_Epinephrine",2] ];
	
	SYG_PILOT_GRENADE_SET = [["ACE_SmokeGrenade_Red"], ["ACE_SmokeGrenade_Green"], ["ACE_SmokeGrenade_Violet"], 
	                         ["ACE_SmokeGrenade_White"], ["ACE_SmokeGrenade_Yellow"], ["ACE_HandGrenade"]];
	
	SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK = [ 
				 ["S", "ACE_M1911", "ACE_7Rnd_1143x23_B_M1911", 4], 
				 ["S", "ACE_M9", "ACE_15Rnd_9x19_B_M9", 4]
				];
	SYG_PISTOL_WPN_SET_WEST_STD_GLOCK = [ 
				 ["S", "ACE_Glock17", "ACE_17Rnd_9x19_G17", 4],
				 ["S", "ACE_Glock18", "ACE_33Rnd_9x19_G18", 4]
				];
				
	SYG_PISTOL_WPN_SET_WEST_STD = SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK + SYG_PISTOL_WPN_SET_WEST_STD_GLOCK;

	SYG_PISTOL_WPN_SET_WEST_STD_SD = [ 
				 ["S", "ACE_M1911SD", "ACE_7Rnd_1143x23_B_M1911", 4], 
				 ["S", "ACE_M9SD", "ACE_15Rnd_9x19_SD_M9", 4]
				];
				
	SYG_PISTOL_WPN_SET_WEST = SYG_PISTOL_WPN_SET_WEST_STD + SYG_PISTOL_WPN_SET_WEST_STD_SD;

	SYG_PILOT_HANDGUN_EAST = [["S", "ACE_Scorpion", "ACE_20Rnd_765x17_vz61", 4]];
	
	SYG_SMG_WPN_SET_WEST = [ 
				["P", "ACE_MP5A5", "ACE_30Rnd_9x19_B_MP5", 6], 
				["P", "ACE_MP5SD", "ACE_30Rnd_9x19_SD_MP5", 6],
				["P", "ACE_MP5A4", "ACE_30Rnd_9x19_B_MP5", 6], 
				["P", "ACE_UMP45", "ACE_25Rnd_1143x23_B_UMP45", 6],
				["P", "ACE_UMP45_SD", "ACE_25Rnd_1143x23_B_UMP45", 6 ]
				];

	SYG_SMG_WPN_SET_EAST = [ 
				["P", "ACE_AKS74U", "ACE_30Rnd_545x39_B_AK", 6], 
				["P", "ACE_AKS74U_Cobra", "ACE_30Rnd_545x39_B_AK", 6], 
				["P", "ACE_AKS74USD","ACE_30Rnd_545x39_SD_AK",6],
				["P", "ACE_AKS74USD_Cobra", "ACE_30Rnd_545x39_SD_AK", 6], 
				["P", "ACE_Bizon", "ACE_64Rnd_9x18_B_Bizon", 6], 
				["P", "ACE_Bizon_SD", "ACE_64Rnd_9x18_B_Bizon_S", 6], 
				["P", "ACE_Bizon_Cobra", "ACE_64Rnd_9x18_B_Bizon", 6],
				["P", "ACE_Bizon_SD_Cobra", "ACE_64Rnd_9x18_B_Bizon_S", 6]
			];
			
	//================================================= SPECIFIC ACE WEAPONS AND MAGAZINES ================================

	// ---------------------------------------------------------------------------------
	// Some exotic MG set
	SYG_MG_SET = [ 
				["P", "ACE_M240G_M145", "ACE_100Rnd_762x51_B_M240", 3], 
				["P", "ACE_M249Para", "ACE_200Rnd_556x45_B_M249", 3], 
				["P", "ACE_M249Para_M145", "ACE_200Rnd_556x45_B_M249", 3],
				["P", "ACE_MG36", "ACE_100Rnd_556x45_B_G36", 4 ]
			];
	
	// ---------------------------------------------------------------------------------
 	// G36 weapon arrays
	// std weapon
	SYG_G36_WPN_SET_STD = ["ACE_G36","ACE_G36K","ACE_G36KA1","ACE_G36C","ACE_G36C_CompAim","ACE_G36C_CompEo"];
	SYG_G36_WPN_SET_STD_SD = [];
	SYG_G36_WPN_SET_SNIPER = ["ACE_G36"];
	SYG_G36_WPN_SET_SNIPER_SD = [];
	
	SYG_G36_MAGS = ["ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_B_G36","ACE_30Rnd_556x45_BT_G36"]; // "ACE_30Rnd_556x45_BT_G36", "ACE_100Rnd_556x45_BT_G36", ""ACE_G36C""

	// ---------------------------------------------------------------------------------			
 	// HK416 weapon arrays
	// std weapon
	SYG_HK416_WPN_SET_STD = ["ACE_HK416","ACE_HK416_aim","ACE_HK416_eotech"];
	SYG_HK416_WPN_SET_STD_OPTICS = ["ACE_HK416_ACOG"];
	SYG_HK416_WPN_SET_STD_SD = ["ACE_HK416_SD","ACE_HK416_aim_SD","ACE_HK416_eotech_SD"];
	SYG_HK416_WPN_SET_STD_SD_OPTICS = ["ACE_HK416_ACOG_SD"];
	SYG_HK416_WPN_SET_SNIPER = ["ACE_Mk12SPR","ACE_HK416_Leu"];
	SYG_HK416_WPN_SET_SNIPER_SD = ["ACE_Mk12SPR_SD","ACE_HK416_Leu_SD"];
	
	SYG_HK416_MAGS = ["ACE_30Rnd_556x45_B_Stanag","ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_SD_Stanag","ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_BT_Stanag"];

	// ---------------------------------------------------------------------------------			
 	// HK417 weapon arrays
	// std weapon
			
	SYG_HK417_WPN_SET_STD = ["ACE_HK417C","ACE_HK417C_EOTECH","ACE_HK417L","ACE_HK417L_EOTECH","ACE_HK417L_M68"];
	SYG_HK417_WPN_SET_STD_OPTICS = ["ACE_HK417C_ACOG","ACE_HK417L_ACOG"];
	SYG_HK417_WPN_SET_STD_SD = ["ACE_HK417C_SD", "ACE_HK417C_EOTECH_SD","ACE_HK417L_SD","ACE_HK417L_EOTECH_SD","ACE_HK417L_M68_SD"];
	SYG_HK417_WPN_SET_STD_SD_OPTICS = ["ACE_HK417C_ACOG_SD","ACE_HK417L_ACOG_SD"];
	SYG_HK417_WPN_SET_SNIPER = ["ACE_HK417L_Leu"];
	SYG_HK417_WPN_SET_SNIPER_SD = ["ACE_HK417L_Leu_SD"];
	
	SYG_HK417_MAGS = ["ACE_20Rnd_762x51_B_HK417", "ACE_20Rnd_762x51_SB_HK417", "ACE_20Rnd_762x51_B_HK417", "ACE_20Rnd_762x51_SB_HK417", "ACE_20Rnd_762x51_B_HK417"];


	// ---------------------------------------------------------------------------------			
 	// SCAR-L weapon arrays
	// std weapon
	SYG_SCARL_WPN_SET_STD = ["ACE_SCAR_L","ACE_SCAR_L_CQB_EOtech","ACE_SCAR_L_CQB_Aim","ACE_SCAR_L_CQB_Docter"] ;
	SYG_SCARL_WPN_SET_STD_OPTICS = ["ACE_SCAR_L_ACOG","ACE_SCAR_L_CQB_mk4","ACE_SCAR_L_Specter","ACE_SCAR_L_shortdot"] ;
	// silenced weapon
	SYG_SCARL_WPN_SET_STD_SD = ["ACE_SCAR_L","ACE_SCAR_L_CQB_EOtech_SD","ACE_SCAR_L_CQB_Aim_SD","ACE_SCAR_L_CQB_Docter_SD"] ;
	SYG_SCARL_WPN_SET_STD_SD_OPTICS = ["ACE_SCAR_L_ACOG_SD","ACE_SCAR_L_CQB_mk4_SD","ACE_SCAR_L_Specter_SD","ACE_SCAR_L_shortdot_SD"] ;
	// sniper weapon
	SYG_SCARL_WPN_SET_SNIPER =  ["ACE_SCAR_L_Marksman", "ACE_SCAR_L_Marksman_ACOG","ACE_SCAR_L_Marksman_Leu"];
	// sniper weapon silenced
	SYG_SCARL_WPN_SET_SNIPER_SD =  ["ACE_SCAR_L_Marksman_SD","ACE_SCAR_L_Marksman_Leu_SD" ];

	SYG_SCARL_MAGS = ["ACE_30Rnd_556x45_B_Stanag", "ACE_20Rnd_556x45_SB_Stanag", "ACE_30Rnd_556x45_SD_Stanag", "ACE_20Rnd_556x45_SB_Stanag","ACE_30Rnd_556x45_BT_Stanag"];

	// ---------------------------------------------------------------------------------			
 	// SCAR-H weapon arrays
	// std weapon
	SYG_SCARH_WPN_SET_STD = ["ACE_SCAR_H","ACE_SCAR_H_CQB","ACE_SCAR_H_CQB_EOtech","ACE_SCAR_H_CQB_Aim","ACE_SCAR_H_CQB_Docter"];
	SYG_SCARH_WPN_SET_STD_OPTICS = ["ACE_SCAR_H_CQB_mk4","ACE_SCAR_H_SPECTER","ACE_SCAR_H_ACOG"];
	// silent weapon
	SYG_SCARH_WPN_SET_STD_SD =  ["ACE_SCAR_H_CQB_EOtech_SD","ACE_SCAR_H_CQB_Aim_SD", "ACE_SCAR_H_CQB_Docter_SD"];
	SYG_SCARH_WPN_SET_STD_SD_OPTICS = ["ACE_SCAR_H_CQB_mk4_SD","ACE_SCAR_H_SPECTER_SD","ACE_SCAR_H_ACOG_SD"];
	// sniper weapon
	SYG_SCARH_WPN_SET_SNIPER =  ["ACE_SCAR_H_Sniper"];
	// sniper weapon silenced
	SYG_SCARH_WPN_SET_SNIPER_SD =  ["ACE_SCAR_H_Sniper_SD"];
	
	// mags: ordinal, sniper, silenced, sniper silenced, tracers
	SYG_SCARH_MAGS = ["ACE_20Rnd_762x51_B_SCAR", "ACE_20Rnd_762x51_SB_SCAR", "ACE_20Rnd_762x51_B_SCAR", "ACE_20Rnd_762x51_B_SCAR","ACE_20Rnd_762x51_B_SCAR"];
	
	// ---------------------------------------------------------------------------------			
 	// M14 weapon arrays
	// std weapon
	SYG_M14_WPN_SET_STD = ["ACE_M14","ACE_M14_reflex","ACE_M14_nam","ACE_M14_sop","ACE_M14_sop_aim","ACE_M14_sop_cmore", "ACE_M14_sop_eotech"];
	SYG_M14_WPN_SET_STD_OPTICS = ["ACE_M14_sop_acog_cqb","ACE_M14_wdl_acog_cqb","ACE_M14_sop_elcan_cqb"];
	// silent weapon
	SYG_M14_WPN_SET_STD_SD =  ["ACE_M14_sopS","ACE_M14_sop_eotechS","ACE_M14_sop_aimS","ACE_M14_sop_cmoreS"];
	SYG_M14_WPN_SET_STD_SD_OPTICS =  ["ACE_M14_sop_acogS_cqb","ACE_M14_sop_elcanS_cqb"];
	// sniper weapon
	SYG_M14_WPN_SET_SNIPER =  ["ACE_M14_sop_dmr"];
	// sniper weapon silenced
	SYG_M14_WPN_SET_SNIPER_SD =  ["ACE_M14_sop_dmrS"];
	// mags: ordinal, sniper, silenced, sniper silenced, tracers
	SYG_M14_MAGS = ["ACE_20Rnd_762x51_B_M14","ACE_20Rnd_762x51_SB_M14", "ACE_20Rnd_762x51_B_M14","ACE_20Rnd_762x51_SB_M14","ACE_20Rnd_762x51_B_M14"];
	
	// ---------------------------------------------------------------------------------			
 	// M21 SNIPER weapon arrays
	// sniper weapon
	SYG_M21_WPN_SET =  ["ACE_M21","ACE_M21_dmr","ACE_M21_police","ACE_M21_wdl"];
	// sniper weapon silenced
	SYG_M21_WPN_SET_SD =  ["ACE_M21_dmrS"];
	// mags: sniper
	SYG_M21_MAGS = ["ACE_20Rnd_762x51_SB_M14"];
	
	// ---------------------------------------------------------------------------------			
 	// M24 SNIPER weapon arrays
	// sniper weapon
	SYG_M24_WPN_SET =  [ "ACE_M24","ACE_M40A3"];
	// mags: sniper
	SYG_M24_MAGS = ["ACE_5Rnd_762x51_SB"];
	

	// ---------------------------------------------------------------------------------			
 	// M110 SNIPER weapon arrays
	// sniper weapon
	SYG_M110_WPN_SET =  ["ACE_M110"];
	// sniper weapon silenced
	SYG_M110_WPN_SET_SD =  ["ACE_M110_SD"];
	// mags: sniper
	SYG_M110_MAGS = ["ACE_20Rnd_762x51_SB_M110"];
	
	// ---------------------------------------------------------------------------------			
 	// HEAVYSNIPER weapon arrays (12.7 mm caliber)
	// heavy sniper weapon

	SYG_HEAVYSNIPER_WPN_SET =  
	[
		["ACE_M82A1",["ACE_10Rnd_127x99_SB_Barrett","ACE_10Rnd_127x99_API_Barrett","ACE_10Rnd_127x99_BT_Barrett"]],
		["ACE_M109",["ACE_5Rnd_25x59_HEDP_Barrett"]],
		["ACE_AS50",["ACE_5Rnd_127x99_SB_AS50","ACE_5Rnd_127x99_API_AS50","ACE_5Rnd_127x99_BT_AS50"]]
	];
	
	// ---------------------------------------------------------------------------------			
 	// HEAVYSNIPER weapon arrays (12.7 mm caliber)
	// heavy sniper weapon
	SYG_M240_MG_WPN_SET =  
	[
		["ACE_M82A1",["ACE_10Rnd_127x99_SB_Barrett","ACE_10Rnd_127x99_API_Barrett","ACE_10Rnd_127x99_BT_Barrett"]],
		["ACE_M109",["ACE_5Rnd_25x59_HEDP_Barrett"]],
		["ACE_AS50",["ACE_5Rnd_127x99_SB_AS50","ACE_5Rnd_127x99_API_AS50","ACE_5Rnd_127x99_BT_AS50"]]
	];

	SYG_M249_MG_WPN_SET =  
	[
		["ACE_M82A1",["ACE_10Rnd_127x99_SB_Barrett","ACE_10Rnd_127x99_API_Barrett","ACE_10Rnd_127x99_BT_Barrett"]],
		["ACE_M109",["ACE_5Rnd_25x59_HEDP_Barrett"]],
		["ACE_AS50",["ACE_5Rnd_127x99_SB_AS50","ACE_5Rnd_127x99_API_AS50","ACE_5Rnd_127x99_BT_AS50"]]
	];

	
	#define SYG_MAG_STD 0
	#define SYG_MAG_SNIPER 1
	#define SYG_MAG_STD_SD 2
	#define SYG_MAG_SNIPER_SD 3
	#define SYG_MAG_STD_TRACER 4
	// ---------------------------------------------------------------------------------			
				
	SYG_STD_PILOT_EQUIPMENT = SYG_STD_MEDICAL_SET + SYG_PILOT_GRENADE_SET + [["E", "NVGoggles"]];
	
	#define WeaponNoSlot            0   // Dummy weapons
	#define WeaponSlotPrimary       1   // Primary weapon
	#define WeaponSlotHandGun       2   // Handgun slot
	#define WeaponSlotSecondary     4   // Secondary weapon (launcher)
	#define WeaponSlotHandGunMag   16   // Handgun magazines (8x)(or grenades for M203/GP-25)
	#define WeaponSlotMag         256   // Magazine slots (12x / 8x for medics)
	#define WeaponSlotGoggle     4096   // Goggle slot (2x)
	#define WeaponHardMounted   65536   // Hard mouted weapon (not for man)

	#define arg(x) (_this select (x))
	#define RANDOM_ARR_ITEM(ARR) (ARR select (floor (random (count ARR ))))

	#define DEFINE_WEAPON_FUNC_SET(NAME) SYG_get##NAME##StdWpn =  { ["P", SYG_##NAME##_WPN_SET_STD select (floor (random (count SYG_##NAME##_WPN_SET_STD ))), SYG_##NAME##_MAGS select SYG_MAG_STD, 6] }; \
	SYG_get##NAME##StdWpnOptics =  { ["P", SYG_##NAME##_WPN_SET_STD_OPTICS select (floor (random (count SYG_##NAME##_WPN_SET_STD_OPTICS ))), SYG_##NAME##_MAGS select SYG_MAG_STD, 6] }; \
	SYG_get##NAME##StdWpnSD =  { ["P", SYG_##NAME##_WPN_SET_STD_SD select (floor (random (count SYG_##NAME##_WPN_SET_STD_SD ))), SYG_##NAME##_MAGS select SYG_MAG_STD_SD, 6] }; \
	SYG_get##NAME##StdWpnSDOptics =  { ["P", SYG_##NAME##_WPN_SET_STD_SD_OPTICS select (floor (random (count SYG_##NAME##_WPN_SET_STD_SD_OPTICS ))), SYG_##NAME##_MAGS select SYG_MAG_STD_SD, 6] }; \
	SYG_get##NAME##Sniper =  { ["P", SYG_##NAME##_WPN_SET_SNIPER select (floor (random (count SYG_##NAME##_WPN_SET_SNIPER ))), SYG_##NAME##_MAGS select SYG_MAG_SNIPER, 6] }; \
	SYG_get##NAME##SniperSD =  { ["P", SYG_##NAME##_WPN_SET_SNIPER_SD select (floor (random (count SYG_##NAME##_WPN_SET_SNIPER_SD ))), SYG_##NAME##_MAGS select SYG_MAG_SNIPER_SD, 6] } \

	#define DEFINE_FILL_AMMO_BOX_FUNC(NAME) SYG_fillAmmoBox##NAME = { \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_OPTICS; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD_OPTICS; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER_SD;} \

	#define DEFINE_FILL_AMMO_BOX_FUNC_STD(NAME) SYG_fillAmmoBox##NAME##_Std = { \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_OPTICS; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_STD_SD_OPTICS;} \


	#define DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(NAME) SYG_fillAmmoBox##NAME##_Sniper = { \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER; \
	{ _this addWeaponCargo [_x, 10] } forEach SYG_##NAME##_WPN_SET_SNIPER_SD;} \
	
	SYG_WHOLE_MAG_LIST = [];

	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_HK416_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_SCARL_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_HK417_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_SCARH_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M14_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M21_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M24_MAGS;
	{ if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; } } forEach SYG_M110_MAGS;
	
	{
		{
			if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x]; };
		}
		forEach _x select 1;
	}forEach SYG_HEAVYSNIPER_WPN_SET;
	
	{
		{
			if (!(_x in SYG_WHOLE_MAG_LIST) ) then { SYG_WHOLE_MAG_LIST = SYG_WHOLE_MAG_LIST + [_x] };
		}
		forEach _x select 1;
	}forEach SYG_M240_MG_WPN_SET;
};

DEFINE_WEAPON_FUNC_SET(SCARL);
DEFINE_WEAPON_FUNC_SET(SCARH);
DEFINE_WEAPON_FUNC_SET(HK416);
DEFINE_WEAPON_FUNC_SET(HK417);

DEFINE_FILL_AMMO_BOX_FUNC_STD(SCARL);
DEFINE_FILL_AMMO_BOX_FUNC_STD(SCARH);
DEFINE_FILL_AMMO_BOX_FUNC_STD(HK416);
DEFINE_FILL_AMMO_BOX_FUNC_STD(HK417);

DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(SCARL);
DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(SCARH);
DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(HK416);
DEFINE_FILL_AMMO_BOX_FUNC_SNIPER(HK417);

SYG_getWholeMagsList = { SYG_WHOLE_MAG_LIST };

SYG_clearAmmoBox = {clearMagazineCargo _this; clearWeaponCargo _this;};

SYG_fillAmmoBoxWithMags = { { _this addMagazineCargo [_x, 100];	} forEach SYG_WHOLE_MAG_LIST; };

//
// Returns 1 for rifle, 2 if pistol, 4 for launcher, 4096 for special items (binocular etc), 65536 - for vehicle guns
// call: _type = _wpn call SYG_readWeaponType;
//
SYG_readWeaponType = { getNumber ( configFile >> "CfgWeapons" >> _this >> "type" );};
SYG_isRifle = { (_this call SYG_readWeaponType) == 1};
SYG_isPistol = { (_this call SYG_readWeaponType) == 2};
SYG_isLauncher = { (_this call SYG_readWeaponType) == 4};

/**
 * Reads only weapons type (not equipment) list from unitPos
 * call: _list = _unit call SYG_readUnitWeapons;
 * returns: array of weapons with values: 1,2,4 
 * 4096, 65536 (see SYG_readWeaponType comments) not used here and is skipped
 */
SYG_readWeapons = {
	private ["_arr", "_type"];
	_arr = [];
	{
		_type = _x call SYG_readWeaponType;
		if ( _type <= 4 ) then {_arr = _arr + _type;};
	} forEach weapons _unit;
	_arr;
};
/**
 * call: _hasMine = _unit call SYG_hasAnyMine;
 * Returns: true if ACE_PipeBomb, PipeBomb, TimeBomb, ACE_TimeBomb, ACE_Claymore arу found in unit inventory
 *
 */
SYG_hasAnyMine = {
	[SYG_MINE_LIST, magazines _unit] call Syg_isListInList;
};

/**
 *
 * Returns: 0 rifleman, 1 rifleman with optics, 2 AT man, 3 AA man,
 *          4 M240 gunner, 5 M249 gunner, 6 M21 sniper, 7 M24/M40/M107 sniper
 *          8 pilot, 9 crew man, 10 SD rifleman, 11 SD rifleman with optics,
 *          12 specnaz, 13 saboteur (with PipeBomb), 14 miner (engineer)
 */
SYG_getUnitType = {
};


/**
 * Rearms unit if he is known to function
 * Returns: true if success, else false. F.e. if unit not known to function
 * call: _res = [_unit<,_rearm_probability<,_advanced_probability>] call SYG_rearmSabotage;
 * params:
 *   _unit: unit to rearm with new weapon
 *   _rearm_probability: probabilty to reard unit. Optional. Default 0.5. Range 0.0 <-> 1.0
 *   _advanced_probability: probability to ream unit with advanced weapon. Must be < _ordinal_probability. Optional. 
 *    Default 0.1. Range 0.0 <-> 1.0
 */
SYG_rearmSabotage = {
// 	["ACE_SquadLeaderW_A","ACE_SoldierWDemo_A","ACE_SoldierWMAT_A","ACE_SoldierWAA","ACE_SoldierWDemo_USSF_LRSD","ACE_SoldierWDemo_USSF_ST"];

private ["_unit","_unit_type","_prob","_adv_rearm","_rnd","_equip", "_ret","_wpn"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_unit_type = typeOf _unit;
		_prob = argopt(1, 0.5);
		_adv_rearm = argopt(2, 0.1); // do advanced rearming  (true) or not (false)
	}
	else	// _this call
	{
		_unit = _this;
		_unit_type = typeOf _unit;
		_prob = 0.5;
		_adv_rearm = 0.1;
	};
	_ret = false;
	_rnd = random 1.0;
	if ( _rnd < _prob ) then  // do rearming
	{
		_adv_rearm = _rnd < _adv_rearm; // do advanced rearming  (true) or not (false)
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK)] + SYG_STD_MEDICAL_SET;
		_ret = true;
		switch (_unit_type) do
		{
			case "ACE_SquadLeaderW_A":
			{
				_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT", 2]]; // small launcher
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 7]]+ [["ACE_SmokeGrenade_White"]];
			};
			case "ACE_SoldierWMAT_A":
			{
				_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT", 2]]; // small launcher
				_wpn = RAR(SYG_HK416_WPN_SET_STD);
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 7]] + [["ACE_SmokeGrenade_White"]];
			};
			case "ACE_SoldierWDemo_A":
			{
				_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT"]]; // small launcher
				_wpn = RAR(SYG_HK416_WPN_SET_STD);
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 7]] + [["ACE_PipeBomb"],["ACE_SmokeGrenade_White"]]; // special mine
			};
			case "ACE_SoldierWAA":
			{
				_equip = _equip + [["P", "ACE_FIM92A", "ACE_Stinger"]]; // AA missile launcher
				_wpn = RAR(SYG_HK416_WPN_SET_STD);
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 6]];
			};
			case "ACE_SoldierWDemo_USSF_LRSD":
			{
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD_SD);
				}
				else
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD_SD);
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 7]] +	[["ACE_Claymore_M"], ["ACE_PipeBomb"], ["ACE_SmokeGrenade_White"]]; // special mine
			};
			case "ACE_SoldierWDemo_USSF_ST":
			{
				_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT"]]; // small launcher
				_wpn = RAR(SYG_HK416_WPN_SET_STD);
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 7]] + [["ACE_PipeBomb"],["ACE_SmokeGrenade_White"]]; // special equipment
			};
			default { /* player globalChat format["unit %1 not detected", _unit_type]; */ _ret = false; };
		};
		//player globalChat format["unit %1, prob %2, adv prob %3, rnd %4, equip %5", _unit_type, _prob, _adv_rearm, _rnd, _equip];

		if ( _ret ) then 
		{
			[_unit,_equip] call SYG_armUnit;
			if (!(_unit hasWeapon "NVGoggles")) then {	_unit addWeapon "NVGoggles"; };
			if (!(_unit hasWeapon "Binocular")) then {	_unit addWeapon "Binocular"; };

		};
	}
	else
	{
		// replace mines to ensure pipebombs ammunition
		[_unit, "ACE_Pipebomb", ["ACE_TimeBomb","ACE_Mine","ACE_Claymore_M"]/*, "ALL"*/] call SYG_handleMags; // replace only 1st found designated type magazine
		//	player globalChat format["unit %1, prob %2, adv prob %3, rnd %4, NOT rearmed", _unit_type, _prob, _adv_rearm, _rnd]
	};
	_ret
};

//
// Rearms sabotage group with std probablity
//
// call: _res = [_unit1,... , _unitN] call SYG_rearmSabotageGroup;
//
SYG_rearmSabotageGroup = {
	// forEach _this
	{
		_x call SYG_rearmSabotage;
	} forEach _this;
};


/**
 * Rearms unit if he is known to function
 * Returns: true if success, else false. F.e. if unit not known to function
 * call: _res = [_unit<,_rearm_probability<,_advanced_probability>] call SYG_rearmSpecops;
 * params:
 *   _unit: unit to rearm with new weapon
 *   _rearm_probability: probabilty to reard unit. Optional. Default 0.5. Range 0.0 <-> 1.0
 *   _advanced_probability: probability to ream unit with advanced weapon. Must be < _ordinal_probability. Optional. 
 *    Default 0.1. Range 0.0 <-> 1.0
 */
SYG_rearmSpecops = {
// 			["ACE_SoldierWSniper2_A","ACE_USMC8541A1A","ACE_SoldierWMAT_USSF_ST_BDUL","ACE_SoldierWAA","ACE_SoldierWB_USSF_ST_BDUL","ACE_SoldierW_Spotter_A","ACE_SoldierWMedic_A","ACE_SoldierWAT2_A"];
private ["_unit","_unit_type","_prob","_adv_rearm","_rnd","_equip", "_ret","_wpn"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_unit_type = typeOf _unit;
		_prob = argopt(1,0.5);
		_adv_rearm = argopt(2,0.1); // do advanced rearming 
	}
	else	// _this call
	{
		_unit = _this;
		_unit_type = typeOf _this;
		_prob = 0.5;
		_adv_rearm = 0.1;
	};
	_ret = false;
	_rnd = random 1.0;
	if ( _rnd < _prob) then  // do ordinal rearming
	{
		_adv_rearm = _rnd < _adv_rearm; // do advanced rearming  (true) or not (false)
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK)] + SYG_STD_MEDICAL_SET;
		_ret = true;
		switch (_unit_type) do
		{
			case "ACE_SoldierWSniper2_A": // M21
			{
				_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_SD)] + SYG_STD_MEDICAL_SET;
				if ( _adv_rearm ) then 
				{
					_wpn = SYG_M21_WPN_SET_SD select 0;
				}
				else
				{
					_wpn = RAR(SYG_M21_WPN_SET);
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 9]]; 
				_equip = _equip + [["ACE_SmokeGrenade_White"],["ACE_HandGrenadeTimed",2]];
			};
			
			case "ACE_USMC8541A1A": // M40A3
			{
				_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_SD)] + SYG_STD_MEDICAL_SET;
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_M110_WPN_SET + SYG_M110_WPN_SET_SD);
				}
				else
				{
					_wpn = RAR(SYG_M24_WPN_SET); 
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 9]]; 
				_equip = _equip + [["ACE_SmokeGrenade_White"],["ACE_HandGrenadeTimed",2]];
			};
			
			case "ACE_SoldierW_Spotter_A":
			{
				_equip =  _equip + [["P","ACE_ANPRC77_Alice"], ["P","LaserDesignator"]] ;
				if ( _adv_rearm ) then 
				{
					switch ( floor(random 3)) do // 1..3 ==0,4..6 == 1,7..9 == 2
					{
						case 0:
						{
							_wpn = RAR(SYG_HK416_WPN_SET_STD_SD_OPTICS);
						};
						case 1:
						{
							_wpn = RAR(SYG_HK417_WPN_SET_STD_SD_OPTICS);
						};
						case 2:
						{
							_wpn = RAR(SYG_SCARL_WPN_SET_STD_SD_OPTICS);
						};
					};
				}
				else { _wpn = RAR(SYG_HK416_WPN_SET_STD_OPTICS); };
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 9]] + [["ACE_SmokeGrenade_White",2],["LaserBatteries"]];
			};
			
			case "ACE_SoldierWB_USSF_ST_BDUL":
			{
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_SD_OPTICS);
				}
				else
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				};
				_equip = _equip + [["P", _wpn, _wpn call SYG_defaultMagazine, 9]];
				_equip = _equip + [["ACE_SmokeGrenade_White",1],["ACE_HandGrenadeTimed",2]];
			};
			
			case "ACE_SoldierWAA":
			{
				_equip = _equip + [["P", "ACE_FIM92A", "ACE_Stinger"]]; // AA missile launcher
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 6]]; 
			};
			
			case "ACE_SoldierWAT2_A":
			{
				_equip = _equip + [["P", "ACE_Dragon", "ACE_Dragon"]]; // AT missile launcher
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD);
				}
				else
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 6]] + [["ACE_SmokeGrenade_White",2]];
			};
			
			case "ACE_SoldierWMAT_USSF_ST_BDUL":
			{
				_equip = _equip + [["P", "ACE_M72", "ACE_LAW_HEAT", 2]]; // small launcher
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_SD_OPTICS);
				}
				else
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 8]];
			};
			
			case "ACE_SoldierWMedic_A":
			{
				_equip = SYG_MEDIC_SET + [["ACE_SmokeGrenade_Red",2]];
				if ( _adv_rearm ) then 
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD_SD);
				}
				else
				{
					_wpn = RAR(SYG_HK416_WPN_SET_STD);
				};
				_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 8]]; 
				//player globalChat format["Medic equipped: %1", _equip];
			};
			
			default { /* player globalChat format["unit %1 not detected", _unit_type]; */ _ret = false; };
		};
		//player globalChat format["unit %1, prob %2, adv prob %3, rnd %4, equip %5", _unit_type, _prob, _adv_rearm, _rnd, _equip];

		if ( _ret ) then 
		{
			[_unit,_equip] call SYG_armUnit;
			if (!(_unit hasWeapon "NVGoggles")) then {	_unit addWeapon "NVGoggles"; };
			if (!(_unit hasWeapon "Binocular")) then {	_unit addWeapon "Binocular"; };
		};
	}
	else
	{
	//	player globalChat format["unit %1, prob %2, adv prob %3, rnd %4, NOT rearmed", _unit_type, _prob, _adv_rearm, _rnd]
	};
	_ret
};

//
// Rearms specops group with std probablity
//
// call: _res = [_unit1,... , _unitN] call SYG_rearmSpecopsGroup;
//
SYG_rearmSpecopsGroup = {
	// forEach _this
	{
		_x call SYG_rearmSpecops;
	} forEach _this;
};

SYG_rearmSpotter = {
private ["_unit","_unit_type","_prob","_adv_rearm","_rnd","_equip", "_wpn"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_unit_type = typeOf _unit;
		_prob = argopt(1,0.666);
		_adv_rearm = argopt(2,0.333); // do advanced rearming 
	}
	else	// _this call
	{
		_unit = _this;
		_unit_type = typeOf _this;
		_prob = 0.666;
		_adv_rearm = 0.333;
	};
	_rnd = random 1.0;
	if ( _rnd < _prob) then  // do ordinal rearming
	{
		_adv_rearm = _rnd < _adv_rearm; // do advanced rearming  (true) or not (false)
		_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD)] + SYG_STD_MEDICAL_SET;
		_equip =  _equip + [["P","ACE_ANPRC77_Alice"], ["P","LaserDesignator"]] ;
		if ( _adv_rearm ) then 
		{
			switch ( floor(random 3)) do
			{
				case 0:
				{
					_wpn = RAR(SYG_HK417_WPN_SET_STD_OPTICS);
				};
				case 1:
				{
					_wpn = RAR(SYG_SCARL_WPN_SET_STD_OPTICS);
				};
				case 2:
				{
					_wpn = RAR(SYG_SCARH_WPN_SET_STD_OPTICS);
				};
			};
		}
		else { _wpn = RAR(SYG_HK416_WPN_SET_STD_OPTICS); };
		_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 9]] + [["ACE_SmokeGrenade_White",2],["LaserBatteries"]];
		[_unit,_equip] call SYG_armUnit;
		if (!(_unit hasWeapon "NVGoggles")) then {	_unit addWeapon "NVGoggles"; };
		if (!(_unit hasWeapon "Binocular")) then {	_unit addWeapon "Binocular"; };
	};
};

/**
 * Always rearm governor!!!
 * call: nul = _gov call SYG_rearmGovernor;
 */
SYG_rearmGovernor = {
private ["_equip", "_wpn"];
	_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD)] + SYG_STD_MEDICAL_SET;
	switch ( floor(random 4)) do
	{
		case 0:
		{
			_wpn = RAR(SYG_HK416_WPN_SET_STD_SD_OPTICS);
		};
		case 1:
		{
			_wpn = RAR(SYG_HK417_WPN_SET_STD_SD_OPTICS);
		};
		case 2:
		{
			_wpn = RAR(SYG_SCARL_WPN_SET_STD_SD_OPTICS);
		};
		case 3:
		{
			_wpn = RAR(SYG_SCARH_WPN_SET_STD_SD_OPTICS);
		};
	};
	_equip = _equip + [["P", _wpn,_wpn call SYG_defaultMagazine, 9]] + [["ACE_SmokeGrenade_Violet",3]];
	[_this,_equip] call SYG_armUnit;
	if (!(_this hasWeapon "NVGoggles")) then {	_this addWeapon "NVGoggles"; };
	if (!(_this hasWeapon "Binocular")) then {	_this addWeapon "Binocular"; };
};


/**
 * Rearms basic unit so that only mashingunners are concerned
 * Returns: true if success, else false. F.e. if unit not known to function
 * call: _res = [_unit<,_rearm_probability<,_advanced_probability>] call SYG_rearmSabotage;
 * or:   _res = _unit call SYG_rearmSabotage;
 * params:
 *   _unit: unit to rearm with new weapon
 *   _rearm_probability: probabilty to reard unit. Optional. Default 0.5. Range 0.0 <-> 1.0
 *   _advanced_probability: probability to ream unit with advanced weapon. Must be < _ordinal_probability. Optional. 
 *    Default 0.1. Range 0.0 <-> 1.0
 */
SYG_rearmBasic = {
	private ["_unit","_prob","_adv_rearm","_ret","_rnd","_wpn","_equip","_magnum"];
	if ( typeName _this == "ARRAY" ) then // [_unit<, prob1<, prob2>>] call
	{
		_unit = arg(0);
		_prob = argopt(1, 0.5);
		_adv_rearm = argopt(2, 0.1); // do advanced rearming 
	}
	else	// _this call
	{
		_unit = _this;
		_prob = 0.5;
		_adv_rearm = 0.1;
	};
	_ret = false;
	_rnd = random 1.0;
	//_probArr = _probArr + [format["%1%2:%3;",typeOf _unit, (typeOf _unit) isKindOf "SoldierWMG",  round(_rnd * 100) / 100]];
	if ( _rnd < _prob ) then
	{
		_adv_rearm = _rnd < _adv_rearm;
		_magnum = 3;
		if ( (typeOf _unit) isKindOf "SoldierWMG" ) then // M240
		{ 	// rearm with some special kind of M240
			if ( _adv_rearm ) then  {_wpn = "ACE_M240G_M145"} else {_wpn = "ACE_M60"};
			//_probArr = _probArr + [format["%1:%2:%3;",typeOf _unit, round(_rnd * 100) / 100, _wpn]];
			_ret = true;
		} 
		else
		{
			if ( (typeOf _unit) isKindOf "SoldierWAR" ) then  // M249
			{	// rearm with some special kind of M249
				if ( _adv_rearm ) then  {_wpn = "ACE_M249Para_M145"} else {_wpn = "ACE_M249Para"};
				//_probArr = _probArr + [format["%1:%2:%3;",typeOf _unit, round(_rnd * 100) / 100, _wpn]];
				_ret = true;
			} 
			else
			{
				if ( (typeOf _unit) == "ACE_SoldierWSniper_A" ) then  // M24-M40
				{	// rearm with some special kind of M24-M40
					_magnum = 9;
					if ( _adv_rearm ) then  {_wpn = SYG_M110_WPN_SET+SYG_M110_WPN_SET_SD;_wpn=RAR(_wpn)} else {_wpn = RAR(SYG_M24_WPN_SET)};
					//_probArr = _probArr + [format["%1:%2:%3;",typeOf _unit, round(_rnd * 100) / 100, _wpn]];
					_ret = true;
				}; //"ACE_SoldierWSniper_A"
			};
		};
		if ( _ret )  then
		{
			_equip = [RAR(SYG_PISTOL_WPN_SET_WEST_STD_NO_GLOCK)] + SYG_STD_MEDICAL_SET;
			_equip = _equip + [["P",_wpn, _wpn call SYG_defaultMagazine,_magnum],["ACE_SmokeGrenade_Green"],["ACE_HandGrenadeTimed",2]];
			[_unit,_equip] call SYG_armUnit;
			if (!(_unit hasWeapon "NVGoggles")) then {	_unit addWeapon "NVGoggles"; };
			if (!(_unit hasWeapon "Binocular")) then {	_unit addWeapon "Binocular"; };
		};
	};
	_ret
};

//
// Rearms basic group with std probablity
//
// call: _res = [_unit1,... , _unitN] call SYG_rearmBasicGroup;
//
SYG_rearmBasicGroup = {
	// forEach _this
	{
		_x call SYG_RearmBasic;
	} forEach _this;
};

/**
 * Returns default magazine type for the designated weapon
 * call: _mag = _wpnType call SYG_defaultMagazine;
 *
 * Where: _wpnType  - class name for the weapon ("ACE_MP5SD" etc)
 */
SYG_defaultMagazine = {
	_arr = getArray( configFile >> "CfgWeapons" >> _this >> "magazines" );
	_arr1 = _arr call SYG_filterACEMagazines;
	if ( count _arr1 > 0 ) then // ACE magazines found
	{
		_arr  = _arr1;
	};
	_arr select 0
};

/**
 * Returns all found ACE magazine type for the designated weapon
 * call: _mags = _wpnType call SYG_defaultMagazinesACE;
 *
 * Where: _wpnType  - class name for the weapon ("ACE_MP5SD" etc)
 */
SYG_defaultMagazinesACE = {
	private ["_arr", "_cnt", "_i"];
	_arr = (getArray ( configFile >> "CfgWeapons" >> _this >> "magazines" ));
	// check magazines visible in game
	_cnt = 0;
	if ( (count _arr) > 0 ) then
	{
		for "_i" from 0 to (count _arr) - 1 do
		{
			
			if ( (getNumber ( configFile >> "CfgMagazines" >> (_arr select _i) >> "ACE_HIDE" )) != 0 ) then
			{
				_arr set [_i, "RM_ME"];
				_cnt = _cnt + 1;
			};
		};
	};
	if ( _cnt > 0 ) then {_arr = _arr - ["RM_ME"];};
	_arr
};

/**
 * Returns filtered array of magazines desgnated as input
 * call: _mags = _mags call SYG_filterACEMagazines;
 *
 * Where: _mags  - array with magazines type names ["ACE_5Rnd_127x99_API_AS50", "ACE_64Rnd_9x18_B_Bizon","ACE_17Rnd_9x19_G17"] etc
 */

SYG_filterACEMagazines = {
	private ["_i","_cnt"];
	_cnt = 0;
	if ( (count _this) > 0 ) then
	{
		for "_i" from 0 to (count _this) - 1 do
		{
			
			if ( (getNumber ( configFile >> "CfgMagazines" >> (_this select _i) >> "ACE_HIDE" )) != 0 ) then
			{
				_this set [_i, "RM_ME"];
				_cnt = _cnt + 1;
			};
		};
	};
	if ( _cnt > 0 ) then {_this = _this - ["RM_ME"];};
	_this
};

/*
 * Returns random equipment list for the WEST pilot
 */
SYG_pilotEquipmentWest = {
//	player globalChat format["item 1: %1, item 2: %2",  _item1, _item2];
	SYG_STD_PILOT_EQUIPMENT + [RANDOM_ARR_ITEM( SYG_SMG_WPN_SET_WEST ), RANDOM_ARR_ITEM( SYG_PISTOL_WPN_SET_WEST ) ]
};

/*
 * Returns random equipment list for the EAST pilot
 */
SYG_pilotEquipmentEast = {
	SYG_STD_PILOT_EQUIPMENT + [ RANDOM_ARR_ITEM(SYG_SMG_WPN_SET_EAST) ] + SYG_PILOT_HANDGUN_EAST
};

// M240: Soldier Machine Gunner "SoldierWMG",
// M249: Soldier Automatic Rifleman "SoldierWAR"
SYG_replacePrimaryWeapon = {
	private ["_unit", "_newWpn", "_mag", "_magCnt", "_wpn", "_i", "_muzzles"];
	_unit   = arg(0);
	_newWpn = arg(1);
	_mag    = arg(2);
	
	_wpn = primaryWeapon _this;
	if ( _wpn != "" ) then {
		_this removeWeapon _wpn;
		_cmags = _wpn call SYG_getCompatibleMagazines;
		_mags = magazines _unit;
		_magCnt = 0; // count how many primary magazines unit has
		{
			if ( _x in _cmags and _x != _mag) then 
				{_magCnt = _magCnt + 1; _unit removeMagazine _x };
		} forEach _mags;
	}
	else 
	{
		if ( count _this > 3 ) then {_magCnt = arg(3)};
	};
	//_magCnt = _magCnt max 1; // at last 1 magazine must be present
	if ( _magCnt > 0 ) then 
	{
		for "_i" from 1 to _magCnt do { _unit addMagazine _mag }; // add new magazines
	};
	_unit addWeapon _newWpn;
	reload _unit;
	//_unit selectWeapon _newWpn;
	_muzzles = getArray(configFile>>"cfgWeapons" >> _newWpn >> "muzzles");
	_unit selectWeapon (_muzzles select 0);
	_magCnt // return number of magazines added
};

//
// adds binocular to unit
//
SYG_addBinocular = {
	_this addWeapon "Binocular";
};

//
// adds NVGoggles to unit
//
SYG_addNVGoggles = {
	_this addWeapon "NVGoggles";
};

/*
 * Arms pilot with full ammunition. Work only for real pilot units of WEST and EAST returning true. 
 * Other units are not armed and function returns false
 * Call: _res = _unit call SYG_armPilotFull;
 */
SYG_armPilotFull = {
	private [ "_res" ];
	_res = false;
	if ( (_this isKindOf "SoldierWPilot") or ( _this isKindOf "SoldierEPilot")) exitWith
	{
		switch ( side _this ) do
		{
			case east:
			{
				[_this, call SYG_pilotEquipmentEast ] call SYG_armUnit;
				_res = true;
			};
			case west:
			{
				//player globalChat format["%1: %2", typeName _this, call SYG_pilotEquipmentWest];
				[_this, call SYG_pilotEquipmentWest ] call SYG_armUnit;
				_res = true;
			};
		};
	};
	if ( true ) exitWith { _res };
};

/*
 * Arm unit with all equipment at one time
 * Params:
 *         unit : unit to equipment
 *         wpnarr: array of weapons/equipment descriptors. Each descriptor is array of items in follow sequence
 *                  [{{"P"|"S"|{"M"|}"E",} WPN/EQ name,} MAG name{, MAG num}], where {item} is optional in some cases
 *
 * Example: [_unit, [ ["P", "ACE_MP5A5", "ACE_30Rnd_9x19_B_MP5", 6], ["S", "ACE_Glock18", "ACE_33Rnd_9x19_G18", 4], ["M", "ACE_Bandage", 2], ["M", "ACE_Morphine",2], ["M", "ACE_MON100",2] ] ] call SYG_armUnit
 */
SYG_armUnit = {
	private [ "_itemCnt", "_itemType", "_pos", "_i", "_j", "_unit", "_args", "_primWpn", "_wpn", "_magCnt", "_scndWpn", "_equipList", "_arr" ];
	if ( typeName _this != "ARRAY" ) exitWith {false};
	_itemCnt = count _this;
	if ( _itemCnt < 1 ) exitWith { hint format["SYG_armUnit: Expected number of args >= 1, found %1", _itemCnt]; false };
	
	_unit = arg(0);
	_arr = arg(1); // main array
	
	if ( (typeName _arr) != "ARRAY" ) exitWith 
	{
		hint format["SYG_armUnit: Expected array of equipment not detected (%1):%2", typeName _arr, _arr];
	};
	_itemCnt = count _arr;
	removeAllWeapons _unit;
	_primWpn = "";
	_scndWpn = "";
	_equipList = [];
	//_wpnList = [];
	if ( _itemCnt > 0 ) then
	{
		for "_i" from 0 to (_itemCnt - 1) do
		{	
			_args = _arr select _i; // get _i-th array with item definition (<wpn_type, wpn_name,> mag_name <, mag_count>) to add to unti
			if ( (typeName _args) != "ARRAY" ) exitWith 
			{
				hint format["SYG_armUnit: Item at pos %1 must be ARRAY, found %2 (%3)", _i, typeName _args, _args];
			};
	//		player globalChat format["SYG_armUnit: add %1-th array[%2] = %3", _i, count _args, _args ];
			_pos = 1;
			_magCnt = 0;
			// check 1st item of array, must be string in any case
			if ( (typeName (_args select 0)) == "STRING" ) then
			{
				switch ( toUpper( _args select 0 ) ) do
				{
					case "P": // Primary weapon, magazines + its optional count  (default 1)
					{ _primWpn = _args select _pos; _pos = _pos + 1; _unit addWeapon _primWpn};
					
					case "S": // Secondary weapon, magazines + its optional count  (default 1)
					{ _scndWpn = _args select _pos; _pos = _pos + 1; _unit addWeapon _scndWpn;};
					
					case "M"; // Magazine[s], simply skip this character
					{};
					case "E": // spEcial equipment, binocular etc
					{
                        for "_i" from _i to 256 do
                        {
                            { if ( count _args > _i) then {_equipList = _equipList + [_args select _pos]; _pos = _pos + 1} };
                        };
					};
					default { _pos = 0 };
				};
				// it may be magazine sequence in follow form: [... "mag_name", mag_cnt]
				if ( (count _args) > _pos ) then // read remaining items as magazine name and its count
				{
					_mag = _args select _pos; 
					_pos = _pos + 1;
					_magCnt = if ( (count _args) > _pos ) then { _args select _pos } else { 1 }; // get number of magazines
					for "_j" from 1 to _magCnt do // adds all requested magazines directly now
					{
						_unit addMagazine _mag;
					};
				};
			}
			else
			{
				hint format["SYG_armUnit: 1st pos must be STRING, found '%1', skipped",  typeName (_args select  0) ];
			};
		};
	}; // if ( _itemCnt > 0 )
	_bsetWeapon = ""; // weapon to select after adding
	// add some special equipment
	// add secondary weapon is exists
	if ( _scndWpn != "" ) then
	{
		_bsetWeapon = _scndWpn;
//		_unit addWeapon _scndWpn;
	};
	// add primary weapon is exists
	if ( _primWpn != "" ) then
	{
		_bsetWeapon = _primWpn;
//		_unit addWeapon _primWpn;
	};
	// now select and reload best weapon in the list
	if ( _bsetWeapon != "" ) then
	{
//		player globalChat format["SYG_armUnit: select/reload %1", _bsetWeapon ];
		reload _unit;
		_unit selectWeapon _bsetWeapon;
//		_muzzles = getArray(configFile>>"cfgWeapons" >> _bsetWeapon >> "muzzles");
//		_unit selectWeapon (_muzzles select 0);
	};
	// load equipment 
	{
		_unit addWeapon _x;
	} forEach _equipList;
};

/**
 * Fills pilot with submachinegun and 6 magazines. Unit MUST be pilot, that is not armed with machinegun
 * Usage:
 *        pilot call SYG_armPilot;
 * Returns: true if pilot detected and equipped, false if equipment for unit not changed
 */
SYG_armPilot = SYG_armPilotFull;

/**
 * Checks if designated weapon name is sniper one
 *
 * Example: "ACE_M21" call SYG_isSniperRifle; // returns true
 */
SYG_isSniperRifle = {
	[_this, SNIPER_WEAPON_LIST] call SYG_isInList;
	if ( _this == "" ) exitWith { false };
	private ["_str"];
	if ( _this call SYG_isMG ) exitWith {false}; // may be MG with optics
	_str = getText ( configFile >> "CfgWeapons" >> _this >> "modelOptics" );
	(_str != "-") && ( _str != "");
};

SYG_hasOptics = {
	if ( _this == "" ) exitWith { false };
	private ["_str"];
	_str = getText ( configFile >> "CfgWeapons" >> _this >> "modelOptics" );
	(_str != "-") && ( _str != "");
};

/**
 * Checks if designated weapon name is inherited from designated weapon list
 *
 * Example: ["ACE_Pecheneg_1P29", SNIPER_WEAPON_LIST ] call SYG_isSniperRifle; // returns false
 */
SYG_isKindOfList = {
	private [ "_name", "_retval"];
	_name = _this select 0;
	_retval = false;
	{
		if ( _name isKindOf _x ) exitWith {_retval = true};
	} forEach (_this select 1);
	_retval
};

/**
 * Checks if designated weapon name is inherited from designated weapon list
 *
 * Example: ["ACE_Pecheneg_1P29", SNIPER_WEAPON_LIST ] call SYG_isSniperRifle; // returns true
 */
SYG_isInList = {
	private [ "_name", "_prev" ,"_retval", "_list"];
	_name = _this select 0;
	if ( _name == "" ) exitWith {false};
	_list = _this select 1;
	_prev = "";
	_retval = false;
	while { true} do 
	{
		if (_name == "" ) exitWith {false}; // not found rifle parent, it can be not weapon name
		if ( _name == "rifle" ) exitWith { _retval = _prev in _list}; // found rifle parent, prev must be MG kind or not
		if ( _name in _list) exitWith { _retval = true };
		_prev = _name;
		_name = configName(  inheritsFrom ( configFile >> "CfgWeapons" >> _name ) );
	};
	_retval
};

//
// checks if unit (_this) has sniper rifle as primary weapon
// Example: _unit call SYG_hasSniperRifle; // return true is unit has some kind of SVD, KSVK, M21, M24, M107 etc
//
SYG_hasSniperRifle = 
{
	if (true) exitWith {(primaryWeapon _this) call SYG_isSniperRifle};
//	player globalChat format["SYG_hasSniperRifle test on '%1'", primaryWeapon _this];
};


/**
 * Checks if designated weapon name is MG
 *
 * Example: "ACE_Pecheneg_1P29" call SYG_isSniperRifle; // returns true
 */
SYG_isMG = {
	[_this, MG_WEAPON_LIST] call SYG_isInList;
};


//
// checks if unit (_this) has MG as primary weapon
// Example: _unit call SYG_hasMG; // return true is unit has some kind of M240, M249, PK, RPK47, RPK74
//
SYG_hasMG = 
{
	if (true) exitWith {(primaryWeapon _this) call SYG_isMG};
//	player globalChat format["hasMG test on '%1'", primaryWeapon _this];
};

 /**
 * Checks if designated weapon name is SMG
 *
 * Example: "ACE_AKS74U_Cobra" call SYG_isSMG; // returns true
 */
SYG_isSMG = {
	[_this, SMG_WEAPON_LIST] call SYG_isInList;
};

SYG_hasSMG = 
{
	if (true) exitWith { (primaryWeapon _this) call SYG_isSMG};
};

SYG_isLauncher = 
{
	[_this, LAUNCHER_WEAPON_LIST] call SYG_isInList;
};

//
// call: _hasLauncher = _unit call SYG_hasLauncher;
//
SYG_hasLauncher = 
{
	private ["_res"];
	_res = false;
	{
		if (_x call SYG_isLauncher) exitWith { _res = true};
	} forEach weapons _this;
	_res;

//	if (true) exitWith { (secondaryWeapon _this) call SYG_isLauncher};
};

// Check if designated weapon has long muzzle
SYG_isLongMizzle = {
	if ( true) exitWith { [_this, LONG_MUZZLE_WEAPON_LIST] call SYG_isInList};
};

//
// call: _hasLongMuzzle = _unit call SYG_hasLongMuzzle;
//
SYG_hasLongMuzzle = 
{
	private ["_res"];
	_res = false;
	{
		if (_x call SYG_isLongMizzle) exitWith { _res = true};
	} forEach weapons _this;
	_res
};

//
// _wpnParent  = _weapon call SYG_getParent; // Parent config class Name
//
SYG_getParent = { 
	configName (inheritsFrom (configFile >> "CfgWeapons" >> _this))
};


//
// Function for pistol detection - by Spooner
// params: _weapon  - item name expected to be or not to be pistol
// Example: isPistol = (secondaryWeapon _unit)  call SYG_isPistol;
//
/* SYG_isPistol = {
	private ["_unknownConfig", "_pistolConfig", "_isPistol"];
	_unknownConfig = configFile >> "CfgWeapons" >> _this;
	_pistolConfig = configFile >> "CfgWeapons" >> "PistolCore";
	
	_isPistol = false;
	while {isClass _unknownConfig} do
	{
	    if (_unknownConfig == _pistolConfig) exitWith
	    {
	        _isPistol = true;
	    };
	
	    _unknownConfig = inheritsFrom _unknownConfig;
	};
	
	_isPistol; // Return.
};
 */
SYG_hasPistol = {
	private ["_ret"];
	_ret = false;
	{
		if ( _x call SYG_isPistol ) exitWith {_ret = true};
	} forEach weapons _this;
	_ret
};

/*
 * Detects is designated as _this weapon supressed (returns true) or not (returns false)
 *
 * call: _isSuprressed = "ACE_AKS74USD_Cobra" call SYG_isSupressed; // returns true
 */
SYG_isSupressed = {
	if ( _this == "" ) then { false} else
	{ getNumber( configFile >> "CfgWeapons" >> _this >> "ace_supressed") > 0 };
};

// Synonym for SYG_isSupressed
SYG_isSilenced = SYG_isSupressed;

// return true if primary weapon of designated unit is supressed one
SYG_hasSupressed = {
	(primaryWeapon _this != "") and ((primaryWeapon _this) call SYG_isSupressed)
};


// Gets all compatible magazines for designated weapon
// _compatibleMagazines = _weapon call SYG_fuelCapacity;
//
SYG_getCompatibleMagazines = {
   private ["_weapon", "_mags"];

    _weapon = configFile >> "CfgWeapons" >> _this; // точка входа в самый верхний класс нашего ствола
    _mags = [];

    { // для всех muzzles нашего ствола
        _mags = _mags + getArray (
            // если очередной (обычно единственный) muzzle -- это this, то читаем магазины у себя,
            // иначе -- у подкласса с указанным muzzle classname.
            ( if(_x == "this")then{ _weapon }else{ _weapon >> _x } ) >> "magazines"
        )
    } foreach getArray (_weapon >> "muzzles");
    _mags
};
