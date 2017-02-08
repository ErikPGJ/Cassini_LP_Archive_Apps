% Read "density", i.e. measured current(!) from ISDAT. The code makes references to sweeps, and it is uncertain if/what
% it does that concerns sweeps, when the function is called for the purpose of continuous current (fix bias), which it is.
%
% ARGUMENTS AND RETURN VALUES
% ===========================
% Entry       : Scalar(?) (integer) index into SC.CONTENTS(i,*), SC.DURATION(i,*) which specifies the time period.
% t_Ne, Ne_TM : Time and value of measured currents in TM units? (internally identical array sizes)
% t_DAC, DAC  : Time and value of bias voltage      in TM units? (internally identical array sizes)
% U_DAC       :                   Bias voltage      in Volt?     (same array size as t_DAC, DAC)
% NOTE: Unknown time format (scalar).
%
function [t_Ne, Ne_TM, t_DAC, DAC, U_DAC] = GetDensity(SC,Entry)
%
% NOTE: Appears to only be called from Read_Density.m.
% NOTE: DAC appears to refer to bias voltage (DAC=digital-to-analogue converter).
% QUESTION: "help isGetDataLite" claims that default unit is "phys", not TM, but "TM" is not specified. How is that
%           possible?
%

% Start time from :  SC.CONTENTS(Entry,:)
% Duration from   :  SC.DURATION(Entry)

Ne_TM = [];
t_Ne  = [];

if (length(SC)>0)
    
    % Get "density data" (denoted 20 Hz), i.e. measured current.
    % Return values are just returned from this function (GetDensity).
    [t_Ne, Ne_TM]   = isGetDataLite( SC.DBH, SC.CONTENTS(Entry,:), SC.DURATION(Entry), SC.PRO, SC.MEM, SC.INS, SC.SIG1, SC.SEN3, SC.CHA1, SC.PAR );   % Unique arguments: SEN3, CHA1
    
    % Get "DAC values", i.e. bias voltages in TM units.
    [t_DAC, DAC]    = isGetDataLite( SC.DBH, SC.CONTENTS(Entry,:), SC.DURATION(Entry), SC.PRO, SC.MEM, SC.INS, SC.SIG1, SC.SEN4, SC.CHA1, SC.PAR );   % Unique arguments: SEN4, CHA1
    
    % The Titan +/-4 V mode has density bias = +4 V, which is max 256 DAC setting.
    % Other data has either smart Bias setting with zero at 127.5 DAC
    % and 256 DAC corresponding to +32 V. Or they have +10 V bias.
    % Read sweep bias
    [t_bias, Ubias] = isGetDataLite( SC.DBH, SC.CONTENTS(Entry,:), SC.DURATION(Entry), SC.PRO, SC.MEM, SC.INS, SC.SIG1, SC.SEN2, SC.CHA2, SC.PAR );   % Unique arguments: SEN2, CHA2
    
    % The DAC value is set near a sweep
    % Find sweep-type from associated sweep
    n_DAC = length(t_DAC);
    if n_DAC >= 1
        U_DAC = zeros(n_DAC,1);
        for i = 1:n_DAC
            %ind  = find( t_bias < t_DAC(i)+0.5 & t_bias > t_DAC(i)-1.5 );   % Select sweep. Find indices where t_bias is "close" to t_DAC(i).
            ind  = find( t_DAC(i)-1.5 < t_bias & t_bias < t_DAC(i)+0.5 );   % Select sweep. Find indices where t_bias is "close" to t_DAC(i).
            if length(ind) < 512
                U_DAC(i) = NaN;
            else
                % Each sweep has 512 points, and each sweep point
                % has two identical bias values
                U_sort   = sort( Ubias(ind(1:512)) );
                U_DAC(i) = U_sort(2*DAC(i)+2);
            end
        end % for
    else
        U_DAC = [];
        DAC   = [];
        t_DAC = [];
    end
else
    disp('Define a spacecraft structure first')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


