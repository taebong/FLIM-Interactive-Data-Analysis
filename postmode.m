function pmode = postmode(input_decay_struct,alpha)
% calculate mode and quantiles based on the Bayesian analysis result
% output_decay_struct = postModeUpdate(input_decay_struct,alpha)
% alpha is the credibility level

if nargin < 2
    alpha = 0.9;
end

fit_detail = input_decay_struct.fit_detail;

if input_decay_struct.fitting_method == 2
    psampled = fit_detail.post;
    pmode = mode(psampled,2);
    pquant_up = quantile(psampled,0.5+alpha/2,2);
    pquant_down = quantile(psampled,0.5-alpha/2,2);
elseif input_decay_struct.fitting_method == 3
    marg_post = fit_detail.marg_post;
    p_vec = fit_detail.p_vec;
    pmode = zeros(length(p_vec),1);
    pquant_up = zeros(length(p_vec),1);
    pquant_down = pquant_up;
    for j = 1:length(p_vec);
        [~,maxind] = max(marg_post{j});
        pmode(j) = p_vec{j}(maxind);
        
        cdf = cumsum(marg_post{j});
        [~,ind_up] = min(abs(cdf-(0.5+alpha/2)));
        [~,ind_down] = min(abs(cdf-(0.5-alpha/2)));
        pquant_up(j) = p_vec{j}(ind_up);
        pquant_down(j) = p_vec{j}(ind_down);
    end
end

pmode = [pmode,pquant_down,pquant_up];