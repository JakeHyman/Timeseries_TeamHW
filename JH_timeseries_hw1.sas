/*
Name: Jacob Hyman
Date: 08/30/2020
Objective: run single esm (seasonal), and double esm (brown) on monthly timeseries ozone data*/


libname tshw "/opt/sas/home/jbhyman/sasuser.viya/time_series_fall_1/HW/data";

proc import datafile= "/opt/sas/home/jbhyman/sasuser.viya/time_series_fall_1/HW/data/Ozone_Raleigh2.csv"
			dbms=csv out= tshw.Ozone_Raleigh replace;

proc contents data=tshw.ozone_raleigh (obs=5);
run;

/*creates training, validation and test datasets*/

data tshw.ozonetrain;
	set tshw.ozone_raleigh;
	keep  date year month month_year Daily_Max_8_hour_Ozone_Concentra;
	where date between '01JAN2014'd and '31DEC2018'd;
	month = month(date);
	year = year(date);
	month_year = (mdy(month, 1, year));
	format month_year yymms7.;
run;
data tshw.ozonevalid;
	set tshw.ozone_raleigh;
	keep  date year month month_year Daily_Max_8_hour_Ozone_Concentra;
	where date between '01JAN2019'd and '31DEC2019'd;
	month = month(date);
	year = year(date);
	month_year = (mdy(month, 1, year));
	format month_year yymms7.;
run;
data tshw.ozonetest;
	set tshw.ozone_raleigh;
	keep date year month month_year Daily_Max_8_hour_Ozone_Concentra;
	where date between '01JAN2020'd and '31MAY2020'd;
	month = month(date);
	year = year(date);
	month_year = (mdy(month, 1, year));
	format month_year yymms7.;
run;

/*generates monthly data*/

/*__________training set________________*/

proc means data=tshw.ozonetrain mean std;
	class month_year;
	var Daily_Max_8_hour_Ozone_Concentra;
	output out=tshw.ozonetrain_monthly;
run;

data tshw.ozonetrain_monthly replace;
	set tshw.ozonetrain_monthly;
	where _STAT_ = "MEAN";
	if month_year=. then delete;
run;
/*___________validation set______________*/

proc means data=tshw.ozonevalid mean std;
	class month_year;
	var Daily_Max_8_hour_Ozone_Concentra;
	output out=tshw.ozonevalid_monthly;
run;

data tshw.ozonevalid_monthly replace;
	set tshw.ozonevalid_monthly;
	where _STAT_ = "MEAN";
	if month_year=. then delete;
run;

/*___________test set______________*/

proc means data=tshw.ozonetest mean std;
	class month_year;
	var Daily_Max_8_hour_Ozone_Concentra;
	output out=tshw.ozonetest_monthly;
run;

data tshw.ozonetest_monthly replace;
	set tshw.ozonetest_monthly;
	where _STAT_ = "MEAN";
	if month_year=. then delete;
run;

/*create timeseries models on training dataset*/
proc print data =tshw.ozonetrain_monthly (obs=5);
run;

proc timeseries data=tshw.ozonetrain_monthly plots=(series decomp sc);
	id month_year interval=month;
	var Daily_Max_8_hour_Ozone_Concentra;
run;

/*creates 12 month forcast using single seasonal model*/
proc esm data=tshw.ozonetrain_monthly print=all plot=all lead=12 outfor=tshw.pred_single_seasonal;
	forecast Daily_Max_8_hour_Ozone_Concentra / model=seasonal;
	id month_year interval=month;
run;

/*creates 5 month forcast using double esm (brown) model*/
proc esm data=tshw.ozonetrain_monthly print=all plot=all lead=12 outfor=tshw.pred_double_brown;
	forecast Daily_Max_8_hour_Ozone_Concentra / model=double;
	id month_year interval=month;
run; 

/*calculate the MAPE for the standard model 
calculated wrong!! */

data tshw.single_seasonal_forcast;
	set tshw.pred_single_seasonal;
	if missing(ACTUAL);
	format month_year YYMMS7.;
run;
data tshw.single_seasonal_score;
	merge tshw.single_seasonal_forcast tshw.ozonevalid_monthly;
	by month_year;
	ABS = abs(Daily_Max_8_hour_Ozone_Concentra - PREDICT);
run;

proc means data=tshw.single_seasonal_score mean;
	var ABS;
run;


/*calculate the MAPE for the brown model*/

data tshw.double_brown_forcast;
	set tshw.pred_double_brown;
	if missing(ACTUAL);
	format month_year YYMMS7.;
run;

proc print data=tshw.double_brown_forcast;
run;

data tshw.double_brown_score;
	merge tshw.double_brown_forcast tshw.ozonevalid_monthly;
	by month_year;
	ABS = abs(Daily_Max_8_hour_Ozone_Concentra - PREDICT);
run;

proc means data=tshw.double_brown_score mean;
	var ABS;
run;

proc means data=tshw.double_brown_score mean;
	var ABS;
run;
