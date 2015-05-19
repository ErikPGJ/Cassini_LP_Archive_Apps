% Run_LP_Archi gets LP data from DBH for a specified time interval, removes
% anomalies, calibrates and saves LP data in a .dat (ASCII) as:
% [YYYY     MM      DD      h       m       s       bias    current]
% [years    months  days    hours   minutes seconds volts   ampers]
% all values are given with 6 significant digits, delimiter is TAB
% filename is /Cassini_LP_DATA_Archive/LP_Swp_Clb/LP_archive_YYYYDOY.dat
%
% Oleg Shebanits, IRFU, 2012-03

start_time = []; end_time = [];
disp('Cassini/RPWS/LP data archiver');
disp('Enter start and end dates for data you wish to archive');
disp('Format: [YYYY MM DD] or [YYYY DOY] (no hh mm ss)');
disp('NOTE: if error, check if date interval begins OR ends when there is no data');
start_time = input('Start date: ');
end_time = input('End date: ');

global datapath apppath
datapath = '../../Cassini_LP_DATA_Archive/';
apppath  = '../../Cassini_LP_Archive_Apps/';

if ~exist(datapath, 'dir') || ~exist(apppath, 'dir')
    datapath
    apppath
    error('Can not find directories. (You might have the wrong current directory.)')
end

% % ------------------------------------
% % TBG is made to run on the whole data except the days with gaps, make it
% % from the list in the readme and uncomment the section (don't forget the
% % END for the loop)
% %
% TBG = [2008 9 25 2008 11 15;
% 2008 11 18 2009 1 3;
% 2009 1 5 2009 1 22;
% 2009 1 24 2009 1 31;
% 2009 2 3 2009 2 10;
% 2009 2 12 2009 4 19;
% 2009 4 21 2010 12 28;
% 2010 12 30 2011 5 7;
% 2011 5 9 2012 2 27];
% %
% for k = 1:length(TBG)
%     start_time = TBG(k,1:3);
%     end_time = TBG(k,4:6);
% %
% % ------------------------------------

if ~isempty(start_time) % unless empty input
    if length(start_time) == 2
        start_time = [doy2date(start_time(1), start_time(2)) 0 0 0]; % set start_time as [yyyy mm dd 0h 0m 0s]
    elseif length(start_time) == 3
        start_time = [start_time 0 0 0]; % set start_time as [yyyy mm dd 0h 0m 0s]
    else
        disp('Only enter year, month and day... aborting.');
        return;
    end
else
    disp('No start date input... aborting.');
    return;
end





if ~isempty(end_time) % unless empty input
    if length(end_time) == 2
        end_time = [doy2date(end_time(1), end_time(2)) 0 0 0]; % set end_time as [yyyy mm dd 0h 0m 0s]
    elseif length(end_time) == 3
        end_time = [end_time 0 0 0]; % set end_time as [yyyy mm dd 0h 0m 0s]
    else
        disp('Only enter year, month and day. Aborting...');
        return;
    end
else
    disp('No end date input... aborting');
    return;
end


total_time = (toepoch(end_time) - toepoch(start_time))/86400;
ss = mod(total_time*20, 60);
mm = mod(total_time*20-ss, 3600)/60;
hh = floor(total_time*20/3600);
sprintf('%g days interval given.\nApproximate execution time: up to %d:%02d:%02d', total_time, hh, mm, ss)
% yesno = input('Enter to continue, write anything to abort', 's');
% if ~isempty(yesno)
%     return;
% end

DBH_name = 'titan.irfu.se';
DBH_port = 33;
DBH = Connect2DBH(DBH_name,DBH_port); % Connect to ISDAT
if DBH == 0, disp([DBH_name,':',DBH_port,' does not respond.']), return, end
[CONTENTS,DURATION] = isGetContentLite(DBH,'Cassini','','lp','','','',''); 

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



timevec = toepoch(start_time):86400:toepoch(end_time)'; % create an epoch vector with 1-day intervals
timevec = fromepoch(timevec');
time = intersect(CONTENTS(:,1:3), timevec(:,1:3), 'rows'); % find days existing in CONTENTS
[m n] = size(time);
time = [time zeros(m,n)];
clear n

data_log = time; % save available days

% tic;

% time = toepoch(time); % converting to epoch for use in the loop
nodata_log = [];
%data_log = [];
for i = 1:m
    % run sweep reading function to calibrate and fix mismatches
    time_s = time(i,:); % beginning of the day
    time_e = fromepoch(toepoch(time(i,:)) + 86400); % end of the day (next day 00:00:00)
    [t_sweep U_sweep I_sweep] = Read_Sweep([time_s; time_e], DBH, CONTENTS, DURATION);
    if ~isempty(t_sweep)
        filename = [datapath, sprintf('LP_Swp_Clb/LP_archive_%4d%03d.dat', time_s(1), date2doy(time_s(1:3)))];
%         if exist(filename, 'file') == 2
%             % ovwrt = input('File exists, overwrite? (Enter = Yes/N = no) ');
%             if 1 %~isempty(ovwrt)
%                 disp(['Not overwriting ' datestr(time_s, 'yyyy-mm-dd')]);
%                 continue
%             end
%         end
        disp(['Writing file: ' filename ' ...']);
        fid4 = fopen(filename, 'w'); fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_sweep) U_sweep I_sweep]'); fclose(fid4);
        %dlmwrite(filename, [fromepoch(t_sweep) U_sweep I_sweep], 'delimiter', '\t', 'precision', 6);
        filesize = dir(filename);
        filesize = filesize.bytes/1024/1024;
        %data_log = [data_log; time_s];
        disp(['Done. File size: ', num2str(filesize), ' MB']);
    else
        disp(['No data from ' datestr(time_s, 'yyyy-mm-dd') ' skipping']);
        nodata_log = [nodata_log; time_s];
        if exist([apppath, 'archi/nodata_log.dat'], 'file') == 2
            nodata = load([apppath, 'archi/nodata_log.dat']);
            % if file exists, check whether the data-free day is already on the list
            if isempty(find(toepoch(time_s) == nodata, 1))
                fid3 = fopen([apppath, 'archi/nodata_log.dat'], 'a'); fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', time_s); fclose(fid3);
            end
        else
            % if file does not exist, create
            fid3 = fopen([apppath, 'archi/nodata_log.dat'], 'w'); fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', time_s); fclose(fid3);
        end
    end
end
clear m
%    toc;


% end % TBG loop