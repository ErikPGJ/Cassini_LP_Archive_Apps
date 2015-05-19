function [t_Ne, Ne_TM, t_DAC, DAC, U_DAC] = GetDensity(SC,Entry)

% Start time from :  SC.CONTENTS(Entry,:)
% Duration from   :  SC.DURATION(Entry)

Ne_TM = [];
t_Ne  = [];

if (length(SC)>0)
    
    % Get density data (denoted 20 Hz)
    [t_Ne, Ne_TM] = isGetDataLite( SC.DBH, SC.CONTENTS(Entry,:), SC.DURATION(Entry), SC.PRO, SC.MEM, SC.INS, SC.SIG1, SC.SEN3, SC.CHA1, SC.PAR );
    
    % Get DAC values
    [t_DAC, DAC] = isGetDataLite( SC.DBH, SC.CONTENTS(Entry,:), SC.DURATION(Entry), SC.PRO, SC.MEM, SC.INS, SC.SIG1, SC.SEN4, SC.CHA1, SC.PAR );
    
    % The Titan +/-4 V mode has density bias = +4 V, which is max 256 DAC setting.
    % Other data has either smart Bias setting with zero at 127.5 DAC
    % and 256 DAC corresponding to +32 V. Or they have +10 V bias.
    % Read sweep bias
    [t_bias, Ubias] = ...
        isGetDataLite( SC.DBH, SC.CONTENTS(Entry,:), SC.DURATION(Entry), SC.PRO, SC.MEM, SC.INS, SC.SIG1, SC.SEN2, SC.CHA2, SC.PAR );
    
    % The DAC value is set near a sweep
    % Find sweep-type from associated sweep
    n_dac = length(t_DAC);
    if n_dac >= 1
        U_DAC = zeros(n_dac,1);
        for i = 1:n_dac
            ind  = find( t_bias < t_DAC(i)+0.5 & t_bias > t_DAC(i)-1.5 ); % Select sweep
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
    disp('Define a space craft structure first')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


