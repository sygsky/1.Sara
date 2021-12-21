/*
	scripts/bonuses/bonus_def.sqf
	author: Sygsky
	description: none
	returns: nothing
*/
#define BONUS_NAME (_bonus select 0)
#define BONUS_SCORE (_bonus select 1)
#define BONUS_TIME (_bonus select 2)
#define BONUS_MARKER_NAME (_bonus select 3)
#define BONUS_MARKER_TYPE (_bonus select 4)

#define SET_BONUS_NAME(name) (_bonus set [0,(name)])
#define SET_BONUS_SCORE(_score) (_bonus set [1,(_score)])
#define SET_BONUS_TIME(_time) (_bonus set[2,(_time)])

//
// Light version means reward for detection only, not for getting to the base
//
#define __VERSION_LIGHT__ // to enable light version
