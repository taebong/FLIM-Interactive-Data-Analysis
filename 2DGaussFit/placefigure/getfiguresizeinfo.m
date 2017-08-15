function currFigureSizeInfo = getfiguresizeinfo(useDefaults)
%GETFIGURESIZEINFO  Get figure size info.
%		FIGINFO = GETFIGURESIZEINFO returns a structure with information about
%		some figure sizes, for example:
%
%		FIGINFO =
% 	       screenSize: [1 1 1280 1024]
%		 figureHeadHeight: 29
%		    menuBarHeight: 21
%		    toolBarHeight: 27
%		lowerBorderHeight: 4
%		  leftBorderWidth: 4
%		 rightBorderWidth: 4
%		    taskBarHeight: 60
%
%		If the information was computed and saved before on the current host
%		and the screen size was not changed, the information only has to be
%		loaded. Otherwise, function COMPUTEFIGURESIZEINFO is started.
%
%		In case the figure size information saved before is no longer valid,
%		for example because you changed the size of the task bar, use function
%		DELETEFIGURESIZEINFO to remove the file containing the invalid
%		information.
%
%		Note 1: This function only works correct if the task bar is at the
%		bottom of your screen!
%
%		Note 2: If the obtained figure size info is not feasible on your
%		system, please help me to improve this function: Open a Matlab figure,
%		make a screenshot and send it together with text displayed by Matlab
%		function VER to the mail adress found in the HTML documentation.
%
%		Markus Buehren
%		Last modified 20.04.2008 
%
%		See also COMPUTEFIGURESIZEINFO, DELETEFIGURESIZEINFO.

if nargin == 0
	useDefaults = 0;
end
	
% check if screen size has changed
% screenSizeCheck = checkscreensize(0);

% check if figure size info has been computed before on this host
getFigureSizeInfoNow = true;
hostname = gethostname;
figureSizeInfoFile = fullfile(tempdir2, sprintf('figuresizeinfo_%s.mat', hostname));
currFigureSizeInfo = [];
figureSizeInfo = [];
if exist(figureSizeInfoFile, 'file')
	load(figureSizeInfoFile);
	
	% check if figure size info was computed before for the given screen size
	screenSize = getscreensizeinpixels;
	for k=1:length(figureSizeInfo) %#ok
		if all(figureSizeInfo(k).screenSize(3:4) == screenSize(3:4))
			currFigureSizeInfo = figureSizeInfo(k);
			getFigureSizeInfoNow = false;
			break
		end
	end
end

% check if figure size info has to be computed now
if getFigureSizeInfoNow || isempty(figureSizeInfo)
	
	% compute figure size info
	currFigureSizeInfo = computefiguresizeinfo(useDefaults);
	if ~isempty(currFigureSizeInfo)
		if ~useDefaults %&& ~screenSizeCheck
			display(currFigureSizeInfo);
			disp(' ');
			if ~yesnoinput('Is the displayed figure size info (in pixels) feasible?')
				currFigureSizeInfo = [];
			end
		end
	end
	if isempty(currFigureSizeInfo)
		%disp(textwrap2('Warning: Automatic retrieval of figure size info failed. Using default values.'));
		currFigureSizeInfo = computefiguresizeinfo(1);
	end
	
	% check if figure size info of other screen sizes is existing
	if isempty(figureSizeInfo)
		figureSizeInfo        = currFigureSizeInfo; %#ok
	else
		figureSizeInfo(end+1) = currFigureSizeInfo; %#ok
	end

	% save retrieved figure size info
	save(figureSizeInfoFile, 'figureSizeInfo');
end

