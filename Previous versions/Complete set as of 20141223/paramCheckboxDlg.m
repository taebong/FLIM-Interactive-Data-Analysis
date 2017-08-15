function ans = paramCheckboxDlg(default)


fheight = 300;
InputFig = figure('units','pixels','position',[800,700,200,fheight],...
    'toolbar','none','menu','none','UserData','Cancel');
% Create yes/no checkboxes
cbox(1) = uicontrol('style','checkbox','units','pixels',...
    'position',[20,fheight-25,50,15],'string','shift','fontsize',12,'Value',1);
cbox(2) = uicontrol('style','checkbox','units','pixels',...
    'position',[20,fheight-50,50,15],'string','A','fontsize',12,'Value',1);
cbox(3) = uicontrol('style','checkbox','units','pixels',...
    'position',[20,fheight-75,50,15],'string','tau','fontsize',12,'Value',1);
cbox(4) = uicontrol('style','checkbox','units','pixels',...
    'position',[20,fheight-100,50,15],'string','f','fontsize',12,'Value',1);
cbox(5) = uicontrol('style','checkbox','units','pixels',...
    'position',[20,fheight-125,50,15],'string','E','fontsize',12,'Value',1);
cbox(6) = uicontrol('style','checkbox','units','pixels',...
    'position',[20,fheight-150,50,15],'string','f2','fontsize',12,'Value',1);
cbox(7) = uicontrol('style','checkbox','units','pixels',...
    'position',[20,fheight-175,50,15],'string','E2','fontsize',12,'Value',1);
% cbox(8) = uicontrol('style','checkbox','units','pixels',...
%     'position',[20,fheight-200,50,15],'string','mean(tau)','fontsize',12,'Value',1);
% 
% bg = uibuttongroup('Visible','off','Position',[0 0 1 0.35],...
%     'SelectionChangedFcn',@bselection);

% % Create three radio buttons in the button group.
% r1 = uicontrol(bg,'Style',...
%     'radiobutton',...
%     'String','Decay name',...
%     'Position',[20 70 100 30],...
%     'HandleVisibility','off');
% 
% r2 = uicontrol(bg,'Style','radiobutton',...
%     'String','Time',...
%     'Position',[115 70 100 30],...
%     'HandleVisibility','off');
% 
% %rbutton(1) = uicontrol('style','radiobutton','string','name','fontsize',12,'Value',1);
% 
% % Make the uibuttongroup visible after creating child objects.
% bg.Visible = 'on';

if nargin == 0
    default = ones(length(cbox),1);
end

for i = 1:length(cbox)
    cbox(i).Value = default(i);
end
% Create OK pushbutton
buttonOk = uicontrol('style','pushbutton','units','pixels',...
    'position',[22,20,70,40],'string','OK',...
    'callback',@doCallback,'fontsize',13,'UserData','OK');
buttonCancel = uicontrol('style','pushbutton','units','pixels',...
    'position',[110,20,70,40],'string','Cancel',...
    'callback',@doCallback,'fontsize',13,'UserData','Cancel');


if ishghandle(InputFig)
    % Go into uiwait if the figure handle is still valid.
    % This is mostly the case during regular use.
    uiwait(InputFig);
end

% Check handle validity again since we may be out of uiwait because the
% figure was deleted.
if ishghandle(InputFig)
    if strcmp(get(InputFig,'UserData'),'OK'),
        vals = get(cbox,'value');
        ans=find([vals{:}]);
        if isempty(ans)
            ans = -99;
        end
    end
    delete(InputFig);
else
    ans=-99;
end
drawnow; % Update the view to remove the closed figure (g1031998)


% Pushbutton callback
    function doCallback(obj, evd) %#ok
        if ~strcmp(get(obj,'UserData'),'Cancel')
            set(gcbf,'UserData','OK');
            uiresume(gcbf);
        else
            delete(gcbf)
        end
    end
end