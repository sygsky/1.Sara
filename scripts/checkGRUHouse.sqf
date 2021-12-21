/*
	author: Sygsky
	description: checks GRU house objects (comp, map, ammo box) in any alive GRU house (Land_army_hut2_int)
	returns: nothing
*/

if (!isNil "checkGRUHouseOn") exitWith {true};
checkGRUHouseOn = true;
player groupChat "Контроль за ГРУ оборудованием стартовал!";
hint localize "Контроль за ГРУ оборудованием стартовал!";
waitUntil {sleep 10; ! (call SYG_checkGRUHouse)};
hint localize "ГРУ оборудование утеряно и нового не ждите!";
checkGRUHouseOn = nil;
