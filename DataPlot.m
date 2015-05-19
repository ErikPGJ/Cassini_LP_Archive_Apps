% plotter, use Read_LP_Archive to extract the measurements first
% query = same as given in Read_LP_Archive
% datatype = same as given in Read_LP_Archive
% DATA = output structure from Read_LP_Archive
%
% function DataPlot(DATA, datatype, query)
function DataPlot(DATA, datatype, query)

if ~strcmp(datatype, 'Sweep') && ~strcmp(datatype, 'Density')
    disp('Datatype not recognized. Please enter "Sweep" or "Density" without the quotation marks');
    return;
end

clearvars -except DATA query datatype

datapath =  '../Cassini_LP_DATA_Archive/';

asklabel = input('Label events? (1 = yes, 0 = no): ');

for evit = 1:numel(DATA)
    clearvars -except DATA evit query datatype asklabel datapath
    
    t = DATA(evit).tUI(:,1);
    U = DATA(evit).tUI(:,2);
    I = DATA(evit).tUI(:,3);
    
    name = DATA(evit).event;
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for Sweep data
    if strcmp(datatype, 'Sweep') 
        
        
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
        
        max_swp_length = 0;
        k = 1;
        
        % remove plateaus, average stuff out (optional) for plotting, separate
        % up-down sweeps, save into sweeps2plot
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
                    swp = [swp; sweeps2plot{k,1}(:,2)];
                    Uplot = [Uplot; sweeps2plot{k,1}(:,1)];
                    time_swp = [time_swp; ones(size(sweeps2plot{k,1}(:,1)))*sweeps2plot{k,2}];
                    timevec = [timevec; sweeps2plot{k,2}]; % one time for each sweep
                    k = k + 1;
                end
                if ~isempty(U_2)
                    sweeps2plot{k,1} = [U_2 I_2]; sweeps2plot{k,2} = t_swp(end); % one time for the whole sweep
                    swp = [swp; sweeps2plot{k,1}(:,2)];
                    Uplot = [Uplot; sweeps2plot{k,1}(:,1)];
                    time_swp = [time_swp; ones(size(sweeps2plot{k,1}(:,1)))*sweeps2plot{k,2}];
                    timevec = [timevec; sweeps2plot{k,2}]; % one time for each sweep
                    k = k + 1;
                end
                
            end
            %if max_swp_length < length(U_swp), max_swp_length = length(U_swp); end
        end
        
        
        
        %%%%%%%% flyby identifier
        eventlist = importdata([datapath, 'event_list.dat'], '\t');
        % eventlist is a structure with fields data and textdata
        % eventlist.data is YYYY DOY HH MM SS of a closest approach (SS is always 0)
        % eventlist.textdata is a cell array with first row storing comments
        % from the .dat file and second to last rows (1 more row than .data!)
        % storing {flyby_number moon} as strings
        timevec = fromepoch(timevec);
        [event_time, ~, i_list] = intersect(timevec(:,1:5), eventlist.data(:,1:5), 'rows');
        
        
        timevec = toepoch(timevec);
        
        figh = genvarname(sprintf('fig%02d', evit));
        eval([figh '= figure(evit);']);
        eval(['set(' figh ', ''Position'', [100 100 1000 400]);']);
        
        sc1 = scatter(time_swp, Uplot, 400/sqrt(length(timevec)), real(log(swp)), 'filled', 'Marker', 's');
        add_timeaxis;
        if max(Uplot) > 30
            axis([min(time_swp)-50 max(time_swp)+50 min(Uplot)-1 max(Uplot)+1]);
            mpos = max(Uplot)+2.6;
        else
            axis([min(time_swp)-50 max(time_swp)+50 min(Uplot)-0.3 max(Uplot)+0.3]);
            mpos = max(Uplot)+0.4;
        end
        
        cbar = colorbar('YTickLabel', {linspace(min(swp),max(swp),11)/1e-9});
        clh = text(0.1,0.1,'{\bf I [nA]}', 'Units', 'normalized', 'Position', [1.06 1.03]);
        set(gca, 'Position', [0.07 0.1 0.8 0.75]);
        
        texth = text(0.1,0.1,'{\bf log(I [nA])}');
        set( texth, 'Units', 'Normalized', 'FontSize', [14]', 'Position', [0.01 0.85]);
        
        
        %if strcmp(query,'Rev'), title('32-Volt sweeps'); else title([name ', ' datestr(fromepoch(time_swp(floor(length(time_swp)/2))), 'yyyy-mm-dd')]); end
        if timevec(end)-timevec(1) >= 84600
            titlestr = [datestr(fromepoch(timevec(1)),'yyyy-mm-dd HH:MM') ' to ' datestr(fromepoch(timevec(end)),'yyyy-mm-dd HH:MM')];
        else
            titlestr = datestr(fromepoch(timevec(1)),'yyyy-mm-dd');
        end
        ttl = text(0.7,1.15, titlestr ,'Units','normalized');
        
        ylabel('\bf{U_{bias}  [V]}');
        xlabel('\bf{UT}');
        
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for Density data
    elseif strcmp(datatype, 'Density')
        
        %%%%%%%% flyby identifier
        eventlist = importdata([datapath, 'event_list.dat'], '\t');
        % flybylist is a structure with fields data and textdata
        % flybylist.data is YYYY DOY HH MM SS of a closest approach (SS is always 0)
        % flybylist.textdata is a cell array with first row storing comments
        % from the .dat file and second to last rows (1 more row than .data!)
        % storing {flyby_number moon} as strings
        t = fromepoch(t);
        [event_time, ~, i_list] = intersect(t(:,1:5), eventlist.data(:,1:5), 'rows');
        t = toepoch(t);
        
        figh = genvarname(sprintf('fig%02d', evit));
        eval([figh '= figure(evit);']);
        eval(['set(' figh ', ''Position'', [100 100 1000 400]);']);
        
        sct=scatter(t,real(log(I)),40,U,'filled','Marker','s');
        add_timeaxis;
        cbar = colorbar('YTickLabel', {linspace(min(U),max(U),10)});
        clh = text(0.1,0.1,'{\bf U [V]}', 'Units', 'normalized', 'Position', [1.06 1.03]);
        set(gca, 'Position', [0.07 0.1 0.8 0.75]);
        
        if t(end)-t(1) >= 84600
            titlestr = [datestr(fromepoch(t(1)),'yyyy-mm-dd HH:MM') ' to ' datestr(fromepoch(t(end)),'yyyy-mm-dd HH:MM')];
        else
            titlestr = datestr(fromepoch(t(1)),'yyyy-mm-dd');
        end
        ttl = text(0.7,1.15, titlestr ,'Units','normalized');
        
        texth = text(0.1,0.1,'{\bf log(I [mA])}');
        set( texth, 'Units', 'Normalized', 'FontSize', [14]', 'Position', [0.01 0.85]);
        
        ylabel('\bf{I [mA]}');
        set(gca, 'YTickLabel', linspace(min(I),max(I),9)/1e-6);
        xlabel('\bf{UT}');
        datatype = 'Continuous Current Density';
        mpos = max(real(log(I)))+2;
    end
    
    header_str = ['Cassini RPWS LP ' query ' ' datatype ' Data '];
    texth     = text(0.1,0.1,header_str, 'FontSize', 14, 'FontWeight', 'bold');
    set(texth,'Units','normalized', ...
        'Position',[-0.07 1.15], ...
        'FontName', 'Times', ...
        'FontWeight', 'bold', ...
        'FontSize', 14);
    
    
    if asklabel
        for i = 1:size(event_time,1)
            text(toepoch([event_time(i,:) 0]), mpos, [eventlist.textdata{i_list(i)+1,1} sprintf('\n|') num2str(eventlist.data(i_list(i),7)) eventlist.textdata{i_list(i)+1,3}], 'FontSize', 10, 'FontWeight', 'bold');
        end
    end
    
end
return