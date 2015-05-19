function res = timeaxis(limit)
% res = timeaxis(limit)
%   returns tick mark locations and labels for a time axis
%   in a cell array. limit is a 2-element vector in seconds.

dtime = limit(2)-limit(1);

% get the time difference between two ticks and the number of unlabeled ticks
if dtime>3600*24*180
  dticv = 3600*24*30;
  mtics = 2;
elseif dtime>3600*24*7
  dticv = 3600*24*7;
  mtics = 7;
elseif dtime>3600*48
  dticv = 3600*24;
  mtics = 1;
elseif dtime>3600*24
  dticv = 3600*6;
  mtics = 1;
%elseif dtime>3600*12
%  dticv = 3600*2;
%  mtics = 2;
%elseif dtime>3600*5
elseif dtime>3600*12
  dticv = 3600;
  mtics = 6;
elseif dtime>=3600*2
  dticv = 1800;
  mtics = 3;
elseif dtime>3600
  dticv = 1200;
  mtics = 2;
elseif dtime>60*30
  dticv = 600;
  mtics = 5;
elseif dtime>60*10
  dticv = 300;
  mtics = 5;
elseif dtime>60*3
  dticv = 60;
  mtics = 6;
elseif dtime>60
  dticv = 20;
  mtics = 4;
elseif dtime>30
  dticv = 10;
  mtics = 5;
elseif dtime>10
  dticv = 5;
  mtics = 5;
elseif dtime>6
  dticv = 2;
  mtics = 4;
elseif dtime>3
  dticv = 1;
  mtics = 5;
elseif dtime>1
  dticv = 0.5;
  mtics = 5;
elseif dtime>.6
  dticv = .2;
  mtics = 4;
else
  dticv = 0.1;
  mtics = 5;
end

% calculate the time value of the first major tick
% tbeg = dticv*ceil(limit(1)/dticv);

% calculate the time value of the first minor tick
dmort = dticv/mtics;
tbeg = dmort*ceil(limit(1)/dmort);

% calculate the number of ticks
ttic = tbeg;
ntics = 0;
while ttic<=limit(2)
%  ttic = ttic+dticv;
  ttic = ttic+dmort;
  ntics = ntics+1;
  if ntics>100
    warning, 'too many ticks in timeaxis'
    break;
  end
end
% generate array with the time values of the major ticks
% tictv = tbeg + dticv.*[0:ntics-1];
% generate array with the time values of the ticks
tictv = tbeg + dmort*[0:ntics-1];

% generate the time strings for the labels,
ticstr = cell(1, ntics);
ticval = mod(tictv, 86400);
% use the long format hh:mm:ss, if more than one label within one second,
%     else use hh:mm
%n = find(tictv-floor(tictv)<2e-7);
n=1:ntics;
hour = floor(ticval(n)/3600);
minute = floor(mod(ticval(n), 3600)/60);
if dticv>=60
  format = '%02d:%02d';
  hhmmss = [hour; minute];
elseif dticv<1
  format = '%02d:%02d:%04.1f';
  hhmmss = [hour; minute; mod(ticval(n), 60)];
else
  format = '%02d:%02d:%02d';
  hhmmss = [hour; minute; mod(ticval(n), 60)];
end

ind_labels=find(mod(tictv,dticv)==0);
for j=n,ticstr{j} = ' ';end
for j=ind_labels, ticstr{j} = sprintf(format, hhmmss(:,j));end

ind_ms_labels=find(mod(tictv(ind_labels),1)>0);
if length(ind_ms_labels) < length(ind_labels),
for j=ind_labels(ind_ms_labels), ticstr{j} = sprintf('%4.1f', mod(tictv(j),1));end
end

res{1} = tictv;
res{2} = ticstr;
