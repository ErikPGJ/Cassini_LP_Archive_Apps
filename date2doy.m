function doy = date2doy(day)
%date2doy
%usage: doy = date2doy(day)
%   format day:[year month date]
% (c) Michiko
% last update: Aug. 2006

% = Check input parameters.==========================================
  if nargin<1, help date2doy, return, end
  error(nargchk(1,1,nargin))

  eomdays = eomday(day(:,1)*ones(1,12),ones(length(day(:,1)),1) *[1:12]);

  % --- 'sum.m' does not work like before !!! --- % 
  % doy = sum( eomdays(:,1:day(:,2)-1),2);
  % --- Instead one shold make a loop ----------- %
    doy=[];
    for k=1:size(day,1)
        doy = [doy;sum( eomdays(k,1:day(k,2)-1),2)]; 
    end
  doy = doy + day(:,3);
  
  return
          
