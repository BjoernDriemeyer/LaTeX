# makefile to compile a LaTeX Document
# if `make: Nothing to be done for 'watch'.` results, use `make -B watch`
# adapted from http://paulklemm.com/blog/2016-03-06-watch-latex-documents-using-latexmk/
# version 22.03.17, Fabian Roos

# first rule is default rule
all: main_example.pdf

# compilation rule using latexmk
# `-bibtex`         runs bibtex or biber as needed to generate bbl files
#                   together with `-C` it removed the `bbl` file
# `-pdf`            generate pdf using `pdflatex`, see `-pdflua`
# `-f`              force mode, continue despite errors, not to pause use `nonstopmode`
# `-pdflatex='pdflatex -synctex=1 -interaction=nonstopmode'` do not stop
# `-pvc`            run a file previewer and continually update the pdf file, must be `-pvc -f`
# `-c`              clean up
# `-C`              clean up all files, also pdf
# `-auxdir=foo`
# `-shell-escape`   enable \write18{SHELL COMMAND}
main_example.pdf: main_example.tex
	latexmk -bibtex $(PREVIEW_CONTINUOUSLY) -shell-escape -pdf -f -pdflatex='pdflatex -synctex=1 -interaction=nonstopmode' main_example.tex


# compile and watch for changes using `-pvc`
.PHONY: watch
watch: PREVIEW_CONTINUOUSLY=-pvc
watch: main_example.pdf

# do not delete the pdf file if watch is canceled
# https://tex.stackexchange.com/questions/285166/
.PRECIOUS: %.pdf

# open document
.PHONY: see
see:
	evince main_example.pdf 2>/dev/null &

# clean working directory
.PHONY: clean
clean:
	latexmk -C

# very clean with bbl file and tikz
.PHONY: vclean
vclean:
	latexmk -C -bibtex
	rm tikz/*
