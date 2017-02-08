%
% Wrapper around ISDAT's isGetContentLite to correct for bug(s) in the returned values.
% Use this instead of isGetContentLite.
%
function [start, dur] = isGetContentLiteWrapper( varargin )

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
end
