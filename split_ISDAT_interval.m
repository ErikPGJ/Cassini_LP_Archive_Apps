% Function for dealing with an ISDAT bug which causes calls for ISDAT data to fail for certain longer time
% intervals (possibly time intervals which include certain samples).
% Takes ISDAT time interval and splits it up into multiple ones.
%
%
% ARGUMENTS
% =========
% i                  : Index to time interval in CONTENTS and DURATION.
% N                  : Number of pieces to split the ISDAT time interval into.
% CONTENTS, DURATION (also known as "start", "dur"): As output from isGetContentLite.
%
%
% Initially created 2017-11-06 by Erik P G Johansson, IRF Uppsala, Sweden.
%
function [CONTENTS, DURATION] = split_ISDAT_interval(CONTENTS, DURATION, i, N)
% PROPOSAL: Include functionality for finding row.

    % ASSERTION
    if N < 1
        error('Illegal argument N=%i.', N)
    elseif (i < 0) || (size(CONTENTS,1) < i)
        error('Illegal argument i=%i.', i)
    elseif size(DURATION, 2) ~= 1
        error('Illegal size of DURATION.')
    elseif size(CONTENTS, 1) ~= size(DURATION, 1)
        error('Illegal combination of sizes of CONTENTS and DURATION.')
    end

    t_start_0 = toepoch(CONTENTS(i, :));
    dt_0      = DURATION(i);
    
    t_stop_0 = t_start_0 + dt_0;
    
    t_start_1 = linspace(t_start_0, t_stop_0, N+1)';   % linspace gives row vector + transpose ==> column vector.
    dt_1 = diff(t_start_1);
    t_start_1(end) = [];
    
    CONTENTS_replacement = fromepoch(t_start_1);
    DURATION_replacement = dt_1;    % Column vector
    
    % Replace original row with multiple rows.
    CONTENTS = [CONTENTS(1:(i-1), :); CONTENTS_replacement; CONTENTS((i+1):end, :)];
    DURATION = [DURATION(1:(i-1), :); DURATION_replacement; DURATION((i+1):end, :)];
end
