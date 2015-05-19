

for evit = 1:numel(DATA)
	
	
	clearvars -except DATA evit query datatype asklabel DATA_CLEANED
	
	if ~isempty(DATA(evit).tUI)
		t = DATA(evit).tUI(:,1);
		U = DATA(evit).tUI(:,2);
		I = DATA(evit).tUI(:,3);
		
		name = DATA(evit).event;
		
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for Sweep data
		
		
		% indexing start and end of sweeps
		swp_end_ind = find(diff(t) > 1);
		swp_start_ind = [1; swp_end_ind+1];
		swp_end_ind = [swp_end_ind; length(t)];
		
		% sweep length for each sweep
		% (obs, using diff here won't give length of the last sweep)
		% max_swp_length = 1 - swp_start_ind + swp_end_ind; % this gives length of all sweeps (also possible to do diff and add length of last sweep)
		
		swp = []; Uplot = []; time_swp = []; timevec = [];
		
		% split data into sweeps
		for i = 1:length(swp_start_ind)
			t_swp = t(swp_start_ind(i):swp_end_ind(i)); % time for i-th sweep
			U_swp = U(swp_start_ind(i):swp_end_ind(i)); % U for i-th sweep
			I_swp = I(swp_start_ind(i):swp_end_ind(i)); % I for i-th sweep
			
			% make a cell array with each cell containing one sweep
			sweeps{i,1} = [t_swp U_swp I_swp];
		end
				
		tUI = [];
		for i = 1:size(sweeps,1)	
			if size(sweeps{i},1) == 1024
				tUI = [tUI; sweeps{i}];
			end
		end
		
		DATA_CLEANED(evit).tUI = tUI;
		DATA_CLEANED(evit).event = name;
		
	end
	
end
