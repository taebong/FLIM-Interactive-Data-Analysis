function save_fit_result(pathname, decay_struct)

ex = exist(pathname,'dir');

if pathname == 0
    errordlg('Enter valid pathname')
elseif ex == 0
    mkdir(pathname);
end

fitting_method = decay_struct.fitting_method;
nexpo = decay_struct.nexpo;

if fitting_method == 0
    errordlg('Fit before save result');
else
    if fitting_method == 1
        method = 'LS';
    elseif fitting_method == 2
        method = 'Gibbs';
    else
        method = 'Bayes';
    end
    
    N_param = 2*nexpo + 1;
    
    name = decay_struct.name;
    time = decay_struct.time;
    decay = decay_struct.decay;
    fit_region = decay_struct.fit_region;
    fit = decay_struct.fit;
    residual = decay_struct.residual;
    fit_result =  decay_struct.fit_result;
    Chi_sq = decay_struct.Chi_sq;
    irf = decay_struct.irf;
    time_irf = decay_struct.time_irf;
    fitvar = decay_struct.fitvar;
    
    h(1) = figure;
    subplot(4,1,(1:3)');
    semilogy(time,decay,'ro')
    hold on;
    semilogy(time(fit_region(1):fit_region(2)),fit,'k');
    xlim([time(1),time(end)]);
    ylabel('count')
    legend('Decay',[method, ' Fit'])
    
    subplot(4,1,4);
    plot(time,residual);
    hold on;
    line([0;10],[0,0])
    xlim([time(1),time(end)]);
    ylim([-5,5]);
    xlabel('time (ns)');
    
    %S = datestr(now,'yyyymmddTHHMM');
    
    %saveas(h(1),[pathname, '/', S, '_' name, '_', method, '_Fit.fig'])
    saveas(h(1),[pathname, '/', name, '_', method, '_Fit.fig'])
    close(h(1));
    
    h(2) = figure;
    histogram(residual,-5:5)
    xlabel('Weighted Residual')
    ylabel('Freq')
    
    saveas(h(2),[pathname, '/', name, '_', method, '_Fit_Residual.fig'])
    close(h(2))
    
    if fitting_method == 2
        h(3) = figure;
        dp = decay_struct.dp;
        pmin = decay_struct.fit_result(:,4);
        pmax = decay_struct.fit_result(:,5);
        psampled = decay_struct.post;
        for i = 1:N_param
            subplot(N_param,1,i)
            histogram(psampled(i,:),'BinMethod','sturges','BinLimits',[pmin(i),pmax(i)],'BinWidth',dp(i));
            switch i
                case 1
                    xlabel('shift');
                case 2
                    xlabel('A');
                case 3
                    xlabel('tau');
                case 4
                    xlabel('f');
                case 5
                    xlabel('E');
            end
        end
        
        saveas(h(3),[pathname, '/', name, '_', method, '_Marginal_Posterior.fig'])
        close(h(3))
        
    elseif fitting_method == 3
        h(3) = figure;
        p_vec = decay_struct.p_vec;
        marg_post = decay_struct.marg_post;
        
        for j = 1:N_param
            subplot(N_param,1,j)
            plot(p_vec{j},marg_post{j},'linewidth',3);
        end
        
        saveas(h(3),[pathname, '/', name, '_', method, '_Marginal_Posterior.fig'])
        close(h(3))
        
    end
    
    
%     p_result = cell(8,6);
%     if fitvar == 1
%         p_result(2:8,1) = {'shift';'A';'tau1';'f';'E';'f2';'E2'};
%     elseif fitvar == 2
%         p_result(2:8,1) = {'shift';'A';'tau1';'f';'tau2';'f2';'E2'};
%     end
%     p_result(1,2:6) = {'Fit','sigma','Fix','Min','Max'};
%     
%     p_result(2:8,2:6) = num2cell(fit_result);
%    xlswrite([pathname, '/', method, '_Fit_Result.xls'],p_result,name,'B2');
    
%     p_otherinfo = {'Total Count',sum(decay);'Reduced Chi-Sq',Chi_sq};
%    xlswrite([pathname, '/', method, '_Fit_Result.xls'],p_otherinfo,name,'G3');
    
%     if fitting_method == 1
%         converged = decay_struct.converged;
%         p_method_info = {'Fitting Method', 'LM'; 'Converged?',converged};
%     elseif fitting_method ==3
%         prior = decay_struct.prior;
%         if prior == 1
%             prior_name = 'Constant';
%         end
%         p_method_info = {'Fitting Method', 'Bayes'; 'Prior',prior_name};
%     end
%    xlswrite([pathname, '/', method, '_Fit_Result.xls'],p_method_info,name,'J3');
    
    save([pathname, '/', name,'_',method,'_fitted_decay.mat']...
        ,'decay_struct');
    
end



