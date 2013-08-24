function toIgor_button_callBack2(hObject,eventData)
figData = guidata(hObject);
plotCanvas = figData.panel;
ch = get(plotCanvas,'children');
moving_ch = [];

for i=1:length(ch)
    if ~strcmp('legend', get(ch(i),'tag')) && (~isprop(ch(i),'style') || ~strfind(get(ch(i),'style'), 'button'))
        moving_ch = [moving_ch ch(i)];
    end
end

for c = 1:length(moving_ch)
    prompt{c} = sprintf('Axis %d',c);
    def{c} = get(moving_ch(c),'tag');
end
dlg_title = 'Input for peaks function';

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer = inputdlg(prompt,dlg_title,1,def,options);

for c = 1:length(moving_ch)
    makeAxisStructLocal(moving_ch(c),answer{c});
end

end