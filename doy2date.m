function [out] = doy2date(YEAR,DOY)
%doy2date
% usage:
% [year month day] = doy2date(year,doy)
% 
% (c) Michiko

% = Check input parameters.==========================================
  if nargin<1, help doy2date, return, end
  error(nargchk(2,2,nargin))

% ===================================================================

out = ones(length(YEAR(:,1)),3);
for n=1:length(YEAR(:,1))
    year = YEAR(n,:); doy  =  DOY(n,:);
    total_day = cumsum(eomday(year,1:12));
    month = find( total_day>= doy ); month = month(1);
    if month>1
      pmonth = find( total_day< doy ); day = doy-total_day(pmonth(end));
    else, day = doy;
    end
    out(n,:) = [year month day];
end
