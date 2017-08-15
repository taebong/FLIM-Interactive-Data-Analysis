function dt = getdtfromsdt(sdt)
range = sdt.SP_TAC_R*10^9;
gain = double(sdt.SP_TAC_G);
resol = double(sdt.SP_ADC_RE);
dt = range/(gain*resol);