function sp = graphbar(sp,points,barheight)
% graphbar(sp,points,barheight)
%   barheight can be the mean (will also be plotted) or something else;

onesies = ones(size(points));

column = 1;
span = [column-.45, column+.45];
height = [barheight, barheight];
a = area(sp,span,height,'DisplayName','bar');
hold(sp,'on');
set(a,'facecolor',[.7 .7 1])
line(onesies,points,...
    'Marker','o',...
    'LineStyle','none',...
    'MarkerFaceColor',[0 0 1],...
    'MarkerEdgeColor',[0 0 1],...
    'Parent',sp,...
    'DisplayName', 'data');

line(column,barheight,...
    'Marker','o',...
    'LineStyle','none',...
    'MarkerFaceColor','none',...
    'MarkerEdgeColor',[0 0 1],...
    'Parent',sp,...
    'DisplayName', 'height');


e = errorbar(sp,column,mean(points),std(points)/sqrt(length(points)),'ob');
set(e,'DisplayName','mean');
set(sp,'tag','dimtau');
