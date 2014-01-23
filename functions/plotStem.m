function plotStem(value)

y = get(gca, 'YLim');
hold on
s = stem(value, y(2));
set(s, 'color', 'r')