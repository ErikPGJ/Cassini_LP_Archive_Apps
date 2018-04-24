%
% Interprets vector on form [YEAR DOY] or [YEAR DAY MONTH].
% NOTE: No argument check other than size of vector.
%
%
% ARGUMENTS AND RETURN VALUE
% ==========================
% modifiedTimeVector : Vector [YEAR DOY] or [YEAR MONT DAY_OF_MONT]
% timeVector         : Equivalent vector [YEAR MONTH DAY 0 0 0], i.e. BEGINNING OF DAY.
%
%
% Created by Erik P G Johansson, IRF Uppsala, Sweden 2016-01-26.
% (Code reorganized into separate function to avoid duplicating code.)
%
function timeVector = interpret_user_input_day(modifiedTimeVector)

if ~isempty(modifiedTimeVector) % unless empty input
    if length(modifiedTimeVector) == 2
        
        timeVector = [doy2date(modifiedTimeVector(1), modifiedTimeVector(2)), 0, 0, 0];   % Set timeVector to [yyyy mm dd 0h 0m 0s].
        
    elseif length(modifiedTimeVector) == 3
        
        timeVector = [modifiedTimeVector, 0, 0, 0];       % Set timeVector to [yyyy mm dd 0h 0m 0s].
        
    else        
        error('Time specification vector contains the wrong number of components (should be 2 or 3).');
    end
else
    error('Time specification vector is empty.');
end

end
