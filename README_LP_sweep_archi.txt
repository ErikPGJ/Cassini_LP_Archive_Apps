%% readme for Cassini_LP_Archive_Apps/archi/Run_LP_Archi.m %%

The data is already calibrated.
filename generator: LP_archive_YEARDOY.dat
data format is: [YYYY MM DD hh mm ss U_bias current] all numbers are saved with 6 digits, SPACE delimiter
units: [years    months  days    hours   minutes seconds volts   ampers]
Files are saved in the  Cassini_LP_DATA_Archive/LP_Swp_Clb/
(full path is printed out as the file is being written)


The HOW-TO:
- go to directory Cassini_LP_Archive_Apps/archi/
- Run "Run_LP_Archi.m"
- enter start date as [YYYY MM DD]
- and end date as [YYYY DD MM] (end date being the last day to run)
- approximate execution time will be displayed (based on average over all days), Enter to confirm and continue
- data with negative spikes in time is cut out and saved in /archi/spikelog.mat as variables named spikelog_Ubias_YEADDOY and spikelog_current_YEARDOY (re-running a day replaces the variable, running new days appends variables to the .mat)
- sit back and enjoy automatization...or at least until an error occurs.

IMPORTANT: Currently there is a glitch in DBH files and file 2001-4-22 11:00:11.76 - 12:... has DURATION of almost 15 years.
IF the glitch is present in CONTENTS/DURATION, a warning will come up. To abort, type N (DEFAULT!), to cut out the glitch data and continue, type Y.

Errors encountered are due to something happening between the files (DBH), so between the hours.
The program will not save empty files, instead skipping dates with no data.
Hence, start date and end date are completely arbitrary (but within the CONTENTS of course).

RUNNING MANUALLY DURING GAPS:
Run Read_Sweep.m and locate the gap (you will get errors from DBH if the time interval contains the gap, so just run different intervals to locate the gap)
After the gap is located (see list of times below for examples):
- clear workspace 
- run Read_Sweep.m from the beginning of the day until the gap
- run getspikelog.m
- duplicate all variables in the workspace (select all, right-click, duplicate)
- run Read_Sweep.m from the end of gap until the end of the day
- run getspikelog.m
- note that now variables from first part of the day are named *Copy
- run SaveSw.m to combine the data and the spikelog for the whole day



Cassini_LP_DATA_Archive/LP_Swp_Clb/spikelog.mat contains the cut out spike data
variables are named "spikelog_Ubias_YYYYDOY" and "spikelog_current_YYYYDOY" and contain time (epoch) and Ubias resp. time (epoch) and current values
2002-6-12 - possibly first time anomaly (negative spike)

Here's a list of such "gaps" so far:
(If the problem in DBH is fixed these days should be re-run to fill in possible data in the missing hours!)
NOTE: if more than 1 gap per day, marked by *, **, *** and so on
      if negative spike is present too, marked with ~

1997-10-25 11:59:57 - 12:00:01 * ~
1997-10-25 13:00:02 - 13:00:03 **
1997-10-25 19:59:58 - 20:00:03 ***
1997-10-25 22:59:58 - 23:00:03 ****
1999-1-1 05:59:59 - 06:00:01 ~
2001-4-21 10:59:27 - 12:00:06 - first gap since 1999-8-18, whole day is empty
2001-6-11 13:59:52 - 14:00:02 ~
2001-10-27 11:59:22 - 12:00:10
2001-12-6 03:59:59 - 04:00:02
2001-12-14 15:59:58 - 16:00:01
2001-12-31 21:00:00 - 21:00:01
2002-6-27 02:59:54 - 03:00:02
2002-9-10 19:59:28 - 20:00:09
2003-6-28 18:59:45 - 19:00:17
2003-12-22 20:59:51 - 21:00:47
2004-8-13 14:48:55 - 15:00:05 - this one missing a sweep at 14:59:35
2004-9-20 14:59:45 - 15:00:05
2004-10-9 00:56:24 - 01:00:08
2005-7-21 00:59:55 - 01:00:25
2006-5-29 23:59:59 - 2006-5-30 00:00:01
2006-7-12 15:59:49 - 16:00:15
2006-11-17 15:59:54 - 16:00:14
2006-12-12 13:59:53 - 14:00:01 ~
2006-12-27 14:59:53 - 15:00:07
2007-11-19 05:59:33 - 06:00:46 * ~
2007-11-19 07:58:13 - 08:18:55 **
2007-12-8 18:59:49 - 19:00:01
2008-3-24 08:59:59 - 09:00:02
2008-6-16 05:59:59 - 06:00:01
2008-7-12 21:59:57 - 22:00:13
2008-7-31 03:59:51 - 04:00:01 * ~ can be empty between here and next one
2008-7-31 04:58:58 - 05:00:03 **
2008-9-24 17:59:45 - 18:00:01
2008-11-16 15:59:59 - 16:00:01
2008-11-17 01:59:44 - 02:00:01 * can be empty between here and next one
2008-11-17 02:59:59 - 03:00:01 **
2009-1-4 02:59:57 - 02:59:59 ~
2009-1-23 07:59:58 - 07:59:59 * can be empty between here and next one
2009-1-23 08:59:58 - 08:59:59 ** ~
2009-2-1 07:52:27 - 08:20:50 * ~ NOTE: at least 5 gaps, up to several hours, a check-up showed data gaps at Iowa as well, probably maintenance or instrument is off
2009-2-1 12:27:30 - 13:05:47 ** can be empty between here and next one
2009-2-1 13:49:04 - 17:29:00 ***
2009-2-1 18:59:45 - 19:00:00 ****
2009-2-1 21:59:58 - 22:00:01 *****
2009-2-2 03:59:56 - 04:00:05 * ~ can be empty between here and next one
2009-2-2 04:59:55 - 05:00:00 **
2009-2-11 07:59:54 - 08:00:10 * can be empty between here and next one
2009-2-11 08:59:55 - 09:00:01 ** ~
2009-4-20 01:59:57 - 02:00:01
2010-12-29 11:59:57 - 12:00:06
2011-5-8 23:00:07 - 23:00:09 can be empty between here and end of the day
2012-1-28 09:56:03 - 09:02:03 - note that time intervals overlap but probably problem is in the 9h-file, the day is empty though (9h-file is last for the day)
2012-1-29 04:38:37 - 04:38:38

Other notes:
Program freezing on DBH call:
	it has happened that titan.irfu.se stopped responding after a while of running the program. Whether it's an overload in larger batches or a communication issue is not clear.
	Recommendation is thus to run the program 3-4 months at a time, if encountered try restarting Matlab/terminal
	UPDATE: DBH connection might crash because of the connect-spam from Read_Sweep. (it tried to connect each time Read_Sweep is called without DBH	parameter)
	Moved connection to DBH to the Run file and made it call Read_Sweep with a DBH parameter, seemed to fix the issue.
Calibrate returns error: 
	when running years 2009 and 2011 Calibrate returned: "Error using load - unable to read
	LPp_lg_hf.dat ..." but when the process was resumed from the day the error happened everything
	worked again. The dates are 2009-10-21 and 2011-2-24.
	
