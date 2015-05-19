%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cassini_LP_Archive_Apps/:
%
% README.txt
%   - this file
%
% readme_LP_cntcurr_archi.txt
%   - more detailed description of the continuous current density part
%   apart from the description, contains a list of gaps in DBH cont. current density data
%
% readme_LP_sweep_archi.txt
%   - more detailed description of the sweep part,
%   apart from the description, contains a list of gaps in DBH sweep data
%
% *_times.dat
%   - times of events ([YEAR MM DD hh mm 00]) from EventsTable, apoapse (=start of Rev) and times of closest approach for all moons there is close approach to
%   used for the reading routine
%
% Cassini_LP_DATA_Archive/LP_Swp_Clb
%   - contains the LP sweep data files named "LP_archive_YYYYDOY.dat",
%   the data is stored as [YYYY MM DD hh mm ss U_bias current],
%   currernt is already calibrated
%
% Cassini_LP_DATA_Archive/LP_Swp_Clb/spikelog.mat
%   - contains the cut out data (negative spikes in time vector),
%   saved in a variable for each day for bias and current
%   named "spikelog_Ubias_YEARDOY" and "spikelog_current_YEARDOY" respectively
%
% Cassini_LP_DATA_Archive/LP_Swp_Clb/spikelog_sweep_bias.dat
%   - contains the dates where negative spikes in time vector of sweep data were found, dates saved as [YEAR MM DD DOY]
%
% Cassini_LP_DATA_Archive/LP_Swp_Clb/spikelog_sweep_current.dat
%   - contains the dates where negative spikes in time vector of sweep data were found, dates saved as [YEAR MM DD DOY]
%
% Cassini_LP_DATA_Archive/Cnt_CurDat/
%   - contains the continuous current density data files named "LP_CntCur_YYYYDOY.dat",
%   the data is stored as [YYYY MM DD hh mm ss U_DAC Ne_I]
%   current is already calibrated
%
% Cassini_LP_DATA_Archive/Cnt_CurDat/spikelog.mat
%   - contains the cut out data (negative spikes in time vector),
%   save in a variable for each day named "spikelog_YEARDOY"
%
% Cassini_LP_DATA_Archive/Cnt_CurDat/spikelog_density.dat
%   - contains the dates where negative spikes in time vector of continuous current density data
%   were found, dates saved as [YEAR MM DD DOY]
%
% Cassini_LP_Archive_Apps/
%   - parent directory for all programs used for archiving
%
% Read_LP_Archive.m
%   - a routine for reading data from the saved .dat files
%
% DataPlot.m
%   - plotter, imports events from Read_LP_Archive output, plots with scatter (similar to SweepMap)
%   in progress, not refined yet. does not support mixed voltages (transitions from +/-32 to +/-4V).
%
% DataPlot4sub.m
%   - plotter, imports events (made for fly-bys) and plots with scatter, 4 events per figure
%   prioritizes +/-4V over +/-32V, plotting only one of them (since voltage is not switched during a fly-by)
%   text and plotsizes are not vectorized, meaning that changing figure size will mess up the texts (particularily the header)
%
% Cassini_LP_Archive_Apps/archi/
%       - contains the archiving program for sweep data from Cassini LP and
%       required sub-routines from /home/jwe/Matlab/Cassini/Sweep_Save
%
% Cassini_LP_Archive_Apps/archi/Run_LP_Archi.m
%           - the main program for extracting and storing LP sweep data
%           calls Read_Sweep.m (see readme_LP_sweep_archi.txt for details)
%
% Cassini_LP_Archive_Apps/archi/Read_Sweep.m
%           - modified Read_Sweep_mm.m (original by M. Morooka)
%           extracts sweeps from DBH, removes negative spikes in time vectors of
%           bias and current data (removed data is stored in "/archi/spikelog.mat",
%           separate files for Ubias and current), calibrates and returns
%           NOTE: does nothing with plateus, storing ALL good measurements
%           also handy for manually scanning specific dates to pin-point errors, gaps etc
%
% Cassini_LP_Archive_Apps/archi/SaveSw.m
%           - simple program for manual saving of sweep data from one day
%           Read_Sweep.m must be run to get output variables to save
%           (see description in SaveSw.m for details)
%
% Cassini_LP_Archive_Apps/archi/Read_Sweep_34.m
%           - an exact copy of Read_Sweep.m except for using DBH port 34 instead of 33,
%           intended for running manual scan of the days with gaps for pinpointing the gaps
%           for running with port 34 on auto, change the value in Run_LP_Archi.m
%           DBH port 34 goes dead (doesn't restart) after few runs, making this one useless for now...
%
% Cassini_LP_Archive_Apps/archi/SpikeScan.m
%           - scan all existing files within specified time interval for negative time spikes
%           returns corresponding dates to re-run
%           NOTE:   - wrote this one after discovering an imperfection in the Read_Sweep.m
%                   spike removing algorithm and had to check if program missed anything
%                   from before the fix
%
% Cassini_LP_Archive_Apps/archi/nodata_log.dat
%           - contains the [YYYY MM DD hh mm ss] of the days with no data
%
% Cassini_LP_Archive_Apps/cnt_cur
%       - contains program for extracting continuous current density date from Cassini LP
%       and required sub-routines from /home/jwe/Matlab/Cassini/Density
%
% Cassini_LP_Archive_Apps/cnt_cur/Run_Cnt_Curr.m
%           - the main program for extracting and storing LP cont. current density data
%           calls Read_Density.m (see readme_LP_cntcurr_archi.txt for details)
%
% Cassini_LP_Archive_Apps/cnt_cur/Read_Density.m
%           - modified Process.m (original in /home/jwe/Matlab/Cassini/Density,
%           copy in cnt_cur_draft folder), extracts cont. current density data from DBH,
%           removes bad values of U_DAC, plots U_DAC and Ne_I vs time (optional)
%           also handy for manually scanning specific dates to pin-point errors, gaps etc
%           UPDATE: now includes time-spike removing, removed data is stored in "/cnt_cur/spikelog.mat"
%           format of removed data is [t(epoch) U_DAC Ne_I] (in one variable since U_DAC is generated to match Ne_I, not measured with its own time vector)
%
% Cassini_LP_Archive_Apps/cnt_cur/SaveCCD.m
%           - simple program for manual saving of Cont. Current Density (CCD) data from one day
%           Read_Density.m must be run to get output variables to save
%           (see description in SaveCCD.m for details)
%
% Cassini_LP_Archive_Apps/cnt_cur/SpikeScan.m
%           - same as the one in /archi/ but modded to scan the CCD files.
%           created it after discovering negative spikes in data from 2008-3-22
%           (which had an error, possibly related to the neg.spike, investigating...)
%           returns variable spikelog containing [YYYY MM DD hh mm ss] that had spikes
%           and saves spikelog as .dat (spikelog.dat)
%
% Cassini_LP_Archive_Apps/cnt_cur/Spike_Removal_Tool.m
%           - loads files corresponding to dates listed in spikelog variable (or spikelog.dat)
%           removes spikes (same routine as for sweeps, taken from /archi/Read_Sweep.m)
%           saves spike-free CCD data (re-writes old dat-file)
%
% Cassini_LP_Archive_Apps/cnt_cur/ScanFSize.m
%           - a simple program for scanning the cont. current density filesizes
%           (of LP_CntCur_YYYYDOY.dat), prints a list of the files larger than
%           10 MB (burst-mode) and corresponding dates
%
%




NOTE: THESE DAYS WILL NEED TO BE RE-RUN IF/WHEN THE MISSING HOURS ARE FILLED IN!
ALSO - there are different gaps for CCD and Sweep, see respective readmes for the gap lists.
(Gaps in Density data files while Sweep data files exist, so possibly wrong data)

Gaps from density (Cassini CONTENTS) >= 12h
18-Aug-1999 23:00:24 - 01-Jan-2004 01:00:39
08-Jan-2004 20:00:06 - 09-Jan-2004 13:00:13
18-Jan-2004 10:00:08 - 19-Jan-2004 00:00:08
20-Jan-2004 19:00:07 - 28-Jan-2004 00:00:03
31-Jan-2004 05:00:00 - 01-Feb-2004 18:00:00
02-Feb-2004 08:00:00 - 14-May-2004 18:00:03
08-Jul-2004 22:00:46 - 10-Jul-2004 03:04:45
11-Jul-2004 03:00:29 - 11-Jul-2004 17:11:39
06-Jan-2005 11:00:00 - 15-Jan-2005 09:30:56
23-Apr-2005 23:00:03 - 29-Apr-2005 10:00:00
05-Sep-2005 23:00:00 - 06-Sep-2005 11:15:26
07-Sep-2005 08:00:00 - 08-Sep-2005 02:50:48
16-Apr-2006 21:00:01 - 19-Apr-2006 00:00:01
13-Oct-2006 22:00:15 - 14-Oct-2006 10:01:04
21-Feb-2007 10:00:00 - 22-Feb-2007 02:49:24
22-Feb-2007 12:00:07 - 23-Feb-2007 01:12:06
03-Apr-2007 07:00:32 - 03-Apr-2007 21:34:41
04-Apr-2007 07:00:32 - 05-Apr-2007 03:58:18
11-Sep-2007 05:00:09 - 15-Sep-2007 17:45:48
26-Sep-2007 20:00:02 - 27-Sep-2007 13:39:22
07-Oct-2007 00:00:02 - 17-Oct-2007 01:00:53
13-Dec-2007 16:00:31 - 14-Dec-2007 09:03:23
18-Dec-2008 08:00:25 - 18-Dec-2008 23:58:52
03-May-2009 23:00:56 - 05-May-2009 00:19:21
09-Aug-2009 01:00:04 - 09-Aug-2009 19:08:20
15-Sep-2009 22:00:53 - 16-Sep-2009 13:49:03
20-Dec-2009 09:00:10 - 21-Dec-2009 00:42:22
18-Apr-2010 15:00:33 - 19-Apr-2010 09:03:28
21-Jun-2010 17:00:14 - 25-Jun-2010 21:11:21
02-Nov-2010 21:00:02 - 15-Nov-2010 17:25:49
04-Dec-2010 01:00:02 - 05-Dec-2010 11:54:23
24-Jan-2011 08:00:07 - 25-Jan-2011 13:14:30
13-Aug-2011 15:00:20 - 14-Aug-2011 17:07:20


Gaps from density >= 23h
18-Aug-1999 23:00:24 - 01-Jan-2004 01:00:39
20-Jan-2004 19:00:07 - 28-Jan-2004 00:00:03
31-Jan-2004 05:00:00 - 01-Feb-2004 18:00:00
02-Feb-2004 08:00:00 - 14-May-2004 18:00:03
08-Jul-2004 22:00:46 - 10-Jul-2004 03:04:45
06-Jan-2005 11:00:00 - 15-Jan-2005 09:30:56
23-Apr-2005 23:00:03 - 29-Apr-2005 10:00:00
16-Apr-2006 21:00:01 - 19-Apr-2006 00:00:01
11-Sep-2007 05:00:09 - 15-Sep-2007 17:45:48
07-Oct-2007 00:00:02 - 17-Oct-2007 01:00:53
03-May-2009 23:00:56 - 05-May-2009 00:19:21
21-Jun-2010 17:00:14 - 25-Jun-2010 21:11:21
02-Nov-2010 21:00:02 - 15-Nov-2010 17:25:49
04-Dec-2010 01:00:02 - 05-Dec-2010 11:54:23
24-Jan-2011 08:00:07 - 25-Jan-2011 13:14:30
13-Aug-2011 15:00:20 - 14-Aug-2011 17:07:20




