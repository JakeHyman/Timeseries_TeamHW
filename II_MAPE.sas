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
proc timeseries data=ts.ozone out=ts.mon_oz;
	id date interval=month accumulate=average;
	var oz;
run;

/* Create training, validation, and test sets in this datastep */
data ts.oz_train_valid ts.oz_test;
	set ts.mon_oz;
	if date < '01JAN2020'd then output ts.oz_train_valid;
	else output ts.oz_test;
run;

/* Find a 6.53% MAPE on validation set and 5.64% on training with Additive Winters model  */
proc esm data=ts.oz_train_valid print=all plot=all
			seasonality=12 lead=12 back=12 outfor=test;
		forecast oz / model=addwinters;
run;

/* Find a 5.81% MAPE on validation set but curiously a 6.56% MAPE on training set with Multiplicative Winters model  */
/* this is found as the best model by a reasonably comfortable amount so proceed with this one for testing set */
proc esm data=ts.oz_train_valid print=all plot=all
			seasonality=12 lead=12 back=12 outfor=test;
		forecast oz / model=winters;
run;

/* Find a 6.68% MAPE on validation set and a 5.82% MAPE on training set with Additive Seasonal model  */
proc esm data=ts.oz_train_valid print=all plot=all
			seasonality=12 lead=12 back=12 outfor=test;
		forecast oz / model=addseasonal;
run;

/* check the best model (winters multiplicative) with the full data set now */
/* and calculate the MAPE for the last 5 months (test set now) */
proc esm data=ts.mon_oz print = all plot = all 
		seasonality=12 lead=5 back=5 outfor=test;
		forecast oz / model=winters;
run;