function placefigure(figHandle, posSpec)
%PLACEFIGURE  Place figure precisely to a given screen location.
%		PLACEFIGURE(FIGHHANDLE, POSITION) places the figure with the given
%		handle precisely to a given position. The figure borders exactly match
%		with the screen borders and the figures end of at the top of the task
%		bar at the bottom. Possible position specifications are:
%
%		'top left', 'top right', 'top center', 'middle left', 'middle right',
%		'middle center', 'bottom left', 'bottom right', 'bottom center', 'top
%		half', 'bottom half', 'left half', 'right half', 'top left quarter',
%		'top right quarter', 'bottom left quarter', 'bottom right quarter' and
%		'full screen'
%
%		The first nine specifications will only change the figure position but
%		keep the figure size, while the other specifications will change both
%		size and position.
%
%		Alternatively, the figure can be specified using a four-element vector:
%
%		POSITION = [NUMBER_OF_ROWS, NUMBERS_OF_COLUMNS, ROW, COLUMN]
%
%		The figure will be placed into the tile [ROW, COLUMN] of an imaginary
%		lattice with NUMBER_OF_ROWS rows and NUMBERS_OF_COLUMNS colunns.
%
%		Function PLACEFIGUREDEMO shows a demonstration of the capabilities of
%		this function.
%
%		Example:
%		fh = figure;
%		placefigure(fh, 'top left');
%
%		Markus Buehren
%		Last modified: 11.08.2008
%
%		See also PLACEFIGUREDEMO, GETFIGURESIZEINFO.

if nargin == 0
	disp('No input arguments given, starting demo.');
	placefiguredemo;
	return
end

if ~exist('figHandle', 'var')
	figHandle = figure;
end
if ~exist('posSpec', 'var')
	posSpec = 'top left';
end

if ischar(posSpec)
	switch lower(posSpec)
		case {'tl', 'top left', 'left top'}
			moveFig   = [0 1];
			resizeFig = [NaN, NaN];
		case {'tr', 'top right', 'right top'}
			moveFig   = [1 1];
			resizeFig = [NaN, NaN];
		case {'tc', 'top center', 'center top'}
			moveFig   = [0.5 1];
			resizeFig = [NaN, NaN];
		case {'ml', 'middle left', 'left middle'}
			moveFig   = [0 0.5];
			resizeFig = [NaN, NaN];
		case {'mr', 'middle right', 'right middle'}
			moveFig   = [1 0.5];
			resizeFig = [NaN, NaN];
		case {'mc', 'middle center', 'center middle'}
			moveFig   = [0.5 0.5];
			resizeFig = [NaN, NaN];
		case {'bl', 'bottom left', 'left bottom'}
			moveFig   = [0 0];
			resizeFig = [NaN, NaN];
		case {'br', 'bottom right', 'right bottom'}
			moveFig   = [1 0];
			resizeFig = [NaN, NaN];
		case {'bc', 'bottom center', 'center bottom'}
			moveFig   = [0.5 0];
			resizeFig = [NaN, NaN];

		case {'th', 'top half'}
			posSpec = [2 1 1 1];
		case {'bh', 'bottom half'}
			posSpec = [2 1 2 1];
		case {'lh', 'left half'}
			posSpec = [1 2 1 1];
		case {'rh', 'right half'}
			posSpec = [1 2 1 2];

		case {'tlq', 'top left quarter'}
			posSpec = [2 2 1 1];
		case {'trq', 'top right quarter'}
			posSpec = [2 2 1 2];
		case {'blq', 'bottom left quarter'}
			posSpec = [2 2 2 1];
		case {'brq', 'bottom right quarter'}
			posSpec = [2 2 2 2];

		case {'fs', 'full screen', 'full'}
			posSpec = [1 1 1 1];

		otherwise
			error('Position specifier %s unknown.', posSpec);
	end
end

if ischar(posSpec)
	% do nothing, moveFig and resizeFig have been set before
elseif isnumeric(posSpec) && all(isfinite(posSpec)) && length(posSpec) == 4
	nOfRows = posSpec(1);
	nOfCols = posSpec(2);
	row     = posSpec(3);
	col     = posSpec(4);
	if any(abs(posSpec - round(posSpec)) > 1e-10)
		error('Only integer numbers allowed in vector input.');
	end
	posSpec = round(posSpec);
	if nOfRows < 1
		error('Number of rows must be greater or equal one.');
	end
	if nOfCols < 1
		error('Number of columns must be greater or equal one.');
	end
	if row < 1 || row > nOfRows
		error('Invalid row number.');
	end
	if col < 1 || col > nOfCols
		error('Invalid column number.');
	end
	moveFig   = [(col-1)/max(1, nOfCols-1), (nOfRows-row)/max(1, nOfRows-1)]; % rows are counted from the top!
	resizeFig = [1/nOfCols, 1/nOfRows];
else
	error('Unrecognized figure position specification (Only strings and 4-element vectors allowed.');
end

% get figure size
currentUnits = get(0, 'Units');
set(0, 'Units', 'pixels');
figPos = get(figHandle, 'Position');

% get additional figure size info
useDefaults = 0;
try
	figInfo = getfiguresizeinfo;
catch
	useDefaults = 1;
end
if useDefaults || ~isstruct(figInfo) || any(size(figInfo) ~= [1 1]) || ...
		~isfield(figInfo, 'figureHeadHeight')
	% use default values if function getfiguresizeinfo failed
	figInfo = getfiguresizeinfo(1);
end

% compute total figure head height
totalFigureHeadHeight = figInfo.figureHeadHeight;

% check if Matlab was started with option nojvm
if usejava('jvm')
	% check if menu bar is present
	if strcmp(get(figHandle, 'MenuBar'), 'figure')
		totalFigureHeadHeight = totalFigureHeadHeight + figInfo.menuBarHeight;
	end

	% check if tool bar is present
	switch get(figHandle, 'ToolBar')
		case 'figure'
			totalFigureHeadHeight = totalFigureHeadHeight + figInfo.toolBarHeight;

		case 'auto'
			% check if uicontrol is present
			figChildren = get(figHandle, 'Children');
			toolBarPresent = true;
			for k=1:length(figChildren)
				if strcmp(get(figChildren(k), 'Type'), 'uicontrol')
					toolBarPresent = false;
					break
				end
			end
			if toolBarPresent
				totalFigureHeadHeight = totalFigureHeadHeight + figInfo.toolBarHeight;
			end
	end
end

if ischar(posSpec)
	% compute available space for single figure
	availableWidth  = figInfo.screenSize(3) - figInfo.leftBorderWidth   - figInfo.rightBorderWidth + 1;
	availableHeight = figInfo.screenSize(4) - figInfo.lowerBorderHeight - figInfo.taskBarHeight - ...
		totalFigureHeadHeight;
else
	% compute available space for placing several figures
	availableWidth  = figInfo.screenSize(3) - nOfCols*(figInfo.leftBorderWidth   + figInfo.rightBorderWidth - 1);
	availableHeight = figInfo.screenSize(4) - nOfRows*(figInfo.lowerBorderHeight + totalFigureHeadHeight) - ...
		figInfo.taskBarHeight;
end

% resize figure if necessary
if ~isnan(resizeFig(1))
	figPos(3) = ceil(resizeFig(1) * availableWidth);
end
if ~isnan(resizeFig(2))
	figPos(4) = ceil(resizeFig(2) * availableHeight);
end

% move figure to specified position (left/right)
if ischar(posSpec)
	figPos(1) = figInfo.leftBorderWidth + ceil(moveFig(1) * (availableWidth - figPos(3)));
else
	figPos(1) = col*figInfo.leftBorderWidth + (col-1)*figInfo.rightBorderWidth + ...
		ceil(moveFig(1) * (availableWidth - figPos(3)));
end

% move figure to specified position (top/bottom)
if ischar(posSpec)
	figPos(2) = figInfo.lowerBorderHeight + figInfo.taskBarHeight + ...
		ceil(moveFig(2) * (availableHeight - figPos(4)));
else
	figPos(2) = (nOfRows-row+1)*figInfo.lowerBorderHeight + (nOfRows-row) * totalFigureHeadHeight + ...
		figInfo.taskBarHeight + ceil(moveFig(2) * (availableHeight - figPos(4)));
end

% set figure position
set(figHandle, 'Position', correctfigpos(figPos, 'set'));

% reset units
set(0, 'Units', currentUnits);
