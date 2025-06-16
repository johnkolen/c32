paper.pdf: paper.tex paper.bbl
	pdflatex paper.tex
	pdflatex paper.tex
paper.bbl: collatz.bib
	pdflatex paper.tex
	bibtex paper
