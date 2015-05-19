function [Ne_out] = Clean_Density( Ne, t )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [Ne_out] = Clean_Density( Ne, t )
%
%   Matlab function that clean away some bad points in the RPWS LP density
%   data.
%
% J-E. Wahlund, IRF-Uppsala, 2004.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check number of input and output parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  error(nargchk(2,2,nargin))
  error(nargchk(1,1,nargout))

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

  Ne( 1:n_skip ) = NaN .* zeros(1,n_skip);
  Ne_out = Ne;

  return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

