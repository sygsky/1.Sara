//
// GRU_townreconnaissance.sqf, created by Sygsky at 09-DEC-2105
//
// start with GRU town reconnaissance mission. Call only on client to use 'player' variable
//
// call as : _hnd = [_pc, _scorePlus, _scoreMinus] execVM "GRU_scripts\GRU_townreconnaissance.sqf"
// _pc         : pGRU computer or its position 
// _dist       : distance to computer to done mission
// _scorePlus  : positive (> 0)score for success
// _scoreMinus : negative score (< 0) for failure
//

#include "GRU_setup.sqf"

#define SEARCH_DURATION_STEPS 30
#define CYCLE_SLEEP_SEC 2
#define LOST_REMINDER_PERIOD_STEPS 5

#define FADE_OUT_DURATION 0.3
#define FADE_IN_DURATION 6

_rnd_port_msg = 
{
	private ["_cnt"];
	call compile format["_cnt=%1;",localize "STR_GRU_TELE_CNT"];
	call compile format ["localize STR_GRU_TELE_%1", floor(_cnt)]
};

hint localize "+++ GRU_townreconnaissance.sqf run +++";
playSound "ACE_VERSION_DING";
sleep 0.1;

playSound "FlashbangRing";
FADE_OUT_DURATION fadeSound (0.2); // blind his eyes

//titleCut ["","BLACK OUT", FADE_OUT_DURATION];
titleCut ["","WHITE OUT",FADE_OUT_DURATION];

FADE_IN_DURATION fadeSound 1;
titleCut ["","WHITE IN",FADE_IN_DURATION]; // restore vision

(call _rnd_port_msg) spawn {sleep 1; _this call GRU_msg2player;};
sleep (FADE_IN_DURATION);
//titleCut ["","BLACK IN",1];

//10 fadeSound 0;
10 fadeMusic 0;
//[] spawn {sleep 10; 3 fadeSound 1;};

//playSound "tune";

// todo: add MAP

// add secret document (ACE_Map object)
_str = localize "STR_GRU_19"; // "Вы нашли в городе нашего человека и установили с ним контакт"
if ( !(player call GRU_addDoc) ) exitWith
{
	_str = format["%1. %2", _str, localize "STR_GRU_20"]; //"Но Вам некуда даже спрятать этот документ (нет места)!"
	_str call GRU_msg2player; 
	["GRU_msg", GRU_MSG_TASK_SKIPPED, GRU_MAIN_TASK, name player] call XSendNetStartScriptServer; 
	sleep 1;
};

_str = format["%1. %2", _str, localize "STR_GRU_21"];
_str call c; // "Он передал Вам донесение, которое вы надёжно спрятали. Не дай разум уничтожить его случайно!"

_pos = arg(0); // destination
if (typeName _pos == "OBJECT") then {_pos = getPos _pos;};

_dist = argopt(1,5);

// todo: send message to user "document added, keep it hard, delete before death with top menu item 
// todo: add top menu item
_name = "Уничтожить документ";

_menu_id = player addAction [_name, "GRU_scripts\GRU_removedoc.sqf",["REMOVE"], 1000]; // let it be the top menu item
player setVariable ["remove_doc_id", _menu_id];

hint localize format["+++ GRU_townreconnaissance.sqf: params %1, action added ""%2"" +++",_this, _name];

_failure = false;
_search_started_at = 0;

scopeName "exit";

_search_cnt = 0;
_unc_msg_fired = false;

while { true } do
{
	sleep CYCLE_SLEEP_SEC;
	if ( !alive player ) exitWith
	{
		if ( call GRU_hasDoc ) then
		{
			(localize "STR_GRU_12") call GRU_msg2player; // "Вы погибли и враг прочтёт доверенное Вам разведдонесение. Это очень плохо!"
			["GRU_msg", GRU_MSG_TASK_FAILED, GRU_MAIN_TASK, name player] call XSendNetStartScriptServer;
			_failure = true;
		}
		else
		{
			(localize "STR_GRU_13") call GRU_msg2player; // "Вы погибли при исполнении задания ГРУ, но не допустили утечки информации. Сахранийцы не забудут героя!"
			["GRU_msg", GRU_MSG_TASK_SKIPPED, GRU_MAIN_TASK, name player] call XSendNetStartScriptServer; 
			sleep 1;
		};
	};
	
	if ( !TASK_ID_IS_ACTIVE(GRU_MAIN_TASK) ) exitWith
	{
		(localize "STR_GRU_11") call GRU_msg2player; // "ГРУ отменило эту задачу, возвращайтесь к обычной боевой службе"
	};
	
	if ( player call SYG_ACEUnitUnconscious ) then
	{
		if (!_unc_msg_fired) then { _unc_msg_fired = true; (localize "GRU_STR_18") call GRU_msg2player;};
	}
	else
	{
		if ( !(call GRU_hasDoc) ) then // you lost yur map, try to search it in vicinity
		{
			if ( _search_cnt >= SEARCH_DURATION_STEPS ) then 
			{
				(localize "STR_GRU_16") call GRU_msg2player; // "Вы позорно потеряли доверенное Вам разведдонесение! Задание провалено!"
				["GRU_msg", GRU_MSG_TASK_FAILED, GRU_MAIN_TASK, name player] call XSendNetStartScriptServer; 
				_failure = true;
				breakTo "exit";
			};
			if (_search_cnt != 0) then
			{
				if ( (_search_cnt % LOST_REMINDER_PERIOD_STEPS) == 0 ) then
				{
					(format[localize "STR_GRU_15", (SEARCH_DURATION_STEPS - _search_cnt) *CYCLE_SLEEP_SEC]) call GRU_msg2player; // "Найдите карту! У Вас осталось %1 сек. до провала задания!"
				};
			}
			else
			{
				(format[localize "STR_GRU_14",CYCLE_SLEEP_SEC * SEARCH_DURATION_STEPS]) call GRU_msg2player; // "Вы потеряли карту! У вас есть только %1 сек. чтобы найти её!"
			};
			_search_cnt = _search_cnt + 1;
		}
		else 
		{
			if ( (player distance _pos) < _dist ) then 
			{
				// play sound of success, add score etc
				player addScore arg(2);
				// send message on server about success
				["GRU_msg", GRU_MSG_TASK_SOLVED, GRU_MAIN_TASK, name player,4,4] call XSendNetStartScriptServer; 
				breakTo "exit";
			};
			if ( _search_cnt > 0 ) then // map was on groud before this step
			{
				(localize "STR_GRU_22") call GRU_msg2player; // "Ф-у-у-у, пронесло (вытирая пот со лба)..."
				_search_cnt = 0;
			};
		};
		_unc_msg_fired = false;
	};
};

if ( _failure) then {player addScore arg(3)};
player removeAction _menu_id;
["DUMB"] execVM "GRU_scripts\GRU_removedoc.sqf";

if ( true) exitWith {};