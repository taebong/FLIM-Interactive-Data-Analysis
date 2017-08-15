function figPos = correctfigpos(figPos, correctionMode)
%CORRECTFIGPOS  Correct figure position if screen size was changed.
%		FIGPOSNEW = CORRECTFIGUREPOSITION(FIGPOS, MODE) changes the desired
%		figure position vector FIGPOS in the case that the screen size was
%		changed during the currect Matlab session. Use MODE = 'set' before
%		setting a figure position and MODE = 'get' after getting a figure
%		position.
%
%		Example:
%		figPos = correctfigpos(get(figHandle, 'Position'), 'get');
%
%		Markus Buehren
%		Last modified: 21.04.2008
%
%		See also GETSCREENSIZEINPIXELS.

if ~isnumeric(figPos) || any(sort(size(figPos)) ~= [1 4])
	error('First input is not a figure position.');
end

if ~exist('correctionMode', 'var')
	correctionMode = 'set';
elseif ~ischar(correctionMode)
	error('Second input argument has to be a <string.');
end

% save current units
currentUnits = get(0, 'Units');

% get static screen size
set(0, 'Units', 'pixels');
screenSizeStatic = get(0, 'ScreenSize');

% correct figure position vector
switch lower(correctionMode)
	case 'set'
		figPos(2) = figPos(2) - screenSizeStatic(2) + 1;
	case 'get'
		figPos(2) = figPos(2) + screenSizeStatic(2) - 1;
	otherwise
		error('Correction mode %s unknown.', correctionMode);
end

% reset units
set(0, 'Units', currentUnits);
