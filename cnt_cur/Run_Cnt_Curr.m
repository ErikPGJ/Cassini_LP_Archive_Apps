%===================================================================================================
%
% LP Continuous Current extraction and archiving for Cassini
%
% NOTE: MATLAB script for practical purposes (?, debugging?), but could just as well be a function.
%       Not called from anywhere.
% PROPOSAL: Rewrite as function.
%===================================================================================================

% Should not use "clear all" since it clears breakpoints in OTHER
% FILES (or at least Read_Density.m), but NOT IN THIS FILE.
clear VARIABLES

% Measured speed from generating 2015-91 to 2015-181.
%ESTIMATED_WALL_TIME_PER_DATA_TIME = 3.4/86400;   % Could be used for predicting (and displaying) the wall time used by the function.
    
Constants; % Some constants
global datapath apppath
datapath = '../../Cassini_LP_DATA_Archive/';
apppath  = '../../Cassini_LP_Archive_Apps/';

if ~exist(datapath, 'dir') || ~exist(apppath, 'dir')
    datapath
    apppath
    error('Can not find directories. (You might have the wrong current directory.)')
end

Analyse='Cassini';
if(strcmp(Analyse,'Cassini')) % Do cassini analysis ?
    if(~exist('CA')) % Setup if not already done
        CA=Setup_Cassini; % Setup space craft structure for Cassini
    end
    
    
    
    disp('Process Cassini');
    disp('Cassini/RPWS/LP data archiver');
    disp('Enter start and end dates for data you wish to archive');
    disp('Format: [YYYY MM DD] or [YYYY DOY] (no hh mm ss)');
    disp('NOTE: if error, check if date interval begins OR ends when there is no data.');
    t_start = input('Start date (inclusive): ');
    t_end   = input('End date   (EXclusive): ');
    nodata_log = [];
   
    t_start = interpret_user_input_day(t_start);
    t_end   = interpret_user_input_day(t_end);
    N_days = (toepoch(t_end) - toepoch(t_start)) / 86400;

    
	
    time = toepoch(t_start);    
    if(CA.DBH==0) % Only reconnect if not connected
        CA.DBH=Connect2DBH(CA.DBH_Name,CA.DBH_Ports); % Connect to ISDAT
    end
    
    [CA.CONTENTS,CA.DURATION]=GetContents(CA); % Get full contents list
    
    %==================================================
    % Check for longer than expected time intervals.
    % Unknown why.
    %==================================================
    if ~isempty(CA.DURATION(CA.DURATION > 7200)) % check DURATION for anomalies (should not be larger than 3600s)
        warning('WARNING! Found DURATION > 1h10m!');
        disp('Date (CONTENTS)         DURATION');
        disp([datestr(CA.CONTENTS(CA.DURATION > 7200,:), 'yyyy-mm-dd HH:MM:SS     '), num2str(CA.DURATION(CA.DURATION > 7200))]);
        check = input('Proceed? Y/N [N]: ','s');
        if isempty(check) || check == 'N'
            disp('Aborted by user');
            return;
        end
        if check == 'Y'
            disp('Cutting out anomaly in DURATION and CONTENTS');
            CA.CONTENTS(CA.DURATION > 7200,:) = [];
            CA.DURATION(CA.DURATION > 7200) = [];
        end
    end
    %if ~isempty(CA.DURATION(CA.DURATION < 0)) % Check DURATION for anomalies (should not be larger than 3600s)
    %    warning('WARNING! Found intervals with negative length.')
    %end
    
    t_work_start = clock;   % Start time keeping. Exclude time used for user interaction.
    
    
    %==================================================
    % Iterate over days : Obtain data and save to file
    %==================================================
    while time < toepoch(t_end)   % Time is increased by one day at the end of the loop.
        
        if(CA.DBH ~= 0) % If we are connected to ISDAT
            
            %=================================
            % Obtain data for entire time day
            %=================================
            [t_Ne U_DAC Ne_I] = Read_Density(CA, time, time+86400);
            
            
            
            if isempty(t_Ne)
                %========================
                % CASE: There is NO data
                %========================
                disp(['No data from ' datestr(fromepoch(time), 'yyyy-mm-dd')]);
                nodata_log = [nodata_log; time];
                if exist([apppath, 'cnt_cur/nodata_log.dat'], 'file') == 2
                    nodata = load([apppath, 'cnt_cur/nodata_log.dat']);
                    % If file exists, check whether the data-free day is already on the list
                    if isempty(find(time == nodata, 1))
                        fid3 = fopen([apppath, 'cnt_cur/nodata_log.dat'], 'a');
                        fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', fromepoch(time));
                        fclose(fid3);
                    end
                else
                    % If file does not exist, create
                    fid3 = fopen([apppath, 'cnt_cur/nodata_log.dat'], 'w');
                    fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', fromepoch(time));
                    fclose(fid3);
                end
                
                time = time + 86400; % on to the next day
                continue;
            else
                %========================
                % CASE: There is data
                %========================
                time_ymd = fromepoch(t_Ne(1)); % convert from epoch for the file name
                % 86400 seconds in a day                
                filename = [datapath, sprintf('Cnt_CurDat/LP_CntCur_%4d%03d.dat', time_ymd(1), date2doy(time_ymd(1:3)))];
                
                disp(['Writing file: ' filename ' ...']);
                fid4 = fopen(filename, 'w');
                fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_Ne) U_DAC Ne_I]');
                fclose(fid4);
                
                %dlmwrite(filename, [fromepoch(t_Ne) U_DAC Ne_I], 'delimiter', '\t', 'precision', 6);
                filesize = dir(filename);
                filesize = filesize.bytes/1024/1024;
                disp(['Done. File size: ', num2str(filesize), ' MB']);               
            end            
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        time = time + 86400;   % Continue with next day
    end
    
    t_work = etime(clock, t_work_start);
    fprintf(1, 'Wall time use for generating files: %.0f s;  %.1f s/(day of data)\n', t_work, t_work/N_days);
    
end
