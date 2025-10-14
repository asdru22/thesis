#import "template.typ": *
#show: project.with(
  title: [
    #lorem(5)
  ],
  author: "Alessandro Nanni",
  professors: (
    "Prof. Luca Padovani",
  ),
  department: "dipartimento di scienza e ingegneria",
  course: "Corso di Laurea in Informatica per il Management",
  session: "Dicembre",
  academic_year: "2024/2025",
  dedication: [],
  abstract: [
    #todo[sistemare]
    In questo documento tratterò del mio lavoro svolto sotto la supervisione del prof. Padovani nello sviluppare un sistema software che agevola l'utilizzo della _Domain Specific Language_ del videogioco Minecraft.\
    Verranno inizialmente illustrati i problemi sintattici e strutturali di questo ampio ecosistema di file.\
    Successivamente mostrerò come ho provato ad ovviarli, o almeno ridurli, tramite una libreria che si occupa di svolgere le operazioni più tediose e ripetitive.
    Tramite un _working example_ esporrò in che modo ho semplificato lo sviluppo di punti critici, facendo confronti con l'approccio abituale.\
    Infine, mostrerò la differenza in termini di righe di codice e file creati tra i due sistemi, con l'intento di affermare l'efficienza della mia libreria.
  ],
  final: false,
  locale: "it",
  bibliography_file: "bibliography.bib",
)


#include "chapters/introduzione.typ"

#include "chapters/agevolare_sviluppo.typ"

#include "chapters/mia_implementazione.typ"

#include "chapters/conclusione.typ"
