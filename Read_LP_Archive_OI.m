% Function that (essentially) replicates the behaviour of an older version of Read_LP_Archive (OI=old interface).
%
% Like the referred-to old version of Read_LP_Archive, this function makes certain assumptions on the locations of this
% script and of data files and uses that to derive (updated) default paths. These paths are then explicitly passed on
% as arguments to the new version of Read_LP_Archive.
% 
%
% USAGE
% =====
% DATA = Read_LP_Archive_old_behaviour()  # Function will ask used for input.
% DATA = Read_LP_Archive_old_behaviour(datatype, time, query)
%
%
% ARGUMENTS
% =========
% The arguments are identical to the same-named arguments in "Read_LP_Archive".
%
%
% /Erik P G Johansson, IRFU, 2017-08-15

%function DATA = Read_LP_Archive_OI(datatype, time, query)
function DATA = Read_LP_Archive_OI(varargin)

    % Code from old version of Read_LP_Archive
    apppath  = fileparts([mfilename('fullpath'), '.m']);    % Obtain the path to the parent directory of this MATLAB file, e.g. '/data/cassini/Cassini_LP_Archive_Apps'
    datapath = fullfile(apppath(1:end-24), 'Cassini_LP_DATA_Archive');    % 24 = length of string "/Cassini_LP_Archive_Apps".

    dat_dir = datapath;
    LP_Swp_Clb_dir = fullfile(dat_dir, 'LP_Swp_Clb', 'official_data');    % Old code: [datapath, 'LP_Swp_Clb/']
    Cnt_CurDat_dir = fullfile(dat_dir, 'Cnt_CurDat', 'official_data');    % Old code: [datapath, 'Cnt_CurDat/']

    DATA = Read_LP_Archive(dat_dir, LP_Swp_Clb_dir, Cnt_CurDat_dir, varargin{:});
    
    % Code from old version of Read_LP_Archive
    % Emulate the equivalent of old functionality in "Read_LP_Archive". (Not documented.)
    if nargout < 1
        assignin('base', 'DATA', DATA);
        %clear DATA
    end
end
