%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_Dens.m
%
%    Script that plots the density output values.
%
% J-E. Wahlund, IRF-Uppsala, 2004.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  t_YmdHms = fromepoch( t_Ne );

  dummy = 0.1;
  clf;
  cla reset;

  t0 = t_Ne(1);
  Dt = abs( t_Ne(length(t_Ne)) - t0 );

  av_subplot(2,1,-1)
     semilogy( t_Ne, abs(Ne_I) );
     if ~isempty(Isweep)
     hold on;
        semilogy( t_sweep, Isweep, 'r.' );
     hold off;
     end
     grid;

     ylabel('[A]');
     set( gca, 'XLim', [t0 t0+Dt] );
     add_empty_axis( gca );

     texth = text(dummy,dummy,'{\bf N_e}');
     set( texth, 'Units', 'Normalized', ...
                 'FontSize', [16]', ...
                 'Position', [0.01 0.75]);

  % HEADER stuff
  %%%%%%%%%%%%%%
  header_str = ['\bf{Cassini RPWS LP}'];
  texth     = text(dummy,dummy,header_str);
  set(texth,'Units','normalized', ...
   	        'Position',[0.24 1.05], ...
	        'FontName', 'Times', ...
	        'FontWeight', 'bold', ...
                'FontSize', 16);

  t_YmdHms = fromepoch( t_Ne(1) );
  YYYY     = int2str( t_YmdHms(1) );

  if t_YmdHms(2) < 10
     MM = ['0', int2str(t_YmdHms(2))];
  else
     MM   = int2str( t_YmdHms(2) );
  end

  if t_YmdHms(3) < 10
     DD = ['0', int2str(t_YmdHms(3))];
  else
     DD   = int2str( t_YmdHms(3) );
  end

  time_str   = ['Start Date: ', YYYY,'.', MM,'.',DD];
  texth      = text(dummy,dummy,time_str);
  set(texth,'Units','normalized', ...
   	        'Position',[0.6 1.05], ...
	        'FontName', 'Times', ...
	        'FontWeight', 'bold', ...
                'FontSize', 14);


  av_subplot(2,1,-2)
     plot( t_DAC, U_DAC, 'x' );
     if ~isempty(Isweep)
     hold on;
        semilogy( t_sweep, Usweep, 'r.' );
     hold off;
     end

     grid;

     ylabel('DAC');
     set( gca, 'XLim', [t0 t0+Dt] );

     texth = text(dummy,dummy,'{\bf DAC}');
     set( texth, 'Units', 'Normalized', ...
                 'FontSize', [16]', ...
                 'Position', [0.01 0.75]);

     xlabel('\bf{UT}');
     add_timeaxis( gca );


  c_tmp    = fix( clock );
  date_str = sprintf( 'Printed: %s %02d:%02d:%02d  %s', ...
                     date, c_tmp(4), c_tmp(5), c_tmp(6));

  texth    = text( dummy, dummy, date_str);
  set(texth,'Units','normalized', ...
            'Position',[0 -0.1], ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'top', ...
            'FontSize', 8);

  drawnow;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

