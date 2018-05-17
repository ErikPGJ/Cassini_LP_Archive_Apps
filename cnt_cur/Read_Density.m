% Function for reading density data manually
%
%
% USAGE
% =====
% [t_Ne U_DAC Ne_I] = Read_Density(CA, start_time, end_time);
%
%
% ARGUMENTS
% =========
% CA         : Standardized structure, "Spacecraft structure". See "Setup_Cassini.m".
% start_time : Scalar seconds since 1970 (toepoch return value) or time vector [YYYY MM DD hh mm ss].
% end_time   : Scalar seconds since 1970 (toepoch return value) or time vector [YYYY MM DD hh mm ss].
%
%
% RETURN VALUES
% =============
% Ne_I     Continuous current data (denoted 20 Hz)
% t_Ne     Corresponding time
% U_DAC    Corresponding DAC voltage
% Return argument all have the same array size.
%
% Time should be in either epoch or in format of [yyyy mm dd hh mm ss].
% Default S/C is Cassini.
%
%
% NOTE: Writes Cnt_CurDat/spikelog.mat (creates or appends).
%
% Based on Process.m by Jan-Erik Wahlund (original in the ../cnt_cur_draft folder)
% Oleg Shebanits, 2012-02
%
function [t_Ne U_DAC Ne_I TM_values] = Read_Density(CA, start_time, end_time)
%
% PROPOSAL: Merge two identical occurrences of ~isempty(CA.DURATION(CA.DURATION > 7200))...end into separate function.
%

global datapath



%===========================================================
% Use default initialization if not all arguments supplied.
%===========================================================
if nargin<1
    CA = Setup_Cassini;
    CA.DBH = Connect2DBH(CA.DBH_Name,CA.DBH_Ports);   % Connect to ISDAT
    [CA.CONTENTS,CA.DURATION] = GetContents(CA);      % Get full contents list
     
%     if ~isempty(CA.DURATION(CA.DURATION > 7200)) % check DURATION for anomalies (should not be larger than 3600s)
%         warning('WARNING! Found DURATION > 1h10m!');
%         disp('Date (CONTENTS)         DURATION');
%         disp([datestr(CA.CONTENTS(CA.DURATION > 7200,:), 'yyyy-mm-dd HH:MM:SS') '     ' num2str(CA.DURATION(CA.DURATION > 7200))]);
%         check = input('Proceed? Y/N [N]: ','s');
%         if isempty(check) || check == 'N'
%             disp('Aborted by user');
%             return;
%         end
%         if check == 'Y'
%             disp('cutting out anomaly in DURATION and CONTENTS');
%             CA.CONTENTS(CA.DURATION > 7200,:) = [];
%             CA.DURATION(CA.DURATION > 7200) = [];
%         end
%     end
    %[CA.CONTENTS, CA.DURATION] = check_DURATION(CA.CONTENTS, CA.DURATION, 'interactive');    
    [CA.CONTENTS, CA.DURATION] = check_DURATION(CA.CONTENTS, CA.DURATION, 'non-interactive; permit long durations');    

end
if nargin<2
    start_time = input('Start time? Format [YYYY MM DD hh mm ss]: ');
end
if nargin<3
    end_time = input('End time? Format [YYYY MM DD hh mm ss]: ');
end



if(CA.DBH==0) % Only reconnect if not connected
    CA.DBH=Connect2DBH(CA.DBH_Name,CA.DBH_Ports); % Connect to ISDAT
end

if isempty(CA.CONTENTS) || isempty(CA.DURATION)
    % NOTE: The below section seems to be a copy of code further up.
    [CA.CONTENTS,CA.DURATION]=GetContents(CA); % Get full contents list
    
%     if ~isempty(CA.DURATION(CA.DURATION > 7200)) % check DURATION for anomalies (should not be larger than 3600s)
%         warning('WARNING! Found DURATION > 1h10m!');
%         disp('Date (CONTENTS)         DURATION');
%         disp([datestr(CA.CONTENTS(CA.DURATION > 7200,:), 'yyyy-mm-dd HH:MM:SS') '     ' num2str(CA.DURATION(CA.DURATION > 7200))]);
%         check = input('Proceed? Y/N [N]: ','s');
%         if isempty(check) || check == 'N'
%             disp('Aborted by user');
%             return;
%         end
%         if check == 'Y'
%             disp('cutting out anomaly in DURATION and CONTENTS');
%             CA.CONTENTS(CA.DURATION > 7200,:) = [];
%             CA.DURATION(CA.DURATION > 7200) = [];
%         end
%     end
    %[CA.CONTENTS, CA.DURATION] = check_DURATION(CA.CONTENTS, CA.DURATION, 'interactive');
    [CA.CONTENTS, CA.DURATION] = check_DURATION(CA.CONTENTS, CA.DURATION, 'non-interactive; permit long durations');
end



% Convert start_time, end_time to the standard time format if not already.
if length(start_time) > 1
    start_time = toepoch(start_time);
end
if length(end_time) > 1
    end_time = toepoch(end_time);
end



%=======================================================================================================================
% Find the EARLIEST ISDAT time interval "start_entry" that BEGINS AFTER  start_time
% Find the LATEST   ISDAT time interval "end_entry"   that BEGINS BEFORE end_time.
% 
% (Assuming all time intervals are non-overlapping and consecutive, finds those full intervals that lie in the interval
% start_time--end_time.)
%=======================================================================================================================
start_ind   = find( start_time < toepoch(CA.CONTENTS) );
if isempty(start_ind)
    error('Can not find any ISDAT data for the requested time interval.')
end
start_entry = start_ind(1);
end_ind     = find( end_time < toepoch(CA.CONTENTS) );
if (~isempty(end_ind))
    end_entry = end_ind(1) - 1;
else
    end_entry = start_ind( end );
end

if (start_entry <= end_entry)
    
    disp(['First ISDAT entry to use: ' num2str(start_entry) '   ' datestr(CA.CONTENTS(start_entry,:))]);
    disp(['Last  ISDAT entry to use: ' num2str(end_entry)   '   ' datestr(CA.CONTENTS(end_entry,:))]);
    disp(['Processing ' datestr(fromepoch(start_time), 'yyyy-mm-dd')]);

    % Initialize empty arrays to later successively add to.
    % NOTE: (t, Ne_TM, I) and (t_DAC_tmp, DAC_tmp, U_tmp) will grow in separate increments.
    t_DAC = [];
    t     = [];
    %
    Ne_TM = [];
    I     = [];
    DAC   = [];
    U     = [];
    
    %========================================
    % Iterate over all ISDAT time intervals.
    %========================================
 
    for j = start_entry:end_entry
        %    % No need for pausing as of 2012, hardware is fast enough.
        %         % Pause a bit every loop to avoid killing isdat memory.
        %         %disp(['Pausing ' num2str(1) ' seconds to avoid messing Matlab memory']);
        %	 disp(j); disp(end_entry);
        %         RI_CAcounter(1);
        
        % Read density data for one ISDAT time interval.
        try
            [t_tmp, Ne_TM_tmp, t_DAC_tmp, DAC_tmp, U_tmp] = GetDensity(CA,j);
            
        catch
            CA.DBH=Connect2DBH(CA.DBH_Name,CA.DBH_Ports); % RE-Connect to ISDAT
            try
                [t_tmp, Ne_TM_tmp, t_DAC_tmp, DAC_tmp, U_tmp] = GetDensity(CA,j);
            catch
                continue
            end
        end
        I_tmp = Calibrate_cnt_cur( CA, real(Ne_TM_tmp) ); % Calibrate does not accept complex numbers (why is it complex anyway)
        
        %disp(fromepoch( t_DAC_tmp(1,:) ));
        
        % Add cumulatively to arrays
        t     = [t;     t_tmp];
        t_DAC = [t_DAC; t_DAC_tmp];
        %
        Ne_TM = [Ne_TM; Ne_TM_tmp];
        I     = [I;     I_tmp];
        DAC   = [DAC;   DAC_tmp];
        U     = [U;     U_tmp];
    end    % for
    
    if isempty(t)
        % Return with empty return values.
        t_Ne  = t;
        U_DAC = [];
        Ne_I  = [];
        return;
    end
    
    ind = find(diff(t)<0);
    if ~isempty(ind) 
       % t = t(1:ind); Ne_TM = Ne_TM(1:ind); I = I(1:ind);
         t(ind+1) = NaN; Ne_TM(ind+1) = NaN; I(ind+1) = NaN;
    end
    %clear Ne_TM_tmp I_tmp DAC_tmp U_tmp t_tmp t_DAC_tmp
    
    %==================================================================================================
    % Take precautions if t_DAC is not sorted
    % ONLY for U, DAC, t_DAC: Only keep data points for which t_DAC is larger than the preceeding one.
    %==================================================================================================
    if ~issorted(t_DAC)
        % The DAC values are sometimes weird!
        ind       = find( diff(t_DAC) > 0 );    % Find indices for which t_DAC increase.
        t_DAC_new = zeros(length(t_DAC)-length(ind),1);
        DAC_new   = zeros(length(t_DAC)-length(ind),1);
        U_new     = zeros(length(t_DAC)-length(ind),1);
        
        k = 1;
        t_DAC_new(1) = t_DAC(1);
        DAC_new(1)   = DAC(1);
        U_new(1)     = U(1);
        k = k+1;
        for j = 2:length(t_DAC)
            if t_DAC(j) < t_DAC(j-1)   % Skip it!
            else % include
                t_DAC_new(k) = t_DAC(j);
                DAC_new(k)   = DAC(j);
                U_new(k)     = U(j);
                k = k+1;
            end
        end
        
        % clear t_DAC DAC U
        U     = U_new;
        DAC   = DAC_new;
        t_DAC = t_DAC_new;
    end


    % KOKO
    TM_values.DAC_U = U;
    TM_values.t_DAC = t_DAC;
    TM_values.DAC_TM = DAC;

    %================================================================
    % Take away some bad initial I data samples in each DAC segment.
    %================================================================
    n_DAC = length(DAC);
    for j = 1:n_DAC
        % pts_ind := The indices within DAC period j.
        if j == n_DAC   % Last iteration
            pts_ind = find( (t >= t_DAC(j)) );
        else    % Not last iteration
            pts_ind = find( (t >= t_DAC(j)) & (t < t_DAC(j+1)) );
        end
        
        if isempty( pts_ind ) | (length(t(pts_ind)) < 2)
            disp( ['Zero (or one) data points associated with DAC number ' int2str(j)] );
        else
            % Take away some bad initial data samples in each segment.
            I(pts_ind) = Clean_Density( I(pts_ind), t(pts_ind) );
        end
    end
    
    
    
    %SaveDensity( CA, I, t, U, t_DAC );
    %reply = input('Read I_DAC values?  (no=0/yes=1): ');
    %if reply
    %Read_I_DAC;
    %else
    %Isweep = []; % for Plot_Dens (if not reading I_DAC, set it empty)
    %end
    %Plot_Dens;
    %if reply
    %Plot_Cal;
    %end
    
    %=============================================================
    % For any double-values of t_DAC : Remove U and t_DAC values.
    %=============================================================
    if ~isempty(diff(t_DAC) == 0)
        U(diff(t_DAC) == 0) = []; % this one first
        t_DAC(diff(t_DAC) == 0) = [];
    end
    
    
    
    % Only the "beginning" of a time interval has a DAC,
    % need to fill out a DAC for each I value!
    [c int_e ~] = intersect(t, t_DAC);

    disp([length(c) length(t_DAC)]) 

    if ~isempty(c)
        
    	if length(c) ~= length(t_DAC)
           int_s = []; int_e = [];
	   for ii=1:length(t_DAC)-1
	       ind = find(t>=t_DAC(ii)); 
		if isempty(ind), continue, end
                                           int_s = [int_s   ind(1) ];
	       ind = find(t< t_DAC(ii+1)); int_e = [int_e   ind(end) ];
	   end
	   ind = find(t>=t_DAC(end));
	   if ~isempty(ind)
		int_s = [int_s   ind(1) ];
	   	int_e = [int_e length(t)];
	   end
	else
           int_s = int_e;
           int_e = [int_e(2:end); length(t)]; % the last value should be the end of the current array
        end
        
        DAC_temp = NaN*ones(length(I),1); % pre-allocating for speed and convenience
        for k = 1:length(c)
            DAC_temp(int_s(k):int_e(k)-1) = U(k);
        end

	if int_s(end) == length(t)
	   dt = diff([t(int_s(1:end-1)) t(int_s(1:end-1)+1)],1,2);
	else
	   dt = diff([t(int_s) t(int_s+1)],1,2);
	end
	Iflp_blk = find(dt>0.025);

	p_Iflp = [];
	for ii=1:length(Iflp_blk)
            p_Iflp = [p_Iflp int_s(Iflp_blk(ii)):int_e(Iflp_blk(ii))];
	end
	I(p_Iflp) = -I(p_Iflp);
        
        
        I(1:int_s(1)-1) = []; % remove values of I before U is set
        DAC_temp(1:int_s(1)-1) = [];
        t(1:int_s(1)-1) = [];
        U = DAC_temp;

        % t_DAC = t;
        % clear DAC_temp c int_e
        %     t_Ne = t;
        %     U_DAC = U;
        %     Ne_I = I;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Spike Removal Tool
        spikelog = [];
        difneg_ind = find(diff(t)<0); % find negative spikes ALL VALUES NEEDED DON'T ADD ",1" to FIND
        if ~isempty(difneg_ind) % if there are spikes at all...
            Anm = [];
            for i = 1:length(difneg_ind)
                spike_end = find(t > t(difneg_ind(i))); % end of the spike to cut out
                if isempty(spike_end) % = the spike is in the end of time vector
                    spike_end = length(t); % index of the last entry
                end
                Anm = [Anm difneg_ind(i)+1:spike_end(1)-1]; % indexes of spike values to cut out
            end
            spikelog = [spikelog; [t(Anm) U(Anm) I(Anm)]]; % log the spiked values before they are cut
            t(Anm) = []; % remove the spikes in time vector
            U(Anm) = []; % remove the corresponding entries in U_DAC vector
            I(Anm) = []; % remove the corresponding entries in Ne_I vector
            
            timelog = fromepoch(start_time);
            disp(['time anomaly found in ' datestr(timelog, 'yyyy-mm-dd') ', ' num2str(length(spikelog)) ' entries removed']);
            
            % generating variable name "spikelog_YYYYDOY" and saving it in a .mat log
            logvar = genvarname(sprintf('spikelog_%4d%03d', timelog(1), date2doy(timelog(1:3))));
            eval([logvar '= spikelog;']);
            if exist([datapath, 'Cnt_CurDat/spikelog.mat'], 'file') == 2
                save([datapath, 'Cnt_CurDat/spikelog.mat'], logvar, '-append');
            else
                save([datapath, 'Cnt_CurDat/spikelog.mat'], logvar);
            end
            disp(['Anomaly saved in ' logvar]);
            %fid1 = fopen('spikelog_bias.dat', 'a'); fprintf(fid1, '%6.6g %6.6g\n', spikelog); fclose(fid1);
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    else
        disp('No U_DAC matching Ne_I');
        t_Ne = [];
        U_DAC = [];
        Ne_I = [];
        return;
    end
    
else
    disp('No data file');
    t_Ne = [];
    U_DAC = [];
    Ne_I = [];
    return;
end % if entry


if nargout<1,
    assignin('base', 't_Ne', t);
    assignin('base', 'U_DAC', U);
    assignin('base', 'Ne_I', I);
    clear t U I
else
    t_Ne = t;
    U_DAC = U;
    Ne_I = I;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
