#define ROUND2(val) (round((val)*100.0)/100.0)
#define ROUND4(val) (round((val)*10000.0)/10000.0)
#define ROUND0(val) (round(val))
#define arg(num) (_this select(num))
#define argp(arr,num) ((arr)select(num))
#define argopt(num,val) (if((count _this)<=(num))then{val}else{arg(num)})
#define inc(x) x=x+1

_unit = _this select 0;
_this = _this select 3;

_hour   = argopt(0,22);
_min = argopt(1,30);

_date = date;
_date set [3, _hour];
_date set [4, _min];
setDate _date;
if ( true ) exitWith {_cnt};