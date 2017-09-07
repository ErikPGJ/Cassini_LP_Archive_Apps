function SC=Setup_Cassini()

% Spacecraft structure for Cassini with all info needed
SC=[];            
SC.DBH        = 0;                 % ISDAT data base handler
SC.DBH_Name   = 'titan.irfu.se';   % ISDAT host server
SC.DBH_Ports  = [33];              % Possible ports
SC.PRO        = 'Cassini';         % Project name
SC.MEM        = '';                % Member
SC.INS        = 'lp';              % Instrument name
SC.SIG1       = 'sphp';            % 1 signal name
SC.SIG2       = 'cylp-Ex';         % 2 signal name
SC.SIG3       = 'cylp+Ex';         % 3 signal name
SC.SEN1       = 'sweep';           % 1 sensor name
SC.SEN2       = 'bias';            % 2 sensor name
SC.SEN3       = '20Hz';            % 3 sensor name
SC.SEN4       = 'Lp DAC';          % 4 sensor name
SC.CHA1       = '';                % 1 channel name
SC.CHA2       = '';                % 2 channel name
SC.PAR        = '';                % parameter name
SC.R_SC       = 1.0;               % Radius spacecraft  
SC.RP         = 0.025;             % Radius of spherical Langmuir Probe.
SC.SW_MAX     =  34;               % Max sweep bias
SC.SW_MIN     = -34;               % Min sweep bias
SC.SW_REL     = 2.0;               % Size of retarded electron
                                   % region in [V] to be included
                                   % in first fitting stage         
SC.Vsat       = 400e3;             % Satellite Velocity relative
								   % the plasma.
SC.R_Sun      = 9.5;               % Distance to sun 1 au
disp(['Setting up: ',SC.PRO,' S/C structure']);
