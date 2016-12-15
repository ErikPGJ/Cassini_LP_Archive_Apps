function tt=timeform2epoch(t,which_side)
%TIMEFORM2EPOCH change the time format into epoch format.
% usage:
% t_in_epoch = TIMEFORM2EPOCH(t)
% t is in [yyyy mm dd hh mm ss] or [yyyy doy hh mm ss]
% If t is given in [yy mm dd] or [yyyy doy], TIMEFORM2EPOCH returns
% t chose start[00:00:00.0] of the day.
% t will be chosen as end[23:59:59:999] of the day in optionly.
% Use t_in_epoch = TIMEFORM2EPOCH(t,'end')
%
% @Michiko W. Morooka

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  tt=NaN;
  if nargin<1, help timeform2epoch, return, end
  if nargin<2, which_side = 'start'; end
  if ~isequal(which_side,'start') & ~isequal(which_side,'end'), which_side = 'start'; end
  if ~isequal(class(t),'double'), disp('T MUST BE DOUBLE.'), help timeform2epoch, return, end

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      if length(t(1,:))==1, tt = t;
  elseif length(t(1,:))==2,
    switch which_side
      case 'start', tt = toepoch([doy2date(t(:,1),t(:,2)) zeros(length(t(:,1)),3)]);
      case 'end',   tt = toepoch([doy2date(t(:,1),t(:,2)) ones(length(t(:,1)),1)*[23 59 59.999]]);
    end
  elseif length(t(1,:))==3
    switch which_side
      case 'start', tt = toepoch([t zeros(length(t(:,1)),3)]);
      case 'end',   tt = toepoch([t ones(length(t(:,1)),1)*[23 59 59.999]]);
    end
  elseif length(t(1,:))==5, tt = toepoch([doy2date(t(:,1),t(:,2)) t(:,3:5)]);
  elseif length(t(1,:))==6, tt = toepoch(t); 
  else,  help timeform2epoch, return, end

  return
