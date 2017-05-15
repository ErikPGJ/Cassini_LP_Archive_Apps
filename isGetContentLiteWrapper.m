%
% Wrapper around ISDAT's isGetContentLite to correct for bug(s) in the returned values.
% This function is meant to be used instead of isGetContentLite.
%
%
% ARGUMENTS AND RETURN VALUES
% ===========================
% All arguments are passed on directly to "isGetContentLite" and return values are passed on (returned) from
% "isGetContentLite". See "isGetContentLite".
%
%
% NOTE: There are at least two erroneous (too small) DURATION values. There might be many more
% (length(find(DURATION<1000)) == 125) so the code tries to correct for all ISDAT block durations < ~1 h and set them to
% ~1 h. I am uncertain if all other code will work with this.
%
% 
% Originally created 2017-02-0x by Erik P G Johansson, IRF Uppsala, Sweden.
%
function [start, dur] = isGetContentLiteWrapper( varargin )
% PROPOSAL: Manually set duration when it is suspiciously low.
%   PROPOSAL: Set it to ~3600 s.
%   PROPOSAL: Derive it from available data (measurements).
%   PROPOSAL: Derive it from the next 1 h block starting time.
%       CON: Can not handle the last block.
%       CON: Can not handle the absence of blocks (data gaps).
%
% PROPOSAL: Other code (at least Run_LP_Archi.m) contains checks for DURATION > 7200. Move to this function.
%   PRO: Shortens (removes duplication) and clarifies code.
%   NOTE: Original code (Run_LP_Archi.m) asks user for action. Can/should not keep.
%

    [start, dur] = isGetContentLite(varargin{:});
    
    % Correct for what is apparently a bug in ISDAT
    % ---------------------------------------------
    % ISDAT returns a faulty duration value and claims that there is a "data period" for
    % 2017-01-23 17:00:00.2--17:02:46.7 when it really is ~1 h as usual.
    % Therefore replaces that faulty value.
    i = find(   (start(:,1) == 2017) & (start(:,2)==1) & (start(:,3)==23) & (start(:,4)==17) & (start(:,5)==0)  );   % NOTE: Does not check for the "seconds" value.
    if ~isempty(i)
        warning('Correcting for ISDAT DURATION value bug.')
        dur(i) = 3600-0.023;    % Approximate value from inspecting the start value after.
    end
    
    
    % Correct for what is apparently a bug in ISDAT - UNFINISHED
    % ----------------------------------------------------------
    % ISDAT returns a faulty duration value and claims that there is a "data period" for
    % 2017-05-09 (2017-129) 06:xx:xx.x--xxxxxxx (length 3.441230000000000e+02) when it really is ~1 h of data as usual.
    % Therefore replaces that faulty value.
    %i = find(ismember(CONTENTS(:,1:5), [2017, 05, 09, 06, 0], 'rows'));    % NOTE: Does not check for the "seconds" value. %Check minutes correct?
    %if ~isempty(i)
    %    warning('Correcting for ISDAT DURATION value bug.')
    %    dur(i) = 3600 - xxxxx;    % Approximate value from inspecting the start value after.
    %end
    

    %=======================================================================================
    % Force all ISDAT blocks to be reported as lasting at least one hour.
    % Exact values (limit, and forced value) from Michiko Morooka. Uncertain justification.
    %=======================================================================================
    i = find(dur < 3600-0.1);
    if ~isempty(i)
        warning('Correcting for presumed ISDAT DURATION value bug.')
        dur(i) = 3600-0.01;    % Approximate EXPECTED value.
    end

end
