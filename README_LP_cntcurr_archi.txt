%% readme for Cassini_LP_Archive_Apps/cnt_cur/Run_Cnt_Curr %%

The data is already calibrated.
filename generator: LP_CntCur_YEARDOY.dat
data format is: [YYYY MM DD hh mm ss bias current] all numbers are saved with 6 digits, SPACE delimiter
units: [years    months  days    hours   minutes seconds volts   ampers]
Files are saved in the  Cassini_LP_DATA_Archive/
(full path is printed out as the file is being written)
UPDATE: the program now includes code for removing spikes in time, imported from Spike_Removal_Tool.m in then /cnt_cur/ directory

The HOW-TO:
- go to directory Cassini_LP_Archive_Apps/cnt_cur/
- Run "Run_Cnt_Curr.m"
- enter start date as [YYYY MM DD 0 0 0]
- and end date as [YYYY DD MM 0 0 0] (end date being the last day to run)
- approximate execution time is hard to estimate, data is either very scarce or very dense, taking ~15s or ~2min per day to process.
- data with negative spikes in time is cut out and saved in /cnt_cur/spikelog.mat as variables named spikelog_YEADDOY (re-running a day replaces the variable, running new days appends variables to the .mat)
- sit back and enjoy automatization...or at least until an error occurs.

IMPORTANT: Currently there is a glitch in DBH files and file 2001-4-22 11:00:11.76 - 12:... has DURATION of almost 15 years.
IF the glitch is present in CONTENTS/DURATION, a warning will come up. To abort, type N (DEFAULT!), to cut out the glitch data and continue, type Y.

Errors encountered are due to something happening between the files (DBH), so between the hours.
The program will not save empty files, instead skipping dates with no data.
Hence, start date and end date are completely arbitrary (but within the CONTENTS of course).

RUNNING MANUALLY DURING GAPS:
Run Read_Density.m and locate the gap (you will get errors from DBH if the time interval contains the gap, so just run different intervals to locate the gap)
After the gap is located (see list of times below for examples):
- clear workspace 
- run Read_Density.m from the beginning of the day until the gap
- run getspikelog.m
- duplicate all variables in the workspace (select all, right-click, duplicate)
- run Read_Density.m from the end of gap until the end of the day
- run getspikelog.m
- note that now variables from first part of the day are named *Copy
- run SaveCCD.m to combine the data and the spikelog for the whole day

Here's a list of such "gaps" so far:
(If the problem in DBH is fixed these days should be re-run to fill in possible data in the missing hours!)
NOTE: if more than 1 gap per day, marked by *, **, *** and so on
      if there were neg.spikes in the data, marked by ~

2003-11-21 18:00:00 - 18:00:01 ~ first gap since 1999-8-18
2003-11-27 23:00:00 - 23:00:01
2004-6-24 16:00:11 - 16:00:12
2004-7-13 12:00:10 - 12:00:11
2004-9-29 16:00:12 - 16:00:13
2005-11-26 23:00:00 - 23:00:01  last hour empty (23 - 00)
2007-5-17 15:00:01 - 15:00:02
2007-5-23 00:00:07 - 00:00:08 first hour empty (00 - 01)
2007-10-28 22:00:09 - 22:00:10 ~
2007-11-19 07:00:01 - 07:00:02
2008-3-22 09:00:00 - 09:00:01 ~ - ERROR:  In an assignment  A(:) = B, the number of elements in A and B
must be the same. Error in Read_Density (line 130): I(pts_ind) = Clean_Density( I(pts_ind), t(pts_ind) );
traced it to an error in Clean_Density, the input vectors (I, t) had only 2 values each and Clean_Density made the output vector of length 7, causing the error. Manually set those 2 input values to NaN and manually saved that hour in the correct file.
also negative time spikes here...
2008-3-24 09:00:01 - 09:00:02 ~
2008-5-17 19:00:02 - 19:00:03 ~
2008-6-9 04:00:00 - 04:00:01 ~
2008-6-30 09:00:00 - 09:00:01 ~
2008-9-24 17:00:01 - 17:00:02
2008-10-31 14:00:00 - 14:00:01 ~
2008-12-12 07:00:03 - 07:00:04
2009-1-4 01:59:58 - 01:59:59 ~
2009-1-23 06:59:58 - 06:59:59 ~ * since it's neighbouring hours, doesn't find any data betweeb 7 and 8
2009-1-23 07:59:58 - 07:59:59 ~ **
2009-2-1 18:00:00 - 18:00:01
2010-5-22 15:59:57 - 15:59:58
2010-8-4 12:00:01 - 12:00:02

The extremely large files are burst-mode, run ScanFSize.m to get a full list of the days and corresponding files.
