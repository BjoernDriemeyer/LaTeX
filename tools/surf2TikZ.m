%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fabian Roos, fabian.roos@uni-ulm.de %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%% Function for exporting two / three dimensional data as a TikZ picture.%
%%% Should only be used for large plots where classical approach is not %%%
%%% possible, because a '*.png' file is used!                           %%%
%%% With some options uses and therefore requires matlab2tikz           %%%
%%% (tested with 1.0.0.2.)                                              %%%
%%%                                                                     %%%
%%% 'x': The x axis vector with the values for each bin.                %%%
%%%      Simplest approach 1:size(amp,2) for indexing [1; 2; ...; end]  %%%
%%%                                                                     %%%
%%% 'y': The y axis vector with the values for each bin.                %%%
%%%      Simplest approach 1:size(amp,1) for indexing [1; 2; ...; end]  %%%
%%%                                                                     %%%
%%% 'amp': The two dimensional matrix with the z / amplitude values.    %%%
%%%        Values should not be complex!                                %%%
%%%                                                                     %%%
%%% All other settings are controlled with the 'cfg' config struct      %%%
%%% 'cfg.type': Select the type which should be used. Mandatory         %%%
%%%         'imagesc': Use an imagesc plot which is best case if possible %
%%%                    Only possible if xy view is selected (0 90) (x 90) %
%%%         'surf2D':  Use a surf plot for export.                      %%%
%%%                    For different view directions (no all implemented) %
%%%                    Do not use unless you know what you're doing...  %%%
%%%                    Needs a unix system for automatically trimming   %%%
%%%                    and inserting white space in the generated image. %%
%%%         'surf3D':  Use a surf plot for export. Needs gimp processing %%
%%%                    afterwards.                                      %%%
%%%                    Needs a unix system for automatically trimming   %%%
%%%                    and inserting white space in the generated image. %%
%%%                                                                     %%%
%%% 'cfg.view': Optional, specifies the viewing directions and alters   %%%
%%%             accordingly the relation between x, y, amp and the plot %%%
%%%             axis x and y.                                           %%%
%%%             Note: Not all possible viewing directions are implemented %
%%%             and you possible have to alter the code of this function! %
%%%                                                                     %%%
%%% 'cfg.use_colormap': Optional argument which expects as a string the %%%
%%%                 colormap, which should be used to plot.             %%%
%%%                 The colormap is not implemented in the code and     %%%
%%%                 therefore only the picture code is shown.           %%%
%%%                 Possibilities: 'jet' Matlab default prior to R2014b %%%
%%%                                'parula' (use rs_tikz.tex)           %%%
%%%                                                                     %%%
%%% 'cfg.colorbar_range': Optional argument, if a colorbar is chosen.   %%%
%%%                   Expects a vector like [min max] for the colorbar  %%%
%%%                   range.                                            %%%
%%%                                                                     %%%
%%% 'cfg.xlim': Optional vector with the range to be applied to reduce  %%%
%%%             the file size.                                          %%%
%%%                                                                     %%%
%%% 'cfg.ylim': Optional vector with the range to be applied to reduce  %%%
%%%             the file size.                                          %%%
%%%                                                                     %%%
%%%                                                                     %%%
%%% To include the resulting tikz image in a LaTeX document the best    %%%
%%% case is to use the following approach                               %%%
%%% \usepackage{tikzscale} % in the header / preambel                   %%%
%%% \begin{figure}[tbp]                                                 %%%
%%%   \centering                                                        %%%
%%%   \includegraphics[width=0.8\linewidth,height=0.2\textheight]{figure.tikz}
%%%   \caption{The caption of the figure.}                              %%%
%%%   \label{fig:surf2TikZ_example}                                     %%%
%%% \end{figure}                                                        %%%
%%%                                                                     %%%
%%% Revisions:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 24.03.16: * added colormap viridis                                  %%%
%%% 10.02.16: * changed header comment                                  %%%
%%%           * added export of selected options in output code         %%%
%%%           * save the surf2D figure in a file                        %%%
%%% 19.01.16: * added support for viewing option (-90,0)                %%%
%%% 10.01.16: * check for reasonable input vector and discard for 3D    %%%
%%% 31.12.15: * labels with correct use of siunitx                      %%%
%%% 01.10.15: * added more viewing directions and corresponding xmin... %%%
%%% 30.09.15: * changed to cfg structure                                %%%
%%%           * added view() as an input parameter                      %%%
%%%           * added xlim and ylim as input parameter. for png creation! %
%%% 13.07.15: * 'enlargelimits = false' set for 'surf3D' plot           %%%
%%%           * changed y label text to have normal font at m/s         %%%
%%% 26.04.15: * basic version (created with use of 'imagesc2TikZ.m')    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ ] = surf2TikZ(x, y, amp, cfg)
%% show usage and check for consistency
if nargin == 0
    disp('Usage of "surf2TikZ": surf2TikZ(x, y, amp, cfg)')
    disp('See help surf2TikZ for additional optional arguments')
    return
end

%% Nargin Handling
if ~isfield(cfg,'type')
    error('No type ("imagesc", "surf2D", "surf3D") specified. This is not an optional parameter. Aborting.')
end

if ~isfield(cfg,'use_colormap')
    cfg.use_colormap = '';
    warning('No colormap ("jet", "parula") specified. Colormap deactivated.')
end

if ~isfield(cfg,'colorbar_range')
    cfg.colorbar_range = [min(min(amp)) max(max(amp))];
    warning('No colorbar range ("[min max]") specified. Using default range.')
end

if ~isfield(cfg,'view')
    if strcmp(cfg.type, 'imagesc')
        cfg.view = [0 90];
        warning('No view specified. [0 90] selected.')
    elseif strcmp(cfg.type, 'surf2D')
        cfg.view = [0 90];
        warning('No view specified. [0 90] selected.')
    elseif strcmp(cfg.type, 'surf3D')
        cfg.view = [-45 25];
        warning('No view specified. [-45 25] selected.')
    end
end


%% Consitancy Check
% check if input variables are consistent
% if ~strcmp(cfg.type, 'surf3D')
%     % in case of a 3DFFT plot this check should be discarded
%     if ~( size(amp,2) == length(x) && size(amp,1) == length(y) )
%         error('Inputvariables of x, y or amp do not have corresponding size! Aborting...')
%     end
% end

if isfield(cfg,'colorbar_range')
    if ~(size(cfg.colorbar_range,1) == 1 && size(cfg.colorbar_range,2) == 2 )
        error('Range should be in form of [min max]!')
    end
end

disp('This is "surf2TikZ":')

if strcmp(cfg.use_colormap, 'parula')
    disp([9 'Colormap parula selected: Either use code generated with matlab2TikZ (type=imagesc) or use style file (rs_tikz.tex)!'])
end


%% Limit Plotting Direction
if isfield(cfg,'xlim')
    x_min = find(x>cfg.xlim(1),1) - 1;
    x_max = find(x>cfg.xlim(2),1) + 1;
    
    if x_min < 1
        error('The chosen xlim vector is invalid: xmin too small.')
    end
    
    if x_max > length(x)
        error('The chosen xlim vector is invalid: xmax to large.')
    end
    
    x = x(x_min:x_max);
    amp = amp(:,x_min:x_max);
end

if isfield(cfg,'ylim')
    y_min = find(y>cfg.ylim(1),1) - 1;
    y_max = find(y>cfg.ylim(2),1) + 1;
    
    if y_min < 1
        error('The chosen ylim vector is invalid: ymin too small.')
    end
    
    if y_max > length(y)
        error('The chosen ylim vector is invalid: ymax to large.')
    end
    
    y = y(y_min:y_max);
    amp = amp(y_min:y_max,:);
end


%% Export as a 2D figure using imagesc approach (matlab2tikz required)
if strcmp(cfg.type, 'imagesc')
    % open new figure and plot the data
    figure
    imagesc(x, y, amp)
    
    view(cfg.view)
    % imagesc starts the y dimension on top left instead of bottom left
    % -> use normal direction
    set(gca, 'YDir', 'normal');
    
    % If given, the selected colormap is chosen for creating the '*.png'
    if strcmp(cfg.use_colormap, 'jet')
        colorbar
        colormap jet
    elseif strcmp(cfg.use_colormap, 'parula')
        colorbar
        colormap parula
    elseif strcmp(cfg.use_colormap, 'viridis')
        colormap viridis
    end
    
    % If given, use the selected colorbar range for setting up the colorbar,
    % because the colorbar values are directly asociated with an color and
    % cannot be changed after the export.
    if exist('colorbar_range', 'var')
        caxis(cfg.colorbar_range)
    end
    
    % export figure to TikZ using several options
    % -> 'noSize': Do not set a size, not necessary for 'standalone' and
    %              'tikzscale'
    % -> 'showInfo': Do not show an information message
    % -> 'showWarnings': Do not show warnings, espacially for using 'noSize'
    matlab2tikz('imagesc.tikz', 'noSize', true, 'showInfo', false, 'showWarnings', false)
    
    % See '4.3.7 Using External Graphics as Plot Sources'
    disp([9 'Exporting imagesc-1.png... Done!'])
    disp([9 'Either use the code generated by matlab2TikZ (imagesc.tikz)...'])
    disp([9 '... or: Use the following code and save it as a *.tikz file. Some values must be adapted!'])
    disp([9 ' ~~~ Code for a 2D plot: ~~~'])
    disp([9 '% created with surf2TikZ written by Fabian Roos'])
    disp([9 '% chosen settings: view: ' num2str(cfg.view)])
    disp([9 '\begin{tikzpicture}'])
    disp([9 '\begin{axis}['])
    disp([9 9 'axis on top,'])
    disp([9 9 'enlargelimits = false,'])
    disp([9 9 '% colorbar,'])
    if strcmp(cfg.use_colormap, 'jet')
        disp([9 9 'colormap/jet,']) % if parula is chosen, no need to set colormap
    end
    disp([9 9 '% colorbar style = {%'])
    disp([9 9 9 '% ylabel = {Leistung in \si{\decibel}},'])
    disp([9 9 9 '% % ytick = {-50,-40,...,0},'])
    disp([9 9 '% },'])
    disp([9 9 '% point meta min = ' num2str(cfg.colorbar_range(1)) ','])
    disp([9 9 '% point meta max = ' num2str(cfg.colorbar_range(2)) ','])
    disp([9 9 '% xtick = {0,20,...,100},'])
    disp([9 9 '% ytick = {0,20,...,60},'])
    disp([9 9 '% xlabel = {$x$ in \si{\metre}},'])
    disp([9 9 '% ylabel = {$y$ in \si{\metre\per\second}},'])
    disp([9 9 '% xmin = 0,'])
    disp([9 9 '% xmax = 100,'])
    disp([9 9 '% ymin = 0,'])
    disp([9 9 '% ymax = 20,'])
    disp([9 ']'])
    disp([9 '\addplot graphics'])
    if cfg.view(1) == 0 && cfg.view(2) == 90
        disp([9 '[xmin = ' num2str(min(x)) ', xmax = ' num2str(max(x)) ', ymin = ' num2str(min(y)) ', ymax = ' num2str(max(y)) ']'])
    elseif cfg.view(1) == -90 && cfg.view(2) == 90
        disp([9 '[xmin = ' num2str(min(y)) ', xmax = ' num2str(max(x)) ', ymin = ' num2str(min(min(x))) ', ymax = ' num2str(max(max(x))) ']'])
    end
    disp([9 '{imagesc-1.png};'])
    disp([9 '\end{axis}'])
    disp([9 '\end{tikzpicture}'])
    
    % At the end close the figure
    close
end

%% Export as a 2D figure using print approach
if strcmp(cfg.type, 'surf2D')
    % open new figure and plot the data
    h = figure;
    surf( x, y, amp, 'EdgeColor', 'None' )
    
    % use as default the 2D plot view
    view(cfg.view)
    
    % save additionally as a fig file using the compact option of Matlab
    % 2014b or later
    savefig(h, 'surf2D.fig', 'compact')
    
    % if given, the selected colormap is chosen for creating the '*.png'
    % note: No colorbar is displayed, because this colorbar should not exist in
    %       the saved png file!
    if strcmp(cfg.use_colormap, 'jet')
        colormap jet
    elseif strcmp(cfg.use_colormap, 'parula')
        colormap parula
    elseif strcmp(cfg.use_colormap, 'viridis')
        colormap viridis
    end
    
    % if given, use the selected colorbar range for setting up the colorbar,
    % because the colorbar values are directly asociated with an color and
    % cannot be changed after the export.
    if exist('colorbar_range', 'var')
        caxis(cfg.colorbar_range)
    end
    
    % hide the axis environment, because this is set up using pgfplots later on
    axis off
    
    % save the actual plot as a png
    print -dpng surf2D -r400
    
    % trim all the white space which matlab adds to the image
    system('mogrify -trim surf2D.png');
    
    % set the white background to transparent
    system('mogrify -transparent white surf2D.png');
    
    % see '4.3.7 Using External Graphics as Plot Sources'
    disp([9 'Exporting surf2D.png... Done!'])
    disp([9 'Use the following code and save it as a *.tikz file. Some values must be adapted!'])
    disp([9 'Only set xmin, xmax, ymin, ymax all together or none of them! If not, no plot is created.'])
    disp([9 ' ~~~ Code for a 2D plot: ~~~'])
    disp([9 '% created with surf2TikZ written by Fabian Roos'])
    disp([9 '% chosen settings: view: ' num2str(cfg.view)])
    if isfield(cfg,'xlim')
        disp([9 '% xmin: ' num2str(cfg.xlim)])
    end
    if isfield(cfg,'ylim')
        disp([9 '% ymin: ' num2str(cfg.ylim)])
    end
    disp([9 '\begin{tikzpicture}'])
    disp([9 '\begin{axis}['])
    disp([9 9 'axis on top,'])
    disp([9 9 'enlargelimits = false,'])
    disp([9 9 '% colorbar,'])
    if strcmp(cfg.use_colormap, 'jet')
        disp([9 9 'colormap/jet,']) % if parula is chosen, no need to set colormap
    end
    disp([9 9 '% colorbar style = {%'])
    disp([9 9 9 '% ylabel = {Leistung in \si{\decibel}},'])
    disp([9 9 9 '% % ytick = {-50,-40,...,0},'])
    disp([9 9 '% },'])
    disp([9 9 '% point meta min = ' num2str(cfg.colorbar_range(1)) ','])
    disp([9 9 '% point meta max = ' num2str(cfg.colorbar_range(2)) ','])
    disp([9 9 '% xtick = {0,20,...,100},'])
    disp([9 9 '% ytick = {0,20,...,60},'])
    disp([9 9 '% xlabel = {$x$ in \si{\metre}},'])
    disp([9 9 '% ylabel = {$y$ in \si{\metre\per\second}},'])
    disp([9 ']'])
    disp([9 '\addplot graphics'])
    if cfg.view(1) == 0 && cfg.view(2) == 90
        disp([9 '[xmin = ' num2str(min(min(x))) ', xmax = ' num2str(max(max(x))) ', ymin = ' num2str(min(min(y))) ', ymax = ' num2str(max(max(y))) ']'])
    elseif cfg.view(1) == 0 && cfg.view(2) == 0
        disp([9 '[xmin = ' num2str(min(x)) ', xmax = ' num2str(max(x)) ', ymin = ' num2str(min(min(amp))) ', ymax = ' num2str(max(max(amp))) ']'])
    elseif cfg.view(1) == -90 && cfg.view(2) == 90
        disp([9 '[xmin = ' num2str(min(y)) ', xmax = ' num2str(max(y)) ', ymin = ' num2str(min(min(x))) ', ymax = ' num2str(max(max(x))) ']'])
    elseif cfg.view(1) == 90 && cfg.view(2) == 0
        disp([9 '[xmin = ' num2str(min(y)) ', xmax = ' num2str(max(y)) ', ymin = ' num2str(min(min(amp))) ', ymax = ' num2str(max(max(amp))) ']'])
    elseif cfg.view(1) == -90 && cfg.view(2) == 0
        disp([9 '[xmin = ' num2str(min(y)) ', xmax = ' num2str(max(y)) ', ymin = ' num2str(min(min(amp))) ', ymax = ' num2str(max(max(amp))) ']'])
    end
    disp([9 '{surf2D.png};'])
    disp([9 '\end{axis}'])
    disp([9 '\end{tikzpicture}'])
    
    % at the end close the figure
    close
end

%% Export as a 3D figure using print approach (matlab2tikz required)
if strcmp(cfg.type, 'surf3D')
    % open new figure and plot the data
    figure
    surf( x, y, amp, 'EdgeColor', 'None' )
    
    % If given, the selected colormap is chosen for creating the '*.png'
    % Note: No colorbar is displayed, because this colorbar should not exist in
    %       the saved png file!
    if strcmp(cfg.use_colormap, 'jet')
        colormap jet
    elseif strcmp(cfg.use_colormap, 'parula')
        colormap parula
    elseif strcmp(cfg.use_colormap, 'viridis')
        colormap viridis
    end
    
    % If given, use the selected colorbar range for setting up the colorbar,
    % because the colorbar values are directly asociated with an color and
    % cannot be changed after the export.
    if exist('colorbar_range', 'var')
        caxis(cfg.colorbar_range)
    end
    
    % hide the axis environment, because this is set up using pgfplots later on
    axis off
    
    % do the export once again for a 3D plot
    view(cfg.view)
    
    % save the actual plot as a png
    print -dpng surf3D -r400
    
    % trim all the white space which matlab adds to the image
    system('mogrify -trim surf3D.png');
    
    % set the white background to transparent
    system('mogrify -transparent white surf3D.png');
    
    % See 'Support for External Three-Dimensional Graphics'
    % in '4.3.8 Keys To Configure Plot Graphics'
    disp([9 'Exporting surf3D.png... Done!'])
    disp([9 'Use the following code and save it as a *.tikz file. Some values must be adapted!'])
    disp([9 'Only set xmin, xmax, ymin, ymax all together or none of them! If not, no plot is created.'])
    disp([9 ' ~~~ Code for a 3D plot: ~~~'])
    disp([9 '% created with surf2TikZ written by Fabian Roos'])
    disp([9 '% chosen settings: view: ' num2str(cfg.view)])
    disp([9 '\begin{tikzpicture}'])
    disp([9 '\begin{axis}['])
    disp([9 9 'grid,'])
    disp([9 9 'minor tick num = 1,'])
    disp([9 9 'enlargelimits = false,'])
    disp([9 9 '% zmin = ' num2str(cfg.colorbar_range(1)) ','])
    disp([9 9 '% zmax = ' num2str(cfg.colorbar_range(2)) ','])
    disp([9 9 '% xtick = {0,20,...,100},'])
    disp([9 9 '% ytick = {0,20,...,60},'])
    disp([9 9 '% ztick = {-45,-30,...,0},'])
    disp([9 9 '% xlabel = {$x$ in \si{\metre}},'])
    disp([9 9 '% ylabel = {$y$ in \si{\metre\per\second}},'])
    disp([9 9 '% colorbar,'])
    if strcmp(cfg.use_colormap, 'jet')
        disp([9 9 'colormap/jet,']) % if parula is chosen, no need to set colormap
    end
    disp([9 9 '% colorbar style = {%'])
    disp([9 9 9 '% ylabel = {Leistung in \si{\decibel}},'])
    disp([9 9 9 '% % ytick = {-50,-40,...,0},'])
    disp([9 9 '% },'])
    disp([9 9 '% point meta min = ' num2str(cfg.colorbar_range(1)) ','])
    disp([9 9 '% point meta max = ' num2str(cfg.colorbar_range(2)) ','])
    disp([9 ']'])
    disp([9 '\addplot3 graphics['])
    disp([9 9 'points={% important'])
    disp([9 9 '(?,?,?) => (?,?-?)'])
    disp([9 9 '(?,?,?) => (?,?-?)'])
    disp([9 9 '(?,?,?) => (?,?-?)'])
    disp([9 9 '(?,?,?) => (?,?-?)'])
    disp([9 9 '}]{surf3D.png};'])
    disp([9 '\end{axis}'])
    disp([9 '\end{tikzpicture}'])
    
    disp([9 'To determine the required parameters open image in gimp and select points (pt) as the metric.'])
    disp([9 'Ignore png shift'])
    disp([9 'Then determine the height in points of the image, because pgfplots starts counting from low left and gimp from top left.'])
    disp([9 'Pick 4 (four) points in the Matlab figure, save the coordinates and determine the corresponding point values.'])
    disp([9 '(matX,matY,matZ) => (gimpX,gimpHEIGHT-gimpY)'])
    
    % do not close figure because coordinates need to be estimated
end
end