% Spike Removal Tool for continuous current density data
% usage:
% run SpikeScan.m in cnt_cur directory to get the spikelog variable (and spikelog.dat) listing
% dates with negative spikes in CCD data (if spikelog.dat does not exist or
% is outdated)
% run this tool

datapath = '../../Cassini_LP_DATA_Archive/';

if ~exist('spikelog', 'var')
    if exist('spikelog.dat', 'file') == 2
        spikelog = load('spikelog.dat');
    else disp('No information on spike content');
    end
else
    
    t = toepoch(spikelog); % convert to epoch
    
    for i = 1:length(spikelog(:,1)) % loop through dates in spikelog
        filename = [datapath, sprintf('Cnt_CurDat/LP_CntCur_%4d%03d.dat', spikelog(i,1), date2doy(spikelog(i,1:3)))];
        disp(['loading ' sprintf('LP_CntCur_%4d%03d.dat', spikelog(i,1), date2doy(spikelog(i,1:3))) ' ...']);
        data = load(filename); % no existance check since spikelog only contains dates of existing files
        time = toepoch(data(:,1:6)); % extract time vector from CCD file
        
        difneg_ind = find(diff(time)<0); % find negative spikes
        cnt = 0;
        while  ~isempty(difneg_ind) % until no spikes left...
            if ~isempty(difneg_ind) % if there are spikes at all...
                Anm = find(abs(diff(time))>1); % find ALL spikes (pos & neg)
                [c, ~, ind_all] = intersect(difneg_ind,Anm); % ind_all shows index of neg. derivatives in AnmU
                if isempty(c) || length(ind_all) ~= length(difneg_ind)
                    Anm = [difneg_ind+1, difneg_ind+1]; % in case it's just a 1-value-thingie
                else
                    if c(end) ~= Anm(end) % c is the intersection, this checks if the spike is on the last sweep
                        Anm = [difneg_ind+1, Anm(ind_all+1)];
                    else Anm = [difneg_ind+1, [Anm(ind_all(1:end-1)+1); length(time)]]; % and if spike is indeed in last sweep, cut the end off
                    end
                end
                
            else
                Anm = [];
            end
            
            if ~isempty(Anm) % unless index is empty
                data(Anm(:,1):Anm(:,2),:) = []; % remove first value of the spike
                time(Anm(:,1):Anm(:,2),:) = [];
                cnt = cnt + sum(Anm(:,2)-Anm(:,1))+size(Anm,1);
            end
            difneg_ind = find(diff(time)<0); % find negative spikes
        end
        if cnt > 0
            disp(['time anomaly found in ' datestr(spikelog(i,:)) ', ' num2str(cnt) ' entries removed']);
        end
        clear Anm
        disp(['Writing ' filename]);
        fid4 = fopen(filename, 'w'); fprintf(fid4, '%4g %02g %02g %02g %02g %06.4f %+6.5e %+6.5e\n', data'); fclose(fid4);
        %dlmwrite(filename, data, 'delimiter', '\t', 'precision', 6);
        disp('Done');
        clear data filename cnt time
    end
    

end
