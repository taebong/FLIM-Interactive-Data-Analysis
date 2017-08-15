function screenSize = getscreensizeinpixelspc
%GETSCREENSIZEINPIXELSPC  Same as get(0, 'ScreenSize'), but dynamic.
%		SZ = GETSCREENSIZEINPIXELSPC returns a 1x4 vector of doubles giving the
%		size of the display in pixels, in the same way as get(0, 'ScreenSize'),
%		except it reads the current settings rather than reading a static copy
%		made at MATLAB startup time.
%
%		GETSCREENSIZEINPIXELSPC uses a Win32 API call and therefore will only
%		work on Windows. Type "mex getscreensizeinpixelspc.c" to compile the
%		mex-file. If the mex-file is not found, the normal static screen size
%		retrieval is used.
%
%		<a href="matlab:doc rootobject_props">Root object properties</a>.
%
%		Note: The corresponding mex-file was taken from the Matlab Central
%		contribution "Get screen size (dynamic)" from Russell Goyder.
%
%		Markus Buehren
%		Last modified: 20.04.2008
%
%		See also GETSCREENSIZEINPIXELS.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent warnmex
if isempty(warnmex)
	disp(textwrap2(sprintf(['This is the m-file %s.m, not the mex-file! ', ...
		'Dynamic screen size retrieval is thus not possible.'], mfilename)));
	warnmex = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ispc
	error('Function %s may only be called on Windows!', mfilename);
end

currentUnits = get(0, 'Units');
set(0, 'Units', 'pixels');
screenSize = get(0, 'ScreenSize');
set(0, 'Units', currentUnits);
