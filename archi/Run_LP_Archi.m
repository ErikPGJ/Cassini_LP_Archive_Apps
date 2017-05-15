% Run_LP_Archi gets LP data from DBH for a specified time interval, removes
% anomalies, calibrates and saves LP data in a .dat (ASCII) as:
%    [YYYY    MM      DD    h      m        s        bias   current]
%     years   months  days  hours  minutes  seconds  volts  amperes   .
%
% All values are given with 6 significant digits, delimiter is TAB,
% filename is /Cassini_LP_DATA_Archive/LP_Swp_Clb/LP_archive_YYYYDOY.dat
%
% Oleg Shebanits, IRFU, 2012-03
%
%
% ARGUMENTS: [t_start_incl t_end_excl]  (optional)
%  
function Run_LP_Archi(varargin)

    % Measured speed from generating 2015-91 to 2015-181.
    ESTIMATED_WALL_TIME_PER_DATA_TIME = 8.4/86400;   % Used for predicting (and displaying) the wall time used by the function.
    
    if length(varargin) == 0
        disp('Cassini/RPWS/LP data archiver');
        disp('Enter start and end dates for data you wish to archive');
        disp('Format: [YYYY MM DD] or [YYYY DOY] (no hh mm ss)');
        disp('NOTE: if error, check if date interval begins OR ends when there is no data');
        start_time = input('Start date (INclusive): ');
        end_time   = input('End date   (EXclusive): ');
    elseif length(varargin) == 2
        start_time = varargin{1};
        end_time   = varargin{2};
    else
        error('Illegal number of arguments')
    end

    global datapath apppath
    datapath = '../../Cassini_LP_DATA_Archive/';
    apppath  = '../../Cassini_LP_Archive_Apps/';
    
    % ~ASSERTIONS
    if ~exist(datapath, 'dir') || ~exist(apppath, 'dir')
        datapath
        apppath
        error('Can not find relative directories. (You might have the wrong current directory.)')
    end
    [parentDir, baseName, ext] = fileparts(pwd);
    if ~strcmp([baseName,ext], 'archi')
        error('This code appears to be written to be called with archi/ as current directory. Otherwise (if called from archi/) it might call the wrong but same-named functions causing it to crash.')
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
    
    

    start_time = interpret_user_input_day(start_time);
    end_time   = interpret_user_input_day(end_time);


    total_time_s = toepoch(end_time) - toepoch(start_time);
    % Estimated time (wall time) needed for generating data.
    % NOTE: Relies on hardcoded conversion constant!
    estimated_walltime_exec_s = (toepoch(end_time) - toepoch(start_time)) * ESTIMATED_WALL_TIME_PER_DATA_TIME;
    ss = mod(estimated_walltime_exec_s, 60);
    mm = mod(estimated_walltime_exec_s-ss, 3600)/60;
    hh = floor(estimated_walltime_exec_s/3600);
    sprintf('%g days interval given.\nEstimated execution time: up to %d:%02d:%02d', total_time_s/86400, hh, mm, ss)
    % yesno = input('Enter to continue, write anything to abort', 's');
    % if ~isempty(yesno)
    %     return;
    % end

    DBH_name = 'titan.irfu.se';
    DBH_port = 33;
    DBH = Connect2DBH(DBH_name,DBH_port); % Connect to ISDAT
    if DBH == 0, disp([DBH_name,':',DBH_port,' does not respond.'])
        return
    end
    [CONTENTS,DURATION] = isGetContentLiteWrapper(DBH,'Cassini','','lp','','','','');

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
            disp('Cutting out anomaly in DURATION and CONTENTS');
            CONTENTS(DURATION > 7200,:) = [];
            DURATION(DURATION > 7200) = [];
        end
    end



    % Create a vector containing the beginning of every requested day.
    % NOTE: Subtracts 86400 to exclude specified end day.
    days_requested = toepoch(start_time):86400:(toepoch(end_time)-86400);  
    days_requested = fromepoch(days_requested);
    
    % Select the requested days from the data in CONTENTS.
    % NOTE: This will eliminate requested days for which there is no data.    
    % Produces list of days on format: [year, month, day, 0, 0, 0].
    days_requested_available = intersect(CONTENTS(:,1:3), days_requested(:,1:3), 'rows');   % Find days existing in CONTENTS. 
    [N_days N_time_fields] = size(days_requested_available);   % N_days = days with data, not number of requested days (I think).
    days_requested_available = [days_requested_available zeros(N_days,N_time_fields)];
    %clear N_time_fields     % Seems unnecessary. Remove when sure that only functions, and no scripts, are called afterwards.

    %data_log = days_requested_available; % save available days

    t_work_start = clock;   % Start time keeping. Exclude time used for user interaction.

    % days_requested_available = toepoch(days_requested_available); % converting to epoch for use in the loop
    nodata_log = [];
    %data_log = [];
    for i = 1:N_days
        % run sweep reading function to calibrate and fix mismatches
        t_day_begin = days_requested_available(i,:);                            % Beginning of the day.
        t_day_end = fromepoch(toepoch(days_requested_available(i,:)) + 86400);  % End of the day (next day 00:00:00).
        [t_sweep, U_sweep, I_sweep] = Read_Sweep([t_day_begin; t_day_end], DBH, CONTENTS, DURATION);
        if ~isempty(t_sweep)
            filename = [datapath, sprintf('LP_Swp_Clb/LP_archive_%4d%03d.dat', t_day_begin(1), date2doy(t_day_begin(1:3)))];
            %         if exist(filename, 'file') == 2
            %             % ovwrt = input('File exists, overwrite? (Enter = Yes/N = no) ');
            %             if 1 %~isempty(ovwrt)
            %                 disp(['Not overwriting ' datestr(t_day_begin, 'yyyy-mm-dd')]);
            %                 continue
            %             end
            %         end
            disp(['Writing file: ' filename ' ...']);
            fid4 = fopen(filename, 'w'); fprintf(fid4, '%4g %02g %02g %02g %02g %07.4f %+.5e %+.5e\n', [fromepoch(t_sweep) U_sweep I_sweep]'); fclose(fid4);
            %dlmwrite(filename, [fromepoch(t_sweep) U_sweep I_sweep], 'delimiter', '\t', 'precision', 6);
            file_info = dir(filename);
            file_size = file_info.bytes/(1024*1024);
            %data_log = [data_log; t_day_begin];
            disp(['Done. File size: ', num2str(file_size), ' MiB']);
        else
            disp(['No data from ' datestr(t_day_begin, 'yyyy-mm-dd') ' skipping']);
            nodata_log = [nodata_log; t_day_begin];
            if exist([apppath, 'archi/nodata_log.dat'], 'file') == 2
                nodata = load([apppath, 'archi/nodata_log.dat']);
                % if file exists, check whether the data-free day is already on the list
                if isempty(find(toepoch(t_day_begin) == nodata, 1))
                    fid3 = fopen([apppath, 'archi/nodata_log.dat'], 'a'); fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', t_day_begin); fclose(fid3);
                end
            else
                % if file does not exist, create
                fid3 = fopen([apppath, 'archi/nodata_log.dat'], 'w'); fprintf(fid3, '%4g %02g %02g %02g %02g %07.4f\n', t_day_begin); fclose(fid3);
            end
        end
        
    end % end % TBG loop
    
    t_work = etime(clock, t_work_start);
    fprintf(1, 'Wall time use for generating files: %.0f s;  %.1f s/(day of data)\n', t_work, t_work/N_days);

end