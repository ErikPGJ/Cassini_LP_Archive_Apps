

time_ymd = fromepoch(t_Ne(1)); % convert from epoch for the file name
load('../../Cassini_LP_DATA_Archive/Cnt_CurDat/spikelog.mat', ...
    sprintf('spikelog_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3))));
