close all
clear all

pathname = 'E:\Needleman Lab\Analysis\FLIM\Interactive Data analysis\2DGaussFit\WeightedLSTestResult\';
filename = 'xtest**.mat';
data=dir([pathname filename]);

for i = 1:length(data)
    load([pathname data(i).name]);
    
    h = figure;
    subplot(1,2,1), imagesc(x,y,z)
    axis image;
    
    pstring=sprintf('%g,',param(1,:));
    if size(param,1) ==2
        pstring2=sprintf('%g,',param(2,:));
        text(mean(x),max(y)+3.2,pstring2,'HorizontalAlignment','center');
    end
    text(mean(x),max(y)+1.8,'x,y,sigx,sigy,theta,h,bg','HorizontalAlignment','center');
    text(mean(x),max(y)+2.5,pstring,'HorizontalAlignment','center');
    text(mean(x),min(y)-1.5,['# photons=',num2str(Ntot(1))],'HorizontalAlignment','center');
    
    subplot(1,2,2), plot(pfit(:,1),pfit(:,2),'ob');
    hold on
    plot(cm(:,1),cm(:,2),'xr');
    fitstring=sprintf('%.2f,',mean(pfit,1));
    stdfit = sprintf('%.2f,',std(pfit,1));
    text(param(1,1),param(1,2)+1.8,'mean pfit','HorizontalAlignment','center');
    text(param(1,1),param(1,2)+1.6,fitstring,'HorizontalAlignment','center');
    text(param(1,1),param(1,2)+1.4,'std pfit','HorizontalAlignment','center');
    text(param(1,1),param(1,2)+1.2,stdfit,'HorizontalAlignment','center');
    text(param(1,1),param(1,2)-1.3,['mean xrms=',num2str(mean(xrms))],'HorizontalAlignment','center');
    text(param(1,1),param(1,2)-1.5,['std xrms=',num2str(std(xrms))],'HorizontalAlignment','center');
    
    axis image
    axis([param(1,1)-1,param(1,1)+1,param(1,2)-1,param(1,2)+1]);
    
    
    legend('LS','CM')

    print(h,'-dpng',[pathname data(i).name(1:end-4) '.png'])
    close(h)
    
end