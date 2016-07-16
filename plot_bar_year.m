function plot_bar_year(freq_arr, sp_ind, searches, years)
% plot_bar_year(f, s, se, y)
%
% Takes frequency array, regexes, and years attributed to processed
% speeches, and outputs a bar graph showing frequencies by year.
%
% Written by Aaron Huffman for NION
% March 9, 12 2012

%% Predetermine useful variables.
speech_years = years(sp_ind);

len = length(speech_years);
axes_cellarr = cell(len,1);

s1 = size(freq_arr, 1);
s2 = size(freq_arr, 2);

%% Set colors.

c = zeros(s2, 3);

for i = 1:s2
	c(i,:) = [rand(1) rand(1) rand(1)];
end

%% Create figure and plot bars.
figure;
hold on;

for i = 1:s2
	bar(1, 0, 'FaceColor', c(i,:));
end

for i = 1:(s1*s2)
	[a b] = find(freq_arr==max(max(freq_arr)), 1);
	bar(a, freq_arr(a, b), 'FaceColor', c(b,:));
	if freq_arr(a, b)==0
		break;
	end
	freq_arr(a,b) = 0;
end

%% Set XTick values and appropriately center x axis.
ticks = 1:len;
xlen = [0 len+1];

set(gca,'XTick',ticks,'XLim',xlen);
i = 1;

%% Seek duplicate years and attribute tags to them.
while i<=len
	n = 'a';
	if length(find(speech_years==speech_years(i)))>1
		for k = 1:length(find(years==speech_years(i)))
			str_inp = num2str(speech_years(i));
			axes_cellarr(i) = {strcat(str_inp, n)};
			n = char(n+1);
			i = i+1;
		end
	else
		axes_cellarr(i) = {num2str(speech_years(i))};
		i = i+1;
	end
end

axset = axis;
Y = axset(3:4);

textobj = text(ticks, Y(1)*ones(1,length(ticks)), axes_cellarr);

set(textobj,'HorizontalAlignment','right','VerticalAlignment','top', ...
	'Rotation',45);

set(gca,'XTickLabel','');

for i = 1:length(textobj)
	extent(i,:) = get(textobj(i),'Extent');
end

smallY = min(extent(:,2));
middleX = xlen(1)+abs(diff(xlen))/2;

text(middleX,smallY,'Speeches', 'VerticalAlignment','top', ...
	'HorizontalAlignment','center');

title('Occurrences by Year');
ylabel('Frequency');
leghand = legend(searches, 'location', 'Best');

set(leghand, 'Interpreter','none');

end
