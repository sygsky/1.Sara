// GRUClient.sqf, created by Sygsky on 09-DEC-2015
// receives and process all messages from server to client

#include "x_macros.sqf"
#include "GRU_setup.sqf"

private ["_msg"];

_msg = arg(0);
switch (_msg)	 do
{
	case "GRU_msg": // the only message used for GRU operations (main id)
	{
		_msg = arg(1); // sub-id, e.g. ["GRU_msg", GRU_MSG_START_TASK, _kind<,player_name>] call XSendNetStartScriptClient;
		_kind = arg(2);
		_task_name = switch _kind do 
		{
			case GRU_MAIN_TASK: { localize "STR_GRU_2"};
			
			case GRU_SECONDARY_TASK: { "GRU_SECONDARY_TASK"};
			
			case GRU_OCCUPIED_TASK: {"GRU_OCCUPIED_TASK"};

			case GRU_PERSONAL_TASK: {"GRU_PERSONAL_TASK"};

			case GRU_FIND_TASK: {"GRU_FIND_TASK"};
			default {format ["Unknown GRU task kind %1",_kind]};
		};
		_player_name = argopt(3,localize "STR_GRU_9");
		switch _msg do
		{
			case GRU_MSG_STOP_TASK: {
				titleText[ format[localize "STR_GRU_5", localize "STR_GRU_4",localize "STR_GRU_1",_task_name,localize "STR_GRU_3" ],"PLAIN DOWN"]; // "Задача ГРУ ""доставить развединфо из города"" прекращена"
			};
			case GRU_MSG_START_TASK: {
				titleText[ format[localize "STR_GRU_6", localize "STR_GRU_4",localize "STR_GRU_1", _task_name ],"PLAIN DOWN"]; // "Поступила новая задача ГРУ ""доставить развединфо из города"""
			};
			case GRU_MSG_TASK_SOLVED: {
				playSound "tune"; // playSound "fanfare";
				titleText[ format[localize "STR_GRU_7", localize "STR_GRU_4",localize "STR_GRU_1", _task_name, _player_name ],"PLAIN DOWN"]; // "задача ГРУ ""доставить развединфо из города"" выполнена (имя)"
			};
			case GRU_MSG_TASK_FAILED: {
				titleText[ format[localize "STR_GRU_8", localize "STR_GRU_4",localize "STR_GRU_1", _task_name, _player_name ],"PLAIN DOWN"]; // "задача ГРУ ""доставить развединфо из города"" провалена (имя)"
			};
			case GRU_MSG_TASK_ACCEPTED: {
				// send back info to all clients and add accepted player to the list
				titleText[ format[localize "STR_GRU_5", localize "STR_GRU_4",localize "STR_GRU_1",_task_name,localize "STR_GRU_3" ],"PLAIN DOWN"]; // "Задачу ГРУ ""доставить развединфо из города"" выполняет ИМЯ"
			};
			default {hint localize format["GRUClient.sqf: ""GRU_msg"" unknown sub-id %1", _this]};
		};
	};

	case "INIT": {};
	// other messages (on real client)
	default { hint localize format["XSendNetStartScriptClient: to process in real client %1", _this ]; };
};
