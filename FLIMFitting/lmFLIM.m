function [p,X2,sigma_p,sigma_y,corr,R_sq,cvg_hst, converged] = lmFLIM(decay_struct)

% [p,X2,sigma_p,sigma_y,corr,R_sq,cvg_hst, converged] = lmFLIM(decay_struct)
%
% Levenberg Marquardt FLIM curve-fitting: minimize sum of weighted squared residuals
% -------- FIELDS in decay_struct ---------
% fitsetting = matrix containing information of initial parameters, p_min
% and p_max
% time   = FLIM time data
% decay  = FLIM data
% time_irf = time axis of irf data
% irf = irf data
% dp     = fractional increment of 'p' for numerical derivatives
%          dp(j)>0 central differences calculated
%          dp(j)<0 one sided 'backwards' differences calculated
%          dp(j)=0 sets corresponding partials to zero; i.e. holds p(j) fixed
%          Default:  0.001;
% fit_start,fit_end = these indexes specify the region where you want to
% analyze
% refcurve = reference curve to correct for ripple. length should be the
% same as irf. default is uniform.
%
% ---------- OUTPUT VARIABLES -------
% p       = least-squares optimal estimate of the parameter values
% X2      = Chi squared criteria
% sigma_p = asymptotic standard error of the parameters
% sigma_y = asymptotic standard error of the curve-fit
% corr    = correlation matrix of the parameters
% R_sq    = R-squared cofficient of multiple determination
% cvg_hst = convergence history
% converged = whether or not the fit has converged

%   Henri Gavin, Dept. Civil & Environ. Engineering, Duke Univ. 13 Apr 2011
%   modified from: http://octave.sourceforge.net/optim/function/leasqr.html
%   using references by
%   Press, et al., Numerical Recipes, Cambridge Univ. Press, 1992, Chapter 15.
%   Sam Roweis       http://www.cs.toronto.edu/~roweis/notes/lm.pdf
%   Manolis Lourakis http://www.ics.forth.gr/~lourakis/levmar/levmar.pdf
%   Hans Nielson     http://www2.imm.dtu.dk/~hbn/publ/TR9905.ps
%   Mathworks        optimization toolbox reference manual
%   K. Madsen, H.B., Nielsen, and O. Tingleff
%   http://www2.imm.dtu.dk/pubdb/views/edoc_download.php/3215/pdf/imm3215.pdf

%   significantly modified by Tae Yeon Yoo in Needleman Group for FLIM analysis.
%   modified on 2/20/2015

global func_calls

nexpo = decay_struct.nexpo;
Nparam = 2*nexpo+1;

time = decay_struct.time;
decay = decay_struct.decay;
time_irf = decay_struct.time_irf;
irf = decay_struct.irf;

% rough estimate of noise in noise region
noisefrom = decay_struct.noise_region(1);
noiseto = decay_struct.noise_region(2);
estNoise = mean(decay(noisefrom:noiseto));

% initial guess, lower and upper bounds of parameters
% P(t|param) (not normalized)
% if one expo:
% P = param(2)*exp(-t/param(3))+(1-param(2))
% param(2): fractional amp of expo decay
% param(3): lifetime of the first decay
%
% if two expo & fitvar = E:
% P = param(2)*param(4)*exp(-t/param(3))+param(2)*(1-param(4))*exp(-t/(param(3)*param(5)))+(1-param(2));
% param(4) : fraction of the first decay
% param(5) : ratio of tau2 to tau1
%
% if two expo & fitvar = tau2:
% P = param(2)*param(4)*exp(-t/param(3))+param(2)*(1-param(4))*exp(-t/param(3))+(1-param(2));
% param(4) : fraction of the first decay
% param(5) : lifetime of second decay
%
% param(1) : shift of decay model from IRF (usually ranges from -10 to 10)

%paramter setting
fitsetting = decay_struct.fit_result;
p_min = fitsetting(1:Nparam,4);
p_max = fitsetting(1:Nparam,5);
pinit = (p_min+p_max)/2;
pinit(2) = 1-estNoise/max(decay);
dp = decay_struct.fit_detail.dp;

% Parameters to fix
free= ~fitsetting(1:Nparam,3);

for i = find(free==0)
    pinit(i) = fitsetting(i,1);
    p_max(i) = pinit(i);
    p_min(i) = pinit(i);
end

% reference curve to correct for ripples
if isfield(decay_struct,'refcurve')==0 || isempty(decay_struct.refcurve)
    refcurve = ones(length(irf),1);
else
    refcurve = decay_struct.refcurve;    
end

converged = 1;

tensor_parameter = 0;

func_calls = 0;			% running count of function evaluations

if isfield(decay_struct,'fit_region')
    fit_start = decay_struct.fit_region(1);
    fit_end = decay_struct.fit_region(2);
else
    fit_start = min(find(decay>0));
    fit_end = max(find(decay>0));
end

%total photon counts in fit region
counts = sum(decay(fit_start:fit_end));

%laser repetition period
laserT = decay_struct.laserT;

fitvar = decay_struct.fitvar;

c = [nexpo,counts,fit_start,fit_end,fitvar,laserT];
p = pinit;

%weight on residual
%weight = (fitend-fitstart+1)/sqrt(decay(fitstart:fitend)'*decay(fitstart:fitend));
nonzeroDecay = decay;
nonzeroDecay(decay==0)=1;
sigy = sqrt(nonzeroDecay);
weight = 1./sigy(fit_start:fit_end);


t = time(fit_start:fit_end);
p = p(:); y_dat = decay(fit_start:fit_end);		% make column vectors

Npar = length(p); 			% number of parameters
Npnt = length(y_dat);			% number of data points

if length(t) ~= length(y_dat)
    disp('lm.m error: the length of t must equal the length of y_dat');
    length_t = length(t);
    length_y_dat = length(y_dat);
    X2 = 0; corr = 0; sigma_p = 0; sigma_y = 0; R_sq = 0; cvg_hist = 0;
    if ~tensor_parameter,
        return;
    end
end

% Algorithmic Paramters

prnt = 3;		% >1 intermediate results; >2 plots
MaxIter = 60*Npar;	% maximum number of iterations
epsilon_1     = 1e-8;	% convergence tolerance for gradient (default 1e-8)
epsilon_2     = 1e-7;	% convergence tolerance for parameters (default 1e-7)
epsilon_3     = 1e-6;	% convergence tolerance for Chi-square (defualt 1e-6)
epsilon_4     = 1e-2;	% determines acceptance of a L-M step
lambda_0      = 1e-2;	% initial value of damping paramter, lambda
lambda_UP_fac = 11;	% factor for increasing lambda
lambda_DN_fac =  9;	% factor for decreasing lambda
Update_Type   =  1;	% 1: Levenberg-Marquardt lambda update
% 2: Quadratic update (as in Mathworks lstsqrnonlin)
% 3: Nielsen's lambda update equations

if ( tensor_parameter & prnt == 3 ) prnt = 2; end

plotcmd='figure(11); plot(t(:,1),y_dat,''og'',t(:,1),y_hat,''-b''); axis tight; drawnow ';

p_min=p_min(:); p_max=p_max(:); 	% make column vectors

if length(dp) == 1, dp = dp*ones(Npar,1); end

idx   = find(dp ~= 0);			% indices of the parameters to be fit
Nfit = length(idx);			% number of parameters to fit
stop = 0;				% termination flag

if ( length(weight) < Npnt )		% squared weighting vector
    weight_sq = ( weight(1)*ones(Npnt,1) ).^2;
else
    weight_sq = (weight(:)).^2;
end

[alpha,beta,X2,y_hat,dydp] = lm_matx(time,p,decay,time_irf,irf,weight_sq,dp,c,fit_start,fit_end,refcurve);

if ( max(abs(beta)) < epsilon_1 )
    fprintf(' *** Your Initial Guess is Extremely Close to Optimal ***\n')
    fprintf(' *** epsilon_1 = %e\n', epsilon_1);
    stop = 1;
end


if ( Update_Type == 1 )
    lambda  = lambda_0;			% Marquardt: init'l lambda
else
    lambda  = lambda_0 * max(diag(alpha));	% Mathworks and Nielsen
    nu=2;
end


X2_old = X2;					% previous value of X2
p_old = 2*p;					% previous parameters

cvg_hst = ones(MaxIter,Npar+2);		% initialize convergence history

iteration = 0;					% iteration counter
while ( ~stop & iteration <= MaxIter )		% --- Main Loop
    
    iteration = iteration + 1;
    
    % incremental change in parameters
    if ( Update_Type == 1 )
        delta_p = pinv( alpha + lambda*diag(diag(alpha)) ) * beta;	% Marquardt
    else
        delta_p = pinv( alpha + lambda*eye(Npar) ) * beta;	% Mathworks and Nielsen
    end
    
    %  big = max(abs(delta_p./p)) > 2;			% this is a big step
    
    % --- Are parameters [a+delta_a] much better than [a] ?
    
    p_try = p;
    p_try(idx) = p(idx) + delta_p(idx);                      % update the [idx] elements
    p_try = min(max(p_min,p_try),p_max);           % apply constraints
    
    y1 = lm_decay_model(time,p_try,c,time_irf,irf,refcurve);
    y1 = y1(fit_start:fit_end);
    delta_y = y_dat - y1;       % residual error using a_try
    func_calls = func_calls + 1;
    X2_try = delta_y' * ( delta_y .* weight_sq );  % Chi-squared error criteria
    
    if ( Update_Type == 2 )
        %    One step of quadratic line update in the delta_a direction for minimum X2
        X2_try1 = X2_try;
        alpha_q = beta'*delta_p / ( (X2_try1 - X2)/2 + 2*beta'*delta_p ) ;
        delta_p = delta_p * alpha_q;
        
        p_try = p;
        p_try(idx) = p(idx) + delta_p(idx);                     % update only [idx] elements
        p_try = min(max(p_min,p_try),p_max);          % apply constraints
        
        y2 = lm_decay_model(time,p_try,c,time_irf,irf,refcurve);
        y2 = y2(fit_start:fit_end);
        delta_y = y_dat - y2;      % residual error using p_try
        func_calls = func_calls + 1;
        X2_try = delta_y' * ( delta_y .* weight_sq ); % Chi-squared error criteria
    end
    
    rho = (X2 - X2_try) / ( 2*delta_p' * (lambda * delta_p + beta) ); % Nielsen
    
    if ( rho > epsilon_4 )		% it IS significantly better
        
        X2_old = X2;
        p_old = p;
        p = p_try(:);			% accept p_try
        
        [alpha,beta,X2,y_hat,dydp] = lm_matx(time,p,decay,time_irf,irf,weight_sq,dp,c,fit_start,fit_end,refcurve);
        
        % decrease lambda ==> Gauss-Newton method
        
        if ( Update_Type == 1 )
            lambda = max(lambda/lambda_DN_fac,1.e-7);		% Levenberg
        end
        if ( Update_Type == 2 )
            lambda = max( lambda/(1 + alpha_q) , 1.e-7 );	% Mathworks
        end
        if ( Update_Type == 3 )
            lambda = lambda*max( 1/3, 1-(2*rho-1)^3 ); nu = 2;	% Nielsen
        end
        
        if ( prnt > 2 )
            %eval(plotcmd);
        end
        
    else					% it IS NOT better
        
        X2 = X2_old;			% do not accept a_try
        
        % increase lambda  ==> gradient descent method
        
        if ( Update_Type == 1 )
            lambda = min(lambda*lambda_UP_fac,1.e7);		% Levenberg
        end
        if ( Update_Type == 2 )
            lambda = lambda + abs((X2_try - X2)/2/alpha_q);	% Mathworks
        end
        if ( Update_Type == 3 )
            lambda = lambda * nu;   nu = 2*nu;			% Nielsen
        end
        
    end
    
    if ( prnt > 1 )
        fprintf('>%3d | chi_sq=%10.3e | lambda=%8.1e \n', iteration,X2,lambda );
        fprintf('    param:  ');
        for pn=1:Npar
            fprintf(' %10.3e', p(pn) );
        end
        fprintf('\n');
        fprintf('    dp/p :  ');
        for pn=1:Npar
            fprintf(' %10.3e', delta_p(pn) / p(pn) );
        end
        fprintf('\n');
    end
    
    
    cvg_hst(iteration,:) = [ p'  X2/2  lambda ];	% update convergence history
    
    
    if ( max(abs(delta_p./p)) < epsilon_2  &  iteration > 2 )
        fprintf(' **** Convergence in Parameters **** \n')
        fprintf(' **** epsilon_2 = %e\n', epsilon_2);
        stop = 1;
    end
    if ( X2/Npnt < epsilon_3  &  iteration > 2 )
        fprintf(' **** Convergence in Chi-square  **** \n')
        fprintf(' **** epsilon_3 = %e\n', epsilon_3);
        stop = 1;
    end
    if ( max(abs(beta)) < epsilon_1  &  iteration > 2 )
        fprintf(' **** Convergence in r.h.s. ("beta")  **** \n')
        fprintf(' **** epsilon_1 = %e\n', epsilon_1);
        stop = 1;
    end
    if ( iteration == MaxIter )
        disp(' !! Maximum Number of Iterations Reached Without Convergence !!')
        stop = 1;
        converged = 0; 
    end
    
end					% --- End of Main Loop

% --- convergence achieved, find covariance and confidence intervals

% equal weights for paramter error analysis
weight_sq = (Npnt-Nfit+1)/(delta_y'*delta_y) * ones(Npnt,1);

[alpha,beta,X2,y_hat,dydp] = lm_matx(time,p,decay,time_irf,irf,weight_sq,dp,c,fit_start,fit_end,refcurve);

if nargout > 2				% standard error of parameters
    covar = pinv(alpha);
    sigma_p = sqrt(diag(covar));
end

if nargout > 3				% standard error of the fit
    %  sigma_y = sqrt(diag(dydp * covar * dydp'));
    sigma_y = zeros(Npnt,1);
    for i=1:Npnt
        sigma_y(i) = dydp(i,:) * covar * dydp(i,:)';
    end
    sigma_y = sqrt(sigma_y);
end

if nargout > 4				% parameter correlation matrix
    corr = covar ./ [sigma_p*sigma_p'];
end

if nargout > 5				% coefficient of multiple determination
    R_sq = corrcoef([y_dat y_hat]);
    R_sq = R_sq(1,2).^2;
end

if nargout > 6				% convergence history
    cvg_hst = cvg_hst(1:iteration,:);
end

nonzero_data = decay;
nonzero_data(find(decay==0))=1;
sigy = sqrt(nonzero_data);
weight_sq = 1./sigy(fit_start:fit_end).^2;

[alpha,beta,X2,y_hat,dydp] = lm_matx(time,p,decay,time_irf,irf,weight_sq,dp,c,fit_start,fit_end,refcurve);
X2 = X2/(Npnt-Nfit-1);

% endfunction  # ---------------------------------------------------------- LM


function dydp = lm_dydp(time,p,y,time_irf,irf,dp,c,fit_start,fit_end,refcurve)
% dydp = lm_dydp(t,p,y,{dp},{c})
%
% Numerical partial derivatives (Jacobian) dy/dp for use with lm.m
% Requires n or 2n function evaluations, n = number of nonzero values of dp
% -------- INPUT VARIABLES ---------
% t  = m-vector of independent variables (used as arg to func)
% p  = n-vector of current parameter values
% y  = func(t,p,c) n-vector initialised by user before each call to lm_dydp
% dp = fractional increment of p for numerical derivatives
%      dp(j)>0 central differences calculated
%      dp(j)<0 one sided differences calculated
%      dp(j)=0 sets corresponding partials to zero; i.e. holds p(j) fixed
%      Default:  0.001;
% c  = optional vector of constants passed to y_hat = func(t,p,c)
%---------- OUTPUT VARIABLES -------
% dydp = Jacobian Matrix dydp(i,j)=dy(i)/dp(j)	i=1:n; j=1:m

%   Henri Gavin, Dept. Civil & Environ. Engineering, Duke Univ. November 2005
%   modified from: ftp://fly.cnuce.cnr.it/pub/software/octave/leasqr/
%   Press, et al., Numerical Recipes, Cambridge Univ. Press, 1992, Chapter 15.


global func_calls

m=length(y);			% number of data points
n=length(p);			% number of parameters

if nargin < 7
    dp = 0.001*ones(1,n);
end

ps=p; dydp=zeros(m,n); del=zeros(n,1);         % initialize Jacobian to Zero

for j=1:n                       % loop over all parameters
    
    del(j) = dp(j) * (1+abs(p(j)));  % parameter perturbation
    p(j)   = ps(j) + del(j);	      % perturb parameter p(j)
    
    if del(j) ~= 0
        y1=lm_decay_model(time,p,c,time_irf,irf,refcurve);
        y1=y1(fit_start:fit_end);
        func_calls = func_calls + 1;
        
        if (dp(j) < 0)		% backwards difference
            dydp(:,j) = (y1-y)./del(j);
        else			% central difference, additional func call
            p(j) = ps(j) - del(j);
            y2 = lm_decay_model(time,p,c,time_irf,irf,refcurve);
            y2 = y2(fit_start:fit_end);
            dydp(:,j) = (y1-y2) ./ (2 .* del(j));
            func_calls = func_calls + 1;
        end
    end
    
    p(j)=ps(j);		% restore p(j)
    
end

% endfunction # ------------------------------------------------------ LM_DYDP



function [alpha,beta,Chi_sq,y_hat,dydp] = lm_matx(time,p,data,time_irf,irf,weight_sq,dp,c,fit_start,fit_end,refcurve)
% [alpha,beta,Chi_sq,y_hat,dydp] = lm_matx(func,t,p,y_dat,weight_sq,{da},{c})
%
% Evaluate the linearized fitting matrix, alpha, and vector beta,
% and calculate the Chi-squared error function, Chi_sq
% Used by Levenberg-Marquard algorithm, lm.m
% -------- INPUT VARIABLES ---------
% t     = m-vectors or matrix of independent variables (used as arg to func)
% p     = n-vector of current parameter values
% y_dat = n-vector of data to be fit by func(t,p,c)
% weight_sq = square of the weighting vector for least squares fit ...
%	    inverse of the standard measurement errors
% dp = fractional increment of 'p' for numerical derivatives
%      dp(j)>0 central differences calculated
%      dp(j)<0 one sided differences calculated
%      dp(j)=0 sets corresponding partials to zero; i.e. holds p(j) fixed
%      Default:  0.001;
% c  = optional vector of constants passed to y_hat = func(t,p,c)
%---------- OUTPUT VARIABLES -------
% alpha	= linearized Hessian matrix (inverse of covariance matrix)
% beta  = linearized fitting vector
% Chi_sq = 2*Chi squared criteria: weighted sum of the squared residuals WSSR
% y_hat = model evaluated with parameters 'p'

%   Henri Gavin, Dept. Civil & Environ. Engineering, Duke Univ. November 2005
%   modified from: ftp://fly.cnuce.cnr.it/pub/software/octave/leasqr/
%   Press, et al., Numerical Recipes, Cambridge Univ. Press, 1992, Chapter 15.

global func_calls

Npar = length(p);		% number of parameters

y_dat = data(fit_start:fit_end);
%size(y_dat)

alpha = zeros(Npar);
beta  = zeros(Npar,1);

y_hat = lm_decay_model(time,p,c,time_irf,irf,refcurve); % evaluate model using parameters 'p'
y_hat = y_hat(fit_start:fit_end);
%size(y_hat)
func_calls = func_calls + 1;

delta_y = y_dat - y_hat;	% residual error between model and data

dydp = lm_dydp(time,p,y_hat,time_irf,irf,dp,c,fit_start,fit_end,refcurve);

alpha = dydp' * ( dydp .* ( weight_sq * ones(1,Npar) ) );

beta  = dydp' * ( weight_sq .* delta_y );

Chi_sq = delta_y' * ( delta_y .* weight_sq ); 	% Chi-squared error criteria

% endfunction  # ------------------------------------------------------ LM_MATX

