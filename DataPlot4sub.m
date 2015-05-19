% plotter, use Read_LP_Archive to extract the measurements first
% gives figures with 4 subplots of events on each
% no sorting of 4/32V data, 4V is prioritized
% best used for fly-bys, not whole orbits or extended preiods of measuring with mixed
% voltage
% query = same as given in Read_LP_Archive
% datatype = same as given in Read_LP_Archive
% DATA = output structure from Read_LP_Archive


function DataPlot4sub(DATA, query, datatype)
clearvars -except DATA query datatype
for evit = 1:numel(DATA)
    if isempty(DATA(evit).tUI), continue; end
    clearvars -except DATA evit query datatype
    t = DATA(evit).tUI(:,1);
    U = DATA(evit).tUI(:,2);
    I = DATA(evit).tUI(:,3);
    
    name = DATA(evit).event;
    
    
    
    % indexing start and end of sweeps
    swp_end_ind = find(diff(t) > 1);
    swp_start_ind = [1; swp_end_ind+1];
    swp_end_ind = [swp_end_ind; length(t)];
    
    % sweep length for each sweep
    % (obs, using diff here won't give length of the last sweep)
    % max_swp_length = 1 - swp_start_ind + swp_end_ind; % this gives length of all sweeps (also possible to do diff and add length of last sweep)
    
    for i = 1:length(swp_start_ind)
        t_swp = t(swp_start_ind(i):swp_end_ind(i)); % time for i-th sweep
        U_swp = U(swp_start_ind(i):swp_end_ind(i)); % U for i-th sweep
        I_swp = I(swp_start_ind(i):swp_end_ind(i)); % I for i-th sweep
        
        % make a cell array with each cell containing one sweep
        sweeps{i,1} = [t_swp U_swp I_swp];
    end
    
    max_swp_length = 0;
    k = 1;
    
    for i = 1:size(sweeps,1)
        
        t_swp = sweeps{i}(:,1);
        U_swp = sweeps{i}(:,2);
        I_swp = sweeps{i}(:,3);
        
        ind1 = find(gradient(U_swp) < 0); % first half of the sweep indexed
        ind2 = find(gradient(U_swp) > 0); % second half of the sweep indexed
        
        if ~isempty(ind1) % needed here in case it's just a half-sweep
            if U_swp(1) == U_swp(2)
                ind1 = [ind1(1)-1; ind1];
            end
            if U_swp(end) == U_swp(end-1)
                ind1 = [ind1; ind1(end)+1];
            end
        end
        if ~isempty(ind2) % needed here in case it's just a half-sweep
            if U_swp(1) == U_swp(2)
                ind2 = [ind2(1)-1; ind2];
            end
            if U_swp(end) == U_swp(end-1)
                ind2 = [ind2; ind2(end)+1];
            end
        end
        
        % first half of the sweep
        t_1 = t_swp(ind1);
        U_1 = U_swp(ind1);
        I_1 = I_swp(ind1);
        
        % get rid of plateaus
        ind_p1 = find(diff(U_1) == 0);
        if ~isempty(U_1)
            if U_1(1) == U_1(2)
                t_1(ind_p1) = []; U_1(ind_p1) = []; I_1(ind_p1) = []; % cut out as usual
            else
                t_1(ind_p1+1) = []; U_1(ind_p1+1) = []; I_1(ind_p1+1) = []; % since first plateau is missing value, skip it and cut out from next
            end
        end
        
        % second half of the sweep
        t_2 = t_swp(ind2);
        U_2 = U_swp(ind2);
        I_2 = I_swp(ind2);
        
        % get rid of plateaus
        ind_p2 = find(diff(U_2) == 0);
        if ~isempty(U_2)
            if U_2(1) == U_2(2)
                t_2(ind_p2) = []; U_2(ind_p2) = []; I_2(ind_p2) = []; % cut out as usual
            else
                t_2(ind_p2+1) = []; U_2(ind_p2+1) = []; I_2(ind_p2+1) = []; % since first plateau is missing value, skip it and cut out from next
            end
        end
        
        t_2 = t_2(end:-1:1); U_2 = U_2(end:-1:1); I_2 = I_2(end:-1:1); % mirroring vectors for averaging with first half of sweep (only for sweepmap plot)
        
        if 0 % average the V-sweep?
            U_swp = mean([U_1 U_2], 2); % even if one half of sweep is missing, mean() works
            %t_swp = t_swp(1)*ones(length(U_swp),1);
            I_swp = mean([I_1 I_2], 2);
            sweeps2plot{i,1} = [U_swp I_swp]; sweeps2plot{i,2} = t_swp(1); % one time for the whole sweep
        else
            if ~isempty(U_1)
                sweeps2plot{k,1} = [U_1 I_1]; sweeps2plot{k,2} = t_swp(1); % one time for the whole sweep
                k = k + 1;
            end
            if ~isempty(U_2)
                sweeps2plot{k,1} = [U_2 I_2]; sweeps2plot{k,2} = t_swp(end); % one time for the whole sweep
                k = k + 1;
            end
        end
        %if max_swp_length < length(U_swp), max_swp_length = length(U_swp); end
    end
    
    clear *_mesh
    sweep4_mesh = NaN*ones(256, size(sweeps2plot, 1)); % empty matrix for pcolor
    sweep32_mesh = NaN*ones(256, size(sweeps2plot, 1)); % empty matrix for pcolor
    U_mesh32 = []; U_mesh4 = [];
    
    timevec = []; time4 = []; time32 = [];
    k = 1;
    U_plot32 = []; U_plot4 = [];
    sweeps32 = []; sweeps4 = [];
    
    for i = 1:size(sweeps2plot,1)
        if size(sweeps2plot{i,1}(:,1),1) == 256 || size(sweeps2plot{i,1}(:,1),1) == 512 % skip all non-standard sweeps (rare, at most few per day) won't go higher since plateau-removal cuts it in half and 1024 is max
            %swp_l = size(sweeps2plot{i,1},1);
            if max(sweeps2plot{i,1}(:,1)) >= 30 % if +/-32V sweep
                sweep32_mesh(:,i) = sweeps2plot{i,1}(:,2);
                U_mesh32 = sweeps2plot{i,1}(:,1);
                
                sweeps32 = [sweeps32; sweeps2plot{i,1}(:,2)];
                U_plot32 = [U_plot32; sweeps2plot{i,1}(:,1)];
                time32 = [time32; ones(size(sweeps2plot{i,1}(:,1)))*sweeps2plot{i,2}];
            elseif max(sweeps2plot{i,1}(:,1)) <= 5 % if +/-4V sweep
                %sweep4_mesh(:,k) = sweeps2plot{i,1}(:,2); k = k+1;
                %U_plot4 = sweeps2plot{i,1}(:,1);
                %time4 = [time4; sweeps2plot{i,2}];
                sweeps4 = [sweeps4; sweeps2plot{i,1}(:,2)];
                U_plot4 = [U_plot4; sweeps2plot{i,1}(:,1)];
                time4 = [time4; ones(size(sweeps2plot{i,1}(:,1)))*sweeps2plot{i,2}];
            end
            timevec = [timevec; sweeps2plot{i,2}];
        end
        %timevec = [timevec ones(size(sweeps2plot{i,1}(:,1)))*sweeps2plot{i,2}];
    end
    
    
    % z = [];
    % for i = 1:size(sweep4_mesh,1)
    % z = [z; sweep4_mesh(i,:)'];
    % end
    
    dummy      = 0.1;
    
    if mod(evit,4) == 1 % make a new figure every 4 iterations
        fig = figure;
        set(fig, 'Position', [5 5 1000 1000]);
    end
    
    if mod(evit,4) ~= 0, fsub = mod(evit,4); else fsub = 4; end % number of subplot, 1-4
    
    subplot(4,1,fsub);
    
    if ~isempty(time4)
        time_p = time4; U_plot_p = U_plot4; sweeps_p = sweeps4; % not perfected. if you increase the time interval for a flyby both 32 and 4V data will be present but only one of them printed. since 4V is first it is prioritized
    elseif ~isempty(time32)
        time_p = time32; U_plot_p = U_plot32; sweeps_p = sweeps32;
    else
        disp(['No sweeps found for ' name]);
        continue;
    end
    
    sc1 = scatter(time_p, U_plot_p, 40, real(log(sweeps_p)), 'filled', 'Marker', 's');
    add_timeaxis;
    colorbar;
    axis([min(time_p)-50 max(time_p)+50 min(U_plot_p)-1 max(U_plot_p)+1]);
    
    set(gca, 'Position', [0.07 1-fsub*0.24 0.83 0.80/4]);
    
    texth = text(dummy,dummy,'{\bf log(I [nA])}');
    set( texth, 'Units', 'Normalized', 'FontSize', [14]', 'Position', [0.01 0.85]);
    
    
    title([name ', ' datestr(fromepoch(time_p(floor(length(time_p)/2))), 'yyyy-mm-dd')]);
    ylabel('\bf{U_{bias}  [V]}')
    if fsub == 4 || i == numel(DATA), xlabel('\bf{UT}'); end
    if mod(evit,4) == 1
        header_str = ['Cassini RPWS LP ' query ' ' datatype ' Data '];
        texth     = text(dummy,dummy,header_str, 'FontSize', 14, 'FontWeight', 'bold');
        set(texth,'Units','normalized', ...
            'Position',[-0.05 1.15], ...
            'FontName', 'Times', ...
            'FontWeight', 'bold', ...
            'FontSize', 14);
    end
end
return