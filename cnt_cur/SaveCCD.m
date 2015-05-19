% manually save data from specific day (Read_Density.m must be run first!)

% this line is optional, intended for adding the pre-gap data (*Copy) to post-gap data
% to get the *Copy-s, run Read_Density.m for the time period before the gap,
% select all the output variables in the workspace, right-click ->  Duplicate

t_Ne = [t_NeCopy; t_Ne]; Ne_I = [Ne_ICopy; Ne_I]; U_DAC = [U_DACCopy; U_DAC];
time_ymd = fromepoch(t_Ne(1)) % convert from epoch for the file name
datapath = '../../Cassini_LP_DATA_Archive/';

% generating variable name "spikelog_YYYYDOY" and saving it in a .mat log
if exist(sprintf('spikelog_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3))), 'var')
    logvar = genvarname(sprintf('spikelog_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3))));
    logCopy = genvarname(sprintf('spikelog_%4d%03dCopy', time_ymd(1), date2doy(time_ymd(1:3))));
    eval([logvar '=[' logvar ';' logCopy '];']);
    save([datapath, 'Cnt_CurDat/spikelog.mat'], logvar, '-append');
    disp(['Anomaly saved in ' logvar]);
end




% 86400 seconds in a day
filename = [datapath, sprintf('Cnt_CurDat/LP_CntCur_%4d%03d.dat', time_ymd(1), date2doy(time_ymd(1:3)))]
disp(['Writing file: ' filename ' ...']);
fid4 = fopen(filename, 'w'); fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_Ne) U_DAC Ne_I]'); fclose(fid4);
%dlmwrite(filename, [fromepoch(t_Ne) U_DAC Ne_I], 'delimiter', '\t', 'precision', 6);
filesize = dir(filename);
filesize = filesize.bytes/1024/1024;
disp(['Done. File size: ', num2str(filesize), ' MB']);