function [I_cal] = CalLP_Cassini( tm_data );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [I_cal] = CalLP_Cassini( tm_data );
%
%   Matlab function that calibrates Cassini LP data. 
%
%   Jan-Erik Wahlund, 
%   Swedish Institute of Space Physics, Uppsala Division, 1997.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MUST use the lf calibration files for continuous current data since it is 
% go through the A/D converter!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  load LPp_lg_lf.dat     % Loads MATLAB variable LPp_lg_lf.
  load LPn_lg_lf.dat     % Loads MATLAB variable LPn_lg_lf.

  I_n  = abs( LPn_lg_lf( :, 1) );
  I_p  = LPp_lg_lf( :, 1);

  tm_n = LPn_lg_lf( :, 2 );
  tm_p = LPp_lg_lf( :, 2 );

  % Smooth the calibration curves! Gives better values for 
  % small currents. Using 3:rd order polynominal fits.
  % NOT NEEDED FOR THE NOISE-FREE LF DATA!!!
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Pn   = polyfit( log10(I_n), tm_n, 3 );
  %Pp   = polyfit( log10(I_p), tm_p, 3 );

  %tm_Pn = polyval( Pn, log10(I_n) );
  %tm_Pp = polyval( Pp, log10(I_p) );

  % Make a total calibration curve.
  I_t  = [I_n; I_p];
  tm_t = [tm_n; tm_p];

  [tm_s, ind_s] = sort( tm_t );
  I_s           = I_t( ind_s );

% tm_s must be STRICT monotonic ! Costed me 2 hours work. :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for i = 1:length( tm_s )
      ind_s = find( tm_s == tm_s(i) );
      if length( ind_s ) > 1
         if tm_s(i+1) < 2097.5
     	    tm_s(i+1) = tm_s(i+1) + 0.1;
         else
     	    tm_s(i+1) = tm_s(i+1) - 0.1;
         end
      end
  end

  % Skip all points below 1.0e-10 A! (MEASUREMENT THRESHOLD)
  [ind_thr] = find( I_s > 1.0e-11 );
  I_thr     = I_s( ind_thr );
  tm_thr    = tm_s( ind_thr );

  I_cal = interp1( tm_thr, I_thr, tm_data );  

  ind_sign = find( tm_data < 2097.5 );
  I_cal(ind_sign) = - I_cal(ind_sign);

  return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

