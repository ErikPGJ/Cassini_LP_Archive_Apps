%
% LP Continuous Current extraction and archiving for Cassini
% NOTE: Writes Cnt_CurDat/spikelog.mat (creates or appends) via "Read_Density".
%
%
% USAGE
% =====
% Run_Cnt_Curr
% Run_Cnt_Curr(t_start_incl, t_end_excl)
%
% 
% ARGUMENTS
% =========
% t_start_incl : Start date, inclusive.
% t_end_excl   : Stop date, exclusive.
%
%
% NOTE: Can not called from any directory.
% NOTE: Appears to be able to handle non-1-hour ISDAT time intervals, assuming they still do not span midnight.
%
% BUG: Adds dates to nodata_log file for dates for which there is not data, but does not remove dates for which there is
% data.
%
% PROPOSAL: Rewrite as function without any user interaction or move user interaction to wrapper script.
%    NOTE: There is user interaction when finding intervals longer than ~2 h.
% PROPOSAL: Optional flag for disabling long DURATION warning.
function Run_Cnt_Curr(varargin)

% Should not use "clear all" since it clears breakpoints in OTHER FILES, but NOT IN THIS FILE.
clear VARIABLES

% Measured speed [days/file?] from generating 2015-91 to 2015-181.
%ESTIMATED_WALL_TIME_PER_DATA_TIME = 3.4/86400;   % Could be used for predicting (and displaying) the wall time used by the function.

Constants; % Some constants
global datapath apppath
datapath = '../../Cassini_LP_DATA_Archive/';
apppath  = '../../Cassini_LP_Archive_Apps/';
NODATA_LOG_FILE        = fullfile(apppath, 'cnt_cur', 'nodata_log.dat');
DATA_FILE_PATH_PATTERN = fullfile(datapath, 'Cnt_CurDat', 'LP_CntCur_%4d%03d.dat');



% ~ASSERTIONS
if ~exist(datapath, 'dir') || ~exist(apppath, 'dir')
    datapath
    apppath
    error('Can not find directories. (You might have the wrong current directory.)')
end
[parentDirJunk, baseName, ext] = fileparts(pwd);
if ~strcmp([baseName,ext], 'cnt_cur')
    error('This code appears to be written to be called with cnt_cur/ as current directory. Otherwise (if called from archi/) it might call the wrong but same-named functions causing it produce files with bad values (in the past it used the wrong Calibrate.m).')
end


Analyse='Cassini';
if(strcmp(Analyse,'Cassini')) % Do cassini analysis ?
    if(~exist('CA'))    % Setup if not already done
        CA=Setup_Cassini;    % Setup spacecraft structure for Cassini
    end
    
    if length(varargin) == 0    
        disp('Process Cassini');
        disp('Cassini/RPWS/LP data archiver');
        disp('Enter start (INCLUSIVE) and end (EXCLUSIVE) dates for data you wish to archive');
        disp('Format: [YYYY MM DD] or [YYYY DOY] (no hh mm ss)');
        disp('NOTE: if error, check if date interval begins OR ends when there is no data.');
        t_start = input('Start date (INclusive): ');
        t_end   = input('End date   (EXclusive): ');
    elseif length(varargin) == 2
        t_start = varargin{1};
        t_end   = varargin{2};
    else
        error('Illegal number of arguments.')
    end
    nodata_log = [];
    
    t_start = interpret_user_input_day(t_start);
    t_end   = interpret_user_input_day(t_end);
    N_days = (toepoch(t_end) - toepoch(t_start)) / 86400;   % NOTE: Does not consider leap seconds.
    
    
    
    time = toepoch(t_start);
    if(CA.DBH==0) % Only reconnect if not connected
        CA.DBH=Connect2DBH(CA.DBH_Name,CA.DBH_Ports); % Connect to ISDAT
    end
    
    [CA.CONTENTS,CA.DURATION]=GetContents(CA); % Get full contents list
    
    %==================================================
    % Check for longer than expected time intervals.
    % Unknown why.
    %==================================================
%     DURATION_WARNING_LIMIT = 2*3600;   % Maximum duration value which will not give warning. Unit seconds.
%     if ~isempty(CA.DURATION(CA.DURATION > DURATION_WARNING_LIMIT)) % check DURATION for anomalies (should not be larger than 3600 s)
%         warning('WARNING! Found DURATION > %i [s]!', DURATION_WARNING_LIMIT);
%         disp('Date (CONTENTS)         DURATION');
%         disp([datestr(CA.CONTENTS(CA.DURATION > DURATION_WARNING_LIMIT, :), 'yyyy-mm-dd HH:MM:SS     '), num2str(CA.DURATION(CA.DURATION > DURATION_WARNING_LIMIT))]);
%         check = input('Proceed? Y/N [N]: ','s');
%         if isempty(check) || check == 'N'
%             disp('Aborted by user');
%             return;
%         end
%         if check == 'Y'
%             disp('Cutting out anomaly in DURATION and CONTENTS');
%             CA.CONTENTS(CA.DURATION > DURATION_WARNING_LIMIT,:) = [];
%             CA.DURATION(CA.DURATION > DURATION_WARNING_LIMIT) = [];
%         end
%     end
    [CA.CONTENTS, CA.DURATION] = check_DURATION(CA.CONTENTS, CA.DURATION, 'interactive');
    %if ~isempty(CA.DURATION(CA.DURATION < 0)) % Check DURATION for anomalies (should not be larger than 3600s)
    %    warning('WARNING! Found intervals with negative length.')
    %end

    t_work_start = clock;   % Start time keeping. Exclude time used for user interaction.



    %==================================================
    % Iterate over days : Obtain data and save to file
    %==================================================
    while time < toepoch(t_end)   % Time is increased by one day at the end of the loop.
        
        if(CA.DBH ~= 0) % If we are connected to ISDAT
            
            %========================================================
            % Obtain data for entire time day
            %
            % This is the data that will actually be written to file.
            %========================================================
            [t_Ne U_DAC Ne_I] = Read_Density(CA, time, time+86400);   % NOTE: Does not consider leap seconds.
            
            
            
            if isempty(t_Ne)
                %================================
                % CASE: There is NO data
                %
                % Add the date to nodata_log.dat.
                %================================
                disp(['No data from day ' datestr(fromepoch(time), 'yyyy-mm-dd')]);
                nodata_log = [nodata_log; time];
                if exist(NODATA_LOG_FILE, 'file') == 2
                    nodata = load([apppath, 'cnt_cur/nodata_log.dat']);
                    
                    % If nodata_log does NOT contain the day, then add the day to the file.
                    if isempty(find(time == nodata, 1))
                        fid3 = fopen(NODATA_LOG_FILE, 'a');
                        fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', fromepoch(time));
                        fclose(fid3);
                    end
                else
                    % If file does not exist, create
                    fid3 = fopen(NODATA_LOG_FILE, 'w');
                    fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', fromepoch(time));
                    fclose(fid3);
                end
                
                time = time + 86400;   % On to the next day   % NOTE: Does not consider leap seconds.
                continue;
            else
                %=====================
                % CASE: There is data
                %
                % Write data file.
                %=====================
                time_ymd = fromepoch(t_Ne(1)); % convert from epoch for the file name
                % 86400 seconds in a day
                filename = sprintf(DATA_FILE_PATH_PATTERN, time_ymd(1), date2doy(time_ymd(1:3)));
                
                disp(['Writing file: ' filename ' ...']);
                fid4 = fopen(filename, 'w');
                fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_Ne) U_DAC Ne_I]');
                fclose(fid4);
                
                %dlmwrite(filename, [fromepoch(t_Ne) U_DAC Ne_I], 'delimiter', '\t', 'precision', 6);
                filesize = dir(filename);
                filesize = filesize.bytes/1024/1024;
                disp(['Done. File size: ', num2str(filesize), ' MiB']);
            end
            
        end   % if(CA.DBH ~= 0)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        time = time + 86400;   % Continue with next day   % NOTE: Does not consider leap seconds.
    end
    
    t_work = etime(clock, t_work_start);
    fprintf(1, 'Wall time use for generating files: %.0f s;  %.1f s/(day of data)\n', t_work, t_work/N_days);

else
    error('Can not interpret spacecraft.')
end

end