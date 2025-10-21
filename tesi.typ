#import "template.typ": *
#import "/util.typ": *

#show: project.with(
    title: [
        Framework per la Metaprogrammazione di Minecraft
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
        In questo documento tratterò del mio lavoro svolto sotto la supervisione del prof. Padovani nello sviluppare un sistema software che agevola l'utilizzo della _Domain Specific Language_ del videogioco #glos.mc.\
        Inizialmente verranno illustrate la struttura e i principali componenti di questa DSL, evidenziandone gli aspetti sintattici e strutturali che ne determinano le principali criticità.
        Successivamente verrà presentato l'approccio adottato per mitigare tali problematiche, mediante l'utilizzo di una libreria Java da me sviluppata, progettata per semplificare le operazioni più ripetitive e laboriose.\
        Attraverso un _working example_ verrà poi mostrato come tale libreria consenta di ridurre la complessità nello sviluppo dei punti più critici, mettendola a confronto con l'approccio tradizionale.\
        Infine, mostrerò la differenza in termini di righe di codice e file creati tra i due sistemi, con l'intento di affermare l'efficienza della mia libreria.
    ],
    final: false,
    locale: "it",
    bibliography_file: "bibliography.bib",
)

= Introduzione
Se non fosse per il videogioco #glos.mc, non sarei qui ora. Quello che per me nel 2014 era un modo di esprimere la mia creatività costruendo con cubi in un mondo tridimensionale, si è rivelato presto essere il luogo dove per anni ho scritto ed eseguito i miei primi frammenti di codice.\
Motivato dalla mia abilità nel saper programmare in questo linguaggio non banale, ho perseguito una carriera di studio in informatica.

Pubblicato nel 2012 dall'azienda svedese Mojang, #glos.mc è un videogioco appartenente al genere _sandbox_, famoso per l'assenza di una trama predefinita, in cui è il giocatore stesso a costruire liberamente la propria esperienza e gli obiettivi da perseguire.\
Come suggerisce il nome, le attività principali consistono nello scavare per ottenere risorse e utilizzarle per creare nuovi oggetti o strutture. Il tutto avviene all'interno di un ambiente tridimensionale virtualmente infinito.

Data l'assenza di regole predefinite, fin dai primi anni #glos.mc includeva un rudimentale insieme di comandi che consentiva ai giocatori di aggirare le normali meccaniche di gioco, ad esempio ottenendo risorse istantaneamente o spostandosi liberamente nel mondo.
Con il tempo, tale meccanismo è diventato un articolato linguaggio di configurazione e scripting, basato su file testuali, che costituisce una _Domain Specific Language_ (DSL) attraverso la quale sviluppatori di terze parti possono modificare numerosi aspetti e comportamenti dell'ambiente di gioco.

#glos.mc è sviluppato in Java, ma la sua DSL, chiamata #glos.mcf, adotta un paradigma completamente diverso. Essa non consente di introdurre nuovi comportamenti intervenendo direttamente sul codice sorgente: le funzionalità aggiuntive vengono invece definite attraverso gruppi di comandi, interpretati dal motore interno di #glos.mc (e non dal compilatore Java), ed eseguiti solo al verificarsi di determinate condizioni. In questo modo l'utente percepisce tali funzionalità come parte integrante dei contenuti originali del gioco.
Negli ultimi anni, grazie all'introduzione e all'evoluzione di una serie di file in formato #glos.json, è progressivamente diventato possibile creare esperienze di gioco quasi completamente nuove. Tuttavia, il sistema presenta ancora diverse limitazioni, poiché gran parte della logica continua a essere definita e gestita attraverso i file #glos.mcf.

Il tirocinio ha avuto come obiettivo la progettazione e realizzazione di un sistema che semplificasse la creazione, sviluppo e distribuzione di questi file, creando un ambiente di sviluppo unificato.
Esso consiste in una libreria Java che consente di definire la gerarchia dei file in un sistema ad albero tramite oggetti. Una volta definite tutte le feature, esegue il programma per ottenere un progetto pronto per l'uso.

Il risultato è un ambiente di sviluppo più coerente e accessibile, che permette di integrare feature di Java in questa DSL, per facilitare la scrittura e gestione dei file.

Nel Capitolo 1 verrà presentata la struttura generale del sistema, descrivendone gli elementi principali e il loro funzionamento. Il Capitolo 2 sarà invece dedicato all'analisi delle principali problematiche e limitazioni del sistema, insieme a una rassegna delle soluzioni proposte nello stato dell'arte. Nel Capitolo 3 verrà illustrata la struttura e implementazione della mia libreria, accompagnata da un _working example_ volto a mostrare in modo concreto il funzionamento del progetto. L'ultimo capitolo sarà dedicato all'analisi dei risultati ottenuti e delle possibili evoluzioni future.

#include "corpo.typ"
