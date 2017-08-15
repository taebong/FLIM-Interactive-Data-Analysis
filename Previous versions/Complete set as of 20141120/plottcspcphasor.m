function [G,S] = plottcspcphasor(decay,ref,ref_tau,freq,delta_t) 
%decay is the array of the decay curve from TCSPC 
%ref is the decay curve of the reference or IRF curve 
%ref_tau is the lifetime of the reference compound (zero for IRF) 
%freq is the freq domain freq you want to use to plot the phasor 
%delta_t is the size (time) of each of the bins of the decay curve 

w=2*pi*freq; 

%calculate ref phasor 
Gn_ref=0; 
Sn_ref=0; 
area_ref=0; 
for bin = 1:length(ref)-1 
    Gn_ref = Gn_ref + ref(bin).*cos(w*delta_t.*(bin-.5))*delta_t; 
    Sn_ref = Sn_ref + ref(bin).*sin(w*delta_t.*(bin-.5))*delta_t; 
    area_ref = area_ref + (ref(bin) +ref(bin+1)).*delta_t./2;
end

G_ref = Gn_ref./area_ref; 
S_ref = Sn_ref./area_ref; 

%calculate phase and modulation corrections 
M_ref = (1 + (w*ref_tau).^2).^(-0.5); 
ph_ref = atan(w*ref_tau);

M_cor = sqrt(G_ref.^2+S_ref.^2)./M_ref; 
ph_cor = -atan2(S_ref,G_ref)+ph_ref; 

%calculate data phasor 
Gn=0; Sn=0; area=0; 
for bin = 1:length(decay)-1 
    Gn = Gn + decay(bin).*cos(w*delta_t.*(bin-.5))*delta_t; 
    Sn = Sn + decay(bin).*sin(w*delta_t.*(bin-.5))*delta_t; 
    area = area + (decay(bin) +decay(bin+1)).*delta_t./2;
end

Gdec = Gn./area; 
Sdec = Sn./area; 
G = (Gdec.*cos(ph_cor) - Sdec.*sin(ph_cor))./M_cor; 
S = (Gdec.*sin(ph_cor) + Sdec.*cos(ph_cor))./M_cor; 

%Plot phasor point and universal circle 
theta = 0:0.01:pi; 
plot(0.5+0.5*cos(theta),0.5*sin(theta)); 
axis([0 1 0 1]); 
axis square; 
hold on; 
xlabel('G') 
ylabel('S') 
plot(G,S,'r*')