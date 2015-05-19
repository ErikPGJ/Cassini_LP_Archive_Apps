function add_empty_axis( h, t_start_epoch );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function add_empty_axis( h, t_start_epoch );
%
%    Adds an empty axis to the axis given by handle h if t_start_epoch 
%    given, adds so many seconds to the time axis for example if time 
%    is in seconds from the beginning of 0300 UT 01-Jan-2001 then use 
%    add_empty_axis(h, toepoch([2001 01 01 03 00 00]))
%
%    Jan-Erik Wahlund, IRF-Uppsala, 2002.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if nargin < 2 
     t_start_epoch = 0; 
  end

  hh = reshape( h, 1, prod(size(h)) );
  clear h
  h  = hh;
  for j = 1:length(h)
      axes(h(j));
      ax   = axis;
      tint = ax(1:2) + t_start_epoch;
      res  = timeaxis(tint);

      set( h(j), 'XTick', res{1}-t_start_epoch );
      set( h(j), 'XTickLabel', [' '] );
  end

  start_time = fromepoch( ax(1)+t_start_epoch );
  time_label = datestr( datenum(start_time), 1 );

  disp( time_label );
  %xlabel( time_label );

  return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

