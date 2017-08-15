function platform = getplatform
%GETPLATFORM  Get operating system information.
%		GETPLATFORM returns a string describing the used operation system, for
%		example 'Microsoft Windows XP'.
%
%		Markus Buehren
%		Last modified: 20.04.2008

platform = system_dependent('getos');
