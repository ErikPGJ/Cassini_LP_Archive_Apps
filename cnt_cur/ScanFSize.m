% program to scan continious current density files and get the list of
% burst modes (huge files from 10 to 100 MB)
% prints the date (yyyy-mm-dd), file name and file size (in MB) with tab delimiter

disp('This scans for unusually big files in cont. curr. archive...\n date format is [YYYY MM DD]');
s_time = input('Enter start time of scan: ');
e_time = input('Enter end time of scan: ');
datapath = '../../Cassini_LP_DATA_Archive/';

if isempty(s_time)
    s_time = [1999 8 18];
end
if isempty(e_time)
    e_time = [2011 10 1];
end

s_name = [num2str(s_time(1)) num2str(date2doy(s_time))];
e_name = [num2str(e_time(1)) num2str(date2doy(e_time))];

% spikelog = [];
for i = toepoch([s_time 0 0 0]):86400:toepoch([e_time 0 0 0])
    time = fromepoch(i);
    filename = [datapath, sprintf('Cnt_CurDat/LP_CntCur_%4d%03d.dat', time(1), date2doy(time(1:3)))];
    if exist(filename) == 2
        filesize = dir(filename);
        filesize = filesize.bytes/1024/1024;
        if filesize >= 10
%             LParchive = load(filename);
            disp([datestr(time, 'yyyy-mm-dd') sprintf('\tLP_CntCur_%4d%03d.dat\t%5.2f MB', time(1), date2doy(time(1:3)), filesize)]);
%             figure;
%             title(datestr(time));
%             subplot(2,1,1); plot(toepoch(LParchive(:,1:6)), LParchive(:,7)); add_timeaxis;
%             ylabel('U_DAC');
%             subplot(2,1,2); plot(toepoch(LParchive(:,1:6)), LParchive(:,8)); add_timeaxis;
%             xlabel('time'); ylabel('Ne_I');
        end
    end
end

