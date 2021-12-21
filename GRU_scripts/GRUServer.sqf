// GRUClient.sqf, created by Sygsky on 09-DEC-2015
// receives and process all messages from client to server

// ["msg_to_user",_player_name,[_msg1, ... _msgN]<,_delay_between_messages<,_initial_delay>>]

#include "x_macros.sqf"
#include "GRU_setup.sqf"

// call as follow: _task_id call GRU_stopTask;
GRU_stopTask = {
	if (!isServer) exitWith {};
	private ["_task_id"];
	if ( _this call GRU_taskActive ) then
	{
		// stop old task first
		GRU_tasks set [_this, []];
		publicVariable "GRU_tasks";
		// send info about it second
		["GRU_msg", GRU_MSG_STOP_TASK, _this] call XSendNetStartScriptClient;
		sleep 4.37;
	};
};

//
//  call on server as follow: [... params ...] call GRU_startNewTask;
//
// params: [_task_kind, [_task params...]]
//
GRU_startNewTask = {
	hint localize format["GRUServer.sqf.GRU_startNewTask: %1", _this];
	if (!isServer) exitWith {};
	private ["_task_id"];
	_task_id = arg(GRU_TASK_KIND);
	if ( TASK_ID_NOT_VALID(_task_id)) exitWith { hint localize format["GRUServer.sqf.GRU_startNewTask: illegal task id %1, must be {0..%2}", _task_id, (count GRU_tasks)]};
	_task_id call GRU_stopTask;
	GRU_tasks set[_task_id, arg(GRU_TASK_PARAMS)];
	publicVariable "GRU_tasks";
	["GRU_msg", GRU_MSG_START_TASK, _task_id] call XSendNetStartScriptClient;
	sleep 1.31416;
};

private ["_msg"];

_msg = arg(0);
switch (_msg) do
{
	case "GRU_msg": // the only message used for GRU operations (main id)
	{
		_task_id = arg(2);
		if ( !(_task_id call GRU_taskActive) ) exitWith { hint localize format["Server GRU_msg designated task (%1) is not active %2",_task_id, _this];};
		_msg = arg(1); // sub-id, e.g. ["GRU_msg", GRU_MSG_START_TASK, _task_id<,player_name>] call XSendNetStartScriptClient;
		_task_name_id = "<UNKNOWN>";
		_task_name = switch _task_id do 
		{
			case GRU_MAIN_TASK: { _task_name_id = "STR_GRU_2"; localize "STR_GRU_2"};
			
			case GRU_SECONDARY_TASK: { "<GRU_SECONDARY_TASK>" };
			
			case GRU_OCCUPIED_TASK: { "<GRU_OCCUPIED_TASK>" };

			case GRU_PERSONAL_TASK: { "<GRU_PERSONAL_TASK>" };

			case GRU_FIND_TASK: { "<GRU_FIND_TASK>" };
			default {format ["Unknown GRU task kind %1",_task_id]};
		};
		_player_name = argopt(3,"<Unknown>");
		switch _msg do
		{
			case GRU_MSG_STOP_TASK;
			case GRU_MSG_START_TASK: {
				hint localize "--- GRU_MSG_START_TASK/GRU_MSG_STOP_TASK can't be send from client to server";
			};
			case GRU_MSG_TASK_SOLVED: {
				// stop corresponding task and send info back to all clients
				_task_id call GRU_stopTask; // done!!!
				_msg = ["localize","STR_GRU_7", "localize", "STR_GRU_4", "localize", "STR_GRU_1", "localize", _task_name_id, _player_name];
				["msg_to_user","",[_msg],4,4] call XSendNetStartScriptClient;
			};
			case GRU_MSG_TASK_FAILED: {
				// stop corresponding task and send info back to all clients
				_task_id call GRU_stopTask; // done!!!
				_msg = ["localize","STR_GRU_8", "localize", "STR_GRU_4","localize", "STR_GRU_1", "localize",_task_name_id, _player_name];
				["msg_to_user","",[_msg],4,4] call XSendNetStartScriptClient;
			};
			
			case GRU_MSG_TASK_SKIPPED: { // user mission was unsuccessfull but task can continue
				_task = _task_id call GRU_getTask;
				_agent_list = argp(_task,GRU_MAIN_LIST); 
				if ( _player_name in _agent_list) then
				{
					_task set [GRU_MAIN_LIST, _agent_list - [_player_name]];
					publicVariable "GRU_tasks";
					hint localize format["Server GRU_MSG_TASK_SKIPPED: ""%1"" removed from agent list", _player_name];
				}
				else
				{
					hint localize format["Server GRU_MSG_TASK_SKIPPED: player %1 isn't in list %2", _player_name, _agent_list];
				};
			};
			case GRU_MSG_TASK_ACCEPTED: {
				// send info back to all clients
				_task = _task_id call GRU_getTask;
				_agent_list = argp(_task,GRU_MAIN_LIST); 
				if ( !_player_name in _agent_list) then
				{
					_task set [GRU_MAIN_LIST, _agent_list + [_player_name]];
					publicVariable "GRU_tasks";
				};
				_msg = ["localize","STR_GRU_10", "localize", "STR_GRU_1", "localize", _task_name_id, _player_name];
				["msg_to_user","",[_msg]] call XSendNetStartScriptClient;
			};
			default {hint localize format["--- GRUClient.sqf: ""GRU_msg"" unknown sub-id %1", _this]};
		}; // switch _msg do
	}; // case "GRU_msg"
	
	case "INIT": {};
	// other messages (on real server)
	default { hint localize format["XSendNetStartScriptClient: server still not support msg id %1", _this ]; };
}; //switch (_msg) do
