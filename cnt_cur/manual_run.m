time = input('Enter [year doy] : ');
time = toepoch([doy2date(time(1),time(2)) 0 0 0]);

CA = Setup_Cassini;
CA.DBH=Connect2DBH(CA.DBH_Name,CA.DBH_Ports); % Connect to ISDAT
[CA.CONTENTS,CA.DURATION]=GetContents(CA); % Get full contents list

% if ~isempty(CA.DURATION(CA.DURATION > 7200)) % check DURATION for anomalies (should not be larger than 3600s)
%     warning('WARNING! Found DURATION > 1h10m!');
%     disp('Date (CONTENTS)         DURATION');
%     disp([datestr(CA.CONTENTS(CA.DURATION > 7200,:), 'yyyy-mm-dd HH:MM:SS') '     ' num2str(CA.DURATION(CA.DURATION > 7200))]);
%     check = input('Proceed? Y/N [N]: ','s');
%     if isempty(check) || check == 'N'
%         disp('Aborted by user');
%         return;
%     end
%     if check == 'Y'
%         disp('cutting out anomaly in DURATION and CONTENTS');
%         CA.CONTENTS(CA.DURATION > 7200,:) = [];
%         CA.DURATION(CA.DURATION > 7200) = [];
%     end
% end
[CA.CONTENTS, CA.DURATION] = check_DURATION(CA.CONTENTS, CA.DURATION, 'interactive');

t_Ne = []; U_DAC = []; Ne_I = [];
for h = 0:3600:82800
    try
        [t_Ne_temp, U_DAC_temp, Ne_I_temp] = Read_Density(CA,time+h, time+h+3600);
    catch
        CA.DBH = Connect2DBH('titan.irfu.se', 33); % Connect to ISDAT
        continue
    end
        Ne_I = [Ne_I; Ne_I_temp]; U_DAC = [U_DAC; U_DAC_temp]; t_Ne = [t_Ne; t_Ne_temp];
end

datapath = '../../Cassini_LP_DATA_Archive/';
apppath = '../../Cassini_LP_Archive_Apps/';

whos('t_Ne', 'U_DAC', 'Ne_I')

if input('Save? 1 = yes : ')
    time_ymd = fromepoch(t_Ne(1)); % convert from epoch for the file name
    % 86400 seconds in a day
    filename = [datapath, sprintf('Cnt_CurDat/LP_CntCur_%4d%03d.dat', time_ymd(1), date2doy(time_ymd(1:3)))];
    disp(['Writing file: ' filename ' ...']);
    fid4 = fopen(filename, 'w'); fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_Ne) U_DAC Ne_I]'); fclose(fid4);
    %dlmwrite(filename, [fromepoch(t_Ne) U_DAC Ne_I], 'delimiter', '\t', 'precision', 6);
    filesize = dir(filename);
    filesize = filesize.bytes/1024/1024;
    disp(['Done. File size: ', num2str(filesize), ' MB']);
end