/*
Name: Jacob Hyman 
Date: 09/15/20
Objective: see if there is autocorrelation in the training dataset.
Remove whatever autocorrelation is present and check if ARIMA 
reduces model to white nosie*/


proc contents data=tshw.ozonetrain_monthly;
run;

/*
Task 1: Check the stationarity of the average monthly Ozone levels 
	including any potential trend and/or random walks; 
	the analysts recommend using the Augmented Dickey-Fuller tests
	up to lag 2 tests for the results, however, 
	you are welcome to suggest other techniques
	as long as the reasons are clearly stated and supported*/

proc arima data=tshw.ozonetrain_monthly plots=all;
	identify var=Daily_Max_8_hour_Ozone_Concentra nlag=10 stationarity=(adf=2);
run;
quit;

/*random walk is present
Single Mean is most appropriate for this model*/


/*
Task 2: What strategies (if any) should the client take to make the data stationary (the EPA
	would like to consider only non-seasonal options at this time, however, feel free to
	discuss recommendations)?*/

/*taking the first difference removes autocorrelation for Trend and Single Mean*/
proc arima data=tshw.ozonetrain_monthly plots=all;
	identify var=Daily_Max_8_hour_Ozone_Concentra(1) nlag=10 stationarity=(adf=2);
run;
quit;

/*checks to see if trend is present, it doesn't look like it is*/
data newvar;
	set tshw.ozonetrain_monthly;
	time = _n_;
run;

proc reg data = newvar;
	model Daily_Max_8_hour_Ozone_Concentra = time;
run;
quit;
/*almost no correlation between time and Daily_Max*/
/*Pr > F = 0.8214*/
/*R^2 = 0.0009*/

proc arima data=newvar plots=all;
	identify var=Daily_Max_8_hour_Ozone_Concentra crosscorr=time;
	estimate input=time;
run;
quit;



/*Does the stationary time series exhibit white noise?
 Provide evidence on whether it
does or does not have white noise and the implications for 
future ARIMA modeling.*/

/*autocorrelation is reduced by taking 1 diff, but there is still 
significant autocorrelation present due to the seasonality of the data*/
proc arima data=tshw.ozonetrain_monthly plots=all;
	identify var=Daily_Max_8_hour_Ozone_Concentra(1) nlag=10;
	estimate method=ml;
run; 
quit;

/*check to see if you can also fit an MA model to the data*/
proc arima data=tshw.ozonetrain_monthly plots=all;
	identify var=Daily_Max_8_hour_Ozone_Concentra(1) nlag=10;
	estimate q=2 method=ml;
run;
quit;
