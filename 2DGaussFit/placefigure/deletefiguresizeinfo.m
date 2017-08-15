function deletefiguresizeinfo
%DELETEFIGURESIZEINFO  Delete saved figure size info.
%		DELETEFIGURESIZEINFO removes the file containing the figure size info
%		for the current host.
%
%		Markus Buehren
%		Last modified: 20.04.2008
%
%		See also COMPUTEFIGURESIZEINFO, GETFIGURESIZEINFO.

figureSizeInfoFile = sprintf('%s/figuresizeinfo_%s.mat', tempdir2, gethostname);

if exist(figureSizeInfoFile, 'file')
	delete(figureSizeInfoFile);
end
