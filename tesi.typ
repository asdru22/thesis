#import "template.typ": *
#import "util.typ": *
#import "@preview/treet:1.0.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": chart, plot

#show: project.with(
    title: [
        Un Framework per la\
        Meta-programmazione\
        di Minecraf#h(0.0001pt)t
    ],
    author: "Alessandro Nanni",
    professors: (
        "Prof. Luca Padovani",
    ),
    department: "dipartimento di informatica\n-\n scienza e ingegneria",
    course: "Corso di Laurea in Informatica per il Management",
    session: "Dicembre",
    academic_year: "2024/2025",
    dedication: [
        Desidero innanzitutto ringraziare il prof. Padovani dell'_Alma Mater Studiorum_ Università di Bologna per la disponibilità e il prezioso supporto durante questo percorso, e per avermi dato l'opportunità di approfondire e lavorare con tecnologie di mio particolare interesse.


        Ringrazio la mia famiglia per avermi sempre incoraggiato e sostenuto durante tutto il mio percorso formativo.
        Un ringraziamento speciale va a mia zia Lalli, che mi ha accolto in casa sua per tre anni, offrendomi un ambiente sereno in cui potermi dedicare agli studi.

        Infine, un grazie di cuore ai miei cari amici Alessio, Daniele, Giovanni, Jacopo e Luca per le tante ore di studio trascorse insieme e per aver reso la mia vita universitaria più leggera.
    ],
    abstract: [
        Il _Domain Specific Language_ (_DSL_) del videogioco svedese #glos.mc, #glos.mcf, permette la creazione di pacchetti di contenuti modulari, denominati #glos.pack, in grado di modificare o aggiungere meccaniche di gioco.
        Nonostante il suo ampio utilizzo, questo linguaggio presenta notevoli limitazioni strutturali e sintattiche: ogni funzione deve essere definita in un file separato e non dispone di costrutti quali variabili, istruzioni condizionali e meccanismi di iterazione.
        Questi vincoli producono codice prolisso e ripetitivo, compromettendo la leggibilità e la manutenibilità nei progetti di ampia scala.

        Per superare tali problemi, questa tesi propone una libreria Java sviluppata durante il tirocinio accademico che, a partire da un'analisi approfondita delle carenze e difetti di #glos.mcf, giunge alla formulazione di un'astrazione che rappresenta la struttura di un #glos.pack come un albero di oggetti tipizzati. Sfruttando costrutti di Java e _factory methods_, la libreria consente la generazione programmatica dei #glos.pack, offrendo zucchero sintattico e utilità che semplificano l'accesso ai file di risorse principali. L'approccio proposto sfrutta la programmazione ad oggetti per fornire validazione statica, supporta la definizione di più risorse all'interno di un singolo file sorgente e automatizza la generazione di _boilerplate_, eliminando così la necessità di preprocessori o script esterni.

        Un _working example_ conferma l'approccio scelto: nel #glos.pack di esempio il codice scritto è ridotto del 40%, consolidando 31 file in 3 file sorgente, con miglioramenti significativi in termini di densità del codice e manutenibilità del progetto.
    ],
    final: true,
    locale: "it",
    bibliography_file: "bib.yaml",
)
~@minecraft
= Introduzione

Creato nel 2009 dallo svedese Markus Persson e sviluppato nel 2011 dall'azienda Mojang Studios~@mojang, #glos.mc~@minecraft è un famoso videogioco tridimensionale appartenente al genere _sandbox_~@sandbox, cioè caratterizzato dall'assenza di una trama predefinita, dove è il giocatore stesso a costruire liberamente la propria esperienza e gli obiettivi da perseguire.\
Il gioco presenta un mondo composto da cubi formati da _voxel_ (controparte tridimensionale del pixel) generati proceduralmente, dove i giocatori possono raccogliere risorse, costruire strutture, creare oggetti e affrontare creature ostili.

#glos.mc è diventato il videogioco più venduto al mondo, perché non è semplicemente un prodotto di intrattenimento, ma un ambiente flessibile, accessibile, continuamente ampliato e sostenuto da una community globale che lo ha trasformato in un fenomeno culturale trasversale.
#figure(image("assets/image.png"), caption: [Un mondo di #glos.mc.])

Fin dalle sue origini, i creatori di #glos.mc hanno messo a disposizione dei giocatori un insieme di comandi~@command che consentiva di aggirare gli ostacoli incontrati nella propria esperienza di gioco.\
Con il tempo, tale sistema si è evoluto in un articolato linguaggio di configurazione e scripting basato su file testuali, costituendo di fatto un _Domain Specific Language_~@dsl (_DSL_) mediante il quale sviluppatori di terze parti possono modificare numerosi aspetti e comportamenti dell'ambiente di gioco.

Con _Domain Specific Language_ si intende un linguaggio di programmazione progettato per un ambito applicativo specifico, caratterizzato da un livello di astrazione più elevato e una sintassi semplificata rispetto ai linguaggi _general purpose_#footnote[Un linguaggio _general purpose_ (o "a scopo generale"), come Java, C++ o Python, è progettato per risolvere un'ampia varietà di problemi in diversi domini applicativi.]. I DSL sono sviluppati in coordinazione con esperti del campo nel quale verrà utilizzato il linguaggio.
#quote(
    attribution: [JetBrains],
    block: true,
)[In many cases, DSLs are intended to be used not by software people, but instead by non-programmers who are fluent in the domain the DSL addresses.]

Questa definizione fornita dagli sviluppatori di JetBrains, azienda olandese specializzata nella creazione di ambienti di sviluppo integrati (_Integrated Development Environments_, IDE), descrive perfettamente chi sono gli utilizzatori del _Domain Specific Language_ di #glos.mc.

#glos.mc è sviluppato in Java~@java-book, ma questo DSL, chiamato #glos.mcf~@mc-function, adotta un paradigma completamente diverso.
Esso non consente di introdurre nuovi comportamenti intervenendo direttamente sul codice sorgente del gioco.
Le funzionalità aggiuntive vengono invece definite attraverso gruppi di comandi testuali, interpretati dal motore interno di #glos.mc (e non dal compilatore Java) ed eseguiti solo al verificarsi di determinate condizioni.
In questo modo tali funzionalità appaiono all'utente come parte integrante dei contenuti originali del gioco.
Negli ultimi anni, grazie all'introduzione e all'evoluzione di file in formato #glos.json~@json in grado di modificare componenti precedentemente inaccessibili, è progressivamente diventato possibile creare esperienze di gioco sempre più complesse e originali.
Tuttavia, il sistema presenta ancora diverse limitazioni, poiché una parte sostanziale della logica continua a essere implementata attraverso i file #glos.mcf, meno versatili e potenti rispetto a codice Java.

Il tirocinio accademico ha avuto come obiettivo la progettazione e realizzazione di un framework che semplifica lo sviluppo e la distribuzione di gruppi di file #glos.mcf e #glos.json tramite un ambiente di sviluppo unificato.
Tale framework consiste in una libreria Java che permette di definire la gerarchia dei file in un sistema ad albero tramite oggetti.
Una volta definite tutte le funzionalità, viene eseguito il programma per ottenere una cartella "pacchetto" (#glos.pack) pronta per essere utilizzata.
In questo modo lo sviluppo del pacchetto risulta più coerente e accessibile, permettendo di integrare _feature_ di Java in questo DSL per facilitare la scrittura e la gestione dei file.

Nel capitolo successivo viene presentata la struttura generale del sistema di #glos.pack, descrivendone gli elementi costitutivi e il loro funzionamento. Segue un'analisi sistematica delle principali problematiche e limitazioni tecniche dell'infrastruttura, corredata da una rassegna critica delle più recenti soluzioni proposte. Viene quindi illustrata la progettazione e l'implementazione della libreria sviluppata, accompagnata da un caso d'uso concreto (_working example_) che ne dimostra l'applicazione pratica. Il lavoro si conclude con un'analisi quantitativa e qualitativa dei risultati ottenuti, evidenziando i benefici dell'approccio proposto in termini di riduzione della complessità e miglioramento della manutenibilità del codice.

Il codice sorgente della libreria è reperibile al seguente link: #link("https://github.com/asdru22/OOPack").

= Struttura e Funzionalità di un Pack

== Definizione di un Pack
Un #glos.pack rappresenta l'intero progetto di sviluppo: esso agisce come contenitore logico per le due componenti fondamentali, #glos.dp e #glos.rp, che pur rimanendo cartelle distinte costituiscono un'unica unità funzionale.
Un #glos.dp può essere paragonato alla cartella `java` di un progetto Java: esso contiene la parte che detta la logica dell'applicazione tramite file #glos.json e #glos.mcf.\

I progetti Java sono dotati di una cartella `resources`~@java-resource. Similmente, #glos.mc impiega la cartella #glos.rp~@resourcepack per dichiarare le risorse da utilizzare.
Essa contiene principalmente font, modelli 3D, #glos.tex~@game-texture, traduzioni e suoni.\
Con l'eccezione di #glos.tex e suoni, i quali richiedono l'estensione `png`~@png e `ogg`~@ogg rispettivamente, tutti gli altri file sono in formato #glos.json.\
I #glos.rp sono stati concepiti e rilasciati prima dei #glos.dp, con lo scopo di dare ai giocatori la possibilità di sovrascrivere le #glos.tex e altri _asset_~@assets del videogioco per renderle più affini ai propri gusti.
Gli sviluppatori di #glos.dp hanno poi iniziato ad utilizzare i #glos.rp per definire le risorse che il loro progetto avrebbe impiegato.

I #glos.rp hanno portata globale e vengono applicati a tutti i _save file_, ovvero su ogni mondo creato. Le cartelle #glos.dp, invece, devono essere collocate nella directory `datapack` dei mondi nei quali si desidera utilizzarle.\
Pertanto, partendo dalla cartella radice di #glos.mc (`.minecraft/`), i #glos.rp si trovano nella directory `.minecraft/resourcepacks`, mentre i #glos.dp sono collocati in `.minecraft/saves/<world name>/datapacks`.\
L'insieme di #glos.dp e #glos.rp è chiamato #glos.pack. Questo, riprendendo il parallelismo precedente, corrisponde all'intero progetto Java, e sarà poi la cartella pubblicata dallo sviluppatore.

== Struttura e Componenti di Datapack e Resourcepack

All'interno di un #glos.pack, #glos.dp e #glos.rp hanno una struttura molto simile.

#figure(
    grid(
        columns: 2,
        gutter: 10em,
        align(left, tree-list[
            - *#glos.dp*
                - pack.mcmeta
                - pack.png
                - data
                    - _namespace_
                        - advancement
                        - function
                        - loot_table
                        - recipe
                        - worldgen
                        - ...
        ]),
        align(left, tree-list[
            - *#glos.rp*
                - pack.mcmeta
                - pack.png
                - assets
                    - _namespace_
                        - font
                        - lang
                        - models
                        - textures
                        - sounds
                        - ...
        ]),
    ),
    caption: [#glos.dp e #glos.rp a confronto.],
)

Nonostante l'estensione non lo indichi, il file `pack.mcmeta` è scritto in formato #glos.json e definisce l'intervallo delle versioni (denominate _format_) supportate dalla cartella. Tali versioni variano ad ogni aggiornamento di #glos.mc e non corrispondono alla _game version_ effettiva.\
Ad esempio, per la versione 1.21.10 del gioco, il `pack_format` dei #glos.dp è 88, mentre quello dei #glos.rp è 69. Questi valori possono variare anche settimanalmente durante il rilascio degli _snapshot_~@snapshot, ovvero versioni preliminari di sviluppo che introducono nuove funzionalità e modifiche prima del rilascio ufficiale di un aggiornamento del videogioco.

Ancora più rilevanti sono le cartelle contenute in `data` e `assets`, chiamate #glos.ns~@namespace.
Un #glos.ns è un identificatore univoco che serve a organizzare e distinguere i contenuti di diversi #glos.pack. Corrisponde al nome della cartella radice in cui si sta operando. Un #glos.ns serve anche a rendere le risorse univoche, evitando così conflitti nel caso di _path_ identici.

#quote(
    block: true,
    attribution: [Nathan Adams#footnote[Sviluppatore di #glos.mc inglese, membro del team che sviluppa _feature_ inerenti a #glos.dp.]],
    [This isn't a new concept, but I thought I should reiterate what a "namespace" is. Most things in the game has a namespace, so that if we add `something` and a mod (or map, or whatever) adds `something`, they're both different `something`s. Whenever you're asked to name something, for example a loot table, you're expected to also provide what namespace that thing comes from. If you don't specify the namespace, we default to `minecraft`. This means that `something` and `minecraft:something` are the same thing.],
)

In genere un #glos.ns o coincide con il nome stesso del progetto che si sta sviluppando, o è una sua abbreviazione. La convenzione vuole che #glos.dp e #glos.rp del medesimo #glos.pack utilizzino lo stesso #glos.ns.\
Tuttavia, si vedrà che operare in #glos.ns distinti non è sufficiente a garantire l'assenza di conflitti tra #glos.pack installati contemporaneamente.

Il namespace `minecraft` è riservato alle risorse native del gioco: sovrascriverle comporta il rischio di rimuovere funzionalità originali o di alterarne il comportamento previsto.\
#e interessante notare come anche gli sviluppatori di #glos.mc stessi facciano uso dei #glos.dp per definire e organizzare molti comportamenti del gioco, come ad esempio la dichiarazione delle risorse ottenibili dai blocchi scavati (_loot table_), o gli ingredienti necessari per creare un certo oggetto (_recipe_).
In altre parole, i #glos.dp non sono solo uno strumento a disposizione dei giocatori per personalizzare l'esperienza, ma costituiscono anche il meccanismo interno attraverso il quale il gioco stesso struttura e gestisce alcune delle sue funzionalità principali.\
Occorre specificare che i comandi e i file `.mcfunction` non sono utilizzati in alcun modo dagli sviluppatori di #glos.mc per implementare funzionalità del videogioco: esso è interamente sviluppato in Java.

All'interno dei #glos.ns si trovano directory i cui nomi identificano in maniera univoca la natura e la funzione dei file contenuti al loro interno.
Se nella cartella `recipe` è presente un file #glos.json che non possiede una struttura comune a tutte le ricette, il compilatore solleverà un errore e il file non sarà disponibile nella sessione di gioco.

La cartella `function` contiene file e sottodirectory con file di testo in formato #glos.mcf. Questi file permettono alle diverse risorse di un #glos.pack di interagire tra loro tramite funzioni.

Per identificare univocamente le risorse all'interno di #glos.dp e #glos.rp si utilizzano le _resource location_.
La loro struttura è composta da due parti separate dai due punti (`:`): il #glos.ns e il percorso della risorsa.
Rispetto a un _path_ completo, la _resource location_ omette la cartella funzionale che categorizza il tipo di risorsa.\
Ad esempio, per riferirsi alla ricetta situata in `foo/recipe/my_item.json`, si utilizza la _resource location_ `foo:my_item`, dove `foo` è il #glos.ns e `my_item` è l'identificatore della risorsa.
La cartella `recipe`, che indica la tipologia della risorsa, non compare nella _resource location_ poiché il compilatore determina automaticamente il tipo di risorsa in base al contesto d'uso. Se la _resource location_ viene letta in un contesto che richiede una ricetta, il compilatore cercherà il file nella cartella `recipe`; se invece il contesto richiede una funzione, cercherà nella cartella `function`.

== Il Sistema dei Comandi

Prima di analizzare i comandi, è necessario definire gli elementi basilari su cui operano.

#glos.mc permette di creare ed esplorare mondi generati da un _seed_~@seed casuale, ognuno diverso dagli altri. Ogni mondo è composto da _chunk_~@chunk, sezioni colonnari aventi base di $16 times 16$ unità e altezza di 320 unità.\
L'unità più piccola all'interno di questa griglia è il blocco, la cui forma corrisponde a quella di un cubo di lato unitario.
Ogni blocco è dotato di collisione, ed individuabile nel mondo tramite coordinate dello spazio tridimensionale.
Si definiscono entità invece tutti gli oggetti dinamici che si spostano in un mondo: sono dotate di una posizione, rotazione e velocità.

I dati persistenti di blocchi ed entità sono compressi e memorizzati in una struttura dati ad albero chiamata _Named Binary Tags_~@nbt (#glos.nbt). Il formato "stringificato", `SNBT`, è accessibile ai giocatori e si presenta come una struttura molto simile a #glos.json, formata da coppie di chiave e valori.\

#figure(
    ```snbt
    {
      name1: 123,
      name2: "foo",
      name3: {
        subname1: 456,
        subname2: "bar"
        },
      name4: [
        "baz",
        456,
        {
          subname3: "bal"
        }
      ]
    }
    ```,
    caption: [Esempio di `SNBT`.],
)

Un comando è un'istruzione testuale che #glos.mc interpreta per eseguire una specifica azione, come assegnare oggetti al giocatore, modificare l'ora del giorno o creare entità. Molti comandi richiedono selettori per individuare l'entità su cui essere applicati o eseguiti.\

#figure(
    ```mcfunction
    say @e[
      type = player
    ]
    ```,
    caption: [Esempio di comando che tra tutte le entità (`@e`), stampa quelle di tipo giocatore.],
)
Nonostante il sistema dei comandi sia privo delle funzionalità tipiche dei linguaggi di programmazione di alto livello, quali cicli `for` e `while`, strutture dati complesse o variabili generiche, esso fornisce comunque strumenti che consentono di simulare alcuni di questi comportamenti in forma limitata.\
Di seguito verranno illustrati i comandi che più si avvicinano a concetti tipici di programmazione.
=== Scoreboard
Il comando `scoreboard`~@scoreboard permette di creare dizionari di tipo `<Entità, Objective>`.
Un `objective` rappresenta un valore intero associato ad una condizione (_criteria_) che ne determina la variazione. Il _criteria_ `dummy` corrisponde ad una condizione vuota, irrealizzabile.
Su questi valori è possibile eseguire operazioni aritmetiche semplici, quali la somma o la sottrazione di un valore prefissato, oppure calcolare il risultato delle quattro operazioni aritmetiche fondamentali#footnote[Le operazioni aritmetiche fondamentali sono somma, sottrazione, moltiplicazione e divisione.] con altri `objective`.
Dunque una #glos.score può essere meglio vista come un dizionario `<Entità, <Intero, Condizione>>`.\
Prima di poter eseguire qualsiasi operazione su di essa, una #glos.score deve essere creata tramite il comando `scoreboard objectives add <objective> <criteria>`.\
Per eseguire operazioni indipendenti da entità specifiche si usano i _fakeplayer_.
Al posto di nomi di giocatori o selettori, si aggiunge un prefisso con caratteri non validi (come `$` o `#`) che rende impossibile la corrispondenza con un utente reale, assicurando così la disponibilità permanente del valore.

#figure(
    ```mcfunction
    scoreboard objectives add my_scoreboard dummy
    scoreboard players set #20 my_scoreboard 20
    scoreboard players set #val my_scoreboard 100
    scoreboard players operation #val my_scoreboard /= #20 my_scoreboard
    ```,
    caption: [Esempio di operazioni su una #glos.score, equivalente a `int val = 100; val /= 20;`],
)

Dunque, il sistema delle #glos.score permette di creare ed eseguire operazioni semplici esclusivamente su interi, con _scope_~@scope globale, se e solo se fanno parte di una #glos.score dichiarata.

=== Data
Per ottenere, modificare e combinare i dati #glos.nbt associati a entità, blocchi e #glos.str si utilizza il comando `data`~@data.
Come precedentemente citato, il formato #glos.nbt, una volta compresso, viene utilizzato per la persistenza dei dati di gioco.
Oltre alle informazioni relative a entità e blocchi, in questo formato vengono salvati anche gli #glos.str.
Essi sono un modo efficiente di immagazzinare dati arbitrari che non dipendono dall'esistenza di un certo blocco o entità.
Possono essere visti come la controparte di `data` per i _fakeplayer_.
Per prevenire i conflitti, ogni #glos.str dispone di un prefisso, che convenzionalmente coincide con il #glos.ns. Vengono dunque salvati nel file `command_storage_<namespace>.dat` come un dizionario #glos.nbt.

#figure(
    ```mcfunction
    data modify storage my_namespace:storage name set value "My Cat"
    data merge entity @n[type=cat] CustomName from storage my_namespace:storage name
    data remove storage my_namespace:storage name
    ```,
    caption: [Esempio di operazioni su dati #glos.nbt],
)
Questi comandi definiscono la stringa `My Cat` nello #glos.str, successivamente impostano il valore dallo #glos.str al campo nome dell'entità gatto più vicina, e infine eliminano i dati dallo #glos.str.

=== Execute
Il comando `execute`~@execute permette l'esecuzione in catena di più comandi, cambiando valori quali l'entità esecutrice e la posizione.
Questi e altri elementi definiscono il contesto di esecuzione, ossia l'insieme dei parametri che regolano le modalità di esecuzione del comando.
Si usa il selettore `@s` per identificare l'entità del contesto di esecuzione corrente.\
Tramite `execute` è possibile specificare condizioni preliminari e memorizzare l'esito di un comando. Dispone di 14 sottocomandi, raggruppati in 4 categorie:
- modificatori: cambiano il contesto di esecuzione;
- condizionali: controllano se certe condizioni sono rispettate;
- contenitori: salvano i valori di output di un comando in una #glos.score, o in un contenitore di NBT;
- `run`: esegue un altro comando.
Tutti questi sottocomandi possono essere concatenati e usati più volte all'interno di uno stesso comando `execute`.

#figure(
    ```mcfunction
    execute as @e
      at @s
      store result score @s on_stone
      if block ~ ~-1 ~ stone
    ```,
    caption: [Esempio di comando `execute`.],
)
Questo comando sta definendo quattro istruzioni da svolgere:
+ per ogni entità (`execute as @e`);
+ sposta l'esecuzione alla propria posizione attuale (`at @s`);
+ salva l'esito della prossima istruzione nello _score_ `on_stone` di quell'entità;
+ controlla se nella posizione del contesto di esecuzione corrente, il blocco sottostante sia di tipo `stone`.
Al termine dell'esecuzione, lo _score_ `on_stone` di ogni entità sarà 1 se posizionata su un blocco di pietra, 0 altrimenti.

== Le Funzioni in Minecraft
Le funzioni sono insiemi di comandi raggruppati all'interno di un file #glos.mcf. Una funzione non può esistere se non in un file con estensione `.mcfunction`.
A differenza di quanto il nome possa suggerire, esse non prevedono valori di input o di output, ma contengono uno o più comandi eseguiti secondo l'ordine in cui sono scritti nel file.

Le funzioni in #glos.mc vengono eseguite all'interno di un _game loop_ (o _tick_ = $1/20$ di secondo), completando tutti i comandi che contengono, comprese eventuali chiamate ad altre funzioni.
In base alla complessità del _branching_ e alle operazioni eseguite dalle funzioni, il compilatore (o più precisamente, il motore di esecuzione dei comandi) alloca una certa quantità di risorse per svolgere tutte le istruzioni durante un singolo _tick_.
Il tempo di elaborazione aggiuntivo richiesto per l'esecuzione di un comando o di una funzione è definito _overhead_.

Le funzioni possono essere invocate da altri file di un datapack in più modi:

- tramite comandi: `function namespace:function_name`~@function esegue la funzione immediatamente, mentre `schedule namespace:function_name <delay>`~@schedule la esegue dopo un intervallo di tempo specificato;
- da _function tag_: una _function tag_ è una lista in formato #glos.json contenente riferimenti a funzioni. #glos.mc ne fornisce due nelle quali inserire le funzioni da eseguire rispettivamente ogni _game loop_~@tick(`tick.json`)#footnote[Il _game loop_ di #glos.mc viene eseguito 20 volte al secondo; di conseguenza, anche le funzioni incluse nel tag `tick.json` vengono eseguite con la stessa frequenza.], e ogni volta che si ricarica da disco il datapack (`load.json`). Queste due _function tag_ sono riconosciute dal compilatore di #glos.mc solo se nel namespace `minecraft`;
- altre risorse di un #glos.dp quali ricompense di `Advancement` (obiettivi) e effetti di `Enchantment` (incantesimi).

Quando un comando `execute` modifica il contesto di esecuzione (ad esempio cambiando il giocatore o la posizione), questa modifica non influenza i comandi successivi nella funzione corrente, ma si applica alle funzioni chiamate a partire da quel punto.

Le funzioni possono contenere comandi _macro_: istruzioni precedute dal carattere `$` che dispongono di uno o più segnaposto nella forma `$(identificatore)`. Tali segnaposto fungono da variabili il cui valore viene risolto dinamicamente al momento dell'invocazione.

L'invocazione di una funzione _macro_ richiede la clausola `with`, seguita da una sorgente dati in formato #glos.nbt (oggetto letterale, entità, blocco o #glos.str).
Il meccanismo di espansione opera in tre fasi: acquisizione dell'oggetto #glos.nbt dalla sorgente specificata, sostituzione testuale di ogni segnaposto `$(chiave)` con il valore corrispondente estratto dall'oggetto, ed esecuzione dei comandi risultanti. Qualora un segnaposto non trovi corrispondenza nell'oggetto fornito, l'esecuzione della funzione fallisce.

#figure(
    {
        codly(
            header: [main.mcfunction],
        )
        [```mcfunction
        function foo:macro_test {value:"bar"}
        function foo:macro_test {value:"123"}
        ```]
        v(10pt)
        codly(
            header: [macro_test.mcfunction],
        )
        [```mcfunction
        $say my value is $(value)

        ```]
    },
    caption: [Esempio di chiamata di funzione con _macro_.],
) <esempio_macro>
Il primo comando di `main.mcfunction` stamperà `my value is bar`, il secondo `my value is 123`.

L'esecuzione dei comandi di una funzione può essere interrotta dal comando `return`. Funzioni che non contengono questo comando possono essere considerate di tipo `void`. Tuttavia il comando `return` può solamente restituire la parola chiave `fail` per indicare insuccesso o un valore intero fisso.

Una funzione può essere richiamata ricorsivamente, anche modificando il contesto in cui viene eseguita. Questo comporta il rischio di creare chiamate senza fine, qualora la funzione sia invocata senza alcuna condizione di arresto. #e quindi responsabilità del programmatore definire i vincoli alla chiamata ricorsiva.

#codly(
    header: [iterate.mcfunction],
)
#figure(
    ```mcfunction
    particle flame ~ ~ ~
    execute if entity @p[distance=..10] positioned ^ ^ ^0.1 run function foo:iterate
    ```,
    caption: [Esempio di funzione ricorsiva che crea una scia lunga 10 blocchi nella direzione dove il giocatore sta guardando.],
) <funzione_ricorsiva>

Ogni volta che viene chiamata, questa funzione istanzia una piccola #glos.tex intangibile e temporanea (_particle_~@particle) alla posizione associata al contesto di esecuzione.
Successivamente controlla se è presente un giocatore nel raggio di 10 blocchi.
In caso positivo sposta il contesto di esecuzione avanti di $1/10$ di blocco e si chiama nuovamente la funzione.
Quando il sotto-comando `if` fallisce, ovvero non c'è nessun giocatore nel raggio di 10 blocchi, l'esecuzione è arrestata.

Un linguaggio di programmazione si definisce Turing completo~@turing-complete se soddisfa tre condizioni fondamentali:
+ Presenta rami condizionali: deve poter eseguire istruzioni diverse in base a una condizione logica. Nel caso di #glos.mcf, ciò è realizzabile tramite il sotto-comando `if`.
+ #e dotato di iterazione o ricorsione: deve consentire la ripetizione di operazioni. In questo linguaggio, tale comportamento è ottenuto attraverso l'utilizzo di funzioni ricorsive.
+ Permette la memorizzazione di dati: deve poter gestire una quantità arbitraria di informazioni. In #glos.mcf, ciò avviene tramite la manipolazione dei dati all'interno degli #glos.str.

Pertanto, #glos.mcf può essere considerato a tutti gli effetti un linguaggio Turing completo. Tuttavia, come verrà illustrato nella sezione successiva, sia il linguaggio stesso sia il sistema di file su cui si basa presentano diverse limitazioni e inefficienze.

In particolare, l'implementazione di funzionalità relativamente semplici richiede un numero considerevole di righe di codice e di file, che in un linguaggio di più alto livello potrebbero essere realizzate in maniera molto più concisa.

= Problemi Pratici e Limiti Tecnici

Il linguaggio #glos.mcf non è stato originariamente concepito come sistema di programmazione Turing completo.
Infatti, negli anni antecedenti all'introduzione dei #glos.dp, il comando `scoreboard` era impiegato in maniera convenzionale per monitorare le statistiche dei giocatori, quali il tempo di gioco o il numero di blocchi scavati.
Gli sviluppatori di #glos.mc osservarono come questo e altri comandi venivano impiegati dalla comunità per creare nuove meccaniche e giochi rudimentali.
Hanno dunque aggiornato progressivamente il sistema, fino a giungere, nel 2017, alla nascita dei #glos.dp.


Ancora oggi l'ecosistema dei #glos.dp è in costante evoluzione, con _snapshot_ che introducono nuove funzionalità o aggiornano quelle esistenti.
Tuttavia, questo ambiente presenta ancora diverse limitazioni di natura tecnica, riconducibili al fatto che non era stato originariamente concepito per supportare logiche di programmazione complesse o per essere impiegato in progetti di grandi dimensioni.

== Limitazioni di Scoreboard
Come è stato precedentemente citato, il comando `scoreboard` è utilizzato per eseguire operazioni su interi. Tuttavia, esso presenta numerosi vincoli.

Dopo aver creato un _objective_, è necessario impostare le costanti da utilizzare per le eventuali operazioni di moltiplicazione e divisione.
Inoltre, è ammessa una sola operazione per comando `scoreboard`.

Di seguito viene mostrato come l'espressione `int x = (y*2)/4-2` si calcola in #glos.mcf. Le variabili sono prefissate da `$`, e le costanti da `#`.

#figure(
    local(
        annotations: (
            (
                start: 1,
                end: 3,
                content: block(
                    width: 2em,
                    rotate(-90deg, reflow: true, align(center)[Inizializzazione]),
                ),
            ),
            (
                start: 5,
                end: 8,
                content: block(
                    width: 2em,
                    rotate(-90deg, reflow: true, align(center)[Operazioni su `$y`]),
                ),
            ),
        ),
        ```
        scoreboard objectives add math dummy
        scoreboard players set #2 math 2
        scoreboard players set #4 math 4

        scoreboard players set $y math 10
        scoreboard players operation $y math *= #2 math
        scoreboard players operation $y math /= #4 math
        scoreboard players remove $y math 2
        scoreboard players operation $x math = $y math
        ```,
    ),
    caption: [Esempio con $y=10$],
)<scoreboard_set_const>
Qualora non fossero stati impostati i valori di `#2` e `#4`, il compilatore li avrebbe valutati come 0 e il risultato dell'espressione non sarebbe stato corretto.

Si noti come, nell'esempio precedente, le operazioni vengano eseguite sulla variabile $y$, il cui valore risultante viene successivamente assegnato a $x$.
Di conseguenza, sia `$x` che `$y` conterranno il risultato finale pari a 3. Questo implica che il valore di $y$ viene modificato, a differenza dell'espressione a cui l'esempio si ispira, dove esso rimane invariato.
Per evitare questo effetto collaterale, è necessario eseguire l'assegnazione $x = y$ prima delle altre operazioni aritmetiche.

#figure(
    local(
        annotations: (
            (
                start: 4,
                end: 8,
                content: block(
                    width: 2em,
                    rotate(-90deg, reflow: true, align(center)[Operazioni su `$x`]),
                ),
            ),
        ),
        ```mcfunction
        scoreboard objectives add math dummy
        scoreboard players set #2 math 2
        scoreboard players set #4 math 4
        scoreboard players set $y math 10
        scoreboard players operation $x math = $y math
        scoreboard players operation $x math *= #2 math
        scoreboard players operation $x math /= #4 math
        scoreboard players remove $x math 2
        ```,
    ),
    caption: [Esempio di espressione con `scoreboard`],
)

La soluzione è quindi semplice, ma mette in evidenza come in questo contesto non sia possibile scrivere le istruzioni nello stesso ordine in cui verrebbero elaborate da un compilatore tradizionale.

Un ulteriore caso in cui l'ordine di esecuzione delle operazioni e il dominio ristretto agli interi assumono particolare rilevanza riguarda il rischio di errori di arrotondamento nelle operazioni che coinvolgono valori prossimi allo zero.

Si supponga di voler calcolare il $5%$ di 40. In un linguaggio di programmazione di alto livello, entrambe le espressioni `40/100*5` e `40*5/100` restituiscono correttamente il valore 2. Scomponendo queste operazioni in comandi `scoreboard` si ottengono rispettivamente i seguenti comandi:

#figure(
    [
        #local(
            skips: ((7, 95),),
            number-format: numbering.with("1"),
            ```mcfunction
            scoreboard players operation set $val math 40
            scoreboard players operation $val math /= #100 math
            scoreboard players operation $val math *= #5 math
            ```,
        )
        #v(5pt)
        ```mcfunction
        scoreboard players operation set $val math 40
        scoreboard players operation $val math *= #5 math
        scoreboard players operation $val math /= #100 math
        ```
    ],
    caption: [Calcolo della percentuale con ordine di operazioni invertito],
)

Nel primo caso, poiché $40 / 100 = 0$ nel dominio degli interi, il risultato finale sarà 0: nella riga 3, infatti, viene eseguita l'operazione $0 times 5$.\
Nel secondo caso, invece, si ottiene il risultato corretto pari a 2, poiché le operazioni vengono eseguite nell'ordine $40 times 5 = 200$ e successivamente $200 / 100 = 2$.

== Assenza di Funzioni Matematiche
Poiché tramite le #glos.score è possibile eseguire esclusivamente le quattro operazioni aritmetiche fondamentali, il calcolo di funzioni più complesse, quali logaritmi, esponenziali, radici quadrate o funzioni trigonometriche, risulta particolarmente difficile da implementare.

Occorre inoltre considerare che tali operazioni sono limitate al dominio dei numeri interi. #e dunque richiesto implementare un algoritmo che approssimi queste funzioni, oppure utilizzare una _lookup table_~@lookup-table.

#figure(
    [```mcfunction
        scoreboard players set #sign math -400
        scoreboard players operation .in math %= #3600 const
        execute if score .in math matches 1800.. run scoreboard players set #sign math 400
        execute store result score #temp math run scoreboard players operation .in math %= #1800 const
        scoreboard players remove #temp math 1800
        execute store result score .out math run scoreboard players operation #temp math *= .in math
        scoreboard players operation .out math *= #sign math
        scoreboard players add #temp math 4050000
        scoreboard players operation .out math /= #temp math
        execute if score #sign math matches 400 run scoreboard players add .out math 1
        ```
    ],
    caption: [Algoritmo che approssima la funzione $sin(x)$.],
)

La scrittura di algoritmi di questo tipo è impegnativa e richiede spesso di gestire un input moltiplicato per $10^n$ con output#footnote[Nell'esempio, esso è rappresentato dal valore del _fakeplayer_ `.out` della #glos.score `math`.] di tipo intero le cui ultime $n$ cifre rappresentano la parte decimale del risultato. Inoltre, questo approccio può facilmente provocare problemi di _integer overflow_.

In seguito all'introduzione delle _macro_, si è diffuso l'utilizzo di _lookup table_. Una _lookup table_ consiste in un #glos.a memorizzato in uno #glos.str che contiene tutti gli output di una funzione per un intervallo prefissato di input.

Si consideri il caso in cui sia necessario conoscere la radice quadrata con precisione decimale di tutti gli interi tra 0 e 100.
Si può creare uno #glos.str che contenga i valori $sqrt(i) space forall i in [0,100] inter NN$.

#figure(
    local(
        skips: ((7, 95),),
        number-format: numbering.with("1"),
        ```mcfunction
        data modify storage my_storage sqrt set value [
          0,
          1.0,
          1.4142135623730951,
          1.7320508075688772,
          2.0,
          10.0
        ]
        ```,
    ),
    caption: [_Lookup table_ per $sqrt(x), "con" 0<=x<=100$.],
) <ex-8>
Dunque, data `get storage my_storage sqrt[4]` restituirà il quinto elemento dell'#glos.a, ovvero $2.0$, l'equivalente di $sqrt(4)$.

Poiché sono richiesti gli output per decine, se non centinaia, di valori in input, i comandi per la creazione delle _lookup table_ sono generati mediante script Python~@python-book ed eseguiti dal compilatore di #glos.mc esclusivamente durante l'inizializzazione del #glos.dp (tramite `load.json`).
Dal momento che tali strutture sono soggette a sole operazioni di lettura e non di scrittura, non si presenta il rischio di modifiche durante la sessione di gioco.

== Alto Rischio di Conflitti

In @ex-8 è stato modificato lo #glos.str `my_storage` per inserirvi un #glos.a. Si noti che non è stato specificato alcun #glos.ns, per cui il sistema ha assegnato implicitamente quello predefinito, `minecraft`.

Qualora un mondo contenga due #glos.dp sviluppati da autori diversi, ed entrambi modifichino lo #glos.str `my_storage` senza indicare esplicitamente un #glos.ns, potrebbero verificarsi sovrascritture di dati.

Un'altra situazione che può provocare conflitti si verifica quando due #glos.dp sovrascrivono la stessa risorsa nel #glos.ns `minecraft`.
Se entrambi modificano `minecraft/loot_table/blocks/stone.json`, che determina gli oggetti ottenibili da un blocco di pietra, il compilatore utilizzerà il file del #glos.dp caricato per ultimo ignorando le funzionalità dell'altro.

Il rischio di sovrascrivere o utilizzare in modo improprio risorse appartenenti ad altri #glos.dp non riguarda solo file che prevedono una _resource location_, ma si estende anche a componenti come #glos.score e #glos.tag.

Nell'esempio seguente vengono presentati due frammenti di codice tratti da #glos.dp sviluppati da autori diversi con il medesimo obiettivo di eseguire una funzione sull'entità chiamante (`@s`) al termine di un determinato intervallo di tempo.
In entrambi i casi, le funzioni deputate all'aggiornamento del timer vengono eseguite a ogni _tick_, ovvero 20 volte al secondo.

#figure(
    {
        codly(
            header: [timer\_a.mcfunction],
        )
        [```mcfunction
        scoreboard players add @s timer 1
        execute if score @s timer matches 20 run function some_function
        ```]
        v(10pt)
        codly(
            header: [timer\_b.mcfunction],
        )
        [```mcfunction
        scoreboard players remove @s timer 1
        execute if score @s timer matches 0 run function some_function
        ```]
    },
    caption: [Due funzioni che aggiornano un timer.],
)

Le due funzioni modificano il medesimo _fakeplayer_ all'interno della stessa #glos.score. Poiché `timer_a` incrementa il valore di `timer` mentre `timer_b` lo decrementa, al termine di ogni _tick_ esso risulta invariato.
Qualora entrambe modificassero `timer` nella stessa direzione, ad esempio incrementandolo, la durata effettiva del timer risulterebbe dimezzata.
Questo costituisce uno dei motivi per cui il nome di una _scoreboard_ deve essere prefissato con un #glos.ns, ad esempio `a.timer`#footnote[Come separatore si utilizza `.` anziché `:` in quanto quest'ultimo è un carattere ammesso nel nome di una #glos.score.].

Tra le condizioni in base alle quali i selettori possono filtrare le entità, vi sono i _tag_, stringhe memorizzate in un #glos.a nei dati #glos.nbt di un'entità.\
Dunque, se nell'esempio precedente gli sviluppatori necessitano che la funzione `timer` venga eseguita esclusivamente dalle entità contrassegnate da un determinato _tag_, ad esempio `has_timer`, i comandi per invocare `timer_a` e `timer_b` risulteranno i seguenti:

#figure({
    codly(
        header: [tick\_a.mcfunction],
    )
    [```mcfunction
    execute as @e[tag=has_timer] run function a:timer_a
    ```]
    v(10pt)
    codly(
        header: [tick\_b.mcfunction],
    )
    [```mcfunction
    execute as @e[tag=has_timer] run function b:timer_b
    ```]
})

In entrambi i casi, `@e[tag=has_timer]` seleziona lo stesso insieme di entità. Ciò può risultare problematico se, allo scadere del timer di $b$, vengono eseguiti comandi che determinano comportamenti inaspettati o erronei per le entità del #glos.dp di $a$ o viceversa.

Dunque, come per i nomi delle #glos.score, è buona norma prefissare i _tag_ con il #glos.ns del proprio progetto.

In conclusione, la convenzione vuole che si utilizzino prefissi anche per i nomi di #glos.str, #glos.score e _tag_, nonostante i #glos.dp compilino correttamente anche senza di essi.

== Assenza di Code Blocks

Nei linguaggi di alto livello quali C o Java, i blocchi di codice che devono essere eseguiti condizionalmente o iterativamente vengono racchiusi tra parentesi graffe.
In Python, invece, la stessa funzione è ottenuta tramite l'indentazione del codice.

Nelle funzioni #glos.mcf, nessuno di questi due costrutti è supportato. Per eseguire condizionalmente una serie di comandi, è necessario creare un file separato che li contenga, oppure ripetere la medesima condizione su ciascuna riga.
Quest'ultima soluzione comporta un maggiore _overhead_, in particolare quando il comando viene eseguito ripetutamente nel corso di più _tick_.

Di seguito viene illustrato un esempio di implementazione di un blocco `if-else` o `switch`, tramite il comando `return` per interrompere il flusso di esecuzione nella funzione corrente.

#figure(
    local(
        number-format: numbering.with("1"),
        header: [conditional_example.mcfunction],
        ```mcfunction
        execute if entity @s[type=cow] run return run say I'm a cow
        execute if entity @s[type=cat] run return run say I'm a cat
        say I'm neither a cow nor a cat
        ```,
    ),
    caption: [Funzione che in base all'entità esecutrice, stampa un messaggio diverso.],
)
In questa funzione, i comandi dalla riga 2 in avanti non verranno eseguiti qualora il tipo dell'entità sia `cow`.
Se la condizione alla riga 1 risulta falsa, l'esecuzione procede alla riga successiva, dove viene effettuato un nuovo controllo sul tipo dell'entità. Anche in questo caso, se la condizione è soddisfatta, l'esecuzione si interrompe.

La funzione è sufficientemente intuitiva e simile a costrutti tipici dei linguaggi di programmazione di alto livello.

#figure(
    [```
        switch(entity){
          case "cow" -> print("I'm a cow")
          case "cat" -> print("I'm a cat")
          default -> print("I'm neither a cow nor a cat")
        }
        ```
    ],
    caption: [Pseudocodice equivalente alla funzione precedente.],
)

Si ipotizzi ora di voler eseguire due o più comandi in base all'entità selezionata.

#figure(
    local(
        number-format: numbering.with("1"),
        ```mcfunction
        execute if entity @s[type=cow] run say I'm a cow
        execute if entity @s[type=cow] run return run say moo

        execute if entity @s[type=cat] run say I'm a cat
        execute if entity @s[type=cat] run return run say meow

        say I'm neither a cow nor a cat
        ```,
    ),
    caption: [Funzione errata per eseguire più comandi data una certa condizione.],
)

Si noti come la condizione da soddisfare per l'esecuzione dei comandi sia ripetuta, in quanto non è possibile raggrupparli in un blocco di codice. Tale approccio comporta un notevole overhead, specialmente per operazioni di selezione dispendiose quali la deserializzazione di #glos.nbt.
Dunque si creano funzioni che raggruppano i comandi da eseguire sotto la stessa condizione.

#codly(
    header: [main.mcfunction],
)
```mcfunction
execute if entity@s[type=cow] run return run function is_cow
execute if entity@s[type=cat] run return run function is_cat

say I'm neither a cow or a cat
```

#codly(
    header: [is_cow.mcfunction],
)
```mcfunction
say I'm a cow
say moo
```
#codly(
    header: [is_cat.mcfunction],
)
```mcfunction
say I'm a cat
say meow
```

Considerando che i #glos.dp si basano sull'esecuzione condizionale di funzioni in base a eventi naturalmente occorrenti nel gioco, sono numerosi i casi in cui ci si trova a creare più file che contengono un numero ridotto, purché significativo, di comandi.

L'unica strategia per implementare cicli è mostrata in @funzione_ricorsiva, attraverso la ricorsione.
Di conseguenza, ogni volta che è necessario implementare un ciclo, è indispensabile creare almeno una funzione che si richiama.
Se è invece richiesto un contatore per tenere traccia dell'iterazione corrente (il classico indice `i` dei cicli `for`), è possibile utilizzare funzioni ricorsive che si richiamano passando come parametro una _macro_, il cui valore viene aggiornato all'interno del corpo della funzione. In alternativa, si possono scrivere esplicitamente i comandi necessari a gestire ciascun valore possibile, in modo analogo a quanto avviene con le _lookup table_.

Un'entità giocatore dispone di 36 _slot_ utilizzati per contenere oggetti.
Si ipotizzi di voler individuare in quale _slot_ dell'inventario del giocatore si trovi l'oggetto `diamond`.
Una possibile soluzione consiste nell'utilizzare una funzione che iteri da 0 a 35, dove il parametro della _macro_ indica lo _slot_ da controllare. Tuttavia, questo approccio comporta un _overhead_ maggiore rispetto alla verifica esplicita di ciascuno dei 36 _slot_.

#figure(
    local(
        header: [find_diamond.mcfunction],
        skips: ((3, 33),),
        number-format: numbering.with("1"),
        ```mcfunction
         execute if items entity @s container.0 diamond run return run say slot 0
         execute if items entity @s container.1 diamond run return run say slot 1
         execute if items entity @s container.35 diamond run return run say slot 35
        ```,
    ),
)

In questa funzione, la ricerca viene interrotta da `return` appena si trova un diamante, ed è stato provato che abbia un _overhead_ minore della soluzione ricorsiva.\
Come nel caso delle _lookup table_, i file che fanno controlli di questo genere sono solitamente creati con script Python.

Il @esempio_macro illustra come l'impiego delle _macro_ imponga la definizione di una funzione dedicata: tale funzione deve essere in grado di accettare parametri esterni e di sostituirli nei comandi contrassegnati dal simbolo `$`. Si tratta verosimilmente dell'unico caso in cui la creazione di una nuova funzione risulta genuinamente giustificata e non causata da vincoli di #glos.mcf.

Dunque, programmando in #glos.mcf, è richiesto creare una funzione, ovvero un file dedicato, ogni volta che si necessita di:
- un blocco `if-else` che esegua più comandi;
- un ciclo;
- utilizzare una funzione _macro_.

Ciò comporta un numero di file sproporzionato rispetto alle effettive righe di codice.
Inoltre, si presentano ulteriori problematiche relative alla struttura delle cartelle e dei file nello sviluppo di #glos.dp e #glos.rp.

== Organizzazione e Complessità della Struttura dei File
Le limitazioni precedentemente illustrate sono inerenti alla sintassi dei comandi e ai limiti delle funzioni; tuttavia, non sono da trascurare le complessità legate all'organizzazione e alla struttura di un #glos.pack.

Affinché #glos.dp e #glos.rp vengano riconosciuti dal compilatore, essi devono trovarsi rispettivamente nelle directory `.minecraft/saves/<world_name>/datapacks` e `.minecraft/resourcepacks`.
Tuttavia, operare su queste cartelle in modo separato può risultare oneroso, considerando l'elevato grado di interdipendenza tra le due. Lavorare direttamente dalla directory radice `.minecraft/` risulta poco pratico, poiché essa contiene un numero considerevole di file e cartelle non pertinenti allo sviluppo del #glos.pack.

Un approccio alternativo consiste nel centralizzare #glos.dp e #glos.rp in un'unica directory e collegarla alle posizioni attese dal compilatore mediante _symlink_ o _junction_~@symlink.\
I _symlink_ (collegamenti simbolici) e le _junction_ sono riferimenti a file o directory che consentono di accedere a un percorso diverso come se fosse locale, evitando la duplicazione dei contenuti.

Disporre di un'unica cartella radice contenente #glos.dp e #glos.rp semplifica notevolmente la gestione del progetto.
In particolare, consente di creare una sola _repository_~@repository Git~@git, facilitando così il versionamento del codice, il tracciamento delle modifiche e la collaborazione tra più sviluppatori.\
Attraverso il sistema delle _release_ di GitHub~@github è possibile ottenere un link diretto al #glos.dp e al #glos.rp pubblicati, utilizzabile nei principali siti di hosting e condivisione di #glos.pack.
Tali piattaforme, gestite da piccoli team di sviluppo, tendono ad affidarsi a servizi esterni per l'archiviazione dei file, come appunto GitHub.

Ipotizzando di operare in un ambiente di lavoro unificato, come quello illustrato in precedenza, viene presentato un esempio di struttura contenente i file necessari per introdurre un nuovo _item_~@item (oggetto) nel gioco.
Nonostante l'_item_ costituisca una delle funzionalità più semplici da implementare, la sua integrazione richiede comunque un quantitativo notevole di file.

#figure(
    grid(
        columns: 2,
        gutter: 5em,
        align(left, tree-list[
            - #glos.dp
                - data
                    - _my_namespace_
                        - recipe
                            - my_item.json
                        - loot_table
                            - my_item.json
                        - advancement
                            - use_my_item.json
                        - function
                            - on_item_use.mcfunction
        ]),
        align(left, tree-list[
            - #glos.rp
                - assets
                    - _my_namespace_
                        - item
                            - my_item.json
                        - models
                            - item
                                - my_item.json
                        - textures
                            - item
                                - my_item.png
                        - lang
                            - en_us.json
                        - sounds
                            - item
                                - my_item.ogg
                        - sounds.json
        ]),
    ),
    caption: [File necessari per implementare un semplice _item_.],
)

Nella sezione _data_, che determina la logica e i contenuti del gioco, `loot_table` e `recipe` definiscono rispettivamente gli attributi
dell'oggetto e la modalità con cui questo può essere creato.
L'_advancement_ `use_my_item` è usato per rilevare quando un giocatore usa l'oggetto, invocando la funzione `on_item_use` che in questo esempio riprodurrà un suono.

I suoni devono essere collocati nella directory _assets_. Affinché possano essere riprodotti, i file audio in formato `.ogg` devono essere registrati nel file `sounds.json`.
Nella cartella _lang_ sono presenti i file responsabili della gestione delle traduzioni, organizzate come insiemi di coppie chiave-valore.\
Per definire l'aspetto visivo dell'oggetto, si parte dalla sua _item model definition_, situata nella cartella `item`. Questa specifica il modello che l'_item_ utilizzerà. Il modello 3D, collocato in `models/item`, ne definisce la forma geometrica, mentre la #glos.tex associata al modello è contenuta nella directory `textures/item`.

Si osserva quindi che, per implementare anche la _feature_ più semplice, è necessario creare sette file e modificarne due. Pur riconoscendo che ciascun file svolge una funzione distinta, risulterebbe certamente più comodo poter definire questo tipo di risorse _inline_~@inline.

Con il termine _inline_ si intende la definizione e l'utilizzo di una o più risorse direttamente all'interno del file in cui vengono impiegate.
Questa modalità risulterebbe particolarmente vantaggiosa quando un file gestisce contenuti specifici e indipendenti.
Ad esempio, nell'aggiunta di un nuovo _item_, il relativo modello e #glos.tex non verrebbero mai condivisi con altri oggetti, rendendo superfluo separarli in file distinti.

Infine, l'elevato numero di file rende l'ambiente di lavoro complesso da navigare.
In progetti di grossa portata, questa frammentazione implica non solo una significativa quantità di tempo dedicata alla ricerca di file specifici, ma anche bassa leggibilità, rischi di inconsistenze durante modifiche distribuite su più file, e problematiche nella gestione del versionamento.

== Stato dell'Arte delle Ottimizzazioni del Sistema

Alla luce delle numerose limitazioni di questo sistema, sono state rapidamente sviluppate soluzioni volte a rendere il processo di sviluppo più efficiente e intuitivo.

In primo luogo, gli stessi sviluppatori di #glos.mc dispongono di strumenti interni che automatizzano la creazione dei file #glos.json necessari al corretto funzionamento di determinate _feature_. Durante lo sviluppo, tali file vengono generati automaticamente tramite codice Java eseguito in parallelo alla scrittura del codice sorgente, evitando così la necessità di definirli manualmente.

Un esempio lampante è il file `sounds.json`, il quale registra i suoni e definisce quali file `.ogg` utilizzare. Questo contiene quasi 25.000 righe di oggetti #glos.json, ed è creato e aggiornato tramite software appositi ogni volta che viene inserita una _feature_ che necessita di un nuovo suono.

Tuttavia, questo software non è disponibile al pubblico, e anche se lo fosse, semplificherebbe la creazione solo dei file #glos.json, non di #glos.mcf. Dunque, sviluppatori indipendenti hanno realizzato dei propri precompilatori, progettati per generare automaticamente #glos.dp e #glos.rp con mezzi più pratici e intuitivi.

Un precompilatore è uno strumento che consente di scrivere le risorse e la logica di gioco in un linguaggio più semplice, astratto o strutturato, e di tradurle automaticamente nei numerosi file #glos.json, #glos.mcf e cartelle richieste dal gioco.\
Il precompilatore al momento più completo e potente si chiama _beet_~@beet, e si basa sulla sintassi di Python, integrata con comandi di #glos.mc.\
Questo precompilatore, come molti altri, presenta due criticità principali:
- Elevata barriera d'ingresso: solo gli sviluppatori con una buona padronanza di Python sono in grado di sfruttarne appieno le potenzialità;
- Assenza di documentazione: la mancanza di una guida ufficiale rende il suo utilizzo accessibile quasi esclusivamente a chi è in grado di comprendere direttamente il codice sorgente di _beet_.

Altri precompilatori forniscono un'interfaccia più intuitiva e un utilizzo più immediato al costo della completezza delle funzionalità, limitandosi dunque a produrre solo una parte delle componenti che costituiscono l'ecosistema dei #glos.pack.
Spesso, inoltre, la sintassi di questi linguaggi risulta più verbosa rispetto a quella dei comandi originali, poiché essi offrono esclusivamente un approccio programmatico alla composizione dei comandi senza portare ad alcun incremento nella loro velocità di scrittura.

#figure(
    [```java
        Execute myExecuteCommand = new Execute()
          .as("@a")
          .at("@s")
          .if("entity @s[tag=my_entity]")
          .run("say hello")
        ```
    ],
)
Questo risulta più articolato rispetto alla sintassi tradizionale `execute as @a at @s if entity @s[tag=my_entity] run say hello`.

= Progettazione della Libreria

== Metodologia e Scelte Progettuali

Alla luce del contesto descritto e delle limitazioni degli strumenti esistenti, si è ricercata una soluzione che consentisse di ridurre la complessità e preservare la completezza delle funzionalità.
Di seguito sono illustrate le principali decisioni progettuali e le ragioni che hanno portato alla scelta del linguaggio di sviluppo.

Inizialmente si è tentato di progettare un _superset_~@superset di #glos.mcf, ovvero un linguaggio che estende quello originale introducendo nuove funzionalità, e mantenendone la compatibilità.
Tale linguaggio avrebbe consentito di dichiarare e utilizzare elementi multipli (#glos.mcf e #glos.json) all'interno di un unico file, arricchendo inoltre la sintassi dei comandi con zucchero sintattico volto a velocizzare la scrittura delle sezioni più verbose.

#figure(
    [```mcf
        package foo
        scoreboard players operation @s var *= 4
        if score @s var matches 10.. run function {
          say hello
          say something else
        }
        ```
    ],
    caption: [Esempio di questo _superset_, caratterizzato da file con l'estensione `.mcf`],
)
Compilando il codice di questo linguaggio ideale, verrebbe non solo creata la funzione definita all'interno delle parentesi graffe, ma anche inserito il #glos.ns prima di `var` e verrebbe creato il comando che assegna allo _score_ costante `#4` il valore 4.
Come è stato mostrato nel @scoreboard_set_const, per eseguire divisioni e moltiplicazioni per valori costanti, è prima necessario definirli in uno _score_.
Compilando il frammento di codice dell'esempio, si sarebbero ottenuti i seguenti file:

#figure({
    codly(
        header: [load.mcfunction],
    )
    [```mcfunction
    scoreboard players set #4 foo.var 4
    ```]
    v(10pt)
    codly(
        header: [main.mcfunction],
    )
    [```mcfunction
    scoreboard players operation @s foo.var *= #4 foo.var
    execute if score @s foo.var matches 10.. run function foo:5a3c50
    ```]
    v(10pt)
    codly(
        header: [5a3c50.mcfunction],
    )
    [```mcfunction
    say hello
    say something else
    ```]
})

Inizialmente si è scelto di utilizzare la versione Java della libreria ANTLR~@antlr per definire la grammatica del linguaggio. Tuttavia, è emerso che la realizzazione di una grammatica in grado di cogliere tutte le sfumature della sintassi di #glos.mcf, integrandovi al contempo le estensioni proposte, avrebbe richiesto un impegno di sviluppo incompatibile con i vincoli temporali di un progetto di tirocinio.

Si è quindi optato per lo sviluppo di una libreria che consentisse di definire la struttura di un #glos.pack, dalla radice del progetto fino ai singoli file, mediante oggetti, in modo da rappresentare l'intero insieme delle risorse come un albero n-ario.
Tale struttura viene quindi attraversata in fase di esecuzione per generare automaticamente i file e le cartelle corrispondenti ai nodi all'interno delle directory di #glos.dp e #glos.rp.

Il principale vantaggio di questo approccio consiste nella possibilità di definire più elementi all'interno dello stesso file, evitando così la frammentazione del codice e semplificando la gestione della struttura complessiva del #glos.pack.
Inoltre, l'impiego di un linguaggio ad alto livello consente di sfruttare costrutti quali cicli e funzioni per automatizzare la generazione di comandi ripetitivi (ad esempio le già citate _lookup table_). La rappresentazione a oggetti della struttura permette anche di definire metodi di utilità per accedere e modificare i nodi da qualsiasi punto del progetto.
Ad esempio, si può implementare un metodo `addTranslation(key, value)` che permette di aggiungere, indipendentemente dal contesto in cui viene invocato, una nuova voce nel file delle traduzioni.

Si è dunque valutato quale linguaggio di programmazione, tra Python e Java, fosse più adatto per la realizzazione della libreria.

#figure(
    table(
        align: top + left,
        columns: 3,
        [], table.cell(align: horizon + center)[*Vantaggi*], table.cell(align: horizon + center)[*Svantaggi*],
        table.cell(align: horizon + center)[*Python*],
        [
            - Gestione semplice di stringhe (`f-string`~@f-strings) e file JSON;
            - Sintassi concisa;
            - Facilmente distribuibile.
        ],
        [
            - Non nativamente orientato agli oggetti;
            - Tipizzazione dinamica che può causare errori a runtime;
            - Prestazioni inferiori in fase di esecuzione.
        ],

        table.cell(align: horizon + center)[*Java*],
        [
            - Maggiore familiarità con progetti di grandi dimensioni;
            - Completamente orientato agli oggetti;
            - Compilazione ed esecuzione più efficienti.
        ],
        [
            - Assenza di `f-strings` e manipolazione delle stringhe più complessa;
            - Gestione dei file JSON più verbosa;
            - Sintassi più prolissa, che rallenta la scrittura del codice.
        ],
    ),
    caption: [Java e Python a confronto.],
)

A seguito di un'attenta analisi, si è optato per Java come linguaggio di sviluppo del progetto, in quanto esso consente di applicare #glos.dep volti a semplificare e rendere più robusta l'implementazione, pur a scapito di una minore immediatezza d'uso per l'utente finale.\
Inoltre, il tipaggio statico di Java permette di identificare in fase di sviluppo eventuali utilizzi impropri di oggetti o metodi della libreria, consentendo anche agli utenti meno esperti di comprendere più facilmente il funzionamento del sistema.

Il progetto, denominato _Object Oriented Pack_ (OOPACK), è organizzato in 4 sezioni principali.
/ `internal`: Contiene classi astratte e interfacce che riproducono la struttura di un generico _filesystem_. Classi e metodi di questo _package_~@package non saranno mai utilizzati dall'utente finale.
/ `objects`: Contiene le classi che rappresentano gli oggetti impiegati da #glos.dp e #glos.rp.
/ `util`: Raccoglie metodi di utilità impiegati sia per il funzionamento del progetto, sia a supporto del programmatore (ponendo attenzione alla visibilità dei singoli metodi).
/ Radice del progetto: Contiene gli oggetti principali che descrivono la struttura di un #glos.pack (`Datapack`,`Resourcepack`,#c.ns,#c.p), a disposizione dell'utente finale.

Questa libreria si occupa di generare #glos.pack, e dunque non interviene direttamente sul codice sorgente Java di #glos.mc per introdurre comportamenti dinamici.
Tuttavia consente di automatizzare la creazione di componenti statiche che, quando attivate tramite comandi o altri elementi di un #glos.dp durante l'esecuzione del gioco, realizzano comportamenti complessi.
Un esempio emblematico è rappresentato dalle _lookup table_: anziché calcolare i valori a runtime, questi vengono pre-generati durante la compilazione per essere successivamente recuperati in modo efficiente.

Dato che il framework è progettato per produrre codice come output, trattandolo come dato piuttosto che come istruzioni da eseguire immediatamente, si può affermare di operare nel campo della meta-programmazione.
La meta-programmazione è un paradigma che abilita un software di operare su programmi o linguaggi trattandoli come dati. Ciò rende possibile la loro manipolazione o generazione in maniera dinamica o in fase di compilazione~@metaprogrammazione.

== Classi Astratte e Interfacce
=== Buildable
L'obiettivo della libreria sviluppata è delegare la creazione dei file che compongono un #glos.pack al metodo `build()` della classe di più alto livello, #c.p.
Di conseguenza, ogni oggetto appartenente al progetto deve essere _buildable_, ovvero "costruibile", affinché si possa generare il file corrispondente in base al proprio nome e contenuto.
L'interfaccia #c.b definisce il contratto che stabilisce quali oggetti possono essere costruiti attraverso il metodo `build()`.
#figure(```java
public interface Buildable {
    void build(Path parent);
}
```)
Il parametro `parent` rappresenta un oggetto di tipo `Path`~@path che specifica la directory di destinazione nel file system locale nella quale verrà generato il file.
Durante il processo di costruzione del progetto, questo percorso viene progressivamente esteso aggiungendo sottocartelle, fino a individuare la posizione finale del file generato.

L'interfaccia #c.fso estende #c.b con lo scopo di rappresentare file e cartelle del _file system_.
Essa definisce il contratto `getContent()`, che specifica il contenuto associato all'oggetto.
Sfruttando il polimorfismo, tale metodo può restituire il contenuto delle classi che rappresentano file, oppure un insieme di #c.fso per le classi che rappresentano cartelle o altri contenitori.

L'interfaccia #c.fso implementa il _design pattern_ strutturale _composite_. Questa architettura permette di organizzare gli oggetti in strutture ad albero, garantendo una gestione uniforme sia per le singole istanze che per le loro aggregazioni.

Questa interfaccia definisce il metodo statico `find()`, il quale permette di trovare un `file` all'interno di un #c.fso che soddisfa una certa condizione, permettendo la comunicazione tra #c.fso in ogni punto del progetto.

#figure(```java
static < T extends FileSystemObject > Optional < T > find(
    FileSystemObject root,
    Class < T > clazz,
    Predicate < T > condition
) {
    if (clazz.isInstance(root)) {
        T casted = clazz.cast(root);
        if (condition.test(casted)) {
            return Optional.of(casted);
        }
    }
    Object content = root.getContent();
    if (content instanceof Set << ? > children) {
        for (Object child: children) {
            Optional < T > found = find(
                (FileSystemObject) child,
                clazz,
                condition
              );
            if (found.isPresent()) {
                return found;
            }
        }
    }
    return Optional.empty();
}
```) <find>

Questo metodo generico accetta come parametri un #c.fso (senza distinzione tra cartella o file), la classe del tipo ricercato (`clazz`) e un `Predicate`~@predicate che esprime la condizione da soddisfare.

Il metodo implementa un algoritmo di ricerca ricorsiva in profondità sulla struttura ad albero.
Per ogni nodo visitato, verifica innanzitutto se esso è un'istanza del tipo ricercato; in tal caso, valuta il predicato fornito e, se soddisfatto, restituisce un #c.o~@optional contenente l'oggetto.
Qualora il nodo corrente non corrisponda al tipo ricercato, il metodo ne recupera il contenuto: se questo è un `Set`~@set, indicando che si tratta di una cartella o una sua sottoclasse, il metodo viene invocato ricorsivamente su ciascun elemento figlio, interrompendo la ricerca non appena viene trovata una corrispondenza. In assenza di risultati, viene restituito un #c.o vuoto.

L'interfaccia #c.fso definisce inoltre il contratto `collectByType(Namespace data, Namespace assets)`, il quale viene sovrascritto dalle classi concrete per specificare l'appartenenza alla categoria _data_ dei #glos.dp o _assets_ dei #glos.rp.

Questo è un esempio di utilizzo del _design pattern_ comportamentale _strategy_. Esso permette di definire una famiglia di algoritmi, incapsularli e renderli intercambiabili. In questo caso viene applicato per separare automaticamente le risorse sfruttando il polimorfismo.

=== AbstractFile e AbstractFolder

Tutti gli oggetti rappresentanti file nel progetto, il cui metodo `build()` scriverà in memoria, sono un'estensione della classe #c.af.\
La classe astratta `AbstractFile<T>` è parametrizzata con un tipo generico `T`, relativo al contenuto del file, memorizzato nell'attributo `content`.
La classe dispone dell'attributo `name`, nel quale è memorizzato il nome del file associato, privo di estensione.
Possiede inoltre un riferimento al `parent`, ovvero alla sottocartella o cartella delle risorse in cui il file sarà collocato.
L'oggetto dispone infine di un riferimento al #glos.ns in cui è contenuto.\
Il metodo `toString()` combina gli attributi `namespace` e `name` per generare la stringa corrispondente alla _resource location_ dell'oggetto.
Grazie a questa implementazione, è possibile inserire direttamente la variabile che rappresenta il file all'interno di altre stringhe, e la sua _resource location_ viene individuata tramite _casting_ implicito a stringa.

#figure(```java
@Override
public String toString() {
  return String.format("%s:%s", getNamespaceId(), getName());
}
```)

La classe #c.af, oltre ad implementare #c.fso, implementa le interfacce `PackFolder` ed `Extension`.\
L'interfaccia `PackFolder` fornisce un unico contratto, `getFolderName()`, per definire il nome della cartella in cui l'oggetto sarà collocato. Ad esempio, la classe `Function` implementa tale metodo restituendo la stringa `"function"`, poiché tutte le funzioni devono risiedere nella cartella `function`.\
Similmente, l'interfaccia `Extension`, mediante il contratto `getExtension()`, consente agli oggetti che estendono #c.af di specificare la propria estensione (`.json`, `.mcfunction`, `.png`).

L'altra classe astratta che implementa #c.fso è #c.afo, parametrizzata con il tipo generico `<T extends FileSystemObject>`. Tale classe mantiene un attributo `children` di tipo `Set<T>`, usato per memorizzare i riferimenti ai nodi figli garantendo l'unicità degli elementi. Il metodo `build()` implementa un attraversamento ricorsivo invocando `build()` su ciascun nodo contenuto in `children`.\
In maniera analoga, il metodo `collectByType(...)` propaga ricorsivamente la classificazione degli oggetti attraverso l'albero, effettuando chiamate polimorfiche a `collectByType(...)` su ogni nodo figlio.

=== Folder e ContextItem
La classe `Folder` estende `AbstractFolder<FileSystemObject>`.
I suoi `children` saranno dunque #c.fso. Dispone di un metodo `add()` per aggiungere un elemento all'insieme dei figli.
Questo viene usato dalla logica interna della libreria, ma non è pensato per l'utilizzo dell'utente finale.

Nella prima iterazione del progetto, la creazione di una cartella con dei figli richiedeva l'istanza di un oggetto `Folder` e la successiva invocazione del metodo `add(...)`, passando come parametro uno o più oggetti istanziati tramite l'operatore `new`.\
Un sistema basato sulla creazione diretta degli oggetti presenta tuttavia diverse limitazioni.
In primo luogo, introduce un forte accoppiamento tra il codice _client_ e le classi concrete: qualsiasi modifica ai costruttori richiederebbe di aggiornare manualmente ogni punto del codice in cui tali oggetti vengono istanziati.
Inoltre, l'utilizzo di espressioni come `myFolder.add(new Function(...))` risulta poco pratico per l'utente finale, specialmente considerando l'obiettivo di offrire un'interfaccia più semplice e immediata per la creazione dei file.

Il sistema è stato quindi modificato per appoggiarsi su un oggetto #c.c che rappresenta il _parent_, ovvero la cartella a cui si vogliono aggiungere nodi. La classe #c.c contiene un attributo statico e privato di tipo `Stack<ContextItem>`~@stack, utilizzato per tracciare il livello di _nesting_ delle cartelle. Il metodo `stack.peek()` restituisce il #c.ci in cima allo stack, corrispondente al contesto corrente.

L'interfaccia #c.ci fornisce il metodo `add()` che un qualsiasi contenitore di oggetti implementerà (non solo `Folder`, ma come si vedrà successivamente, anche #c.ns in quanto anche esso è contenitore di #c.fso).\
L'interfaccia fornisce inoltre due metodi `default` i quali permettono di inserire o eliminare l'oggetto dal #c.c.
#figure(
    ```java
    default void enter() {
        Context.enter(this);
    }
    default void exit() {
        Context.exit();
    }
    ```,
    caption: [Metodi dell'interfaccia #c.ci.],
)
Invocando `enter()`, si inserisce l'oggetto che implementa #c.ci in cima allo `stack` del contesto, indicando che i prossimi #c.fso saranno inseriti in esso.
Per rimuovere l'oggetto dalla cima dello `stack`, si chiama il metodo `exit()`.\
Con questo sistema, il programmatore può spostarsi tra diversi livelli della struttura del _filesystem_ in modo rapido e controllato, senza dover passare manualmente riferimenti ai vari contenitori.

=== Factory
Il sistema deve garantire ad ogni oggetto che estende #c.fso di essere collocato nel #c.ci corretto.
Per gestire automaticamente questo aspetto e al tempo stesso evitare la creazione diretta tramite `new`, si ricorre al #glos.dep #glos.f.

Le #glos.f costituiscono un #glos.dep creazionale finalizzato a separare la logica di inizializzazione degli oggetti dal codice che li utilizza.
Anziché istanziare le classi direttamente, il client delega alla #glos.f la creazione dell'oggetto desiderato.
La #glos.f si occupa di selezionare la classe concreta da istanziare e di determinarne lo stato iniziale.
Nell'implementazione proposta, la #glos.f gestisce inoltre l'inserimento dell'oggetto appena creato nel contesto in cima allo _stack_.

Un'evoluzione di questo concetto è l'_abstract factory_, un _pattern_ che fornisce un'interfaccia per creare famiglie di oggetti correlati o dipendenti tra loro, senza specificare le loro classi concrete.\
L'_abstract factory_ non crea direttamente gli oggetti, ma definisce un insieme di metodi di creazione che le sottoclassi concrete implementano per produrre versioni specifiche di tali oggetti.

Tale approccio risulta particolarmente vantaggioso poiché permette di fornire all'utente molteplici funzioni dedicate alla istanziazione di oggetti.

#figure(
    ```java
    public interface FileFactory<F> {
        F ofName(String name, String content, Object... args);
        F of(String content, Object... args);
    }
    ```,
    caption: [Interfaccia `FileFactory`.],
)

L'utente può definire esplicitamente il nome del file oppure affidare alla libreria la generazione di un identificatore automatico. Come avviene nei compilatori convenzionali, i dettagli implementativi del codice generato e la nomenclatura dei file risultano irrilevanti per l'utente, il quale si limita a verificarne il corretto funzionamento senza necessità di ispezionare gli artefatti prodotti.

Qualora la stringa `name` passata come parametro contenga uno o più caratteri `/`, questi saranno interpretati come separatori di cartelle, creando una gerarchia di sottocartelle.\
Il nome assegnato all'oggetto non influisce sul funzionamento della libreria, poiché quando questo viene utilizzato in un contesto testuale, la chiamata implicita al metodo `toString()` restituisce la sua _resource location_.\

#figure(
    ```java
    Namespace namespace = Namespace.of("foo");
    Function function = Function.f.ofName("bar/baz/my_function","say hello world!");
    System.out.println(function);
    ```,
)
Questo esempio stamperà `foo:bar/baz/my_function`, ovvero la _resource location_ della funzione creata.

Gli oggetti passati come parametro _variable arguments_ (_varargs_~@varargs, `Object... args`) sostituiranno i corrispondenti valori segnaposto (`%s`), interpolando così il contenuto testuale prima che il file venga scritto su disco.

=== Classi File Astratte

L'interfaccia `FileFactory` è implementata come classe annidata all'interno dell'oggetto astratto #c.pf, il quale rappresenta qualsiasi file di contenuto testuale.\
Questa _nested class_, chiamata #c.f, dispone di due parametri ed è impiegata per istanziare le sottoclassi di #c.pf.
#figure(
    ```java
    protected static class Factory<F extends PlainFile<C>, C>
      implements FileFactory<F>
    ```,
    caption: [Intestazione della classe #c.f per #c.pf],
)
`F` è un tipo generico che estende `PlainFile<C>`, rappresenta il tipo di file che la classe istanzierà.
Il contenuto `C` del file è determinato dalle sottoclassi che ereditano #c.pf.
Vincolando `F` a `PlainFile<C>`, la #glos.f garantisce che tutti i file creati abbiano un contenuto di tipo `C` e siano sottoclassi di #c.pf.\
Ciò consente alla #glos.f di operare in modo generico, generando file con contenuti eterogenei senza necessità di duplicare codice.

La #glos.f mantiene un riferimento all'oggetto `Class`~@class parametrizzato con il tipo `F`, corrispondente alla classe degli oggetti da istanziare, utilizzato nel metodo `instantiate()`.
Questa funzione restituisce l'oggetto da creare dati due parametri: il nome del file da creare e il suo contenuto di tipo `Object`, in quanto si sta ancora operando in un contesto generico.

Per istanziare l'oggetto, la funzione ottiene inizialmente un riferimento alla classe del contenuto (`StringBuilder.class` o `JsonObject.class`), necessario per individuare il costruttore della classe `F`.
Successivamente, recupera il costruttore tramite _reflection_~@reflection, verificando che la classe `F` disponga di un costruttore con i parametri `String name` e `C content`.
Prima di procedere con l'istanziazione, rende accessibile il costruttore, operazione indispensabile per accedere a costruttori privati o protetti.
In seguito, crea un'istanza della classe e la aggiunge al contesto corrente.
Infine, restituisce l'oggetto creato.

Le classi #c.tf e #c.jf estendono #c.af, utilizzando rispettivamente #c.sb~@stringbuilder e #c.jo~@jsonobject come tipo di `content`.

#c.tf rappresenta un file di testo generico, il cui contenuto è gestito tramite un oggetto #c.sb per consentire la concatenazione efficiente di stringhe.
L'unica classe che la estende è `Function`, poiché è l'unico tipo di file in un #glos.pack che prevede la scrittura diretta di testo semplice.

#c.jf è invece la classe astratta ereditata da tutti i file #glos.json di un #glos.pack. Il suo contenuto è di tipo #c.jo, affinché si possano gestire e manipolare facilmente dati in formato #glos.json tramite la libreria _GSON_~@gson di Google.\
La #glos.f di #c.jf eredita quella di #c.pf, aggiungendovi metodi specifici per la creazione di file #glos.json.
#figure(
    ```java
    protected static class Factory<F extends JsonFile>
      extends PlainFile.Factory<F, JsonObject>
      implements JsonFileFactory<F>
    ```,
    caption: [Intestazione della classe #c.f per #c.jf.],
)
L'estratto di codice riportato definisce la _nested class_ #glos.f incaricata di istanziare esclusivamente classi che estendono #c.jf.
Questa classe eredita la factory di #c.pf, specializzandola per gestire contenuti di tipo #c.jo. Inoltre, implementa l'interfaccia `JsonFileFactory`, la quale definisce i metodi di creazione specifici per i file #glos.json, che dunque hanno come parametro #c.jo.\
Nella classe #c.jf viene anche eseguito l'#glos.or del metodo `getExtension()` per restituire la stringa `"json"`.

Nonostante il contenuto richiesto dalle classi sopra descritte non sia di tipo `String`, esso viene comunque convertito in stringa prima della scrittura su file.

Prima della scrittura effettiva, ogni file testuale viene sottoposto a un leggero processo di _parsing_.
Oltre alla già citata sostituzione dei valori segnaposto `%s`, dopo che #c.sb e #c.jo sono stati convertiti in stringhe, il contenuto viene analizzato per individuare pattern specifici.
La sottostringa `"$ns$"` viene sostituita con il nome effettivo del #glos.ns attivo al momento della costruzione, mentre `"$name$"` viene sostituito con la _resource location_ del file.
Quest'ultimo risulta particolarmente utile nei casi di dipendenze circolari, in cui può essere richiesto il nome di un oggetto prima che esso sia effettivamente istanziato, dal momento che non è ancora possibile ottenere la sua rappresentazione testuale tramite _casting_ implicito a stringa.

#figure(
    diagram(
        node-stroke: 1pt,
        node-corner-radius: 2pt,
        {
            node((0, 0))[`interface`\ *PackFolder*]
            node((1, 0))[`interface`\ *Extension*]
            node((2, 0))[`interface`\ *FileSystemObject*]
            edge("u", "-|>")

            node((2, -1))[`interface`\ *FileSystemObject*]

            node((1, 1))[*AbstractFile*]
            edge("ul", "--|>")
            edge("ur", "--|>")
            edge("u", "--|>")

            node((2, 1))[*AbstractFolder*]
            edge("u", "--|>")

            node((3, 1))[`interface`\ *ContextItem*]
            node((2, 2))[*Folder*]
            edge("u", "-|>")
            edge("ur", "--|>")

            node((1, 2))[*PlainFile*]
            edge("u", "-|>")
            node((1, 3))[*JsonFile*]
            edge("u", "-|>")
            node((0, 3))[*TextFile*]
            edge("ur", "-|>")

            node((2, 3))[`interface`\ *FileFactory*]

            node((2, 4))[`interface`\ *JsonFileFactory*]
            edge("u", "-|>")
            edge("ul", "--|>")
        },
    ),
    caption: [Diagramma del sistema progettato fino a questo punto.],
)

Nella struttura riportata non sono ancora stati definiti metodi o classi specifiche per l'implementazione di un #glos.pack. Ritengo che questo livello di astrazione sia potenzialmente applicabile anche in altri contesti, in quanto permette di generare in modo sistematico più file a partire da un'unica definizione di riferimento. Questo approccio potrebbe risultare particolarmente utile anche in altri DSL caratterizzati da vincoli strutturali, dove la generazione automatizzata di file correlati è un requisito per la scalabilità e la manutenibilità del codice.

Di seguito invece si esporranno elementi e funzionalità definite appositamente per lo sviluppo dei #glos.pack.

== Classi Concrete

=== File

Le classi astratte #c.dj e #c.aj, sottoclassi di #c.jf, eseguono l'#glos.or del metodo `collectByType()` di #c.fso per indicare l'appartenenza alla categoria #glos.dp o #glos.rp rispettivamente.

#figure(
    ```java
    @Override
    public void collectByType(Namespace data, Namespace assets) {
        data.add(this);
    }
    ```,
    caption: [metodo `collectByType()` di #c.dj.],
)

Queste saranno poi ereditate dalle classi concrete dei file che compongono un #glos.pack.

L'unica eccezione è la classe #c.fn.
Questa estende direttamente #c.tf, indicando la propria estensione (`.mcfunction`) con #glos.or del metodo `getExtension()`, e il tipo tramite #glos.or di `collectByType()` similmente a #c.dj.
Dal momento che #c.tf non dispone di una #glos.f per file di testo non in formato #glos.json, sarà  la #glos.f di #c.fn stessa a estendere `PlainFile.Factory`, definendo come parametro per il contenuto del file #c.sb, e come oggetto istanziato #c.fn.

Le classi rappresentanti file di alto livello sono dotate di un attributo statico e pubblico di tipo `JsonFileFactory<...>` chiamato `f`, parametrizzato per la classe specifica che esso istanzia. Con questo approccio si ha accesso rapido ai _factory methods_ di ogni file, #glos.json e non.
Queste classi sono 39 in totale, e ognuna corrisponde a uno specifico oggetto utile al funzionamento di un #glos.dp o #glos.rp (30 e 9 rispettivamente).
Poiché ognuna di queste deve disporre di una #glos.f, un costruttore, ed eseguire l'#glos.or del metodo `getFolderName()`, è stata impiegata una libreria per generare il loro codice Java.

Una possibile soluzione alternativa avrebbe previsto l'implementazione di un unico metodo statico generico all'interno di `JsonFile.Factory`, strutturato per accettare come argomenti il tipo della classe da istanziare e la relativa directory di riferimento.
Con questo approccio non sarebbe stato necessario creare una classe dedicata per ciascun tipo di file, ma sarebbe risultato sufficiente invocare direttamente la funzione `create()` per generare l'istanza desiderata.
#figure(
    ```java
    Advancement adv = JsonFile.Factory.create(
      Advancement.class,
      "advancement",
      jsonObject
    );
    Model model = JsonFile.Factory.create(Model.class, "model", jsonModel);
    ```,
    caption: [Esempio di approccio alternativo.],
)

Tuttavia è evidente che non risulta comodo per l'utente finale dover specificare tutti questi parametri ogni volta che necessita di utilizzare la #glos.f.\
È stata quindi implementata una classe di utilità `CodeGen` che sfrutta la libreria _JavaPoet_~@javapoet per generare automaticamente le classi rappresentanti i file di un #glos.pack.
Ogni classe generata include i metodi necessari e una #glos.f già parametrizzata accessibile tramite l'attributo statico `f`. Questo approccio permette di creare istanze in modo conciso, ad esempio: `Model.f.of(json)`.


Classi che rappresentano file binari (immagini, suoni) non ereditano la #c.f di #c.pf, ma usano #glos.f proprie per istanziare #c.t e #c.s.

L'oggetto #c.t estende un #c.af che ha come contenuto una #c.bi~@bufferedimage.
Qualora il metodo `of()` riceva come parametro una stringa, questa verrà convertita in un _path_ relativo alla cartella `resources/texture` del progetto Java.
In alternativa, è possibile fornire direttamente un'istanza di #c.bi generata dinamicamente tramite codice Java.

I suoni invece usano come contenuto un #glos.a di byte. La loro #glos.f, similmente a quella di #c.t, permette di caricare suoni dalle risorse del progetto (`resources/sound`).

=== Module

#e stata definita una sottoclasse astratta di `Folder`, denominata #c.m, con l'obiettivo di promuovere la modularità del codice attraverso una chiara separazione delle responsabilità e l'aggregazione di contenuti affini.
Ad esempio, nel contesto dell'implementazione di una feature $A$, tutte le risorse e i dati ad essa correlati possono essere raggruppati all'interno dello specifico #c.m $A$.

La classe dispone di un _entry point_, ovvero una funzione astratta `content()` che verrà sovrascritta da tutte le classi che ereditano #c.m, con lo scopo di fornire un chiaro punto in cui definire la logica interna del modulo.

I moduli vengono istanziati tramite il metodo `register(Class<? extends Module>... classes)`, il quale invoca il costruttore di una o più classi che estendono #c.m.

Quando un nuovo modulo viene istanziato, il costruttore imposta la nuova istanza come contesto corrente. Successivamente viene invocato il metodo `content()`, tramite il quale viene eseguito il codice specifico del modulo. Al termine di questa esecuzione, il costruttore ripristina il contesto precedente chiamando il metodo `exit()` dei #c.ci.
In questo modo si garantisce che l'esecuzione di ciascun modulo avvenga in maniera indipendente, evitando che compili in un contesto non pertinente.

=== Namespace

Le classi concrete di file sono raggruppate all'interno di un #c.ns. Analogamente alla classe `Folder`, quest'ultimo gestisce un `Set` di elementi figli e implementa le interfacce #c.b e #c.ci.
L'implementazione di quest'ultima è necessaria poiché un #c.p può essere composto da molteplici #glos.ns\; è pertanto indispensabile tracciare quello corrente destinato ad accogliere i #c.fso istanziati.\
Poiché gli elementi figli di #c.ns sono di natura diversa (_data_ o _assets_), e saranno scritti in cartelle diverse, è necessario dividerli prima della loro scrittura su file.
Questi devono essere indirizzati verso i rispettivi contesti: il #glos.ns del #glos.dp per la componente _data_ e quello relativo ai #glos.rp per gli _assets_.

La classe presenta una particolarità nel suo metodo `exit()`, usato per indicare quando non si vogliono più creare file su questo #glos.ns.
Oltre a indicare all'oggetto #c.c di chiamare `pop()` sul suo `stack` interno, viene anche chiamato il metodo `addNamespace()` di #c.p che verrà mostrato in seguito.

=== Project

La classe #c.p rappresenta la radice dell'albero corrispondente all'intero #glos.pack, e contiene informazioni essenziali per l'esportazione del progetto. Queste verranno impostate dall'utente finale tramite un _builder_.

Il _builder pattern_ è un #glos.dep creazionale utilizzato per costruire oggetti complessi progressivamente, separando la logica di costruzione da quella di istanziazione dell'oggetto.
#e particolarmente utile quando il costruttore di un oggetto possiede molti parametri opzionali, come nel caso di #c.p.\
Tramite la classe `Builder` di #c.p, si possono specificare:
- il nome del mondo, ovvero in quale _save file_ verrà esportato il #glos.dp;
- il nome del progetto;
- la versione del #glos.pack. Questa verrà usata per comporre il nome delle cartelle #glos.dp e #glos.rp esportate, e anche per ottenere il loro rispettivo `pack_format` richiesto;
- il _path_ dell'icona di #glos.dp e #glos.rp, che verrà prelevata dalle risorse;
- la descrizione in formato #glos.json o stringa di #glos.dp e #glos.rp, richiesta dal file `pack.mcmeta` di entrambi.
- uno o più _build path_, ovvero cartelle radice in cui saranno esportati il #glos.dp e #glos.rp costruiti. In genere questa coinciderà con la cartella globale di #glos.mc, nella quale sono raccolti tutti i #glos.rp e i _save file_, tra cui quello in cui si vuole esportare il #glos.dp.

Dopo aver definito questi valori, il progetto sarà in grado di comporre ogni _path_ cui dovrà esportare i file di #glos.dp e #glos.rp.

Un ulteriore #glos.dep applicato a #c.p è _singleton_, che garantisce l'esistenza di un'unica istanza della classe nell'intero programma, accessibile da qualsiasi punto del codice.
Questo viene implementato tramite una variabile statica e privata di tipo #c.p all'interno della classe stessa. Un riferimento ad essa è ottenuto con il metodo `getInstance()`, che solleva un errore nel caso il progetto non sia ancora stato costruito con il `Builder`.

La classe #c.p dispone al suo interno di attributi di tipo #c.dp e #c.rp. Questi hanno il compito di contenere i file che saranno scritti su memoria rigida ed estendono la classe astratta #c.gp.\
Questa implementa le interfacce #c.b e `Versionable`, fornendo così i metodi per ottenere i _pack format_ corrispettivi alla versione del progetto.\
Dispone inoltre di un attributo `namespaces` di tipo `Map`~@map, nel quale verranno salvati i #c.ns.
Tramite il metodo `makeMcMeta()` viene generato il file `pack.mcmeta`, obbligatorio per #glos.dp e #glos.rp. Esso comunica a #glos.mc il valore di `pack_format`, dipendente dalla versione per la quale è stato sviluppato, oltre alla descrizione del #glos.pack.\
Il metodo `build()` è sovrascritto affinché iteri su tutti i valori del dizionario `namespaces`, propagando la costruzione.

Il metodo `addNamespace()`, accennato precedentemente, non aggiunge direttamente il #glos.ns al progetto. Prima divide i #c.fso che contiene tra quelli inerenti alle risorse (_assets_) e quelli relativi alla logica (_data_). Questa suddivisione viene fatta chiamando il metodo polimorfico già citato `collectByType()`. Al termine della divisione si avranno due nuovi #glos.ns omonimi, ma con i contenuti divisi per funzionalità.
Il #glos.ns che contiene i file di _data_ sarà aggiunto alla lista di #c.ns di `datapack`. Se il #glos.ns contenente gli _assets_ non è vuoto, verrà aggiunto a quelli di `resourcepack`.

L'invocazione del metodo `build()` si propaga a cascata partendo da #c.p verso i campi `datapack` e `resourcepack`, i quali delegano l'operazione ai rispettivi `namespace`.
Questi a loro volta estendono l'esecuzione a tutti gli elementi figli (cartelle e file), garantendo così il completo attraversamento dell'albero.

Con gli oggetti descritti fino ad ora è possibile costruire un intero #glos.pack a partire da codice Java, tuttavia si possono sfruttare ulteriormente proprietà del linguaggio di programmazione per implementare funzioni di utilità, al fine di agevolare lo sviluppo.

== Utilità

=== Meccanismo di Ricerca e Creazione Dinamica dei File

Il metodo `find()`, descritto precedentemente (@find), è impiegato in metodi di utilità che permettono di modificare i contenuti di file, in particolare quelli soggetti a modifiche da più punti del codice.
Ad esempio, i file `lang` dedicati alla localizzazione richiedono un aggiornamento costante per integrare le nuove voci. Similmente, ogni nuovo suono deve essere registrato nel file `sounds.json`.
Come accennato in precedenza, quando questi file di risorse vengono utilizzati dagli sviluppatori di #glos.mc, non vengono modificati manualmente, ma generati automaticamente tramite codice Java proprietario.

Dal momento che tali risorse non sono concepite per essere modificate manualmente, la classe `Util` fornisce metodi dedicati per l'aggiunta programmatica di elementi, invocabili da qualsiasi punto del progetto.
Questo sistema si appoggia ad una funzione che permette di ottenere un riferimento all'oggetto ricercato, o di crearne uno nuovo qualora questo non venga trovato.
#figure(
    ```java
    private static <T extends JsonFile> T getOrCreateJsonFile(
            Namespace namespace,
            Class<T> clazz,
            String name,
            Supplier<T> creator
    ) {
        return namespace.getContent().stream()
                .map(child -> FileSystemObject.find(child,
                        clazz,
                        file -> file.getName().equals(name)))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .findFirst()
                .orElseGet(creator);
    }
    ```,
    caption: [Metodo che sfrutta la programmazione funzionale per restituire il #c.jf cercato.],
)
Il metodo accetta in input il tipo della classe, il nome dell'oggetto ricercato e un `Supplier`~@supplier.
L'esecuzione avvia uno `Stream`~@stream sugli elementi del #glos.ns, applicando a ciascuno una ricerca tramite `find()`: questo passaggio trasforma lo `stream` iniziale in una sequenza di #c.o, dalla quale vengono scartati risultati vuoti.
Successivamente, la pipeline recupera la prima corrispondenza valida tramite `findFirst()`. Se il file viene trovato, viene restituito immediatamente; in caso contrario (se l'#c.o è vuoto), viene attivato il `Supplier` per generare e restituire una nuova istanza.

Si garantisce così che il metodo restituisca l'oggetto ricercato o ne crei uno nuovo qualora non venga trovato. Il metodo `orElseGet()` degli #c.o rappresenta un'applicazione del #glos.dep _lazy loading_, che differisce dal tradizionale `orElse()` per l'uso di un `Supplier` che viene invocato solo se l'#c.o è vuoto. Questo approccio consente di ritardare la creazione di un oggetto fino al momento in cui è effettivamente necessario, rendendo il sistema leggermente più efficiente in termini di memoria~@lazy-loading@lazy-loading-ex.

La funzione appena mostrata è applicata in numerosi metodi di utilità per inserire rapidamente elementi in dizionari o liste #glos.json, uno dei quali è riportato nel frammento di codice seguente.
#figure(
    ```java
    public static void addTranslation(Namespace namespace, Locale locale, String key, String value) {
          String formattedLocale = LocaleUtils.formatLocale(locale);
          JsonObject content = getOrCreateJsonFile(namespace,
                  Lang.class,
                  formattedLocale,
                  () -> Lang.f.ofName(formattedLocale, "{}")
          ).getContent();
          content.addProperty(key, value);
      }
    ```,
    caption: [Applicazione del metodo `getOrCreateJsonFile()`],
)

Questo metodo si occupa di aggiungere una nuova traduzione per un determinato #c.l~@locale (lingua). La traduzione è rappresentata da una coppia chiave-valore, in cui la chiave identifica in modo univoco la componente testuale, e il valore ne specifica la traduzione per il #c.l indicato.
Il metodo ottiene il contenuto JSON del file `lang` corrispondente al #c.l richiesto. Successivamente vi aggiunge la coppia chiave-valore.
Nel caso in cui il file non esista ancora (ad esempio, alla prima esecuzione per quel #c.l), esso viene creato tramite la #glos.f, garantendo comunque l'esistenza del file di traduzione prima dell'inserimento dei dati.

Un'altra applicazione simile sono le funzioni `setOnTick()` e `setOnLoad()`, che permettono di aggiungere o un'intera `Function` o una stringa contenente comandi alla lista di funzioni da eseguire ogni _tick_ o ad ogni caricamento dei file.

=== Sistema di Recupero delle Versioni

Nel `Builder` di #c.p, in base alla versione di gioco specificata, si ottengono i valori del _pack format_ per #glos.dp e #glos.rp.
Questi sono memorizzati in un `Record`~@record chiamato `VersionInfo`.

Quando il `Builder` esegue `VersionUtils.getVersionInfo(String versionKey)`, dove `versionKey` rappresenta il nome della versione (ad esempio `25w05a`), sono eseguiti i seguenti passi:
+ si controlla che sia presente nel _path_ del progetto `resources/_generated` il file `versions.json` contenente tutte le versioni e i format associati;
+ si controlla che sia passato più di un giorno dall'ultima volta che è stato scritto `versions.json`;
+ se il file non è presente oppure è passato più di un giorno dall'ultima volta che è stata eseguita la generazione del file, e dunque c'è la possibilità che sia stata pubblicata una nuova versione o _snapshot_, si ricrea il file;
+ il file viene letto e convertito nel #c.jo corrispondente;
+ qualora `versionKey` coincida con `"latest"`, indicando la necessità di recuperare la versione più recente, si istanzia un `Iterator`#footnote[L'utilizzo dell'`Iterator` è indispensabile per accedere al primo elemento, poiché l'interfaccia `Set` non supporta l'accesso posizionale diretto (es. `getFirst()`).] sulla collezione di #c.jo. Il primo elemento estratto viene quindi convertito nel `Record` `VersionInfo`;
+ se `versionKey` corrisponde al nome di una versione, viene restituito l'oggetto `VersionInfo` corrispondente alla chiave richiesta. Questo conterrà i _pack format_ richiesti da #glos.dp e #glos.rp.

La generazione di `versions.json` avviene mediante una chiamata HTTP~@http verso un'API~@api dedicata, la quale restituisce un oggetto #glos.json contenente i dati completi di tutte le versioni disponibili.\
Queste vengono poi mappate al nome della versione corrispondente e ordinate dalla più recente alla più vecchia. La mappa così creata è avvolta in un #c.o. Se quest'ultimo è vuoto verrà sollevato un errore, altrimenti si scriverà la mappa sul file `versions.json`.

=== Sistema di Compressione e Distribuzione

_Datapack_ e #glos.rp vengono letti ed eseguiti dal compilatore di #glos.mc anche se compressi in archivi `.zip`. Questo formato è particolarmente adatto alla distribuzione, poiché permette di offrire agli utenti due pacchetti leggeri e separati da scaricare.\
La classe #c.p dispone di un metodo `buildZip()` che, dopo aver creato delle cartelle #glos.dp e #glos.rp temporanee tramite il metodo `build()`, provvede a comprimerle generando i rispettivi archivi `.zip`. Al termine dell'operazione, le cartelle temporanee vengono eliminate.

Il metodo `zipDirectory()` si occupa di comprimere il contenuto di una cartella in un archivio `.zip`.
Questo esplora tutte le sottocartelle e file presenti nel percorso specificato, aggiungendo ciascun file all'archivio di destinazione.
Per fare ciò utilizza il metodo `Files.walk(folder)`, che genera uno `stream` di tutti i percorsi contenuti nella cartella, escludendo quelli relativi a cartelle.
Per ogni file trovato, viene calcolato il percorso relativo rispetto alla cartella base (`basePath`), in modo che all'interno dell'archivio venga mantenuta la stessa struttura del progetto originale.\
Per ogni file trovato, il metodo istanzia una nuova _entry_ ZIP, ovvero il contenitore che rappresenta il file all'interno dell'archivio.
Per riempirla con i dati effettivi, viene aperto uno `stream` di lettura sul file sorgente: il contenuto viene quindi inserito nell'archivio tramite la classe `IOUtils`~@io-utils di _Apache Commons_, dopodiché l'_entry_ viene chiusa per indicare che la scrittura del file è stata completata.

Il metodo `buildZip()` è stato pensato per essere usato in concomitanza con un _workflow_~@workflows di GitHub che, qualora il progetto abbia una _repository_ associata, costruisce le cartelle compresse di #glos.dp e #glos.rp ogni volta che viene creata una nuova _release_~@release. Questi archivi, al fine di evitare confusione tra le versioni, vengono automaticamente nominati con la versione specificata nel file `pom.xml`~@pom del progetto Java e saranno scaricabili dalla pagina GitHub che contiene gli artefatti associati alla _release_.

== Implementazione del Working Example

Questa sezione illustra lo sviluppo di un progetto dimostrativo che sfrutta la libreria per creare un #glos.pack finalizzato alla modifica di un _item_ in #glos.mc.
La meccanica implementata prevede che, al clic del tasto destro, l'oggetto consumi una delle tre munizioni disponibili (introdotte come nuovi _item_) per generare un'onda sinusoidale, la cui lunghezza dipende dalla specifica munizione utilizzata.

Viene innanzitutto creato il progetto:
#figure(```java
Project myProject = new Project.Builder()
    .projectName("esempio")
    .version("1.21.10")
    .worldName("OOPack test world")
    .icon("icona")
    .description("esempio tesi")
    .addBuildPath("C:/Users/Ale/AppData/Roaming/.minecraft")
    .build();
```)

In seguito si dichiara il #glos.ns da utilizzare:
#figure(```java
Namespace namespace = Namespace.of("esempio");
```)

Viene poi scritto il modulo `Munizioni`, che definisce il codice e le risorse degli oggetti consumabili. L'_item_ munizione non ha comportamenti propri, tuttavia dispone di una ricetta per poter essere creato a partire da altri _item_. Dunque, un metodo `make()` crea le 3 munizioni diverse in base ai valori primitivi passati.
#figure(```java
@Override
protected void content() {
  make("blue_ammo", "Munizione Blu", "Blue Ammo", "diamond",20);
  make("green_ammo", "Munizione Verde", "Green Ammo", "emerald",25);
  make("purple_ammo", "Munizione Viola", "Purple Ammo", "amethyst_shard",30);
}
```)

I parametri passati al metodo sono, nell'ordine: l'ID interno dell'_item_, la sua traduzione in Italiano, la sua traduzione in Inglese, l'ID di un altro _item_ necessario per la sua creazione, e la distanza in blocchi del raggio generato dall'onda.

Il metodo `make()`, oltre ad aggiungere le traduzioni tramite i metodi di utilità,
#figure(```java
Util.addTranslation("item.esempio.%s".formatted(id), en);
Util.addTranslation(Locale.ITALY, "item.esempio.%s".formatted(id), it);
```)

crea i file relativi all'aspetto visivo dell'_item_.

#figure(
    local(
        annotations: (
            (
                start: 1,
                end: 7,
                content: block(
                    width: 2em,
                    rotate(-90deg, reflow: true, align(center)[Item Model Definition]),
                ),
            ),
            (
                start: 8,
                end: 14,
                content: block(
                    width: 2em,
                    rotate(-90deg, reflow: true, align(center)[Modello 3D]),
                ),
            ),
            (
                start: 15,
                end: 15,
                content: block(
                    width: 2em,
                    rotate(-90deg, reflow: true, align(center)[Texture]),
                ),
            ),
        ),
        ```java
        Item.f.ofName(id,"""
                {
                  "model": {
                    "type": "minecraft:model",
                    "model": "%s"
                  }
                }
                """, Model.f.ofName("item/","""
                {
                	"parent": "item/generated",
                	"textures": {
                		"layer0": "%s"
                	}
                }
                """, Texture.of("item/"+id)
            )
        );
        ```,
    ),
)
La funzione `makeData()` si occupa di creare la _recipe_, ovvero il file #glos.json che indica gli ingredienti richiesti per creare l'oggetto munizione e le sue proprietà, tra cui la distanza dell'onda. Oltre alla _recipe_, è creato un _advancement_ che si è soliti usare per rilevare quando un giocatore possiede uno degli ingredienti richiesti per la creazione dell'oggetto, e dunque comunicare tramite un messaggio sullo schermo che la ricetta è disponibile.

Il modulo `MostraRaggio` si occupa di aggiungere comportamenti all'oggetto `carrot_on_a_stick`#footnote[`carrot_on_a_stick` è l'unico _item_ che possiede una #glos.score in grado di rilevare quando è cliccato con il tasto destro.], per renderlo in grado di consumare le munizioni sopra create e mostrare l'onda.

Viene innanzitutto invocata una funzione che genera la _lookup table_ contenente i valori necessari alla costruzione dell'onda.
Questa memorizza i risultati della funzione seno per gli angoli da $0degree$ a $360degree$ moltiplicati per 10, in modo da rendere l'onda più marcata.

#figure(
    cetz.canvas({
        plot.plot(size: (10, 2), axis-style: "school-book", y-tick-step: 1, {
            plot.add(domain: (0, 360), samples: 200, it => calc.sin(it / 10))
        })
    }),
    caption: [Rappresentazione dei valori memorizzati nella _lookup table_.],
)
#figure(```java
private void makeSinLookup() {
    StringBuilder sin = new StringBuilder("data modify storage esempio:storage sin set value [");
    for (int i = 0; i <= 360; i++) {
        sin.append("{value:").append(Math.sin(Math.toRadians(i * 10))).append("},");
    }
    sin.append("]");
    Util.setOnLoad(Function.f.of(sin.toString()));
}
```)

Successivamente si creano le #glos.score utili al funzionamento del progetto. La #glos.score `click` ha la particolarità di essere automaticamente incrementata ogni volta che il giocatore clicca il tasto destro del mouse, mentre `var` è usata per le operazioni matematiche.

#figure(```java
Util.setOnLoad(Function.f.of("""
  scoreboard objectives add $ns$.click minecraft.used:minecraft.warped_fungus_on_a_stick
  scoreboard objectives add $ns$.var dummy
  """));
```)

Il funzionamento dell'_item_ è implementato con una catena di funzioni annidate. Alla radice c'è una funzione che ogni _tick_ esegue la funzione (@ex-1) che sarà passata come `varargs` della factory, la quale sostituirà `%s`.

#figure(
    local(
        number-format: numbering.with("1"),
        skips: ((3, 44),),
        ```java
        var tick = Function.f.of("""
          execute as @a at @s run function %s""",
        );
        Util.setOnTick(tick);
        ```,
    ),
    caption: [],
)

La funzione di seguito riportata invoca @ex-2 se il giocatore ha cliccato l'_item_, e in seguito azzera il valore della #glos.score per evitare che nel prossimo _tick_ venga eseguita nuovamente la funzione anche se l'_item_ non è stato usato.

#figure(
    ```java
    Function.f.of("""
      execute if score @s $ns$.click matches 1.. run function %s
      scoreboard players reset @s $ns$.click
    """,
    ```,
    caption: [],
) <ex-1>

I seguenti comandi si occupano di controllare se il giocatore possiede _item_ identificati come `ammo`. In caso negativo viene bloccato il flusso di esecuzione, e in caso positivo viene invocata una funzione il cui contenuto è costruito tramite @ex-3, per ottenere i dati relativi alla prima munizione individuata nell'inventario del giocatore. Se è stata trovata una munizione, viene eseguito @ex-4.

#figure(
    ```java
    Function.f.of("""
      execute unless items entity @s container.* *[minecraft:custom_data~{$ns$:{ammo:1b}}] run return fail
      data remove storage $ns$:storage item
      function %s
      execute if data storage $ns$:storage item run function %s
      """,
    ```,
    caption: [],
) <ex-2>

Il metodo seguente genera i comandi per controllare i 36 _slot_ del giocatore. L'esecuzione di quest'ultimi viene arrestata appena viene individuato il primo _item_ contrassegnato come `ammo` e memorizzato in uno #glos.str.

#figure(
    ```java
    private String getSlot() {
      var slots = new StringBuilder();
        for (int i = 0; i <= 35; i++) {
          slots.append("""
            execute if items entity @s container.%1$s *[minecraft:custom_data~{$ns$:{ammo:1b}}] run return run data modify storage $ns$:storage item set from entity @s Inventory[{Slot:%1$sb}]""".formatted(i));
        }
        return slots.toString();
    }
    ```,
    caption: [],
) <ex-3>

Se l'_item_ è stato trovato, vengono eseguiti i seguenti comandi:
+ @ex-4\-2: salva la distanza associata alla munizione nello _score_ `distance`;
+ @ex-4\-3: viene riprodotto un suono. Tramite il metodo di utilità `addSound()` questo è aggiunto al dizionario di `sounds.json` e `Sound.of()` si occupa di prelevare il file `.ogg` al _path_ indicato;
+ @ex-4\-4: chiama una funzione _macro_ che elimina la munizione trovata dallo _slot_ corrispondente;
+ @ex-4\-5: sposta l'esecuzione della funzione all'altezza degli occhi del giocatore, e invoca @ex-5.
#figure(
    local(
        number-format: numbering.with("1"),
        ```java
        Function.f.of("""
          execute store result score $distance $ns$.var run data get storage $ns$:storage item.components."minecraft:custom_data".$ns$.distance 10
          playsound %s player @a[distance=..16]
          function %s with storage $ns$:storage item.components."minecraft:custom_data".$ns$
          execute anchored eyes positioned ^ ^ ^ run function %s
        """, Util.addSound(
          "item.%s".formatted(id),
          "Beam Sparkles",
          Sound.of("item/%s".formatted(id)
        )
        ```,
    ),
    caption: [],
)<ex-4>

La seguente funzione rappresenta il nucleo della logica ricorsiva per creare l'onda.
Essa decrementa lo _score_ `distance`, e memorizza l'esito di questa operazione in uno #glos.str. Se ancora non si è raggiunta la distanza massima, ovvero `$ns$.var matches 1..` ($"var">=1$) si sposta l'esecuzione 0.1 blocchi in avanti e si ripete la funzione.\
@ex-5\-4 invoca la funzione @ex-6, passando l'indice dell'iterazione corrente come parametro.

#figure(
    local(
        number-format: numbering.with("1"),
        ```java
        Function.f.of("""
          scoreboard players remove $distance $ns$.var 1
          execute store result storage $ns$:storage distance.amount int 1 run scoreboard players get $distance $ns$.var
          function %s with storage $ns$:storage distance
          execute if score $distance $ns$.var matches 1.. positioned ^ ^ ^0.1 run function $ns$:$name$
        """)
        ```,
    ),
    caption: [],
) <ex-5>

Questa funzione contiene un solo comando _macro_, che invoca un'ulteriore funzione _macro_, passandole il valore corrispondente a $sin(#raw("amount") times 10)$.

#figure(
    ```java
    Function.f.of("""
      $function %s with storage esempio:storage sin[$(amount)]
    """
    ```,
    caption: [],
) <ex-6>

Impostando la posizione verticale relativa della _particle_ con questo valore, si ottiene la rappresentazione visiva di un'onda sinusoidale.

#figure(
    ```java
    Function.f.of("""
      $particle flame ^ ^$(value) ^
    """)
    ```,
    caption: [],
) <ex-7>

Successivamente i due moduli vengono registrati:
#figure(```java
Module.register(
  MostraRaggio.class,
  Munizioni.class
);
```)

Uscendo dal #glos.ns corrente, esso viene aggiunto indirettamente al progetto.
Quest'ultimo viene costruito e generato in formato `.zip`:

#figure(```java
namespace.exit();
myProject.buildZip();
```)

#e dunque possibile creare una _repository_ e pubblicare una _release_. In seguito una _GitHub action_ esegue il progetto per generare le due cartelle compresse e rinominarle. In questo caso sono chiamate
`datapack-esempio-1.0.0.zip` e `resourcepack-esempio-1.0.0.zip`. Queste sono immediatamente scaricabili e utilizzabili dai giocatori.

= Conclusione

Il presente lavoro di tesi ha affrontato le criticità relative allo sviluppo di contenuti per #glos.mc attraverso il _Domain Specific Language_ nativo #glos.mcf.
L'analisi preliminare ha rivelato come questo linguaggio, nonostante sia dotato di _feature_ affini a quelle dei linguaggi _general purpose_, imponga severi vincoli strutturali e sintattici.
La mancanza di costrutti ad alto livello, combinata con l'obbligo di separare ogni funzione e risorsa in un file distinto, genera codice prolisso, frammentato e difficilmente manutenibile.

Per superare tali limitazioni, è stata progettata e implementata una libreria Java (_OOPACK_) che introduce un approccio orientato agli oggetti per consentire la meta-programmazione di #glos.pack.

La soluzione proposta astrae la struttura di #glos.dp e #glos.rp in un albero di oggetti tipizzati, consentendo agli sviluppatori di definire molteplici risorse all'interno di un unico contesto e di sfruttare i costrutti di un linguaggio _general purpose_.
Con l'automazione della scrittura di _boilerplate_ e fornendo validazione a tempo di compilazione, il framework riduce drasticamente la complessità di gestione dei file e aumenta la densità di codice, offrendo un ambiente di sviluppo più robusto e scalabile rispetto agli strumenti tradizionali.

Al fine di misurare concretamente l'efficienza della libreria, è stata sviluppata una classe `Metrics` con il compito di registrare il numero di righe e di file generati.
Eseguendo il progetto Java associato al _working example_, si nota che il numero di file prodotti è 31, con un totale di 307 righe di codice.

Il codice sorgente del progetto è invece strutturato nei seguenti file Java#footnote[I valori riportati sono arrotondati al multiplo di dieci inferiore, al fine di escludere eventuali righe vuote o commenti.]:
#figure(table(
    columns: (1fr,) * 2,
    [*Classe*], [*Righe di codice*],
    [`Main.java`], [30],
    [`MostraRaggio.java`], [90],
    [`Munizione.java`], [100],
))
Per un totale di 220 righe di codice in 3 file.
Confrontando i due valori, si nota che il numero di file generati è pari a oltre dieci volte quello dei file sorgente.
Le righe prodotte sono il 40% in più di quelle dei file sorgente.

Prendendo come riferimento un esempio più articolato, tratto da un progetto personale che mira a inserire nuove piante nel gioco, sono presenti i seguenti file:
#figure(table(
    columns: (1fr,) * 2,
    [*Classe*], [*Righe di codice*],
    [`Main.java`], [170],
    [`Seeds.java`], [140],
    [`Misc.java`], [20],
    [`Interaction.java`], [100],
    [`Heal.java`], [90],
    [`BloomingBulb.java`], [290],
    [`Bloomguard.java`], [90],
    [`EtchedVase.java`], [300],
    [`Blocks.java`], [160],
))

Eseguendo il programma, a partire da 9 file contenenti complessivamente 1360 righe di codice, vengono generati 137 file per un totale di 2451 righe.

Il seguente grafico mette in relazione il numero di righe e file prodotti per il _working example_ ($P_1$) e il progetto appena citato ($P_2$).

#figure(
    cetz.canvas({
        import cetz.draw: *
        plot.plot(
            name: "plot",
            size: (10, 6),
            x-min: 0,
            y-min: 0,
            x-label: [file],
            y-label: [righe],
            x-tick-step: 10,
            y-tick-step: 250,
            axis-style: "school-book",
            {
                plot.add(((3, 220), (9, 1360)), label: [Libreria _OOPACK_])
                plot.add(((31, 307), (137, 2451)), label: [Approccio tradizionale])
                plot.add(((3, 220), (31, 307)), style: (stroke: (paint: black, thickness: 1pt, dash: "dashed")))
                plot.add(((9, 1360), (137, 2451)), style: (stroke: (paint: black, thickness: 1pt, dash: "dashed")))

                plot.add-anchor("d1", (17, 300))
                plot.add-anchor("d2", (60, 1800))

                plot.add-anchor("p1o", (3, 220))
                plot.add-anchor("p1t", (31, 307))
                plot.add-anchor("p2o", (9, 1360))
                plot.add-anchor("p2t", (137, 2451))
            },
        )
        circle("plot.p1o", radius: 0.02, fill: black, name: "p1o")
        content("p1o.end", [$P_1^o$], anchor: "north", padding: .1)

        circle("plot.p1t", radius: 0.02, fill: black, name: "p1t")
        content("p1t.end", [$P_1^t$], anchor: "south", padding: .1)

        circle("plot.p2o", radius: 0.02, fill: black, name: "p2o")
        content("p2o.end", [$P_2^0$], anchor: "south", padding: .1)

        circle("plot.p2t", radius: 0.02, fill: black, name: "p2t")
        content("p2t.end", [$P_2^t$], anchor: "south", padding: .1)
        content("plot.d1", [$d_1$], anchor: "south", padding: .1)
        content("plot.d2", [$d_2$], anchor: "south", padding: .1)
    }),
    caption: [Numero di righe e file richiesti a confronto.],
)

Calcolando il rapporto tra le componenti dell'asse delle ascisse, ovvero il numero dei file impiegati, per $P_1$ si nota che $31/3=10,3$: ogni file sorgente genera dunque circa 10,3 file di output.
Eseguendo la medesima operazione per $P_2$ si ottiene invece $137/9 = 15,2$. Da questi dati si deduce che la libreria è dotata di "economie di scala positive": maggiore è la portata del progetto, più elevata è la quantità di file gestita automaticamente per ogni singola unità di codice scritta dallo sviluppatore.\
Si può osservare, inoltre, come la linea blu relativa ai progetti sviluppati con la libreria presenti una pendenza maggiore, a dimostrazione di un'elevata densità di contenuti per singolo file sorgente.

Il vantaggio di utilizzare la libreria risulta particolarmente evidente nei progetti di ampia scala quali $P_2$: una volta superata la fase iniziale in cui è necessario implementare metodi specifici per il progetto da sviluppare, diventa immediato sfruttare la libreria per automatizzare la creazione di file con contenuti affini.

Interpretando la distanza tra il punto di partenza (sorgente) e quello di arrivo (output) come una stima del carico di lavoro automatizzato dalla libreria, è evidente che automatizzare lo sviluppo sia vantaggioso per i progetti di scala maggiore.
#let dist(p1x, p2x, p1y, p2y) = $sqrt((p1x-p2x)^2+(p1y-p2y)^2)$
Per il progetto minore $P_1$, la distanza è $d_1=dist(3, 31, 220, 307)=91,4$. Per il progetto maggiore $P_2$, tale valore sale a $d_2=dist(9, 137, 1360, 2451)=1098,5$.

Se si misura la densità di codice del singolo progetto, denominata $p$, come il rapporto tra le sue righe totali e file totali, si vedrà che $p(P_1)=73,7$ e $p(P_2)=151,1$.\
Confrontando le densità di codice $p$, si nota che con un raddoppio della densità nel progetto più grande ($p(P_2) approx 2 dot p(P_1)$), il beneficio dell'automazione $d$ cresce di un fattore 12 ($d_2/d_1 approx 12$).
Ciò suggerisce che l'efficienza della libreria non scala linearmente, ma aumenta in modo significativo all'aumentare della complessità del progetto, ammortizzando rapidamente il costo iniziale di configurazione.

Va tuttavia evidenziato che l'utilizzo della libreria richiede un considerevole sforzo cognitivo, dovuto alla necessità di operare simultaneamente con due linguaggi diversi per sfruttare appieno le potenzialità di entrambi.

Si riconosce inoltre la possibilità di estendere la libreria con ulteriori metodi di utilità, potenzialmente più specifici ma comunque in grado di ridurre il carico di lavoro per lo sviluppatore.
Per esempio, si potrebbe implementare un metodo che, dati uno o più valori costanti in input, crei la funzione contenente i comandi `scoreboard` con il compito di inizializzare i valori delle costanti #glos.score.
Un'altra possibile implementazione riguarda la generazione automatizzata di _lookup table_: un metodo dedicato potrebbe ricevere in input una funzione lambda e utilizzarne i valori di ritorno per costruire il comando di inizializzazione della struttura dati.

Oltre alle competenze tecniche acquisite, la durata prolungata dello sviluppo ha offerto l'opportunità di riconsiderare e affinare l'architettura iniziale.
#e stato possibile intervenire su porzioni di codice formalmente corrette ma subottimali, migliorandone le performance e l'utilizzo per l'utente finale.
Questa revisione costante ha consolidato un approccio critico all'ingegneria del software, valorizzando aspetti quali la manutenibilità del codice e la _user experience_.
