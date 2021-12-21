// macros.sqf

#define __addDead( unit ) unit = unit;
#define __GetEGrp( grp )  grp = createGroup west;
#define __WaitForGroup while {!can_create_group} do {sleep 0.1 + random (0.2)};

#define arg(x) (_this select(x))
#define argp(a,x) ((a)select(x))
#define argopt(num,val) if((count _this)<=(num))then{val}else{arg(num)}
