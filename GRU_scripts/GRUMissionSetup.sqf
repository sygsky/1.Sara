//
// GRUMain.sqf by Sygsky at 08-DEC-2015. For Domination GRU tasks system.
//
// Spawn it sonn after new town target generated
//

#include "x_macros.sqf"
#include "GRU_setup.sqf"

if ( !isNil "GRUMissionSetup_on" ) exitWith {};
GRUMissionSetup_on = true;

call compile preprocessFileLineNumbers "GRU_scripts\GRUCommon.sqf";	// Weapons, re-arming etc

//+++++++++++++++++++++++++++++++++++++++ MAIN CODE ++++++++++++++++++++++++++++

["INIT"] call compile preprocessFileLineNumbers "GRU_scripts\GRUServer.sqf";
["INIT"] call compile preprocessFileLineNumbers "GRU_scripts\GRUClient.sqf";

sleep 5 + random 10;

_ttinfo = call SYG_getTargetTown;
_startScore = [argp(_ttinfo,0),300,true] call SYG_getScore4IntelTask;
[GRU_MAIN_TASK,[ _ttinfo,  _startScore,[]]] call GRU_startNewTask;
GRU_Is_On = true;

player groupChat format["GRU MAIN task started for %1", argp(_ttinfo,1)];

GRU_task_was_successfull = false; // if true, task was successfully completed by somebody, may try to repeat it after

while { GRU_Is_On } do
{
	WAIT_FOR_PLAYER_CONNECTION; // define from "GRU_setup.sqf"
	if ( GRU_task_was_successfull ) then // try next task creation
	{
		sleep 60;
		if ( mt_radio_down || side_main_done ) exitWith { true }; // any of town targets are done

		
	};
	if ( GRU_MAIN_TASK call GRU_activeTaskNotValid ) exitWith 
	{
		// clear task
		GRU_MAIN_TASK call GRU_stopTask;
		hint localize "--------------- MAIN TASK is invalid, exit loop";
		player groupChat "--- GRU MAIN task is invalid, exit loop";
	};
	hint localize format["%1: GRU MAIN TASK is valid",round(time)];
	sleep 60;
};

if ( true ) exitWith {GRUMissionSetup_on = nil;};