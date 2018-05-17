function DBH_test2(CA,tint)


	if length(tint(:,1)) == 1
	   tint = [tint(1:3) 0 0 0];
	   tint = [ toepoch(tint)-3600*24*1,  toepoch(tint)+3600*24*3 ];
	   tint = fromepoch(tint);
	end

	if diff(toepoch(tint))>24*3600

	   tint = toepoch(tint); tint_end = tint(2);
	   tint = tint(1):24*3600:tint(2);
	   if tint(end)~=tint_end, tint = [tint tint_end]; end


	else
	   tint = toepoch(tint);
	end


	first = 1;
	pn = 3;
	for ii=1:length(tint)-1

	    [t_Ne U_DAC Ne_I TM_val] = Read_Density(CA,fromepoch(tint(ii)),fromepoch(tint(ii+1)));

            subplot(pn,1,1)
            plot(t_Ne,Ne_I,'b.')
	    ind_neg = find(Ne_I<0);
	    if  ~isempty(ind_neg)
    	        hold on
	        plot(t_Ne(ind_neg),abs(Ne_I(ind_neg)),'r.')
	    end
	    if first
	       hold on
               time = fromepoch(t_Ne(1));
               title(sprintf('Cassini RPWS/LP %04d/%02d/%02d',time(1:3)))
               limx = t_Ne([1 end]);
               grid on
	    end
	    limx(2) = t_Ne(end);
            xlim(limx), epochtick
	    set(gca,'YScale','log')
    
            subplot(pn,1,2)
            plot(t_Ne,U_DAC,'b.')
	    hold on
	    plot(TM_val.t_DAC,TM_val.DAC_U,'r.')
	    if first
               grid on
	    end
            xlim(limx), epochtick
    
            subplot(pn,1,3)
            plot(t_Ne(1:end-1),diff(t_Ne),'k.')
	    if first
               grid on
	       hold on
	       set(gca,'YScale','log'), ylim([5e-3 20])
	       first = 0;
	    end
            xlim(limx), epochtick

	    drawnow
	    clear t_Ne U_DAC Ne_I TM_val

	end
	for ii=1:pn, subplot(pn,1,ii), hold off, end

end
