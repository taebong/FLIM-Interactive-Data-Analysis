function screenSize = getscreensizeinpixels
%GETSCREENSIZEINPIXELS  Get screen size in pixels.
%		SZ = GETSCREENSIZEINPIXELS returns a 1x4 vector of doubles giving the
%		size of the display in pixels. On Windows, mex-function
%		GETSCREENSIZEINPIXELSPC is called to read the current settings rather
%		than reading a static copy made at MATLAB startup time. On other
%		systems, the static screen size is read using get(0, 'ScreenSize').
%
%		Markus Buehren
%		Last modified 20.04.2008 
%
%		See also GETSCREENSIZEINPIXELSPC.

% if ispc
% 	% check if mex-file getscreensizeinpixelspc is available
% 	whichFile = which('getscreensizeinpixelspc');
% 	if isempty(whichFile) || strcmp(whichFile(end-1:end), '.m')
% 		% mex-function needs to be compiled
% 		mexFileName = which('getscreensizeinpixelspc.c');
% 		if ~isempty(mexFileName)
% 			disp(textwrap2(['Function getscreensizeinpixelspc.c needs to be ', ...
% 				'compiled once on your host. If Matlab asks you to select a ', ...
% 				'compiler, choose the builtin LCC compiler.', sprintf('\n')]));
% 			mex(mexFileName, '-outdir', fileparts(mexFileName));
% 		end
% 	end
% 	
% 	% get screen size
% 	screenSize = getscreensizeinpixelspc;
% else
% 	currentUnits = get(0, 'Units');
% 	set(0, 'Units', 'pixels');
% 	screenSize = get(0, 'ScreenSize');
% 	set(0, 'Units', currentUnits);
% end
	currentUnits = get(0, 'Units');
	set(0, 'Units', 'pixels');
	screenSize = get(0, 'ScreenSize');
	set(0, 'Units', currentUnits);
	
