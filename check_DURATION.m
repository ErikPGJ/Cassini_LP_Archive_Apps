%
% Check DURATION (from ISDAT DBH) for too long time intervals (or negative ones), and, if requested,
% remove the too-long intervals from DURATION and CONTENTS. Optionally user-interactive.
%
%
% ARGUMENTS
% =========
% policy : Set behaviour when finding long DURATION values. One of the following string constants:
%           'interactive',
%           'non-interactive; permit long durations'.
%
%
% First created 2017-09-06 by Erik P G Johansson, IRF Uppsala, Sweden.
% (Code reorganized into separate function to avoid duplicating code.)
%
function [CONTENTS, DURATION] = check_DURATION(CONTENTS, DURATION, policy)
% NOTE: Could possibly be incorporated into isGetContentLiteWrapper instead, and be obsoleted as a separate function.

    % Maximum duration value which will not give warning. Unit seconds.
    % Traditionally, ISDAT has been loaded with data in approximately 1-hour intervals so that should be the only
    % limit that is interesting(?), but 7200 s has also been used for unknown reason.
    DURATION_WARNING_LIMIT = 2*3600;   
    %DURATION_WARNING_LIMIT = 3600;
    
    if ~isempty(DURATION(DURATION > DURATION_WARNING_LIMIT)) % check DURATION for anomalies (should not be larger than 3600 s)
        warning('WARNING! Found DURATION > %i [s]!', DURATION_WARNING_LIMIT);
        
        disp('Date (CONTENTS)         DURATION');
        disp([datestr(CONTENTS(DURATION > DURATION_WARNING_LIMIT, :), 'yyyy-mm-dd HH:MM:SS     '), num2str(DURATION(DURATION > DURATION_WARNING_LIMIT))]);
        
        if strcmp(policy, 'interactive')
            check = lower(input('Remove time intervals with too long DURATION values? Y/N [N]: ','s'));
            if isempty(check) || check == 'n'
                disp('Aborted by user');
                return;
            end
            if check == 'y'
                disp('Removing out time intervals with too long DURATION values.');
                CONTENTS(DURATION > DURATION_WARNING_LIMIT,:) = [];
                DURATION(DURATION > DURATION_WARNING_LIMIT) = [];
            end
        elseif strcmp(policy, 'non-interactive; permit long durations')
            % Do nothing
        else
            error('Illegal argument policy="%s".', policy)
        end
        
        if ~isempty(DURATION(DURATION < 0))
            %warning('WARNING! Found DURATION(s) with negative length.')
            error('WARNING! Found DURATION(s) with negative length.')
        end
    end
end