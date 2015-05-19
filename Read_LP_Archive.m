% function for reading data from archived files
% usage: 
%   either type Read_LP_Archive and input parameters manually
%   OR
%   call by DATA = Read_LP_Archive(datatype, time, query);
%
%   # datatype is either 'Sweep' or "Density'
%
%   # query is either '', 'Rev' or the name of the moon of interest (ex. 'Titan' without quotations)
%       if left empty, allows to specify arbitrary time intervals, else
%       asks for specific event(s) to be entered (ex. Rev5, T42, etc)
%
%   # time can be:
%       -   arbitrary list of time intervals in EPOCH, [YEAR DOY hh mm ss] or [YEAR MM DD hh mm ss]
%           composed as [start_time end_time] matrix (be consistent!)
%       -   a list of numbers corresponding to events specified in query
%           (ex. query = 'Titan' and time = [5; 32; 42; 70] will return
%           data for T5, T32, T42 and T70) composed as [EVENTNUM DURATION]
%           DURATION must be specified in HOURS
%           for specific query:
%           if time is a column-vector (and for 'Rev' it should be), program interprets it as a list of
%           fly-bys/events and will set default fly-by durations to 2h (1h before and
%           1h after the closest approach)
%
%   # DATA is a structure
%       .tUI field contains the [epoch U I] of the event
%       .event contains the name of the event, ex. "interval_#", "Rev#", "T#" etc
%
% /Oleg Shebanits, IRFU, 2012

function DATA = Read_LP_Archive(datatype, time, query)
DATA = [];

apppath = fileparts([mfilename('fullpath'), '.m']);
datapath = [apppath(1:end-24), '/Cassini_LP_DATA_Archive/'];

% ===== for manual use of the function =====
if nargin < 3
    query = input('\nIf you require specific data such as fly-by of a moon or whole revolution,\nspecify by the name of the moon (ex. "Titan") or "Rev" (without quotations) for revolution.\nDefault (leave blank) is custom time interval(s)\n\nEnter query: ','s');
    if      ~strcmp(query, '') &&... % if gibberish input (not empty, but doesn't match anything of the following)
            ~strcmp(query, 'Rev') &&... 
            ~strcmp(query, 'Titan') &&...
            ~strcmp(query, 'Enceladus') &&...
            ~strcmp(query, 'Tethys') &&...
            ~strcmp(query, 'Dione') &&...
            ~strcmp(query, 'Rhea') &&...
            ~strcmp(query, 'Mimas') &&...
            ~strcmp(query, 'Iapetus') &&...
            ~strcmp(query, 'Hyperion') &&...
            ~strcmp(query, 'Phoebe')
        error('Query not recognized. Either no close approach exists or misspelled input.');
    end
end

if nargin < 1
    datatype = input('Data type ("Sweep" or "Density", without quotations)? ', 's');
end

% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% if arbitrary time interval(s) wanted
if strcmp(query, '') 
    if nargin < 2
        start_time = input('Start time? (if several intervals, matrix must have dates/epoch as rows): ');
        end_time = input('End time? (if several intervals, matrix must have dates/epoch as rows): ');
        if isequal(size(start_time),size(end_time))
            time = [start_time end_time];
        else
            error('Time matrices must be of the same format and length');
        end
    end
    
    % checking for input formats of time vectors
    if size(time, 2) == 10 % if entered in [YEAD DOY hh mm ss], convert to epoch
        start_time = toepoch([doy2date(time(:,1), time(:,2)) time(:,3:5)]);
        end_time = toepoch([doy2date(time(:,6), time(:,7)) time(:,8:10)]);
    elseif size(time, 2) == 12 % if entered in [YEAR MM DD hh mm ss], convert to epoch
        start_time = toepoch(time(:,1:6));
        end_time = toepoch(time(:,7:12));
    elseif size(time, 2) == 2 % if entered in epoch
        start_time = time(:,1);
        end_time = time(:,2);
    else
        % if entered in some other weird way except in epoch
        error('Start time was given in wrong format');
    end
    eval(['fieldname = {' sprintf('''%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c to %c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c'';', [datestr(fromepoch(start_time),'dd-mmm-yyyy HH:MM:SS') datestr(fromepoch(end_time),'dd-mmm-yyyy HH:MM:SS')]') '};']); % fieldname for use in the DATA structure
    % now all time vectors are in epoch
% ==========================================

% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% if REV data wanted ******* eval(['test = [' sprintf('''T%d'';', [2 5 6]) ']'])
elseif strcmp(query, 'Rev')
    disp('Rev mode');
    filename = [datapath, 'apoapse_times.dat'];
    timevec = load(filename); % in apoapse_times.dat, first entry is START OF PRIME MISSION and last entry is END OF MISSION
    if nargin < 2
        time = input('\nRev0, RevA, RevB and RevC are -1, 0, 1, and 2 resp., rest are matching numbers. Last Rev is 293.\n\nSpecify event number(s) of interest: ');
    end
    
    % checking for input formats of time vectors
    [m n] = size(time);
    if m > 1 && n > 1 % if input is NOT a vector
        error('Rev list was given in wrong format, only list of Revs needed');
    end
    
    if ~issorted(time, 'rows'), time = sort(time); end
    
    start_time = timevec(time+2,:); % time+2 since Rev3 is actually 5th (after Rev0, RevA, RevB and RevC)
    end_time = fromepoch(toepoch(timevec(time+3,:)) - 1); % minus one second from the start of next Rev, this works since the last entry is the end of mission, the one before it is the last Rev
    
    clear fieldname
    
    disp('Requested events:');
    for j = 1:length(time)
        if time(j) == -1
            fprintf('Rev0,\tduration %.2f days\t%s - %s\n', (toepoch(end_time(j,:))-toepoch(start_time(j,:)))/86400, datestr(start_time(j,:), 'yyyy-mm-dd HH:MM:SS'), datestr(end_time(j,:), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = 'Rev0';
        elseif time(j) == 0
            fprintf('RevA,\tduration %.2f days\t%s - %s\n', (toepoch(end_time(j,:))-toepoch(start_time(j,:)))/86400, datestr(start_time(j,:), 'yyyy-mm-dd HH:MM:SS'), datestr(end_time(j,:), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = 'RevA';
        elseif time(j) == 1
            fprintf('RevB,\tduration %.2f days\t%s - %s\n', (toepoch(end_time(j,:))-toepoch(start_time(j,:)))/86400, datestr(start_time(j,:), 'yyyy-mm-dd HH:MM:SS'), datestr(end_time(j,:), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = 'RevB';
        elseif time(j) == 2
            fprintf('RevC,\tduration %.2f days\t%s - %s\n', (toepoch(end_time(j,:))-toepoch(start_time(j,:)))/86400, datestr(start_time(j,:), 'yyyy-mm-dd HH:MM:SS'), datestr(end_time(j,:), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = 'RevC';
        else
            fprintf('Rev%d,\tduration %.2f days\t%s - %s\n', time(j), (toepoch(end_time(j,:))-toepoch(start_time(j,:)))/86400, datestr(start_time(j,:), 'yyyy-mm-dd HH:MM:SS'), datestr(end_time(j,:), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = sprintf('Rev%d', time(j));
        end
    end
    
    start_time = toepoch(start_time);
    end_time = toepoch(end_time);
    %eval(['fieldname = {' sprintf('''Rev%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================
    
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% if TITAN data wanted
elseif strcmp(query, 'Titan')
    disp('Titan mode');
    filename = [datapath, 'titan_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = input('\nTA, TB and TC are 0, 1 and 2 resp., rest are matching numbers.\nLast fly-by is T126.\nEnter fly-by number(s): ');
        duration = input('Enter corresponding fly-by duration(s) (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a column-vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [T# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows'), time = sort(time); end
    
    start_time = toepoch(timevec(time(:,1)+1,:)) - time(:,2)/2*3600; % time+1 since T3 fly-by is actually 4th (after TA, TB and TC)
    end_time = toepoch(timevec(time(:,1)+1,:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    for j = 1:size(time,1) % num of rows
        if time(j,1) == 0
            fprintf('TA,\tduration %.2fh\t%s - %s\n', time(j,2), datestr(fromepoch(start_time(j,:)), 'yyyy-mm-dd HH:MM:SS'), datestr(fromepoch(end_time(j,:)), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = 'TA';
        elseif time(j,1) == 1
            fprintf('TB,\tduration %.2fh\t%s - %s\n', time(j,2), datestr(fromepoch(start_time(j,:)), 'yyyy-mm-dd HH:MM:SS'), datestr(fromepoch(end_time(j,:)), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = 'TB';
        elseif time(j,1) == 2
            fprintf('TC,\tduration %.2fh\t%s - %s\n', time(j,2), datestr(fromepoch(start_time(j,:)), 'yyyy-mm-dd HH:MM:SS'), datestr(fromepoch(end_time(j,:)), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = 'TC';
        else
            fprintf('T%d,\tduration %.2fh\t%s - %s\n', time(j,1), time(j,2), datestr(fromepoch(start_time(j,:)), 'yyyy-mm-dd HH:MM:SS'), datestr(fromepoch(end_time(j,:)), 'yyyy-mm-dd HH:MM:SS'));
            fieldname{j} = sprintf('T%d', time(j));
        end
    end
    
    %eval(['fieldname = {' sprintf('''T%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================
    
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
% if ENCELADUS data wanted
elseif strcmp(query, 'Enceladus')
    disp('Enceladus mode');
    filename = [datapath, 'enceladus_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = input('\nFirst fly-by is E0, Last fly-by is E22.\nEnter fly-by number(s) : ');
        duration = input('Enter corresponding fly-by duration(s) (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [E# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows'), time = sort(time); end
    
    start_time = toepoch(timevec(time(:,1)+1,:)) - time(:,2)/2*3600; % time+1 since E0 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1)+1,:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('E%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''E%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================

    
% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
elseif strcmp(query, 'Tethys')
    
    % since Tethys only has ONE fly-by...
    disp('Tethys mode');
    filename = [datapath, 'tethys_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = 1;
        duration = input('Enter Te1 duration (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [Te# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows')
        time = sort(time);
    end
    
    start_time = toepoch(timevec(time(:,1),:)) - time(:,2)/2*3600; % time since Te1 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1),:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('Te%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''Te%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
elseif strcmp(query, 'Dione')
    
    disp('Dione mode');
    filename = [datapath, 'dione_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = input('\nFirst fly-by is D1, Last fly-by is D5.\nEnter fly-by number(s) : ');
        duration = input('Enter corresponding fly-by duration(s) (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [D# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows')
        time = sort(time);
    end
    
    start_time = toepoch(timevec(time(:,1),:)) - time(:,2)/2*3600; % time since D1 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1),:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('D%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''D%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
elseif strcmp(query, 'Rhea')
    
    disp('Rhea mode');
    filename = [datapath, 'rhea_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = input('\nFirst fly-by is R1, Last fly-by is R4.\nEnter fly-by number(s) : ');
        duration = input('Enter corresponding fly-by duration(s) (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [R# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows')
        time = sort(time);
    end
    
    start_time = toepoch(timevec(time(:,1),:)) - time(:,2)/2*3600; % time since R1 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1),:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('R%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''R%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================
    

% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
elseif strcmp(query, 'Mimas')
    
    % since Mimas only has ONE fly-by...
    disp('Mimas mode');
    filename = [datapath, 'mimas_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = 1;
        duration = input('Enter M1 duration (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [M# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows')
        time = sort(time);
    end
    
    start_time = toepoch(timevec(time(:,1),:)) - time(:,2)/2*3600; % time since M1 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1),:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('M%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''M%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
elseif strcmp(query, 'Iapetus')
    
    % since Iapetus only has ONE fly-by...
    disp('Iapetus mode');
    filename = [datapath, 'iapetus_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = 1;
        duration = input('Enter I1 duration (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [I# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows')
        time = sort(time);
    end
    
    start_time = toepoch(timevec(time(:,1),:)) - time(:,2)/2*3600; % time since I1 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1),:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('I%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''I%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
elseif strcmp(query, 'Hyperion')
    
    % since Hyperion only has ONE fly-by...
    disp('Hyperion mode');
    filename = [datapath, 'hyperion_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = 1;
        duration = input('Enter H1 duration (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [H# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows')
        time = sort(time);
    end
    
    start_time = toepoch(timevec(time(:,1),:)) - time(:,2)/2*3600; % time since H1 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1),:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('H%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''H%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
elseif strcmp(query, 'Phoebe')
    
    % since Phoebe only has ONE fly-by...
    disp('Phoebe mode');
    filename = [datapath, 'phoebe_times.dat'];
    timevec = load(filename);
    if nargin < 2
        ftime = 1;
        duration = input('Enter P1 duration (hours, default is 2h): ');
        if isempty(duration)
            duration = 2*ones(size(ftime));
            disp('default duration set');
        end
        if ~isequal(size(ftime), size(duration)), error('Fly-by numbers and durations must be vectors of same dimensions'); end
        time(:,1) = ftime; time(:,2) = duration;
    end
    %[m n] = size(time);
    if size(time,2) == 1 % if time is a vector, duration is not specified and must be set to a default value
        ftime = time;
        duration = 2*ones(size(time));
        time = [];
        time(:,1) = ftime; time(:,2) = duration; % this makes a [P# dur] matrix regardless of ftime dimensions
        disp('default duration set');
    end
    
    if ~issorted(time,'rows')
        time = sort(time);
    end
    
    start_time = toepoch(timevec(time(:,1),:)) - time(:,2)/2*3600; % time since P1 fly-by is actually 1st
    end_time = toepoch(timevec(time(:,1),:)) + time(:,2)/2*3600;
    
    clear fieldname
    
    disp('Requested events:');
    fprintf('P%d,\tduration %.2fh\t%4d-%02d-%02d %02d:%02d:%02d - %4d-%02d-%02d %02d:%02d:%02d\n', [time, fromepoch(start_time), fromepoch(end_time)]');
    
    eval(['fieldname = {' sprintf('''P%d'';', time(:,1)) '};']); % fieldname for use in the DATA structure
    
    clear timevec filename m n
    % now all time vectors are in epoch
% ==========================================

% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

else
    error('Error using Read_LP_Archive: Unknown query input');
end

% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% now, the requested event time(s) is/are in start_time and end_time as
% epoch vectors. next step is to scan the files and find the data

if strcmp(datatype, 'Sweep'); % string comparison
    filepath = [datapath, 'LP_Swp_Clb/'];
    filename = 'LP_archive_'; % followed by YEARDOY.dat
elseif strcmp(datatype,  'Density'); % string comparison
    filepath = [datapath, 'Cnt_CurDat/'];
    filename = 'LP_CntCur_'; % followed by YEARDOY.dat
else
    disp('Error using Read_LP_Archive: data type can only be "Sweep" or "Density"');
    error('Wrong data type specified during the call to Read_LP_Archive');
end

dirinfo = dir(filepath);
s_ind = []; e_ind = [];

s_time = fromepoch(start_time);
e_time = fromepoch(end_time);

% convert filenumbers to numbers for comparison
% thelist = [];
namenum = [];
for i = 1:numel(dirinfo)
    namenum = [namenum; cell2mat(textscan(dirinfo(i).name, [filename '%d.dat']))]; % this contains a list of numbers of all existing files
end

st = [s_time(:,1).*1000+date2doy(s_time)];
et = [e_time(:,1).*1000+date2doy(e_time)];


for i = 1:size(s_time,1)
    filelist{i,1} = namenum(namenum >= st(i) & namenum <= et(i));
end

% [cs lists ~] = intersect({dirinfo.name}, file_s); % lists is in chronological order so no sorting needed
% [ce liste ~] = intersect({dirinfo.name}, file_e); % liste is in chronological order so no sorting needed

% now time to load the data

for i = 1:numel(filelist)
    data = [];
    for k = 1:numel(filelist{i})
        disp(['Loading ' filepath filename num2str(filelist{i}(k)) '.dat ...'])
        data = [data; load([filepath filename num2str(filelist{i}(k)) '.dat'])]; % this loads all the files that include the time interval into one variable
        %data = [data; load([filepath dirinfo(k).name])]; % this loads all the files that include the time interval into one variable
        disp('Done');
    end
    if ~isempty(data)
        data = [toepoch(data(:,1:6)) data(:,7) data(:,8)]; % [time_epoch U I]
        data_ind = data(:,1) >= start_time(i) & data(:,1) <= end_time(i); % find data within the requested time and save in DATA.(fieldname)
        DATA(i).tUI = data(data_ind,:);
    else
        DATA(i).tUI = [];
%         disp(['No data for ' fieldname{i}]);
    end
    DATA(i).event = fieldname{i};
    if isempty(DATA(i).tUI), disp(['No data for ' fieldname{i}]); end
end

if nargout < 1
    assignin('base', 'DATA', DATA);
    clear DATA
end

return;

    