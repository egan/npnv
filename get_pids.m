function pid_array = get_pids()
% A = get_pidarray(U)
%
% Collates the page ids on UCSB's presidential state of the union speech database
% index with the year they were given, returning them as a vertical array.
%
% Note that we assume the url and basic construction of the page remain static.
%
% Written 3 March by Egan McComb.

%% Obtain database index from url.
db_index = surlread('http://www.presidency.ucsb.edu/sou.php');

%% Fields to populate:
pids = [];
years = [];

%% Discard data before the menu table.
i = regexp(db_index,'<a name="menu">');
db_index = db_index(i:end);

%% Locate each page id url.
[i, m] = regexp(db_index,'<a href="http://www\.presidency\.ucsb\.edu/ws/index\.php\?pid=\d*">','start','match');
m = char(m);

%% Determine pids and years using index offsets.
for k = 1:length(m)
	yoff = length(strtrim(m(k,:)));
	[poff(1) poff(2)] = regexp(m(k,:),'\d*','start','end');
	pids = [pids; str2num(db_index(i(k)+poff(1)-1:i(k)+poff(2)-1))];
	years = [years; str2num(db_index(i(k)+yoff:i(k)+yoff+3))];
end

%% Sort fields chronologically.
[years sort_i] = sort(years);
pids = pids(sort_i,:);

pid_array = [pids years];
end
