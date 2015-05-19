% program to scan archive files and check for negative spikes
% days with negative spikes will be printed

disp('This scans for negative spikes in .dat archive...\n date format is [YYYY MM DD]');
s_time = input('Enter start time of scan: ');
e_time = input('Enter end time of scan: ');
s_name = sprintf('LP_archive_%4d%03d.dat', s_time(1), date2doy(s_time));
e_name = sprintf('LP_archive_%4d%03d.dat', e_time(1), date2doy(e_time));

spikelog = [];
filepath = '../../Cassini_LP_DATA_Archive/LP_Swp_Clb/';
filelist = dir(filepath); % get info on files

% identify files matching date interval
k1 = 0;
k2 = 0;
for i = 1:numel(filelist)
	if strcmp(filelist(i).name, s_name)
		k1 = i;
	end
	if strcmp(filelist(i).name, e_name)
		k2 = i;
	end
end

	

for i = k1:k2;
	LParchive = load([filepath filelist(i).name]);
	disp(['Scanning ' filelist(i).name]);
	difneg_ind = find(diff(toepoch(LParchive(:,1:6)))<0); % find negative spikes
	if ~isempty(difneg_ind) % if there are spikes at all...
		disp(['Found spike, ' num2str(fromepoch(i))]);
		spikelog = [spikelog; fromepoch(i)];
	end
end

if ~isempty(spikelog)
    disp('Spikes at following dates: ');
    disp(num2str(spikelog));
else
    disp('No spikes found in given time interval');
end


