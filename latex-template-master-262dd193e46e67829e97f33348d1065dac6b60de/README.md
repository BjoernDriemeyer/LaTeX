# LaTeX Template since February 2016
This is the LaTeX template maintained by Fabian Roos, which uses only necessary and hopefully up to
date versions of packages. It comes with examples for the use of TikZ and PGFPlots.

## Settings
Nearly all settings are controlled in the header.tex. Please note that those settings are only a
proposal to achieve a good looking result in my opinion. Not all of them are required to ensure a
MWT style version. For example the paragraph style (see General Coding Tips - New Paragraphs) can be
chosen as you want.

## General Coding Tips
In the following some hints inspired by previous work of students.

### Compilation
If you use an editor you can compile your document using the build-in functions. If you use an text
editor to edit the files, you can invoke `pdflatex main_example.tex` from your terminal. Often
several compilations are necessary (the table of contents needs at least two or three of them) and
the bibliography must be converted using `bibtex main_example`. Either you invoke them using your
editor or you can use the script by invoking `./compile_example.sh`. If something went wrong, you
can delete the temporary files with help of `cleanup_ex.sh`.

### File Structure
A good practice is to use for each chapter or even for a long chapter for each or several
subsections a separate tex file. This keeps the code structured and you can activate or deactivate
parts of your work for error search.

Content files could be stored in the folder *inhalt*, all graphic files can be stored in *gfx*. More
subfolders for each chapter can be useful.

### New Paragraphs
A new paragraph is inserted using a new line (press Enter twice). You should not use commands like
`\\` or `\newline`.

Per default a new paragraph is formatted with no vertical but a horizontal indent. The reason, as
stated in the Koma script manual, is that the beginning of a new paragraph can only be seen if an
horizontal indent is used. For example a new sentence after an equation or on a new page is only
noticed as a new paragraph if there is a horizontal indent. A vertical indent can not be seen. If
you wish no horizontal but a vertical indent activate the parskip option `parskip=half` in the
header.

### Graphic Inclusion
A graphic environment should look like the following example.

```latex
\begin{figure}[tbp]
  \centering
  \includegraphics[width=1.0\linewidth]{gfx/image.tikz}
  \caption{This is the caption of the image.}
  \label{fig:tikzimage}
\end{figure}
```

Please note that you can change the placement of the figure by the options in *[tbp]*. It is best to
use this placement and to avoid the [h!] option forcing LaTeX to place the floating object at the
actual position. For more detailed information about the placement see the [float
terminology](http://tex.stackexchange.com/questions/39017/). Also a common way is to place the
figures at the top or at the bottom and not somewhere in the middle of the text for a better
readability.

Do not use the `\begin{center}` environment due to [unwanted
spaces](http://tex.stackexchange.com/questions/2651/).

You first have to define the caption and then the label, the other way around leads to reference
issues.

You can place two or more figures together in one floating environment using for example the
subcaption package and the following code example.

```latex
\begin{figure}[tbp]
  \centering
  \subcaptionbox{The caption of the first image.
  \label{fig:first}}
  [0.49\linewidth]{\includegraphics[width=0.49\linewidth]{gfx/chirp_sequence_shift_01.tikz}}
  % \hfill for two horizontal images
  % \par\bigskip for two vertical images
  \subcaptionbox{The caption of the second image.
  \label{fig:pgfplotsimg}}
  [0.49\linewidth]{\includegraphics[width=0.49\linewidth,height=0.2\textheight]{gfx/example_plots.tikz}}
  \caption{This is an example for the subcaption package.}
  \label{fig:subcapex}
\end{figure}
```

The first parameter in the `[]` braces is the width of the subfloat. If you choose a value below
0.5, the two floats are positioned left and right of each other. A value larger than 0.5 results in
two floats above and below. The scaling in the `includegraphics` is the actual figure width. Both
values need not to be equal, but if they are different the first one should be larger to prevent
overlapping figures.

If you have images left and right positioned, usually you want the images shifted as left and right
as possible. Therefore you add between the images a `hfill` to fill the horizontal space. If you
have an image above and below and the space is to less, insert a `\par\bigskip`. Or you want that
the top of the first figure and the bottom of your last figure is exactly aligned with the text
margins. Then use a `minipage` and fill the space in between as in the next example.

```latex
\begin{figure}[tbp]
  \begin{minipage}[b][\textheight][b]{\linewidth}
    \centering
    \subcaptionbox{This is an image which was created using the \emph{imagesc} plot function from
      Matlab in combination with matlab2tikz.
    \label{fig:imagesc}}
    [\linewidth]{\includegraphics[width=0.85\linewidth]{gfx/surfimgsc.tikz}}
    \vfill
    \subcaptionbox{For 3D plots there is no suitable way with matlab2tikz. Create the png on your own
      and create an axis environment with PGFPlots.
    \label{fig:surf2tikz3d}}
    [\linewidth]{\includegraphics[width=0.65\linewidth]{gfx/surf2tikz3D.tikz}}
    %
    \caption{An example for 2D and 3D plots.}
    \label{fig:pgfplots}
  \end{minipage}
\end{figure}
```

### References
If you insert a reference using the `\ref` command, insert a protected space ``~`` before, such that a
line break is avoided at this position. Eg. `see Figure~\ref{fig:example}`.

To reference a subfigure and to obtain a result like Fig. 2.1 (a), use
`Fig.~\ref{fig:pgfplots}~(\subref{fig:imagesc})`.

A good procedure is to use a prefix in your labels and references, e.g. `\ref{sec:introduction}`,
`\ref{fig:basics_fmcw}`, `\ref{tab:results}` or `\ref{eq:radar_equation}`. Most editors can
list only the references belonging to one group. This way you can easier find the appropriate
element. You should not use spaces or special characters in the labels.

### Numbers
Write all floating-point numbers equally. In German, use a comma for the decimal separator, in
English use the dot. In German it is necessary to write them in Math mode with braces, e.g.
`$4{,}2$` unless you use the redefinition in the header file.

### Units
If you want to include a value and a unit, the space between is smaller than between two
normal words. A good way to typeset is to use the *siunitx* package. You do not need to be in the
math mode and can type directly `\SI{13,37}{\giga\hertz\per\second}`. This way you get the correct decimal
separator. Also you alter the decimal separator with an option in the header to allow an easy switch
between the languages. If you only want to typeset the unit, use `\si{\micro\second}`.

If you want to use the macros mentioned in the student's information document like `40\Ohm`, then
you have to activate the package `myunits` in the header.

### Equations
Equations inside the text are called *inline equations* and are placed inside two `$a=b$`. If you
want a new line, use the align environment

```latex
\begin{align}
    a &= b\\
    \intertext{bla}\nonumber
    c &= d\,.
\end{align}
```

for typesetting. Equations are aligned at the `&` operator. If a page break is permitted inside the
align environment, it can be prohibited by use of `\\*`. To ensure an alignment even if text is in
between, include the text with `\intertext{bla}`. Normal punctuation of equations helps fluent
reading, but insert a small space `\,.` between the equation and the dot or comma. Inside the text a
line break is avoided if the text is put in a `\mbox{test a}`.

### Subscripts
An subscript in math mode `$f_i$` is in italic, if it is a variable. It is roman (up right) if it is
a short version. The carrier frequency `$f_{\mathrm{c}}$` is set in roman as well as
`$U_{\mathrm{eff}}$`. This also holds for constants like `$\mathrm{i}$`. See the help on
[typefaces](http://physics.nist.gov/cuu/pdf/typefaces.pdf).

### Function Names
All function names are written upright, so use `$\cos$` and if there is now abbreviation available
use `$\operatorname{mod}$`.

### Usage of Parentheses
If a fraction is displayed, the `(` is usually to short, therefore let \LaTeX\ estimate the correct
height with `a = (1+\frac{b}{c})\qquad a = \left(1+\frac{b}{c}\right)`.

### Quotation Marks
Simple ones `\qlq\` and `\grq`, double ones `\glqq\` and `\grqq`.

## Graphic Creation
### General Remarks
How exactly you create your figures is your decision. If you want to illustrate something you can
use Inkscape or TikZ. Please note that so far I offer only basic support for Inkscape graphics. If
you run into any problems find a solution on your own, because there is no assistance from my side.
If you have a TikZ related question you can ask for assistance.

For measurement or simulation results you could either use gnuplot or PGFPlots. I would suggest
PGFPlots and therefore there is an example included. Also for some special cases I wrote a function
to enhance the matlab2tikz approach.

### TikZ
As an introduction to TikZ have a look at the
[manual](http://mirrors.ctan.org/graphics/pgf/base/doc/pgfmanual.pdf). Especially the first
tutorial *A Picture for Karl's Students* is worth reading to get to know the basic idea of TikZ. For
the most questions use google and have a look at the results from
[stackexchange](http://tex.stackexchange.com/).

### PGFPlots
For some information see the [separate file](tools/PGFPlots.md).

For linux users there is a Matlab function called [surf3tikz](https://github.com/Fiech/surf3tikz)
which directly converts a *surf* plot to a PGFPlots image. Please test this functions and report
problems to enhance it further. This function is based on *surf2TikZ.m* Matlab function, which is
therefore obsolete. For compatibility this functions stays in the *tools* folder.

### matlab2tikz
If you want to insert Matlab figures in your document you can export them in most cases directly
using the Matlab function *matlab2tikz* which you have to download for example from [Matlab
Central](http://www.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz-matlab2tikz). Having
an open figure you invoke it by `matlab2tikz('test.tikz')`. In this case you should remove the
dimension settings. Or you pass the appropriate option directly using `matlab2tikz('imagesc.tikz',
'noSize', true)`.

Think about a consistent style, so I prefer for drawings using TikZ only a line for the x and one for
the y axis. For simulation and measurement data I use a box axis, so I would adapt the source code.
Have a look at the included examples.

```latex
\begin{axis}[%
    % width=4.602in, % remove this dimension or use noSize
    % height=3.583in, % remove this dimension or use noSize
    % at={(0.772in,0.484in)}, % not required
    scale only axis,
    xmin=-1e-05,
    xmax=1.5e-05,
    xmajorgrids,
    ymin=-0.04,
    ymax=0.05,
    ymajorgrids,
    % axis background/.style={fill=white}, % not required
    % axis x line*=bottom, % I would remove this line
    % axis y line*=left, % I would remove this line
]
```

### Scaling figures
Use the tikzscale package, which enhances the includegraphics environment. The extension must be
tikz, tex is not supported!

TikZ pictures can be scaled only with a fix axis ratio, therefore use either `width=0.9\textwidth`
or `height=0.25\textheight`. Using both values can lead to a recompilation of the externalized image
every compilation. Only PGFPlots images can be scaled without a fixed axis ratio, therefore both
options are valid. In this case, a PGFPlots image should not have a width or height definition in it
as it is created by matlab2tikz. If these options are not removed, the text and other elements are
not correctly scaled.

See the document for examples of an inserted TikZ and a PGFPlots image.

### Work flow
If you create a TikZ or PGFPlots figure, you could either include them in your document. This means
that you have to compile the whole document which is mostly a huge overhead. Or you can use the
export.tex. This is an example of the standalone class and is designed for creating figures. So
input your figure there and compile the document. If you're satisfied with the result, insert the
figure in your document.

Also if you finished with your thesis, you want to include the figures in your presentation. Usually
it is not possible to include PDF images. But you can include all your images in the export.tex
document. After a compilation you receive a PDF file with one figure per page. With a simple convert
command (see the header of export.tex) you will get a PDF file for each page which you can insert in
your presentation. The density option is the dots per inch value. If you want to zoom in, increase
it.

Using this way, you did not set the dimensions for the graphics because you alter them using the
includegraphics option. This results in equal sides in PGFPlots. If you want to change the axis
ratio, you have to manually set the `width=10cm`, and `height=5cm`, option the axis options. For the
axis ratio there is no difference in setting a width to `width=30cm, height=15cm`. However, this
changes the size of the figure and the axis labels are always constant in size. This means that you
create a figure to fit on a single A4 page. If you use smaller dimensions the axis font ist still
the same! So consider this four altering the dimensions. But use this only to get your axis ratio
for the export and not for including in your document!

An other approach would be to use the externalised PDF files in the tikz folder. Then you get the
scaling from your document. Just invoke `convert -density 400 *.pdf export.png` and you get each PDF
file in a separate image.

### Externalize
A TikZ or PGFPlots image is compiled every time you compile your document. With several figures
included, this process takes usually a lot of time. There is a way to speed up the process. In the
first compilation process each figure is compiled with an external process and the resulting figure
is saved as an pdf file. For the following compilation processes only the pdf gets included.

If you want to activate the externalization, you have to uncomment the corresponding lines in the
header.tex. Also you have to invoke the pdflatex command with a `-shell-escape`, using Windows
`-enable-write18` is to be used. In this version the images are saved in the tikz folder. So please
create it or you will get an error. Or you can use the compile bash script by invoking
`./compile_example.sh`.

### Inkscape
There are several ways of how to include an graphic created with Inkscape. If you also include TikZ
and PGFPlots images and want to use the externalize option a possible way is to use the *svg*
package. This way you only have to include your *.svg* file and let the package do the rest. In the
header in the graphic section I prepared some code lines which you have to uncomment.

The *svg* package loads several other packages, including *subfig* which leads to problems if the
*subcaption* package is loaded. So there is a [temporary
fix](https://tex.stackexchange.com/questions/291929/) to prevent loading the *subfig* package. Very
soon (information from 10.11.2016) there should be an update to the *svg* package to solve this
issue.

Normally you should shrink the page to your drawing so that you do not have white space around it.
But this alters your lineal and points lie on a new coordinate system. So there is an option that
only the drawing and not the whole page is used.

Additionally the image creation is invoked by a call to the inkscape program by your compilation
process. This means you need to compile the document with active shell-escape. Also inkscape must be
on your search path. Due to relative paths all documents must be in the root folder of your project.
To allow the placement in the *gfx* folder there is an other option set. Adding an folder path in
the include is not valid, unless you use it as an option. For more information have a look at the
manual.

Assuming you have uncommented the appropriate lines, placed your *svg* image in the *gfx* folder.
There is an example of how to include the Inkscape images. Please note that you have to omit the file
extension. Only a width scaling is useful, the other axis is scaled appropriate.

```latex
\begin{figure}[tbp]
  \centering
  \includesvg[width=0.5\linewidth]{image}
  \caption{Inkscape image using 0.5 of the linewidth.}
  \label{fig:ink}
\end{figure}
```


## Literature
To manage your literature [JabRef](http://jabref.sourceforge.net/) is one possible program. With
this program you edit the *literatur.bib* file which you include in your document. Only those
entries you use with the `\cite{Roos2015}` command will be printed in the bibliography.

If you are using a newer version, like 2.10, you can directly add the PDF file per right click on
an entry.

In the *Optional fields* the *Month* can be specified. If you use the English three letter
abbreviations, e.g. jan, feb, mar, the month is set according to your bibliography style you choose
in your main document. So please do not insert the German or English long format or any other
abbreviation.

If you import bibtex entries they are often not correct or have an unreasonable formating. This also
holds for bibtex entries from IEEEXplore. The title should be formatted as in the publication. If
each word has an large initial letter, this should be adopted. You can force your literature to use
the large lettering if you put the title in curly braces {}.


## Bug Search
Often the error message in the log file points you to the position and reason for the error. Having
problems with the externalisation, have a look at the last compiled log file of the figure. In this
case this log files contains more information than the main log file.

Often problems are a missing shell escape and a not created tikz folder. See the help provided here
and check if you considered all hints.

### circuitikz and externalize
Is the circuitikz figure externalised, then there is often an error if circuitzikz is used as an
environment. [Simply use](http://tex.stackexchange.com/questions/82064/) `\begin{tikzpicture}`.
