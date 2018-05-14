%
% Function for removing array values to create an array of monotonically increasing values.
%
% This function is mostly intended to replace code in Read_Density.m. Note that that the old implementation (1) only
% worked on bias timestamps (t_DAC), and not measured sample timestamps (t), and (2) removed timestamps that decreased
% compared to the immediately preceeding timestamp, i.e. did not guarantee a non-monotonic time series in the end.
%
%
% ARGUMENTS AND RETURN VALUES
% ============================
% tArray : 1D array of scalars.
% iKeep  : Indices into tArray that point to values which are (strictly) higher than all previous values.
%          Empty array is represented by size 1x0 array.
%
%
% Created 2018-05-14 by Erik P G Johansson.
%
function iKeep = keep_incrementing_values(tArray)

    % ASSERTION
    %if ~isvector(tArray)    % NOTE: isvector([]) == false; isvector(zeros(1,0)) == true
    %    error('Argument is not a vector.')
    %end
    
    % ASSERTION
    if any(~isfinite(tArray))
        error('Argument contains non-finite value(s).')
    end

    
    
    if issorted(tArray)
        iKeep = 1:numel(tArray);   % Works for tArray = [];
    else
        % CASE: tArray is not sorted.
        % CASE: numel(tArray) >= 1      NOTE: issorted([]) returns true.
        iKeep = 1;
        
        for i = 2:numel(tArray)
            if tArray(iKeep(end)) < tArray(i)
                iKeep(end+1) = i;
            end
        end
    end

end
