/**
 *
 *	Вызов функции анимации фонтанов: строка 107, в свою очередь из строки 124
 *
 */

SYG_fountin = {
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)+0.2,(_this select 1)+0,(_this select 2)], [1,0,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)-0.2,(_this select 1)+0,(_this select 2)], [-1,0,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)+0,(_this select 1)+0.2,(_this select 2)], [0,1,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)+0,(_this select 1)-0.2,(_this select 2)], [0,-1,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)+0.2,(_this select 1)+0.2,(_this select 2)], [0.5,0.5,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)-0.2,(_this select 1)-0.2,(_this select 2)], [-0.5,-0.5,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)-0.2,(_this select 1)+0.2,(_this select 2)], [-0.5,0.5,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
drop["\Ca\Data\cl_basic","","Billboard",1,0.2 + random 0.4,[(_this select 0)+0.2,(_this select 1)-0.2,(_this select 2)], [0.5,-0.5,0],0,1,0.1,0,[0.04+random 0.02],[[0.9,1,1,1],[0.8,0.9,1,0.4]],[0],0,0,"","splach.sqf",""];
true
};

_pos = getPos _this;
for "_i" from 0 to 15 do 
{
	sleep 0.5;
	_pos call SYG_fountin;
};
true