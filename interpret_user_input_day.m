% Interprets vector on form [YEAR DOY] or [YEAR DAY MONTH].
% NOTE: No argument check other than size of vector.
%
% Returns [YEAR MONTH DAY 0 0 0], i.e. BEGINNING OF DAY.
%
% Created by Erik P G Johansson, IRF Uppsala, Sweden 2016-01-26
function time_spec = interpret_user_input_day(input_time)

if ~isempty(input_time) % unless empty input
    if length(input_time) == 2
        time_spec = [doy2date(input_time(1), input_time(2)) 0 0 0]; % Set time_spec as [yyyy mm dd 0h 0m 0s]
    elseif length(input_time) == 3
        time_spec = [input_time 0 0 0];       % Set time_spec as [yyyy mm dd 0h 0m 0s]
    else        
        %error('Only enter year, month and day. Aborting...');
        error('Time specification contains the wrong number of components (should be 2 or 3).');
    end
else
    error('Time specification is empty.');
end

end
