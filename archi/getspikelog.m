

time_ymd = fromepoch(t_sweep(1)); % convert from epoch for the file name
load('../../Cassini_LP_DATA_Archive/LP_Swp_Clb/spikelog.mat', ...
    sprintf('spikelog_current_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3))));
load('../../Cassini_LP_DATA_Archive/LP_Swp_Clb/spikelog.mat', ...
    sprintf('spikelog_Ubias_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3))));

