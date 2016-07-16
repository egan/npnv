function plot_bar_pres(freq_arr, searches, speech_names)
% plot_bar_pres(f, s, sp)
%
% Takes frequency array, regexes, and names attributed to processed
% speeches, and outputs a bar graph showing frequencies by president.
%
% Written by Aaron Huffman for NION
% March 9, 12-13 2012

%% Predetermine useful variables.
len = size(speech_names, 1);

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

%% Seek duplicate presidents and attribute tags to them.
for i = 1:len
	j = 1;
	while j<i
		if strcmp(speech_names(i,:),speech_names(j,:))==1
			n = 1;
			k = strmatch(speech_names(i,:), speech_names);
			for m = 1:length(strmatch(speech_names(i,:), speech_names))
				speech_names(k(m),(1:(length(strcat(strtrim(speech_names(k(m),:)), ...
					'(', num2str(n), ')'))))) = strcat(strtrim(speech_names(k(m),:)), '(', num2str(n), ')');
				n = n+1;
			end
		end
		j = j+1;
	end
end

%% Set strings as artificial XTick values, using text objects. This allows for 45 degree rotation.
axes_cellarr = cellstr(speech_names);

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

text(middleX,smallY,'Speeches', ...
'VerticalAlignment','top', ...
'HorizontalAlignment','center');

%% Set specifics for plot.
title('Occurrences by President');
ylabel('Frequency');
leghand = legend(searches, 'location', 'Best');

set(leghand, 'Interpreter','none');

end
