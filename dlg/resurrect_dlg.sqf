//
// by Sygsky at 2016-JAN-14. dlg/resurrect_dlg.sqf, called only on client computer
//
// call as follow: [_max_num, _rad_step execVM "dlg\resurrect-dlg.sqf"]
//
private ["_ok","_XD_display","_ctrl","_index","_max_num","_rad_step","_score","_item"];

//
// call: _arr = [_unit|_object, max_num<, _radious_step>] call SYG_makeRestoreArray;
// result: [[num1, radious1]<,...[numN1, radiousN]>] where num# is number of restorable objects found in radious#
//

#include "x_setup.sqf"
#include "x_macros.sqf"

#define DEFAULT_RADIOUS_STEP 5
#define DEFAULT_RADIOUS_MAX 100

/*
SYG_makeRestoreArray = {
    //player groupChat format["*** %1 call SYG_makeRestoreArray ***", _this];
    if ( count _this == 0) exitWith {[]};
    if ( count _this < 2) exitWith {[]};
    private ["_pos","_num","_step","_dist","_dist_limit","_dist_cnt","_filled_in_dist","_prev_cnt","_cnt","_res","_list","_max_cnt"];

    _pos = arg(0);

    _num = arg(1);
    if ( _num <= 0)  exitWith {[]};

    _step = argopt(2, DEFAULT_RADIOUS_STEP);

    _dist_limit = argopt(3, DEFAULT_RADIOUS_MAX);

    // count number of object in each <5-10> meters circle radious
    _ring_rad = _step;

    _prev_cnt = 1;
    _filled_in_ring = 0;
    _cnt = 0;
    _res = [];
    _list = [_pos, _dist_limit] call SYG_findRestorableObjects;
    _max_cnt = _num min (count _list);
    if ( _max_cnt == 0) exitWith { _res };
    //player groupChat format["[pos %1, max cnt %2, step %3] call SYG_makeRestoreArray: max_cnt %4, %5 restoreable items", _pos, _num, _step, _max_cnt, count _list];
    hint localize format["[pos %1, max cnt %2, step %3] call SYG_makeRestoreArray => found cnt %4", _pos, _num, _step, _max_cnt];
    for "_num" from 0 to _max_cnt - 1 do
    {
        _dist = _pos distance (argp(_list,_num));
        hint localize format["%1: %2 %3 %4", _num + 1, _dist, _ring_rad, _filled_in_ring ];
        if ( _dist > _ring_rad ) then // curent dist limit detected
        {
            if ( _filled_in_ring > 0 ) then
            {
                _res = _res + [[_num, _ring_rad]];
                _filled_in_ring = 0; // start next ring
            };
            // find next ring to fit current object
            while {(_ring_rad < _dist_limit) && ( _dist > _ring_rad)} do
            {
                _ring_rad = _ring_rad + _step;
            };
        };
        if ( _dist <= _ring_rad ) then // curent dist limit detected
        {
            _filled_in_ring = _filled_in_ring + 1; // one more for this dist
        };
    };
    _num = if ( count _res > 0) then {_res select ((count _res) - 1) select 0} else {0}; // last filled count
    if ( _max_cnt > _num ) then
    {
        _res = _res + [[_max_cnt, round(_dist + 0.5) ]]; // fil with lsat object distance
    };
     //player groupChat format["SYG_makeRestoreArray: returns %1", _res];
    _res
};
*/

//player groupChat format["dlg/resurrect_dlg.sqf: _this=%1", _this];

if ( (typeName _this) == "ARRAY") then
{
    _max_num = arg( 0 ); // max number of resurrection to use
    _rad_step = argopt( 1, DEFAULT_RADIOUS_STEP); // step along radious
}
else
{
    _max_num = _this;
    _rad_step = DEFAULT_RADIOUS_STEP ;
};

#define __DEBUG__

_ok = createDialog "XD_ResurrectDialog";

_XD_display = findDisplay 13000;

_ctrl = _XD_display displayCtrl 1000;

// prepare array with with resurrect radious and costs
// _arr = [_unit|_object, max_num<, _radious_step>] call SYG_makeRestoreArray;
SYG_resurrect_array = [player, _max_num, _rad_step, DEFAULT_RADIOUS_MAX] call SYG_makeRestoreArray; // get array for resurrection options

//player groupChat format["SYG_makeRestoreArray returned %1", SYG_resurrect_array];

_cnt = count SYG_resurrect_array;
if ( _cnt == 0) then
{
    _ctrl ctrlSetTooltip (localize "STR_RESTORE_DLG_9");
}
else
{
    _ctrl ctrlSetTooltip format[localize "STR_RESTORE_DLG_5", _cnt];
};
_ctrl lbAdd (localize "STR_RESTORE_DLG_6"); //"nothing";
{
    _index = _ctrl lbAdd format[localize "STR_RESTORE_DLG_8",argp(_x,0), argp(_x,1)]; // "%1 item[s] up to the %2 m."
} forEach SYG_resurrect_array;

_ctrl lbSetCurSel 0;

waitUntil {!dialog || !alive player};

if (!alive player) then {
	closeDialog 13000;
}
else
{
    if (! (isNil "SYG_resurrect_array_index")) then // list was selected
    {
        //player groupChat format["SYG_resurrect_array_index=%1",SYG_resurrect_array_index ];
        if ( (SYG_resurrect_array_index > 0) && ((count SYG_resurrect_array) > 0) ) then // some value is selected
        {
            _item = argp(SYG_resurrect_array,SYG_resurrect_array_index-1);
            _score = [player, argp(_item,1)] call SYG_restoreIslandItems;
            player addScore (-_score);
            player groupChat format[localize "STR_RESTORE_DLG_7", _score]; // "scores subtracted %1"
        };
    };
};

SYG_resurrect_array_index = nil;
SYG_resurrect_array = [];
sleep 0.01;
SYG_resurrect_array = nil;
if (true) exitWith {};