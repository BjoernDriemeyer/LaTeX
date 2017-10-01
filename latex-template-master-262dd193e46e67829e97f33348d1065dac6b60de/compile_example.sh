#!/bin/bash

pdflatex -shell-escape main_example.tex
# makeglossaries main_example
bibtex main_example
pdflatex -shell-escape main_example.tex
pdflatex -shell-escape main_example.tex
