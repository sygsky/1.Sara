/*****************************************************
; ** replace_object.sqs
; ** by JohnnyBoy
; **
; ** Replace one object with another object.  Used to place
; ** EditorUpdate objects without having to include the Editor Addon
; ** in your mission.
; **
; ** example call:  
; **     [this, "Camera1", "cam1"] exec "replace_object.sqs";
; **
; ** Parameter 1: Object to replace.  I like barrel objects as place holders.
; ** Parameter 2: Object Type of object of new object to create.
; ** Parameter 3: Object name of new object, so you can reference this object
; **              in your other scripts.  Place your desired name in this variable
; **              instead of naming the placeholder object you placed in the editor.
*****************************************************/

_obj_to_replace = _this select 0;
_obj_to_create  = _this select 1; 
_obj_name       = _this select 2;

// To prevent an object being created per client, exit if object is not local.
if  !local _obj_to_replace exitWith {hint localize format["replace_object.sqf: can't repplace not local object %1", _obj_to_replace];};
call compile format ["%1 = ""%2"" createvehicle [0,0,0]", _obj_name, _obj_to_create];

_pos = getpos _obj_to_replace; 
_dir = getdir _obj_to_replace;
//deleteVehicle _obj_to_replace; 
deleteCollection _obj_to_replace; 
sleep 0.01;
call compile format ["%1 setpos %2", _obj_name, _pos];
call compile format ["%1 setdir %2", _obj_name, _dir];
if (true) exitWith {};
