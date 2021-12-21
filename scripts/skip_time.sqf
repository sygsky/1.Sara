/*
	author: Sygsky
	description: none
	returns: nothing
*/

#define GOAL_TIME 3.00
// skip it from current to 03:30

skipTime ( GOAL_TIME - daytime + 24 ) % 24;
player groupChat format["time skipped to %1", date];