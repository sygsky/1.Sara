/*
	author: Sygsky
	description: none
	returns: nothing
*/

if (!isNil "SYG_bonusUtils") exitWith {};
if (! (isServer || X_SPE )) exitWith {}; // not for usage on server
SYG_bonusUtils = true;
SYG_bonusMarkedVehs = [];
