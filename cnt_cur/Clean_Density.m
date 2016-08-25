function [Ne_out] = Clean_Density( Ne, t )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [Ne_out] = Clean_Density( Ne, t )
%
%   Matlab function that cleans away some bad points in the RPWS LP density
%   data. Sets (replaces) the first m values of Ne with NaN.
%
%   Ne_out = Modified Ne.
%
% J-E. Wahlund, IRF-Uppsala, 2004.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check number of input and output parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  narginchk(2,2)
  nargoutchk(1,1)


% Make input data as column vectors, and 
% check size of data and time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Ne = Ne(:);  
  t  = t(:);

  if (length(Ne) ~= length(t))
      error('error in Clean_Density: Input vectors not of same size');
  end

% Take away the first few data points 
% and make tham NaN.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  dt = t(2) - t(1);

  if dt > 1
     % 37 point 16 s SURVEY DATA
     n_skip = 1;
  else
     % 20 Hz DATA
     n_skip = 7;
  end
  n_skip = min(n_skip, length(Ne));   % Needed for short vectors. Example: data for 2016-204 (the version available at IRF-U as of 2016-08-25).

  Ne( 1:n_skip ) = NaN .* zeros(1,n_skip);
  Ne_out = Ne;

  return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

