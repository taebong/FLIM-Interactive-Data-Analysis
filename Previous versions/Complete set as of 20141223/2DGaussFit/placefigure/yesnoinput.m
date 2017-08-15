function check = yesnoinput(str)
%YESNOINPUT  Force user decision.
%		ANSWER = YESNOINPUT(STR) diplays string STR and waits for the user to 
%		type 'y' for yes or 'n' for no. TRUE is returned for yes and FALSE for 
%		no.
%
%		Example:
%		answer = yesnoinput('Really delete file?');
%
%		Markus Buehren
%		Last modified: 21.04.2008
%
%		See also INPUT.

while 1
	answer = input([str,' (yes/no)\n'],'s');
	if ~isempty(answer)
		if strcmpi(answer, 'y') || strcmpi(answer, 'yes')
			check  = true;
			return
		elseif strcmpi(answer, 'n') || strcmpi(answer, 'no')
			check  = false;
			return
		end
	else
		disp('Incorrect input. Try again');
	end
end
