% manually save data from specific day (Read_Sweep.m must be run first!)

% this line is optional, intended for adding the pre-gap data (*Copy) to post-gap data
% to get the *Copy-s, run Read_Sweep.m for the time period before the gap,
% select all the output variables in the workspace, right-click ->  Duplicate

% first run getspikelog.m to get the variables, duplicate them and then run
% the code


t_sweep = [t_sweepCopy; t_sweep]; U_sweep = [U_sweepCopy; U_sweep]; I_sweep = [I_sweepCopy; I_sweep];
time_ymd = fromepoch(t_sweep(1)) % convert from epoch for the file name

datapath = '../../Cassini_LP_DATA_Archive/';

% generating variable name "spikelog_current_YYYYDOY" and saving it in a .mat log
if exist(sprintf('spikelog_current_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3))), 'var')
    Ilogvar = genvarname(sprintf('spikelog_current_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3))));
    IlogCopy = genvarname(sprintf('spikelog_current_%4d%03dCopy', time_ymd(1), date2doy(time_ymd(1:3))));
    eval([Ilogvar '=[' Ilogvar ';' IlogCopy '];']);
    save([datapath, 'LP_Swp_Clb/spikelog.mat'], Ilogvar, '-append');
end

% generating variable name "spikelog_Ubias_YYYYDOY" and saving it in a .mat log
if exist([datapath, sprintf('spikelog_Ubias_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3)))], 'var')
    Ulogvar = genvarname( [datapath, sprintf('spikelog_Ubias_%4d%03d', time_ymd(1), date2doy(time_ymd(1:3)))] );
    UlogCopy = genvarname( [datapath, sprintf('spikelog_Ubias_%4d%03dCopy', time_ymd(1), date2doy(time_ymd(1:3)))] );
    eval([Ulogvar '=[' Ulogvar ';' UlogCopy '];']);
    save([datapath, 'LP_Swp_Clb/spikelog.mat'], Ulogvar, '-append');
end


filename = [datapath, sprintf('LP_Swp_Clb/LP_archive_%4d%03d.dat', time_ymd(1), date2doy(time_ymd(1:3)))]

if exist(filename, 'file') == 2
    ovwrt = input('File exists, overwrite? (Enter = Yes/N = no) ');
    if ~isempty(ovwrt)
        %disp(['Skipping ' datestr(time_s, 'yyyy-mm-dd')]);
        return
    end
end


disp(['Writing file: ' filename ' ...']);
fid4 = fopen(filename, 'w'); fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_sweep) U_sweep I_sweep]'); fclose(fid4);
%dlmwrite(filename, [fromepoch(t_sweep) U_sweep I_sweep], 'delimiter', '\t', 'precision', 6);
filesize = dir(filename);
filesize = filesize.bytes/1024/1024;
disp(['Done. File size: ', num2str(filesize), ' MB']);