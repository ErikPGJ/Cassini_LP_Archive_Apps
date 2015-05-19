time = input('Enter [year doy] : ');
time = toepoch([doy2date(time(1),time(2)) 0 0 0]);

DBH=Connect2DBH('titan.irfu.se',33); % Connect to ISDAT
[CONTENTS,DURATION]=isGetContentLite(DBH,'Cassini','','lp','','','','');; % Get full contents list
if ~isempty(DURATION(DURATION > 7200)) % check DURATION for anomalies (should not be larger than 3600s)
    warning('WARNING! Found DURATION > 1h10m!');
    disp('Date (CONTENTS)         DURATION');
    disp([datestr(CONTENTS(DURATION > 7200,:), 'yyyy-mm-dd HH:MM:SS') '     ' num2str(DURATION(DURATION > 7200))]);
    check = input('Proceed? Y/N [N]: ','s');
    if isempty(check) || check == 'N'
        disp('Aborted by user');
        return;
    end
    if check == 'Y'
        disp('cutting out anomaly in DURATION and CONTENTS');
        CONTENTS(DURATION > 7200,:) = [];
        DURATION(DURATION > 7200) = [];
    end
end



t_sweep = []; U_sweep = []; I_sweep = [];
for h = 0:3600:82800
    try
        [t_temp, U_temp, I_temp] = Read_Sweep([fromepoch(time+h); fromepoch(time+h+3600)], DBH, CONTENTS, DURATION);
    catch
        DBH = Connect2DBH('titan.irfu.se', 33); % Connect to ISDAT
        continue
    end
        I_sweep = [I_sweep; I_temp]; U_sweep = [U_sweep; U_temp]; t_sweep = [t_sweep; t_temp];
end
%[t_temp U_temp I_temp] = Read_Sweep([2012 12 5 23 0 0; 2012 12 6 0 0 0], DBH, CONTENTS, DURATION);
%I_sweep = [I_sweep; I_temp]; U_sweep = [U_sweep; U_temp]; t_sweep = [t_sweep; t_temp];

time_s = fromepoch(t_sweep(1));
datapath = '../../Cassini_LP_DATA_Archive/';
apppath = '../../Cassini_LP_Archive_Apps/';

filename = [datapath, sprintf('LP_Swp_Clb/LP_archive_%4d%03d.dat', time_s(1), date2doy(time_s(1:3)))];
if exist(filename, 'file') == 2
    % ovwrt = input('File exists, overwrite? (Enter = Yes/N = no) ');
    if 1 %~isempty(ovwrt)
        disp(['Not overwriting ' datestr(time_s, 'yyyy-mm-dd')]);
        break
    end
end

whos('t_sweep', 'U_sweep', 'I_sweep')

if input('Save? 1 = yes : ')
    
    disp(['Writing file: ' filename ' ...']);
    fid4 = fopen(filename, 'w'); fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_sweep) U_sweep I_sweep]'); fclose(fid4);
    %dlmwrite(filename, [fromepoch(t_sweep) U_sweep I_sweep], 'delimiter', '\t', 'precision', 6);
    filesize = dir(filename);
    filesize = filesize.bytes/1024/1024;
    %data_log = [data_log; time_s];
    disp(['Done. File size: ', num2str(filesize), ' MB']);
end