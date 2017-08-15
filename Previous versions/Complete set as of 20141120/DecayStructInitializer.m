function outputdecaystruct = DecayStructInitializer(inputdecaystruct)

outputdecaystruct = inputdecaystruct;

outputdecaystruct.decay_handle = -99;
outputdecaystruct.fit_handle = -99;
outputdecaystruct.residual_handle = -99;
outputdecaystruct.residual = [];

outputdecaystruct.fit_result = zeros(7,3);
outputdecaystruct.fit_result(1,1) = 0;
outputdecaystruct.fit_result(1,3) = 1;
outputdecaystruct.fit_result(:,4) = [-15;0.7;2;0.01;0.01;0.01;0.3];
outputdecaystruct.fit_result(:,5) = [15;1;4;1;0.3;1;0.8];

outputdecaystruct.Chi_sq = 0;
outputdecaystruct.fit_region = [0,0];
outputdecaystruct.noise_region = [0,0];
outputdecaystruct.fitting_method = 0;
