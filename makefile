# Project directories
CWD := $(abspath $(shell pwd))
SRC := $(CWD)/src
BIB := $(CWD)/bib
OUT := $(CWD)/out

# Compiles with lualatex. Does not compile with xelatex.
ENGINE := pdflatex

# Every source .tex file should correspond to a .pdf output file
SRC_FILES := $(wildcard $(SRC)/*.tex)
OUT_FILES := $(subst src,out,$(subst .tex,.pdf, $(SRC_FILES)))

.PHONY: pdf clean lint
.SILENT: pdf clean lint

pdf: $(OUT_FILES)

clean:
	- rm -f $(OUT)/*

$(OUT):
	mkdir -p $@

$(OUT)/%.pdf: $(SRC)/%.tex $(BIB)/%.bib | $(OUT)
	cd $(SRC) \
	&& openout_any=a $(ENGINE) --jobname=$(basename $@) --output-directory=$(OUT) --file-line-error --shell-escape --synctex=1 $< \
	&& openout_any=a bibtex $(basename $@) \
	&& openout_any=a $(ENGINE) --jobname=$(basename $@) --output-directory=$(OUT) --file-line-error --shell-escape --synctex=1 $< \
	&& openout_any=a $(ENGINE) --jobname=$(basename $@) --output-directory=$(OUT) --file-line-error --shell-escape --synctex=1 $< \
	&& cd ..

lint:
	chktex -I0 -l $(SRC)/.chktexrc $(SRC)/*.tex
	$(foreach x, $(SRC_FILES), lacheck $(x);)
