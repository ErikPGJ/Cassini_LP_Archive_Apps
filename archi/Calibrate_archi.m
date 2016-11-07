function [I_cal] = Calibrate_archi(SC, tm_data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [I_cal] = Calibrate_archi(SC, tm_data);
%
%    Matlab function that calibrates Cassini LP data. 
%
% Jan-Erik Wahlund, Swedish Institute of Space Physics, Uppsala Division, 1997
%
% 2016-11-07: Erik P G Johansson:
%    Renamed "Calibrate" --> "Calibrate_archi" to not confuse it with other function.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  load LPp_lg_hf.dat
  load LPn_lg_hf.dat

  I_n  = abs( LPn_lg_hf( :, 1) );
  I_p  = LPp_lg_hf( :, 1);

  tm_n = LPn_lg_hf( :, 2 );
  tm_p = LPp_lg_hf( :, 2 );

  % These curves overlap in tm. Add, sort & divide.
  tm   = [tm_p; tm_n];
  I    = [I_p; I_n];

  [tm_s, ind] = sort( tm );
  I_s           = I( ind );

  I_ns  = I_s(1:71);
  tm_ns = tm_s(1:71);
  [I_nss, ind] = sort( I_ns );
  tm_nss       = tm_ns(ind);

  I_ps = I_s(72:142);
  tm_ps = tm_s(72:142);
  [I_pss, ind] = sort( I_ps );
  tm_pss       = tm_ps(ind);

  % Smooth the calibration curves! Gives better values for 
  % small currents. Using 3:rd order polynominal fits.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Pn   = polyfit( log10(I_nss), tm_nss, 3 );
  Pp   = polyfit( log10(I_pss), tm_pss, 3 );

  % Create fine spaceing
  II = logspace(-11, -4, 1000);
  tm_Pn = polyval( Pn, log10(II) );
  tm_Pp = polyval( Pp, log10(II) );

  % Add triangel below 1e-10 A
  % Take away polyfit points below 1e-10
  ind = find( II < 1e-10 );
  II(ind)    = [];
  tm_Pn(ind) = [];
  tm_Pp(ind) = [];

  % Replace with triangel below 1e-10 A
  I_l = linspace( 1e-11, 1e-10, 100 );
  tm_n0 = polyval( Pn, -10 );
  tm_p0 = polyval( Pp, -10 );
  
  kn = (1960-tm_n0)/(1e-11-1e-10);
  kp = (1960-tm_p0)/(1e-11-1e-10);
  mn = 1960 - kn*1e-11;
  mp = 1960 - kp*1e-11;

  tm_nl = kn*I_l + mn;
  tm_pl = kp*I_l + mp;

  % Make a total calibration curve.
  I_t  = [II, II, I_l, I_l];
  tm_t = [tm_Pp, tm_Pn, tm_nl, tm_pl];

  [tm_s, ind_s] = sort( tm_t );
  I_s           = I_t( ind_s );

% tm_s must be STRICT monotonic ! Costed me 2 hours work. :-(
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for i = 1:length( tm_s )
      ind_s = find( tm_s == tm_s(i) );
      if length( ind_s ) > 1
     	 tm_s(i+1) = tm_s(i+1) + 0.1;
      end
  end

  % Skip all points below 1e-11 A! (MEASUREMENT THRESHOLD)
  [ind_thr] = find( I_s > 1e-11 );
  I_thr     = I_s( ind_thr );
  tm_thr    = tm_s( ind_thr );

  I_cal = interp1( tm_thr, I_thr, tm_data );  

  ind_sign = find( tm_data < 1960 );
  I_cal(ind_sign) = - I_cal(ind_sign);

  return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

