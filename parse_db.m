function [names, years, speeches] = parse_db(pid_array)
% [N, Y, S] = parse_db(A)
%
% Given an array of page ids and their corresponding years, returns
% arrays containing the name, year, and speech corresponding to each
% page id.
%
% Note that we assume the basic construction of the pages remains static.
%
% Written 3 March by Egan McComb.

names = [];

%% Iterate through speeches.
for k = 1:length(pid_array(:,1))
	% Get speech.
	url = ['http://www.presidency.ucsb.edu/ws/index.php?pid=' num2str(pid_array(k,1))];
	db = surlread(url);

	% Get president's name.
	[i j] = regexp(db,'<title>.*</title>','start','end');
	j = regexp(db(i:j),'<title>[^:]*:','end');
	name = db(i+7:i+j-2);

	% Get the year of the speech.
	year = pid_array(k,2);

	% Get the text of the speech.
	[i j] = regexp(db,'<span class="displaytext">.*</span><hr noshade="noshade" size="1">','start','end');
	j = regexp(db(i:j),'</span>','start');
	speech = db(i+26:i+j-2);

	% Filter the speech text.
	speech = detox(speech);

	%% Construct output arrays.
	names = strvcat(names,name);
	years(k) = year;
	speeches{k} = speech;
end
end
