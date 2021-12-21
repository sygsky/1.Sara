// edit this file and then run setupcopy.bat

// uncomment to show markers for sidemissions, main targets, etc.
//#define __DEBUG__

// uncomment to build the Two Teams version
//#define __TT__

// uncomment the corresponding #define preprocessor command
// use only one at a time
// comment all for the Two Teams version
//#define __OWN_SIDE_WEST__
#define __OWN_SIDE_EAST__
//#define __OWN_SIDE_RACS__

// uncomment the corresponding #define preprocessor command
// select which version you want to create
// you can uncomment multiple versions
// comment all for the Two Teams version
//#define __AI__
//#define __MANDO__
//#define __REVIVE__
#define __ACE__
//#define __CSLA__
//#define __P85__

// uncomment if you want a ranked version like in Evolution
#define __RANKED__

// #define __SCHMALFELDEN__ for Schmalfelden version, #define __UHAO__ for the UHAO version, #define __DEFAULT__ for the default Sahrani version
// uncomment the corresponding preprocessor command for the version you want. Default is __DEFAULT__
// use only one at a time
// comment all for the Two Teams version
#define __DEFAULT__
//#define __SCHMALFELDEN__
//#define __UHAO__

//#define __D_VER_NAME__ "Domination! One Team - West"
//#define __D_VER_NAME__ "Domination! One Team - A.C.E."
//#define __D_VER_NAME__ "Domination! One Team - A.C.E. RA"
#define __D_VER_NAME__ "Domination! One Team - A.C.E. East"
//#define __D_VER_NAME__ "Domination! One Team - West AI"
//#define __D_VER_NAME__ "Domination! One Team - West REVIVE"
//#define __D_VER_NAME__ "Domination! One Team - East"
//#define __D_VER_NAME__ "Domination! One Team - East AI"
//#define __D_VER_NAME__ "Domination! One Team - East Revive"
//#define __D_VER_NAME__ "Domination! One Team - CSLA"
//#define __D_VER_NAME__ "Domination! One Team - P85"
//#define __D_VER_NAME__ "Domination! One Team - Racs"
//#define __D_VER_NAME__ "Domination! One Team - Racs AI"
//#define __D_VER_NAME__ "Domination! One Team - Racs Revive"
//#define __D_VER_NAME__ "Domination! One Team - West Schmalfelden"
//#define __D_VER_NAME__ "Domination! One Team - West Mando"
//#define __D_VER_NAME__ "Domination! One Team - East Uhao"
//#define __D_VER_NAME__ "Domination! Two Teams"

// uncomment, if you want grass at mission start
//#define __WITH_GRASS_AT_START__

// uncomment, if you want the old intro
//#define __OLD_INTRO__

// if true then the old engineer (faster) script gets used
//#define __ENGINEER_OLD__

// if you are still running 1.14 comment the following line
//#define __NO_PARABUG_FIX__

// comment if you don't want that super cool radio tower effect from Spooner and Loki
//#define __WITH_SCALAR__

// respawn delay after death
// doesn't get used in the revive version
#define D_RESPAWN_DELAY 10

//#define __SMMISSIONS_MARKER__

//+++ Sygsky: uncomment to add limited refuelling ability for engineers. Still not realized
//#define __LIMITED_REFUELLING_

//+++ Sygsky: uncomment to debug new airkillers. Only for debug purposes
//#define __SYG_AIRKI_DEBUG__

//+++ Sygsky: uncomment to debug isledefence activity
#define __SYG_ISLEDEFENCE_DEBUG__

//+++ Sygsky: uncomment to debug new base pipebombing
//#define __SYG_PIPEBOMB_DEBUG__

//+++ Sygsky: play New Year music on base
//#define __SYG_NEW_YEAR_GIFT__

//+++ Sygsky: debug governor state
#define __SYG_GOVERNOR_INFO__