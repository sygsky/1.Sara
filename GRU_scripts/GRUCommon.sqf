// GRUCommon.sqf.sqf, created by Sygsky on 09-DEC-2015

#include "GRU_Setup.sqf"

if ( isNil "GRU_tasks" ) then
{
	GRU_tasks = [
	//=========================
	// Main task parameters:
	//  _main_info = [[[9349,5893,0],"Cayo", 210],START_SCORE,PARTICIPANTS_LIST]; // array target_names from i_common.sqf, start town score, list of participants 
	//=========================
		[], // main target (in towns): [target_tow_info, initial_score, list_of_participants]
		
	//=========================
	//   Secondary task parameters:
	//   _sec_info = [50]; // radious of teleport zone
	//=========================
		[], // secondary target. In common case it is not valid as secondary missions are rarely situated at houses
		
		[], // occupied town mission
		
		[], // GRU task (pick-up agents, destroy anti-GLONASS device, etc)
		
	//	[], // GRU addition secondary missions (destroy any carrier with old nuclear missile ...)
		
		[]  // GRU task find mission (weapon in most)
	];
};
// call: _task = _task_id call GRU_getTask;
GRU_getTask = {
	if ( TASK_ID_NOT_VALID(_this)) exitWith {/* hint localize "GRUCommon.sqf.GRU_getTask:TASK_ID_NOT_VALID(_this) == true";  */[]};
	argp(GRU_tasks,_this)
};

//
// call as follow: _isActive = _task_id call GRU_taskActive;
//
GRU_taskActive = {
	TASK_IS_ACTIVE(_this call GRU_getTask)
};

// check task to be active
GRU_activeTaskNotValid = {
	if ( !(_this call GRU_taskActive) ) exitWith {/* hint localize "GRUCommon.sqf.GRU_activeTaskNotValid:GRU_taskActive == false";  */false};
	private ["_task", "_town_info","_param_town","_score_start","_score_start","_score_now"];
	_task = GRU_GET_TASK(_this); // get task array
//	_town_info = GRU_MAIN_GET_TOWN_INFO; 
//	hint localize format["_town_info = %1",_town_info];
	switch (_this) do
	{
		case GRU_MAIN_TASK: 
		{
			// check if town name is actual
			_param_town = call SYG_getTargetTown;
			hint localize format[ "param_town -> %1", _param_town ];
			if ( (count _param_town) == 0 ) exitWith { hint localize "GRUCommon.sqf.GRU_activeTaskNotValid: target town not defined"; false}; // no target town defined
			_name = argp( _param_town,TOWN_NAME_IN_INFO );
			if ( GRU_MAIN_GET_TOWN_NAME != _name ) exitWith { false };
			
			// check if town scores are still not reduced twice against original ones
			_score_start = GRU_MAIN_GET_SCORE;
			_score_now   = [ GRU_MAIN_GET_TOWN_CENTER, 300, true] call SYG_getScore4IntelTask;
			hint localize format["score start %1, score now %2", _score_start, _score_now];
			if ( _score_now < (_score_start / 2)) exitWith { true };
			if ( mt_radio_down OR side_main_done ) exitWith { true }; // any of town targets are done
			// todo: check tower and secondary target to be alive
			false
		};
		default {true}; // other kinds still are not developed, so 
	}
};

//
// call on client oply as follow: _msg call GRU_msg2player;
GRU_msg2player = {
	if (!isNull player ) then  { titleText [ _this, "PLAIN DOWN"];};
};

//
// call on client only (on server always return false and doing nothing) to remove any doc from user inventory and/or rucksack
//
// returns true if some (first detected) doc was found and removed or false if not (e.g. calld on server)
//
GRU_removeDoc = {
	if ( isNull player ) exitWith {false}; // no player -> no docs
	if ( player hasWeapon "ACE_Map") exitWith{ player removeWeapon "ACE_Map"; true};
	private ["_removed"];
	_removed = false;
	{
		if ( argp(_x,0) == "ACE_Map_PDM" ) exitWith 
		{
			[player, "ACE_Map_PDM"] call ACE_Sys_Ruck_RemoveRuckMagazine;
			_removed = true;
		};
	} forEach (player call ACE_Sys_Ruck_RuckMagazines);
	_removed;
};

//
// call on client only (on server always return false and doing nothing) to check document presence in user inventory and/or rucksack
//
// returns true if any doc is detected or false if called on server or no found
//
GRU_hasDoc = {
	if ( isNull player ) exitWith {false}; // no player -> no docs
	if ( player hasWeapon "ACE_Map") exitWith { true};
	private ["_has"];
	_has = false;
	{
		if ( argp(_x,0) == "ACE_Map_PDM" ) exitWith { _has = true; };
	} forEach (player call ACE_Sys_Ruck_RuckMagazines);
	_has
};
//
// calls on client only (on server always return false and doing nothing) to remove any doc from user inventory and/or rucksack
//
// returns true if doc was added or false if no place (rare case of full rucksack) or called
//
GRU_addDoc = {
	if ( isNull player ) exitWith {false}; // no player -> no docs
	// remove ACE_Map
	player addWeapon "ACE_Map";
	if ( player hasWeapon "ACE_Map") exitWith {true};
	
	if ( [player, "ACE_Map_PDM"] call ACE_Sys_Ruck_FitsInRucksack ) exitWith
	{
		[player, "ACE_Map_PDM"] call ACE_Sys_Ruck_AddRuckMagazine; true
	};
	false;
};
