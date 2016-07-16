function varargout = ngram(varargin)
% ngram
%
% GUI frontend to NION's Presidential NGram library.
%
% Written 15-16 March by Aaron Huffman and Egan McComb

% Last Modified by GUIDE v2.5 15-Mar-2012 21:59:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',		mfilename, ...
	 	   'gui_Singleton',	gui_Singleton, ...
		   'gui_OpeningFcn',	@ngram_OpeningFcn, ...
		   'gui_OutputFcn',	@ngram_OutputFcn, ...
		   'gui_LayoutFcn',	[] , ...
		   'gui_Callback',	[]);
if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ngram is made visible.
function ngram_OpeningFcn(hObject, eventdata, handles, varargin)
clear global pres_arr;
clear global year_arr;
clear global regex_arr;

try
	load('data.mat');
	garbage = {names years speeches};
catch err
	str = questdlg('It seems your data.mat file is missing or corrupted. Would you like to generate it now? This is a file required for program function, and may take several minutes to generate. If you already have a copy of data.mat, you may skip this step by including it in the current directory. You must have an internet connection to generate this file.', 'Database Needed', 'Load', 'No, cancel program.', 'Load');
	if strcmp(str,'Load') == 1
		get_db();
		load('data.mat');
	else
		handles.closeFigure = true;
		handles.output = hObject;
		guidata(hObject, handles);
		return;
	end
end

prev_name = names(1,:);
pres_names = char('Select A President', names(1,:));

for i = 1:size(names,1)
	curr_name = names(i,:);
	if strcmp(curr_name, prev_name) == 0
		pres_names = char(pres_names, curr_name);
		prev_name = curr_name;
	end
end

set(handles.year1_ti, 'String', num2str(years(1)));
set(handles.year2_ti, 'String', num2str(years(end))); %#ok<COLND>
set(handles.president1_menu, 'String', pres_names);
set(handles.president2_menu, 'String', pres_names);

% Choose default command line output for ngram
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ngram wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ngram_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

if (isfield(handles,'closeFigure') && handles.closeFigure)
	delete(hObject);
end

% --- Executes on button press in plot_data.
function plot_data_Callback(hObject, eventdata, handles)
set(handles.message_st,'String','Plotting...');

%% Load database file.
load('data.mat');

%% Declare global variables for user arrays.
global pres_arr;
global year_arr;
global regex_arr;

%% Construct regex cell array indices from text inputs and checkboxes.
regexps = {get(handles.regex1_ti,'String');get(handles.regex2_ti,'String');get(handles.regex3_ti,'String')};
i = [(get(handles.regex1_cb,'Value') == 1) (get(handles.regex2_cb,'Value') == 1) (get(handles.regex3_cb,'Value') == 1)];

% Check for regex list file.
if get(handles.regex4_cb,'Value') == 1
	if ~isempty(regex_arr)
		% Cast to char vector.
		regexps = [regexps; regex_arr{:}];
		i = [(get(handles.regex1_cb,'Value') == 1) (get(handles.regex2_cb,'Value') == 1) (get(handles.regex3_cb,'Value') == 1) true(1, size(regex_arr{:}))];
	else
		set(handles.message_st,'String','Warning: Ignoring undefined regex file.');
		set(handles.regex4_cb,'Value',0);
	end
end

%% Get states of "Literal String" toggles.
ls(1) = get(handles.ls1_cb,'Value');
ls(2) = get(handles.ls2_cb,'Value');
ls(3) = get(handles.ls3_cb,'Value');

if (get(handles.ap4_cb,'Value') == 1) && (iscell(regex_arr) == 1)
	ls = [ls true(1,size(regex_arr{:},1))];
elseif iscell(regex_arr)==1
	ls = [ls false(1,size(regex_arr{:},1))];
end

%% Escape metacharacters in appropriate regexes.
for k = find(ls)
	regexps{k} = regexp_asliteral(char(regexps(k)));
end

%% Get states of "As Phrase" toggles.
ap(1) = get(handles.ap1_cb,'Value');
ap(2) = get(handles.ap2_cb,'Value');
ap(3) = get(handles.ap3_cb,'Value');

if (get(handles.ap4_cb,'Value') == 1) && (iscell(regex_arr) == 1)
	ap = [ap true(1,size(regex_arr{:}, 1))];
elseif iscell(regex_arr) == 1
	ap = [ap false(1,size(regex_arr{:}, 1))];
end

%% Replace whitespace with appropriate metacharacters in appropriate regexes.
for k = find(ap)
	regexps{k} = regexp_asphrase(char(regexps(k)));
end

%% Construct regex cell array from indices. Check for input.
regexps = regexps(i);

if isempty(regexps)
    set(handles.message_st, 'String', 'Error: No valid searches.');
    return;
end

%% Construct case sensitivity Boolean vector from checkboxes.
cs(1) = abs(get(handles.cs1_cb,'Value')-1);
cs(2) = abs(get(handles.cs2_cb,'Value')-1);
cs(3) = abs(get(handles.cs3_cb,'Value')-1);

if (get(handles.cs4_cb,'Value') == 1) && (iscell(regex_arr) == 1)
	cs = [cs false(1,size(regex_arr{:},1))];
elseif iscell(regex_arr) == 1
	cs = [cs true(1,size(regex_arr{:},1))];
end

%% Determine filter, mine data, and plot it.
% Filter by president?
if get(handles.president_rb,'Value') == 1
	% Filter manually?
	if get(handles.manual1_rb,'Value') == 1
		% All presidents?
		if get(handles.allpresidents_cb,'Value') == 1
			pres_num = size(get(handles.president1_menu,'String'),1)-1;
			% Construct filter.
			[j n p] = filter_by_pres(1:pres_num,names);
			% Retrieve frequencies.
			f = get_freqs(speeches(j),regexps,cs(i));
			% Collate frequencies by president.
			f = collate_pres(f,1:pres_num,n,get(handles.cum_rb,'Value'));
			% Plot collated frequencies by president.
			plot_bar_pres(f,char(regexps),p);
		% Specific presidents?
		else
			% One president?
			if get(handles.president2_cb,'Value') == 0
				% Retrieve president menu index.
				j = get(handles.president1_menu,'Value');
				% Check for invalid menu selection.
				if j == 1
					set(handles.message_st,'String','Error: Choose a president.');
					return
				end
				% Construct filter.
				j = filter_by_pres(j-1,names);
				% Retrieve frequencies.
				f = get_freqs(speeches(j),regexps,cs(i));
				% Plot frequencies by year.
				plot_bar_year(f,j,regexps,years);
			% Range of presidents?
			else
				% Retrieve first president menu index.
				j1 = get(handles.president1_menu,'Value');
				% Check for invalid menu selection.
				if j1 == 1
					set(handles.message_st,'String','Error: Choose a president.');
					return
				end
				% Retrieve second president menu index.
				j2 = get(handles.president2_menu,'Value');
				% Check for invalid menu selection.
				if j2 == 1
					set(handles.message_st,'String','Error: Choose a president.');
					return
				end
				% Sort menu indices properly.
				sj = sort([(j1-1) (j2-1)]);
				% Construct filter.
				[j n p] = filter_by_pres(sj(1):sj(2),names);
				% Retrieve frequencies
				f = get_freqs(speeches(j),regexps,cs(i));
				% Collate frequencies by president.
				f = collate_pres(f,sj(1):sj(2),n,get(handles.cum_rb,'Value'));
				% Plot collated frequencies by president.
				plot_bar_pres(f,char(regexps),p);
			end
		end
	% Filter with file?
	else
		% Check for empty file.
		if isempty(pres_arr)
			set(handles.message_st,'String','Error: Malformed filter file.');
			return;
		end
		% Construct filter.
		try
			[j n p] = filter_by_pres(pres_arr,names);
		catch err
			set(handles.message_st,'String','Error: Malformed filter file.');
			return
		end
		% Retrieve frequencies.
		f = get_freqs(speeches(j),regexps,cs(i));
		% Collate frequencies by president.
		f = collate_pres(f,pres_arr,n,get(handles.cum_rb,'Value'));
		% Plot collated frequencies by president.
		plot_bar_pres(f,char(regexps),p);
	end
% Filter by year?
else
	% Filter manually?
	if get(handles.manual2_rb,'Value') == 1
		% Retrieve first year.
		y1 = str2num(get(handles.year1_ti,'String'));
		% Retrieve second year.
		y2 = str2num(get(handles.year2_ti,'String'));
		% Check for bad year input.
		if ~isyear(y1,years) || ~isyear(y2,years)
			set(handles.message_st,'String','Error: Invalid year input.');
			return;
		end
		% Sort years properly.
		sy = sort([y1 y2]);
		% Construct filter.
		j = filter_by_year(sy(1):sy(2),years);
		% Retrieve frequencies.
		f = get_freqs(speeches(j), regexps, cs(i));
		% Plot frequencies by year.
		plot_bar_year(f, j, regexps, years);
	% Filter with file?
	else
		% Check for empty file.
		if isempty(year_arr)
			set(handles.message_st,'String','Error: Malformed filter file.');
			return;
		end
		% Construct filter.
		try
			j = filter_by_year(year_arr,years);
		catch err
			set(handles.message_st,'String','Error: Malformed filter file.');
			return
		end
		% Retrieve frequencies.
		f = get_freqs(speeches(j), regexps, cs(i));
		% Plot frequencies by year.
		plot_bar_year(f, j, regexps, years);
	end
end

set(handles.message_st,'String','Plot Complete.');
clc;

% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
set(handles.message_st,'String','Saving...');

%% Load database file.
load('data.mat');

%% Declare global variables for user arrays.
global pres_arr;
global year_arr;
global regex_arr;

%% Construct regex cell array indices from text inputs and checkboxes.
regexps = {get(handles.regex1_ti,'String');get(handles.regex2_ti,'String');get(handles.regex3_ti,'String')};
i = [(get(handles.regex1_cb,'Value') == 1) (get(handles.regex2_cb,'Value') == 1) (get(handles.regex3_cb,'Value') == 1)];

% Check for regex list file.
if get(handles.regex4_cb,'Value') == 1
	if ~isempty(regex_arr)
		% Cast to char vector.
		regexps = [regexps; regex_arr{:}];
		i = [(get(handles.regex1_cb,'Value') == 1) (get(handles.regex2_cb,'Value') == 1) (get(handles.regex3_cb,'Value') == 1) true(1, size(regex_arr{:}))];
	else
		set(handles.message_st,'String','Warning: Ignoring undefined regex file.');
		set(handles.regex4_cb,'Value',0);
	end
end

%% Get states of "Literal String" toggles.
ls(1) = get(handles.ls1_cb,'Value');
ls(2) = get(handles.ls2_cb,'Value');
ls(3) = get(handles.ls3_cb,'Value');

if (get(handles.ap4_cb,'Value') == 1) && (iscell(regex_arr) == 1)
	ls = [ls true(1,size(regex_arr{:},1))];
elseif iscell(regex_arr)==1
	ls = [ls false(1,size(regex_arr{:},1))];
end

%% Escape metacharacters in appropriate regexes.
for k = find(ls)
	regexps{k} = regexp_asliteral(char(regexps(k)));
end

%% Get states of "As Phrase" toggles.
ap(1) = get(handles.ap1_cb,'Value');
ap(2) = get(handles.ap2_cb,'Value');
ap(3) = get(handles.ap3_cb,'Value');

if (get(handles.ap4_cb,'Value') == 1) && (iscell(regex_arr) == 1)
	ap = [ap true(1,size(regex_arr{:}, 1))];
elseif iscell(regex_arr) == 1
	ap = [ap false(1,size(regex_arr{:}, 1))];
end

%% Replace whitespace with appropriate metacharacters in appropriate regexes.
for k = find(ap)
	regexps{k} = regexp_asphrase(char(regexps(k)));
end

%% Construct regex cell array from indices. Check for inputs.
regexps = regexps(i);

if isempty(regexps)
    set(handles.message_st, 'String', 'Error: No valid searches.');
    return;
end

%% Construct case sensitivity Boolean vector from checkboxes.
cs(1) = abs(get(handles.cs1_cb,'Value')-1);
cs(2) = abs(get(handles.cs2_cb,'Value')-1);
cs(3) = abs(get(handles.cs3_cb,'Value')-1);

if (get(handles.cs4_cb,'Value') == 1) && (iscell(regex_arr) == 1)
	cs = [cs false(1,size(regex_arr{:},1))];
elseif iscell(regex_arr) == 1
	cs = [cs true(1,size(regex_arr{:},1))];
end

%% Determine filter, mine data, and save it.
% Filter by president?
if get(handles.president_rb,'Value') == 1
	% Filter manually?
	if get(handles.manual1_rb,'Value') == 1
		% All presidents?
		if get(handles.allpresidents_cb,'Value') == 1
			pres_num = size(get(handles.president1_menu,'String'),1)-1;
			% Construct filter.
			[j n presidents] = filter_by_pres(1:pres_num,names);
			% Retrieve frequencies.
			f = get_freqs(speeches(j),regexps,cs(i));
			% Collate frequencies by president.
			frequencies = collate_pres(f,1:pres_num,n,get(handles.cum_rb,'Value'));
			% Save data.
			uisave({'presidents';'frequencies';'regexps'});
		% Specific president?
		else
			% One president?
			if get(handles.president2_cb,'Value') == 0
				% Retrieve president menu index.
				j = get(handles.president1_menu,'Value');
				% Check for invalid menu selection.
				if j == 1
					set(handles.message_st,'String','Error: Choose a president.');
					return
				end
				% Construct filter.
				[j n presidents] = filter_by_pres(j-1,names);
				% Retrieve frequencies.
				frequencies = get_freqs(speeches(j),regexps,cs(i));
				% Save data.
				uisave({'presidents';'frequencies';'regexps'});
			% Range of presidents?
			else
				% Retrieve first president menu index.
				j1 = get(handles.president1_menu,'Value');
				% Check for invalid menu selection.
				if j1 == 1
					set(handles.message_st,'String','Error: Choose a president.');
					return
				end
				% Retrieve second president menu index.
				j2 = get(handles.president2_menu,'Value');
				% Check for invalid menu selection.
				if j2 == 1
					set(handles.message_st,'String','Error: Choose a president.');
					return
				end
				% Sort menu indices properly.
				sj = sort([(j1-1) (j2-1)]);
				% Construct filter.
				[j n presidents] = filter_by_pres(sj(1):sj(2),names);
				% Retrieve frequencies.
				f = get_freqs(speeches(j),regexps,cs(i));
				% Collate frequencies by president.
				frequencies = collate_pres(f,sj(1):sj(2),n,get(handles.cum_rb,'Value'));
				% Save data.
				uisave({'presidents';'frequencies';'regexps'});
			end
		end
	% Filter with file?
	else
		% Check for empty file.
		if isempty(pres_arr)
			set(handles.message_st,'String','Error: Malformed filter file.');
			return;
		end
		% Construct filter.
		try
			[j n p] = filter_by_pres(pres_arr,names);
		catch err
			set(handles.message_st,'String','Error: Malformed filter file.');
			return
		end
		% Retrieve frequencies.
		f = get_freqs(speeches(j),regexps,cs(i));
		% Collate frequencies by president.
		frequencies = collate_pres(f,pres_arr,n,get(handles.cum_rb,'Value'));
		% Save data.
		uisave({'pres_arr';'frequencies';'regexps'});
	end
% Filter by year?
else
	% Filter manually?
	if get(handles.manual2_rb,'Value') == 1
		% Retrieve first year.
		y1 = str2num(get(handles.year1_ti,'String'));
		% Retrieve second year.
		y2 = str2num(get(handles.year2_ti,'String'));
		% Check for bad year input.
		if ~isyear(y1,years) || ~isyear(y2,years)
			set(handles.message_st,'String','Error: Invalid year input.');
			return;
		end
		% Sort years properly.
		sy = sort([y1 y2]);
		% Create range of years.
		year_range = sy(1):sy(2);
		% Construct filter.
		j = filter_by_year(year_range,years);
		% Retrieve frequencies.
		frequencies = get_freqs(speeches(j),regexps,cs(i));
		% Save data.
		uisave({'year_range';'frequencies';'regexps'});
	% Filter with file?
	else
		% Check for empty file.
		if isempty(year_arr)
			set(handles.message_st,'String','Error: Malformed filter file.');
			return;
		end
		% Construct filter.
		try
			j = filter_by_year(year_arr,years);
		catch err
			set(handles.message_st,'String','Error: Malformed filter file.');
			return;
		end
		% Retrieve frequencies.
		frequencies = get_freqs(speeches(j),regexps,cs(i));
		% Save data.
		uisave({'year_arr';'frequencies';'regexps'});
	end
end

set(handles.message_st,'String','Save Complete.');
clc;

% --- Executes on button press in update_database.
function update_database_Callback(hObject, eventdata, handles)
%% Set message and call database update function.
set(handles.message_st,'String','Updating Database...')
pause(.1);
get_db();
set(handles.message_st,'String','Database Updated.');

% --- Executes on button press in regex_help.
function regex_help_Callback(hObject, eventdata, handles)
%% Open help for the regexp() function.
doc('regexp');

% --- Executes on button press in regex1_cb.
function regex1_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in regex2_cb.
function regex2_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in regex3_cb.
function regex3_cb_Callback(hObject, eventdata, handles)

function regex1_ti_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function regex1_ti_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function regex2_ti_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function regex2_ti_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function regex3_ti_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function regex3_ti_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in president_load.
function president_load_Callback(hObject, eventdata, handles)
%% Open president file.
[f, p] = uigetfile('*');
if f == 0
	return;
end
global pres_arr;
try
	pres_arr = load([p f]);
	pres_arr = unique(pres_arr);
catch err
	set(handles.message_st,'String','Error: Malformed filter file.');
	clear global pres_arr;
end
set(handles.message_st,'String','File successfully loaded.');
set(handles.file1_st,'String',f)

% --- Executes on selection change in president2_menu.
function president2_menu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function president2_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in president2_cb.
function president2_cb_Callback(hObject, eventdata, handles)
%% Hide second president menu if checkbox disabled.
if get(handles.president2_cb,'Value') == 1
	set(handles.president2_menu,'Visible','on');
else
	set(handles.president2_menu,'Visible','off');
end

% --- Executes on selection change in president1_menu.
function president1_menu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function president1_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in allpresidents_cb.
function allpresidents_cb_Callback(hObject, eventdata, handles)
%% Hides president range buttons if "All Presidents" selected.
if get(handles.allpresidents_cb,'Value') == 1
	set(handles.manual1_group,'Visible','off');
else
	set(handles.manual1_group,'Visible','on');
end

% --- Executes on button press in year_load.
function year_load_Callback(hObject, eventdata, handles)
%% Open year file.
[f,p] = uigetfile('*');
if f == 0
	return;
end
global year_arr;
try
	year_arr = load([p f]);
	year_arr = unique(year_arr);
catch err
	set(handles.message_st,'String','Error: Malformed filter file.');
	clear global year_arr;
end
set(handles.message_st,'String','File successfully loaded.');
set(handles.file2_st, 'String', f)


function year1_ti_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function year1_ti_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

function year2_ti_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function year2_ti_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in cs1_cb.
function cs1_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in cs2_cb.
function cs2_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ap3_cb.
function ap3_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ap1_cb.
function ap1_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in cs3_cb.
function cs3_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ap2_cb.
function ap2_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ls1_cb.
function ls1_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ls2_cb.
function ls2_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ls3_cb.
function ls3_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in regex4_cb.
function regex4_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in regex4_load.
function regex4_load_Callback(hObject, eventdata, handles)
%% Open regex file.
[f p] = uigetfile('*');
if f == 0
	return;
end
global regex_arr;
regex_arr = load_file([p f]);
set(handles.message_st,'String','File successfully loaded.');
set(handles.regfile_st,'String',f);
set(handles.regex4_cb,'Value',1);

% --- Executes on button press in cs4_cb.
function cs4_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ap4_cb.
function ap4_cb_Callback(hObject, eventdata, handles)

% --- Executes on button press in ls4_cb.
function ls4_cb_Callback(hObject, eventdata, handles)
