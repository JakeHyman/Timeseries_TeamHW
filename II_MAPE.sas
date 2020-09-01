/* import necessary csv file */
proc import datafile="/opt/sas/home/giingle/sasuser.viya/summarystat_sum2/Ozone_Raleigh2.csv"
			out = ts.ozone dbms=csv replace;
run;

/* Rename cumbersome target variable name */
data ts.ozone;
	set ts.ozone;
	month = month(date);
	year = year(date);
	rename 'Daily Max 8-hour Ozone Concentra'n=oz;
run;

/* Convert daily data into monthly data with the observations from the daily oz values now averaged across each individual month */
proc expand data=ts.ozone out=ts.monthly_ozone from=day to=month;
	id date;
	convert oz / observed= average;
run;

/* Check that the proc expand worked for creating monthly averages for all of the data */
proc sort data= ts.ozone;
	by year;
run;

proc means data = ts.ozone;
	by year;
	var oz;
	class month;
run;
/* It seems to line up so we can now proceed confidently with creating our various splits  */

/* Create training, validation, and test sets in this datastep */
data ts.oz_train_valid ts.oz_test;
	set ts.monthly_ozone;
	if date < '01JAN2020'd then output ts.oz_train_valid;
	else output ts.oz_test;
run;

/* Find a 13.51% MAPE on validation set and 5.64% on training with Additive Winters model  */
proc esm data=ts.oz_train_valid print=all plot=all
			seasonality=12 lead=12 back=12 outfor=test;
		forecast oz / model=addwinters;
run;

/* Find a 5.96% MAPE on validation set but curiously a 6.56% MAPE on training set with Multiplicative Winters model  */
proc esm data=ts.oz_train_valid print=all plot=all
			seasonality=12 lead=12 back=12 outfor=test;
		forecast oz / model=winters;
run;

/* Double-check esm procedure's MAPE and find they agree */
data test2;
	set test;
	if _timeid_ > 60;
	abs_err = abs(error);
	abs_err_obs = abs_err/actual;
run;

proc means data= test2 mean;
	var abs_err_obs abs_err;
run;

/* Find a 6.72% MAPE on validation set and a 5.82% MAPE on training set with Additive Seasonal model  */
proc esm data=ts.oz_train_valid print=all plot=all
			seasonality=12 lead=12 back=12 outfor=test;
		forecast oz / model=addseasonal;
run;