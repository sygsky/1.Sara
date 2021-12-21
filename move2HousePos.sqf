/* move2HousePos.sqf
	author: Sygsky
	description: none
	returns: nothing
*/

#define ROUND2(val) (round((val)*100.0)/100.0)

private ["_bld","_cnt","_i","_str"];
//_bld = nearestBuilding player;
_bld = nearestObject [getPos player, "HouseBase"];
_cnt = _bld call SYG_housePosCount;
if ( _cnt == 0 ) exitWith{player groupChat "Cant' enter this house as pos cnt is 0"};

_str = " ";
for "_i" from 0 to _cnt - 1 do
{
    _pos = _bld buildingPos _i;
    //player groupChat format["pos %1",_pos];
    _str = _str + format["%1,",  ROUND2(_pos select 2)];
};
player groupChat format["%1(%2):%3", typeOf _bld, _cnt, _str ];
_posId = floor random _cnt;

_pos = _bld buildingPos _posId;
_man = objNull;
if ( count units player > 1) then
{
    {
        if (_x != player && canStand _x) exitWith {_man = _x; player groupChat format["+++ player unit %1 found",typeOf _man]; };
    } forEach units player;
};
if ( _man == objNull ) then
{
    _arr =  nearestObjects [player, ["CAManBase"], 200];
    {
        if (_x != player) exitWith { _man = _x; player groupChat format["+++ non player unit %1 found",typeOf _man]; };
    }forEach _arr;
};
if (isNull _man) exitWith {player groupChat "--- No man found near you"};
_dist = round(_man distance player);
if (group _man != group player) exitWith {player groupChat format["--- Man (dist %1) not in your group",_dist]};
_man setPos _pos;
_str = format["[%1,%2,%3]",ROUND2(_pos select 0),ROUND2(_pos select 1),ROUND2(_pos select 2)];
player groupChat format["+%1(%5 m) sent to house %2 pos %3 (%4)", _man, typeOf _bld, _posId, _str , _dist];