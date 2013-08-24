function [] = makeAxisStructLocal(ax, fname)
if exist('figures','dir')
    basedir = 'figures/';
    ind = regexp(pwd,'/');
    p = pwd;
    prefix = ''; % Igor file names are only 31 char, don't have numbers
    %[p(ind(end-1)+1:ind(end)-1),'_'];
else
    fprintf('*** You''re in a weird path, saving to hdf5temp/%s ***\n',fname)
    fprintf('%s',pwd);
    if ~strcmp(pwd,'/Users/tony/hdf5_temp'); 
        basedir = '~/hdf5_temp/';
    else
        basedir = '';
    end
    prefix = '';
end

s = struct;
%get axis properties
Xlabel = get(ax,'Xlabel');
if ~isempty(Xlabel), s.Xlabel = get(Xlabel,'String'); end
Ylabel = get(ax,'Ylabel');
if ~isempty(Ylabel), s.Ylabel = get(Ylabel,'String'); end
s.Xlim = get(ax,'xlim');
s.Ylim = get(ax,'ylim');

%get line data and properties
plotLines = get(ax,'children');

for i=1:length(plotLines)
    curLine = plotLines(end+1-i);
    if strcmp(get(curLine,'type'),'text')
        continue
    end
    displayName = get(curLine,'DisplayName');
    if isempty(displayName)
        i_string = num2str(i); 
        switch length(i_string)
            case 1, i_string = ['00',i_string];
            case 2, i_string = ['0',i_string];
            otherwise
        end
        line_prefix = ['L', i_string];
    elseif ~isempty(str2num(displayName(1)))
        line_prefix = ['n' displayName];
    else line_prefix = displayName; 
    end
    if ~isnan(str2double(line_prefix)) %label is number
        line_prefix = ['n' line_prefix];
    end
    %replace periods in label name
    line_prefix = strrep(line_prefix,'.','pt');
    
    %replace minus signs in label name
    line_prefix = strrep(line_prefix,'-','m');
    
    %replace plus signs in label name
    line_prefix = strrep(line_prefix,'-','p');
    
    %replace white space in label name
    line_prefix = strrep(line_prefix,' ','_');
    
    %replace slash in label name
    line_prefix = strrep(line_prefix,'/','_');
    
    if strcmp(line_prefix,'nL137')
        disp('');
    end
    
    s.([line_prefix '_Y']) = get(curLine,'YData');
    X = get(curLine,'XData');
    if length(X)>500 % X is likely to be a time series
        %if max(diff(diff(X))) == 0 %linear X scale
        %    s.([line_prefix '_start']) = X(1);
        %    s.([line_prefix '_delta']) = X(2) - X(1);
        %else %separate X wave
            s.([line_prefix '_X']) = X;
        %end
    else
        s.([line_prefix '_X']) = X;
    end
    if isprop(curLine,'linestyle')&&...
            ~strcmp('none',get(curLine,'linestyle'))
        l = get(curLine,'linestyle');
        switch l
            case '-'
            s.([line_prefix '_linestyle']) = 0;
            case '--'
            s.([line_prefix '_linestyle']) = 3;
        end
    end
    if isprop(curLine,'Color')
        s.([line_prefix '_color']) = get(curLine,'Color');
    end
    if isprop(curLine,'marker')&&...
            ~strcmp('none',get(curLine,'marker'))
        % map string onto Igor integer
        m = get(curLine,'marker');
        switch m
            case 'o'
            s.([line_prefix '_marker']) = 8;
            if ~strcmp('none',get(curLine,'MarkerFaceColor'))
                s.([line_prefix '_marker']) = 19;
                
            end
            case '+'
            s.([line_prefix '_marker']) = 0;
            case '.'
            s.([line_prefix '_marker']) = 19;
        end
    end
    if isprop(curLine,'MarkerFaceColor')&&...
            ~strcmp('none',get(curLine,'MarkerFaceColor'))
        s.([line_prefix '_markercolor']) = get(curLine,'MarkerFaceColor');
    end
    if isprop(curLine,'MarkerEdgeColor')&&...
            ~strcmp('none',get(curLine,'MarkerEdgeColor'))&&...
            ~strcmp('auto',get(curLine,'MarkerEdgeColor'))
        s.([line_prefix '_markercolor']) = get(curLine,'MarkerEdgeColor');
    end
    if isprop(curLine,'markersize')&&...
            ~strcmp('none',get(curLine,'markersize'))
        s.([line_prefix '_markerSize']) = get(curLine,'markersize');
    end
    if isfield(s,[line_prefix '_marker']) && ~isfield(s,[line_prefix '_markercolor'])
        s.([line_prefix '_markercolor']) = [0 0 0];
    end
    %error bars?
    if isprop(curLine,'UData') && ~isempty(get(curLine,'UData'))        
        s.([line_prefix '_Yerr']) = get(curLine,'UData');
        % Might have xsem struct also
        if isstruct(get(curLine,'UserData')) || isnumeric(get(curLine,'UserData'))
            semX = get(curLine,'UserData');
            if isfield(semX,'semX')
                s.([line_prefix '_Xerr']) = semX.semX;
            elseif isnumeric(semX)
                s.([line_prefix '_Xerr']) = semX;
            end
        end 
    end
    %keyboard;
end

%write hdf5 file
options.overwrite = 1;
if isempty(fname)
    fname = input('Figure Name: ', 's');
end
fname = [prefix,fname];
exportStructToHDF5(s,[fname '.h5'],fname,options);
if ~isempty(basedir)
movefile([fname '.h5'], [basedir fname '.h5']); end

