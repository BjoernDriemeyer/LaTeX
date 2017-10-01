# PGFPlots
*PGFPlots* is based on *TikZ* (that's why you use the `\begin{tikzpicture}` environment) and *PGF*,
the *Portable Graphics Format*. With it you can plot functions and measurement data. This is a short
help file for the use of it. For more information have a look at the
[manual](http://pgfplots.sourceforge.net/pgfplots.pdf) where also tutorials are available.

## The concepts of plotting
I distinguish between three different plotting concepts. If the different concepts and approaches
are understood, adapting them is easy.

The optimal way is to plot a function like *sin*, *x^2* or similar. This way you are in full control
of the plotted domain. The next option is to use (measurement or simulation) data, which you want to
plot. The third case is important if you want to plot a large data set and you run out of TeX
memory. In this case you can use an image of the plot, perhaps created with Matlab, and use
*PGFPlots* only to typeset the axis coordinate system. This ensures that the axis font is
appropriate to your document.

To test the following (minimal working) examples (MWE) save them in a file with tikz extension and
input them in the export.tex file.

### Function Plotting
If you want to plot a function you can use this MWE.

```latex
\begin{tikzpicture}
  \begin{axis}[
      % enlargelimits = false,
      grid = major,
      % xmin = 0,
      % xmax = 3,
      % xtick = {0,0.5,1,...,3},
      title = {In Document Use Caption Instead Of Title},
      xlabel = {$t$ in \si{\micro\second}},
      ylabel = {Voltage in \si{\volt}},
    ]
    
    \addplot[
      blue,
      domain = -pi:pi,
      samples = 100,
    ]{x + sin(deg(x))}; % input of sin() in degree

  \end{axis}
\end{tikzpicture}
```

There are already the usual options included, but some are commented out. See the option list below
for some more information.

### Data Plotting
One possible way to plot data is to store the values as a *comma separated file* (csv). There are
other separators available, so check the manual. If your data file is very large you can use
*lualatex* to compile the externalized plot and if even this is not an option, use the third concept
of including an image and setting the axis with *PGFPlots*.

In a simple case you only have a csv file containing x and y values. If you want to compare
measurement to simulation results you would have to use two separate files with two times the x
coordinates. A simpler way is to use one csv file with three columns: x, sim, meas points. Now you
have to tell PGFPlots to select the appropriate columns or the first two will be selected.

```latex
\begin{tikzpicture}
  \begin{axis}[
      % enlargelimits = false,
      grid = major,
      xlabel = {Samples},
      ylabel = {Power in \si{\decibel}},
      % title = {In Document Use Caption Instead Of Title},
      legend pos = north west,
      legend cell align = left,
      % legend columns = -1,
      cycle list name = roos,
      no markers,
    ]

    % if brackets are used, the cycle list is deativated. Activate it with a +
    \addplot+[
    ]
    table[col sep = comma]{gfx/example_plots.csv};
    
    % no brackets uses the cycle list
    \addplot
    table[x index = 0, y index = 2, col sep = comma]{gfx/example_plots.csv};
    
    \addlegendentry{simulation};
    \addlegendentry{measurement};
  \end{axis}
\end{tikzpicture}
```

If you have more dimensional data, you can use a scatterplot and colour the points. A colorbar can
be simply added by the `colorbar` command. The definition in *rs_tikz.tex* uses the parula colormap.
If you want the classic jet colormap, uncomment the option.

```latex
\begin{tikzpicture}
  \begin{axis}
    [
      % enlargelimits = false,
      grid = major,
      xlabel = {Samples},
      ylabel = {Power in \si{\decibel}},
      % title = {In Document Use Caption Instead Of Title},
      % colormap/jet,
      colorbar,
    ]
    \addplot[
      scatter,
      scatter src = explicit,
      only marks,
    ]
    table[x index = 0, y index = 1, meta index = 2, col sep = comma]{gfx/example_plots.csv};
  \end{axis}
\end{tikzpicture}
```
### Graphic Plotting
Each data point is used as a path point of the vector graphic. If the data consists of too many data
points the file cannot be compiled. And even if you increase the memory limit by using lualatex
there is a boundary where too large data isn't useful to plot. The PDF image would be slow in view
and the file considerable large. This is the reason why you can use an image of your data and add
only the axis environment with PGFPlots. This hold especially for the plots of matrices.

The basic idea is to use a program to plot the data, hide the axis and draw the axis with PGFPlots.
You have to specify the axis limits, because they cannot be determined out of the image.

Using Matlab, plot the figure but do not use a title or a legend. Remove the axis with the command
`axis off` and save the current figure as an image with `print -dpng imagename -r400`. Unfortunately
Matlab has a huge white border, which has to be removed. On a Linux or Mac with imagemagick
installed, invoke `convert -trim imagename.png imagename.png` to remove the white border and
`convert -transparent white imagename.png imagename.png` to set the background to transparent. Use
the data cursor of the figure or analyse the plotted data with the help of Matlab to find the
following values: $x_{\text{min}}$, $x_{\text{max}}$, $y_{\text{min}}$, $y_{\text{max}}$ and if there
are amplitude values present $z_{\text{min}}$, $z_{\text{max}}$ which are needed for the colorbar.

```latex
\begin{tikzpicture}
  \begin{axis}[
      axis on top,
      enlargelimits = false,
      colorbar,
      colorbar style = {%
        ylabel = {Amplitude in \si{\decibel}},
        % ytick = {-50,-40,...,0},
      },
      point meta min = -51.1991,
      point meta max = 0,
      % xtick = {0,20,...,100},
      % ytick = {0,20,...,60},
      xlabel = {$R$ in \si{\metre}},
      ylabel = {$v$ in \si{\metre\per\second}},
      % xmin = 10,
      % xmax = 20,
      % ymin = -30,
      % ymax = 30,
    ]
    \addplot graphics
    [xmin = 0, xmax = 51, ymin = -36.055, ymax = 35.4916]
    {gfx/imagesc-1.png};
  \end{axis}
\end{tikzpicture}
```

The lines from `colorbar` to `point meta max` are only necessary if you want a colobar. Per default
it is assumed that the colour of your figure is in between zero and one. To set the proper colorbar
values the point meta information must be given.

If you want to show only a part of the image using the `xmin` keys, often only correct results are
achieved if all four values are selected.

To plot a matrix from top (`view(0,90)`) there is a better way as to use `print` command. If the
matrix is plotted with the `imagesc` plot, *matlab2TikZ* offers an enhanced export option where for
each matrix cell one pixel in a png image is saved. This dramatically reduces space of the image. So
for a matrix from top view, a good way is to use *matlab2TikZ* for generating the png. The inclusion
is the same.

For a 3D plot with arbitrary axis the process is a bit more complex. *PGFPlots* does not know where
to place the axis and how they are orientated. So you have to hand this information over as stated
in the manual (based on [jake's solution](https://tex.stackexchange.com/questions/52987/)). The basic
idea is that you need for linear independent points and there appropriate coordinates as data values
as well as pixel information.

So you follow the steps as before, but after saving the image you choose four points. For each point
use the data cursor and save the $x$, $y$ and amplitude value. Use a picture editing program (e.g.
*Gimp*, ignore png shift) and find the appropriate values in points and not pixels. Note that
*PGFPlots* starts to count from low left but *Gimp* from top left. So first determine the height and
then use *height-gimp_y_coordinate*.

If you do not use linear independent points or choose data points and points values accordingly, a
misaligned axis is the outcome.

```latex
\begin{tikzpicture}
  \begin{axis}[
      grid,
      minor tick num = 1,
      zmin = -46.7717,
      zmax = 0,
      xtick = {0,15,...,45},
      ytick = {-30,-15,...,30},
      ztick = {-45,-30,...,0},
      xlabel = {$R$ in \si{\metre}},
      ylabel = {$v$ in \si{\metre\per\second}},
      colorbar,
      colorbar style = {%
        % ytick = {-50,-40,...,0},
        ylabel = {Amplitude in \si{\decibel}},
      },
      point meta min = -46.7717,
      point meta max = 0,
    ]
    \addplot3 graphics[
      points={% important
        (15.2,29.86,0) => (73,239-0)
        (0.2,35.49,-30.1) => (1,239-140)
        (1.8,-35.49,-39.25) => (205,239-239)
        (50.8,-36.06,-31.12) => (389,239-148)
    }]{gfx/surf3D.png};
  \end{axis}
\end{tikzpicture}
```

For some special cases there is a Matlab function available for an easier export.


## Notes
Per default each consecutive plot will have different markers and line styles. To control them
either choose the options for each plot or use cycle lists.

If you use `\addplot[]` this deactivates the cycle list. If you explicit state `\addplot+` this
activates the cycle list even if you use the brackets.

To use a colorbar just use the `colorbar` option. You should specify the colormap. In newer versions
of Matlab the parula colormap is the default options, but this colormap is not included in PGFPlots.
Therefore you have to specify it, which is already done in the template (in the file `rs_tikz`). If
you only state `colorbar` the parula colorbar is used unless you specify another by use of
`colormap`.


## Referencing Legends
To reference a legend of the plot in the caption or the text the legend entry can be used. To enable
this functionality add

```latex
\newcommand{\plotref}[1]{\tikzexternaldisable\ref{#1}\tikzexternalenable}
```

to the header. [Source](https://tex.stackexchange.com/questions/65494/)

Each addplot needs an label `\label{leg:sim_0}` and can then be referenced with a
`\protect\plotref{leg:sim_exp}` in the text.

For TikZ images where no label is possible, the entry can be drawn by hand. Therefore consider the
following two examples. Only use the `thick` option, if you plotted in `thick` as well.

```latex
`(\protect\raisebox{2pt}{\protect\tikz \protect\draw[blue,solid,thick](0,0) -- (6mm,0);})`
`(\protect\tikz \protect\draw[blue,fill=blue,thick] (0,0) circle (2pt);)`
```

The problem of multiply-defined labels is [unsolved](https://tex.stackexchange.com/questions/277583/).


## Axis Options
The following listed options are often used inside the `\begin{axis}` environment.

```latex
\begin{axis}[
% Plot Settings
scale only axis=true,       % width and height apply ONLY to the axis rectangle, the resulting
                            % figure will be larger because of any axis descriptions!
                            % Use only with care! Default: false
enlargelimits=false,        % Deactivates the per default activated enlargement of the axis limits
                            % This means that the plot touches the axis. This option should be set
                            % if an image is included. Can be (partly) overwritten if xmin is set
enlarge x limits=false,     % to only deactivate the enlargement of one axis
axis equal,                 % each bin size of both axis has the same length, axis limits are enlarged!
axis equal image,           % same as axis equal, but the axis limits stay constant
grid,                       % add a grid, options:
                            % grid=major, % default, lines at normal tick positions
                            % grid=minor, % must be specified, places at minor tick positions
xmin=0,                     % axis limits are chosen per default, but can be adjusted, same for ymin
xmax=10,                    % axis limits are chosen per default, but can be adjusted, same for ymax
x dir=reverse,              % the x axis starts from right to the left
xtick={0,1,...,10},         % control the axis ticks (where numbers are placed)
xticklabel={A,B,C},         % use those labels instead of the first three numbers,hint: use with xtick
point meta min = -50,       % only for an activated colorbar and if an image is used as data source
point meta max = 0,         % those two lines determines the range of the colorbar
colorbar,                   % activates a colobar. See the notes above for more information
colormap/viridis,           % uses the colormap viridis, or jet
colormap name=parula,       % use the defined colormap parula in the rs_tikz.tex (user defined)
colorbar style = {%         % adjust the colorbar style
  % ytick = {-50,-40,...,0},% adjust the ticks
  ylabel = {Amp in \si{\decibel}}, % the colorbar axis is the y axis, so use this to set the label
},
%
% Labelling and Legends
xlabel={$x$ in \si{\metre}},% label the x axis, the same for the y and z axis. For units use SiUnitx
legend pos = north west,    % controls the position, possible keys: south west|south east|north
                            % west|north east|outer north east
legend style={at={(0.5,0.02)}, anchor=south}, % position it the relative axis (0,0) is left lower
                            % corner, choose an anchor, use an distance of 2% as in the manual and
                            % in https://tex.stackexchange.com/questions/134084
legend cell align = left,   % the legend text is not centred, it is aligned to the left side
legend columns = -1,        % do not use a vertical placement of entries, place them horizontally
legend columns = 2,         % do not only use one column, use with more space between columns
legend style={%             % add space between columns
  /tikz/column 2/.style={%  % https://tex.stackexchange.com/questions/80215/
    column sep=5pt,
  },
},
%
% Labelling: Multiplier
y filter/.code={\pgfmathparse{\pgfmathresult*10.}\pgfmathresult}, % multiply all y data by 10
                            % do not use #1 as result, due to known problems with \addlegendentry
                            % use in addplot option if it should be applied only to one plot
                            % http://tex.stackexchange.com/questions/134754/
scaled x ticks=true,        % per axis (or globally with scaled ticks) very small or large ticks can
                            % be written with as 1 2 3 and at the edge a 10^4. If each tick should
                            % be labelled without a multiplier use =false
x tick label style={/pgf/number format/fixed}, % all ticks labels are written without an multiplier
]
\end{axis}
```

## Addplot Options
```latex
\addplot+[
% Plot Styles               % those options are overwriting a possible cycle list if defined, see hint
blue,                       % specify a colour, see the xcolor package help: red, blue, black, brown, ...
solid,                      % line styles: solid, dotted, densely dotted, loosely dotted, dashed,
                            % densely dashed, loosely dashed, dashdotted, densely dashdotted, ...
line width=thick,           % increase the line width, also possible: 2pt
each nth point=100,         % use only every 100 point
no markers,                 % do not show markers which is possible set by a cycle list
mark=*,                     % every point / sample is indicated with a marker. Avoid to close markers
                            % marker styles: *, x, +, -, |, o, asterisk, star, square, diamond, ...
mark repeat=100,            % draw only each 100th marker
mark size=5pt,              % control the marker size
mark options={solid},       % if the line style is dashed and the marker should not be dashed
mark options={gray},        % if the marks should use a different colour, can be combined with solid
mark options={line width=2pt}, % plot the marker in a bold font
only marks,                 % do not connect the data points
scatter,                    % use a scatter plot
scatter src = explicit,     % use the meta information as colour, must be stated in the table
->,                         % add an arrow at the end
%
% Function Plotting
domain=-pi:pi,              % the range for plotting a function
samples=100,                % number of samples generated to plot the data
]
table[
% Table Settings
%
col sep = comma,            % column separator
x index = 0,
y index = 1,
comment chars = {\%}        % ignore lines starting with this comment char
meta index = 2,             % meta information, e.g. for colouring scatter points
]
{dv8_114_152.csv};          % load csv file
%
% Plot Several Data per loop
\foreach \n in {1,3,5}{%    % use a loop with the x columns and calculate the y columns
  \pgfmathsetmacro{\m}{int(\n+1)}% this line could be used to calculate the second needed column number
  \addplot+[                % use the legend entries option for the legend
  ]
  table[col sep = comma, x index = \n, y index = \m, comment chars = {\%}]{spectral_similarity_vfft.csv};
}
%
% Fill Area in-between
\addplot[                   % example: http://tex.stackexchange.com/questions/7914/
fill=gray,                  % colour to fill with
fill opacity=0.1,           % use a bit transparency
]
fill between[of=A and B];   % where two lines previously were name with `name path=1,`
```

## Misc
```latex
% Misc: Legend of each data curve: possibilities
legend entries={bla,blub},  % add this in the axis options. If comma names are used, put values in {}
\addlegendentry{$v$};       % place at the end of each \addplot command

% Add an Image into the plot
\node[below left] at (rel axis cs:0.99,0.99) {\includegraphics[width=2.5cm]{dv16_it116.png}};
```
