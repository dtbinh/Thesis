# Copyright Projet LAGADIC, 2006
#   http://www.irisa.fr/lagadic
#
#   File: Makefile
#   Author: Nicolas Mansard
#
#   Compilation des sources .tex en .dvi, .ps ...
#
#   Version Control
#     $Id: Makefile,v 1.13 2007/02/28 10:59:48 nmansard Exp $



help:
	@echo "PhD thesis compilaton:"
	@echo "	make dvi, ps, pdf to compile the these.{dvi|ps|df} from these.tex."
	@echo "	Use make bib to re-generate .dvi file (for cross-reference and bib refresh)."
	@echo "Additionnal features: use print to print on cCjaune1, view to display with xdvi."
	@echo "	Use edit to open the main files with emacs."
	@echo "	Use clean and clean_all for temp and all files cleaning."
	@echo ""
	@echo "Chapter activation:"
	@echo "	Use make activate ID=\"1 2\" to activate chapter 1 and 2."
	@echo "	Use make disactive ID=... to disactivate the chapter. Status to print the activation list."
	@echo ""
	@echo "Draft generation."
	@echo "	Use make draft ID=\"1 2 \" for draft generation of chapter 1 and 2 into draft.dvi file."
	@echo "	Use draftview and draftprint for draft display with xdvi and print."
	@echo "	Use make draft.ps and draft.pdf to generate pdf and ps file from draft.dvi."
	@echo "	ID chapter are stored into the file ./id for update rules."

# ---------------------------------------------
# --- EXECUTABLES -----------------------------
# ---------------------------------------------
RM := rm -f
MV := mv
CP := cp -f
AR := ar
TEX2DVI := latex
DVI2PS := dvips -Ppdf -t a4
PS2PDF := ps2pdf -dPDFSETTINGS=/printer 
#DVI2PS := dvips 
#PS2PDF := ps2pdf 
BIBTEX := bibtex
GZIP := gzip -c
XDVI := xdvi -geometry 720x900 -s 4
# ---------------------------------------------
# --- REPERTOIRES -----------------------------
# ---------------------------------------------

PROJECT_DIR		= .
ROOT_DIR		= .
IMG_DIR      		= $(ROOT_DIR)
BIB_DIR   		= $(PROJECT_DIR)/misc

# ---------------------------------------------
# --- CHAPITRE --------------------------------
# ---------------------------------------------

CHAPTER_DIR = chapitres

define chapter_def 
 chapter_$1 = $2
 chapter_name_$1 = $2
 chapter_tex_path_$1 = $(CHAPTER_DIR)/$3
 chapter_$2_id = $1 
 chapter_list+= $1
 chapter_name_list+=$2
endef

#Changer les noms et les path pour utiliser le mode draft

$(eval $(call chapter_def,0,couverture,couverture))
$(eval $(call chapter_def,0b,merci,remerciements))
$(eval $(call chapter_def,0c,intro_generale,introGenerale))
$(eval $(call chapter_def,1,chapitre1,chapitre1))
$(eval $(call chapter_def,2,chapitre2,chapitre2))
$(eval $(call chapter_def,3,chapitre3,chapitre3))
$(eval $(call chapter_def,4,chapitre4,chapitre4)) 
$(eval $(call chapter_def,5,chapitre5,chapitre5)) 
$(eval $(call chapter_def,6,chapitre6,chapitre6)) 
$(eval $(call chapter_def,7,resume,resume/resume))


$(shell touch id)
IDFILE=$(shell cat id)
IDFILE=$(shell cat TOTO)
ifdef NAME
  ID=$(foreach C_NAME,$(NAME),$(chapter_$(C_NAME)_id))
endif
ifndef ID
	IDVAR=$(IDFILE)
else
ifeq ($(ID),all)
	IDVAR=$(chapter_list)
else
	IDVAR=$(ID)
endif
endif
ifndef NAME
	NAME=$(foreach cid,$(IDVAR),$(chapter_$(cid)))
endif

PROG_ACT_SED=$(foreach CID,$(IDVAR),"s/[<>%]*\(.include{$(subst /,\/,$(chapter_tex_path_$(CID))})\)/\1/g")
PROG_DISACT_SED=$(foreach CID,$(IDVAR),"s/[<>%]*\(.include{$(subst /,\/,$(chapter_tex_path_$(CID))})\)/%<>\1/g")
GREP_LIST=$(subst | ,|,$(chapter_name_list:%=%|))

ACTIVE_LIST=$(shell grep -e "include" $(OBJS_TEX) | grep -Ee "$(GREP_LIST:%|=%)" | grep -v "%" )
UNACTIVE_LIST=$(shell  -e "include" $(OBJS_TEX) | grep -Ee "$(GREP_LIST:%|=%)" | grep "%" | sed "s/[ %]*//g" )
ACTIVE_CHAPTER_NAME=$(patsubst \include{chapitres/%},%,$(ACTIVE_LIST))
UNACTIVE_CHAPTER_NAME=$(patsubst \include{chapitres/%},%,$(UNACTIVE_LIST))
#(shell grep -Ee "$(GREP_LIST:%|=%)" $(OBJS_TEX) | grep -v % 

test:
	@echo "$(GREP_LIST)"
	@echo "$(ACTIVE_LIST)"
	@echo "$(GREP_LIST:%|=%)"

activate:
	@echo "Active chapitre(s) #" $(IDVAR) "(" $(NAME) ")"
	@cp $(OBJS_TEX) $(OBJS_TEX).sav
	@cat $(OBJS_TEX) $(foreach PROG,$(PROG_ACT_SED),| sed $(subst <>, ,$(PROG)))  > t.tex
	@mv -f t.tex $(OBJS_TEX)
disactivate:
	@echo "Desctive chapitre(s) #" $(IDVAR) "(" $(NAME) ")"
	@cp $(OBJS_TEX) $(OBJS_TEX).sav
	@cat $(OBJS_TEX) $(foreach PROG,$(PROG_DISACT_SED),| sed  $(subst <>, ,$(PROG))) > t.tex
	@mv -f t.tex $(OBJS_TEX)
status:
	@echo Actifs:
	@$(foreach ch,$(ACTIVE_LIST:\include{chapitres/%}=%),echo "    CHAPITRE $(chapter_$(ch)_id): $(ch)"; )
	@echo Inactifs:
	@$(foreach ch,$(UNACTIVE_LIST:\include{chapitres/%}=%),echo "    CHAPITRE $(chapter_$(ch)_id): $(ch)"; )
act:activate
dis:disactivate


PACKAGE_FILE = misc/packages.tex
label:
	@cp $(PACKAGE_FILE) $(PACKAGE_FILE).sav
	@cat $(PACKAGE_FILE) | sed "s/[ %]*\(\\\usepackage{showkeys}\)/\1/g" > tmp
	@mv -f tmp $(PACKAGE_FILE)
	@make dvi

nolabel:
	@cp $(PACKAGE_FILE) $(PACKAGE_FILE).sav
	@cat $(PACKAGE_FILE) | sed "s/[ %]*\(\\\usepackage{showkeys}\)/% \1/g" > tmp
	@mv -f tmp $(PACKAGE_FILE)
	@make dvi

# ---------------------------------------------
# --- OBJETS ----------------------------------
# ---------------------------------------------

OBJS	=	these
BIB	=	$(BIB_DIR)/bib.bib
CHAPTERS=	$(ACTIVE_LIST:\include{%}=%.tex)


OBJS_TEX	=	$(OBJS:%=%.tex)
OBJS_DVI	=	$(OBJS:%=%.dvi)
OBJS_BBL	=	$(OBJS:%=%.bbl)
OBJS_PS 	=	$(OBJS:%=%.ps)
OBJS_PS_GZ	=	$(OBJS:%=%.ps.gz)
OBJS_PDF	=	$(OBJS:%=%.pdf)

IMPRIMANTE	=	calvino # mCjaune0 #

# ---------------------------------------------
# --- REGLES ----------------------------------
# ---------------------------------------------

# --->
# ---> Regle generale
# --->

.PHONY = all 
all: 

FIGURES4PNG = $(wildcard figures/chapitre4/*.png)
FIGURES4JPG = $(wildcard figures/chapitre4/*.jpg)
FIGURES4PS = $(patsubst %.png,%.ps,  $(FIGURES4PNG))
FIGURES4PS += $(patsubst %.jpg,%.ps,  $(FIGURES4JPG))

FIGURES5PNG = $(wildcard figures/chapitre5/*.png)
FIGURES5JPG = $(wildcard figures/chapitre5/*.jpg)
FIGURES5PS = $(patsubst %.png,%.ps,  $(FIGURES5PNG))
FIGURES5PS += $(patsubst %.jpg,%.ps,  $(FIGURES5JPG))

fig = figures

figures : extractfigures $(FIGURES4PS) $(FIGURES5PS)

extractfigures:
	@tar xvf $(fig).tar.gz

%.ps: %.png
	@echo "Conversion de $< vers $@"
	@convert $< $@ 
%.ps: %.jpg
	@echo "Conversion de $< vers $@"
	@convert $< $@ 

dvi: $(OBJS_DVI)

ps: $(OBJS_PS)
psgz: $(OBJS_PS_GZ)

pdf: figures $(OBJS_PDF) 

print: $(OBJS_PS) 
	lpr -P $(IMPRIMANTE) $^
	@touch print

view: dvi
	$(XDVI) $(OBJS_DVI) &

view_pdf: pdf
	acroread $(OBJS_DVI) &

edit:
	gvim -p $(OBJS_TEX) $(CHAPTERS) misc/commands.tex misc/bib.bib &

# --->
# ---> Regles generiques
# --->

%.dvi: %.tex %.bbl $(CHAPTERS)
	$(TEX2DVI) $< 

.PHONY = bib
bib $(OBJS_BBL): $(BIB)
	$(TEX2DVI) $(OBJS_TEX)
	@echo "->$(BIBTEX) $(<:.tex=)"
	$(BIBTEX) $(OBJS_TEX:.tex=)
	$(BIBTEX) sec
#	$(BIBTEX) myint
#	$(BIBTEX) mynat
	$(TEX2DVI) $(OBJS_TEX) 
	$(TEX2DVI) $(OBJS_TEX) 

%.ps: %.dvi
	$(DVI2PS) $< -o $@

%.pdf: %.ps
	$(PS2PDF) $< $@

%.ps.gz: %.ps
	$(GZIP) $< > $@


# --->
# --->
# ---> Regles de nettoyage
# --->

.PHONY = clean
clean: 
	$(RM) *.aux *.blg *.dvi *.log *.bbl *.toc *.lof *.idx
	$(RM) chapitres/*.aux chapitres/*~
	$(RM) *~ plan/*~ misc/*~ 
	$(RM) plan/*.aux plan/*.blg plan/*.dvi plan/*.log plan/*.bbl plan/*.toc plan/*.lof plan/*.idx
	$(RM) core 
	$(RM) print
	$(RM) -r auto chapitres/auto misc/auto plan/auto
	$(RM) $(DRAFTTMP) id draft.ps draft.pdf

.PHONY = clean_all
clean_all: clean 
	$(RM) *.ps *.pdf plan/*.ps 


#	cat chapitres/etat_art.tex | sed  "s/\\chapter{\([^}]*\)}/\\title{\1} \\maketitle/" | grep -v "\chapter" > /tmp/nmsdtmp.tex

# --->
# ---> DRAFT 
# --->
DRAFTTMP = drafttmp.tex

ifneq ($(IDVAR),$(IDFILE))
	FORCEDRAFT = phonyrule
endif
$(shell echo $(IDVAR) > id)
ifeq ($(IDVAR),)
	WARNING = $(warning WARNING: ID: empty or undefined variable.)
endif
$(call $(WARNING))

.PHONY = phonyrule
phonyrule:

draft: $(DRAFTTMP) draft.dvi


.PHONY = $(DRAFTTMP)
$(DRAFTTMP): $(FORCEDRAFT) $(foreach chap,$(NAME),chapitres/$(chap).tex)
	@echo"" > $(DRAFTTMP)
	$(foreach chap,$(NAME),cat chapitres/$(chap).tex | sed  "s/\\\chapter{\([^}]*\)}/{\\\huge \1 } \n \\\bigskip \n/g" | grep -v "\chapter" >> $(DRAFTTMP);)

draft.dvi: draft.tex $(DRAFTTMP)
	latex $<
	$(BIBTEX) $(<:.tex=)
	latex $<
	latex $<

draftview: draft.dvi
	$(XDVI) draft&

draftprint: draft.ps
	lpr -P $(IMPRIMANTE) $^

