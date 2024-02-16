%
% Function for removing array values to make it easy to create an array of
% monotonically increasing values.
%
% This function is mostly intended to (maybe) replace code in Read_Density.m.
% The (old) implementation of Read_density.m that does not use this function
% (1) removes timestamps that decrease compared to the immediately preceeding
% timestamp, i.e. do not guarantee a non-monotonic time series in the end, and
% (2) sets non-incrementing MEASURED values to NaN (kees the indices),
% but removes non-incrementing DAC values (removes the indices).
% This function's return result can be used to achieve both types of handling.
%
% NOTE: As of 2018-07-02, Read_Density.m does not use this function.
%
%
% ARGUMENTS AND RETURN VALUES
% ============================
% tArray
%       1D array of logical.
% iKeep
%       Logical array of the same size as tArray. True for indices where tArray
%       values are (strictly) higher than all previous values. Empty tArray is
%       represented by size 1x0 array.
%
%
% Created 2018-05-14 by Erik P G Johansson, IRF Uppsala.
%
function iKeep = keep_incrementing_values(tArray)
    % PROPOSAL: Delete file

    % ASSERTION
    %if ~isvector(tArray)    % NOTE: isvector([]) == false; isvector(zeros(1,0)) == true
    %    error('Argument is not a vector.')
    %end

    % ASSERTION
    if any(~isfinite(tArray))
        error('Argument contains non-finite value(s).')
    end



    iKeep = true(size(tArray));
    if ~issorted(tArray)
        % CASE: tArray is not sorted.
        % CASE: numel(tArray) >= 1      NOTE: issorted([]) returns true.
        
        jLastIncrementing = 1;
        for i = 2:numel(tArray)
            if tArray(jLastIncrementing) < tArray(i)
                jLastIncrementing = i;
                % iKeep(i) = true;   % Already set
            else
                iKeep(i) = false;
            end
        end
    end
    
end
