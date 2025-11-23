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
    department: "dipartimento di scienza e ingegneria",
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
        La _Domain Specific Language_ (_DSL_) del videogioco svedese Minecraft, #glos.mcf, consente la creazione di pacchetti di contenuti modulari, denominati #glos.pack, in grado di modificare o aggiungere meccaniche di gioco. Nonostante il suo ampio utilizzo, questo linguaggio presenta notevoli limitazioni strutturali e sintattiche: ogni funzione deve essere definita in un file separato e non dispone di costrutti quali variabili, istruzioni condizionali e meccanismi di iterazione. Questi vincoli producono codice prolisso e ripetitivo, compromettendo la leggibilità e la manutenibilità nei progetti di ampia scala.

        Per superare tali problemi, questa tesi propone una libreria Java sviluppata durante il tirocinio accademico che, a partire da un'analisi approfondita delle carenze e difetti di #glos.mcf, giunge alla formulazione di un'astrazione che rappresenta la struttura di un #glos.pack come un albero di oggetti tipizzati. Sfruttando la sintassi standard di Java e _factory methods_, la libreria consente la generazione programmatica dei #glos.pack, offrendo zucchero sintattico e utilità che semplificano l'accesso ai file di risorse principali. L'approccio proposto sfrutta il sistema di tipi di Java per fornire validazione statica, supporta la definizione di più risorse all'interno di un singolo file sorgente e automatizza la generazione di _boilerplate_, eliminando così la necessità di preprocessori esterni o di sintassi ibride adottate in soluzioni alternative.

        Un _working example_ conferma l'approccio scelto: nel #glos.pack di esempio il codice scritto è ridotto del 40%, consolidando 31 file in 3 file sorgente, con miglioramenti significativi in termini di densità del codice e manutenibilità del progetto.
    ],
    final: true,
    locale: "it",
    bibliography_file: "bib.yaml",
)

= Introduzione
Se non fosse per il videogioco #glos.mc~@minecraft, non sarei qui ora. Quello che per me nel 2014 era un modo di esprimere la mia creatività costruendo bizzarre strutture a cubi in un mondo virtuale, si è rivelato presto essere l'ambiente dove per anni ho scritto ed eseguito i miei primi frammenti di codice utilizzando il suo sistema di comandi.\
Motivato dalla mia acquisita abilità nel saper programmare con questo linguaggio di scripting non convenzionale, ho intrapreso con entusiasmo un percorso di studi in informatica.

Creato nel 2009 dallo svedese Markus Persson e sviluppato nel 2011 dall'azienda Mojang Studios~@mojang #glos.mc è un famoso videogioco tridimensionale appartenente al genere _sandbox_~@sandbox, cioè caratterizzato dall'assenza di una trama predefinita, dove è il giocatore stesso a costruire liberamente la propria esperienza e gli obiettivi da perseguire.\
Il gioco presenta un mondo composto da cubi formati da _voxel_ (controparte tridimensionale del pixel) generati proceduralmente, dove i giocatori possono raccogliere risorse, costruire strutture, creare oggetti e affrontare creature ostili.

#glos.mc è diventato il videogioco più venduto al mondo, perché non è semplicemente un prodotto di intrattenimento, ma un ambiente flessibile, accessibile, continuamente ampliato e sostenuto da una community globale che lo ha trasformato in un fenomeno culturale trasversale.
#figure(image("assets/image.png"),caption: [Un mondo di #glos.mc.])

Fin dalle sue origini, i creatori di #glos.mc hanno messo a disposizione dei giocatori un insieme di comandi~@command che consentiva di aggirare gli ostacoli incontrati nella propria esperienza di gioco.\
Con il tempo, tale sistema si è evoluto in un articolato linguaggio di configurazione e scripting basato su file testuali, costituendo di fatto una _Domain Specific Language_~@dsl (_DSL_) mediante la quale sviluppatori di terze parti possono modificare numerosi aspetti e comportamenti dell'ambiente di gioco.

Con _Domain Specific Language_ si intende un linguaggio di programmazione progettato per un ambito applicativo specifico, caratterizzato da un livello di astrazione più elevato e una sintassi semplificata rispetto ai linguaggi _general purpose_#footnote[Un linguaggio _general purpose_ (o "a scopo generale"), come Java, C++ o Python, è progettato per risolvere un'ampia varietà di problemi in diversi domini applicativi.]. Le DSL sono sviluppate in coordinazione con esperti del campo nel quale verrà utilizzato il linguaggio.
#quote(
    attribution: [JetBrains],
    block: true,
)[In many cases, DSLs are intended to be used not by software people, but instead by non-programmers who are fluent in the domain the DSL addresses.]

Questa definizione fornita dagli sviluppatori di JetBrains, azienda olandese specializzata nella creazione di ambienti di sviluppo integrati (_Integrated Development Environments_, IDE), descrive perfettamente chi sono gli utilizzatori della _domain specific language_ di #glos.mc.

#glos.mc è sviluppato in Java~@java-book, ma questa DSL, chiamata #glos.mcf~@mc-function, adotta un paradigma completamente diverso.
Essa non consente di introdurre nuovi comportamenti intervenendo direttamente sul codice sorgente del gioco.
Le funzionalità aggiuntive vengono invece definite attraverso gruppi di comandi testuali, interpretati dal motore interno di #glos.mc (e non dal compilatore Java) ed eseguiti solo al verificarsi di determinate condizioni.
In questo modo l'utente percepisce tali funzionalità come parte integrante dei contenuti originali del gioco.
Negli ultimi anni, grazie all'introduzione e all'evoluzione di file in formato #glos.json~@json in grado di modificare componenti precedentemente inaccessibili, è progressivamente diventato possibile creare esperienze di gioco sempre più complesse e originali.
Tuttavia, il sistema presenta ancora diverse limitazioni, poiché una parte sostanziale della logica continua a essere implementata attraverso i file #glos.mcf, meno versatili rispetto a Java.

Il tirocinio accademico ha avuto come obiettivo la progettazione e realizzazione di un framework che semplifica lo sviluppo e la distribuzione di gruppi di file #glos.mcf e #glos.json tramite un ambiente di sviluppo unificato.
Tale framework consiste in una libreria Java che permette di definire la gerarchia dei file in un sistema ad albero tramite oggetti.
Una volta definite tutte le funzionalità, viene eseguito il programma per ottenere una cartella "pacchetto" (#glos.pack) pronta per essere utilizzata.
In questo modo lo sviluppo del pacchetto risulta più coerente e accessibile, permettendo di integrare _feature_ di Java in questa DSL che facilitano la scrittura e la gestione dei file.

Nel capitolo successivo viene presentata la struttura generale del sistema di #glos.pack, descrivendone gli elementi costitutivi e il loro funzionamento. Segue un'analisi sistematica delle principali problematiche e limitazioni tecniche dell'infrastruttura, corredata da una rassegna critica delle più recenti soluzioni proposte. Viene quindi illustrata la progettazione e l'implementazione della libreria sviluppata, accompagnata da un caso d'uso concreto (_working example_) che ne dimostra l'applicazione pratica. Il lavoro si conclude con un'analisi quantitativa e qualitativa dei risultati ottenuti, evidenziando i benefici dell'approccio proposto in termini di riduzione della complessità e miglioramento della manutenibilità del codice.

= Struttura e Funzionalità di un Pack

== Cos'è un Pack
Affinché i file #glos.json e #glos.mcf vengano riconosciuti dal compilatore di #glos.mc e integrati nel videogioco, è necessario che siano collocati in specifiche _directory_ predefinite.\
Un #glos.dp può essere paragonato alla cartella `java` di un progetto Java.
Esso contiene la parte che detta la logica dell'applicazione.

I progetti Java sono dotati di una cartella `resources`~@java-resource. Similmente, #glos.mc dispone di una cartella in cui dichiarare le risorse da utilizzare.
Questa si chiama #glos.rp~@resourcepack, e contiene principalmente font, modelli 3D, #glos.tex~@game-texture, traduzioni e suoni.\
Con l'eccezione di #glos.tex e suoni, i quali richiedono l'estensione `png`~@png e `ogg`~@ogg rispettivamente, tutti gli altri file sono in formato #glos.json.\
Le #glos.rp sono state concepite e rilasciate prima dei #glos.dp, con lo scopo di dare ai giocatori la possibilità di sovrascrivere le #glos.tex e altri _asset_~@assets del videogioco per renderle più affini ai propri gusti. Gli sviluppatori di #glos.dp hanno poi iniziato ad utilizzare #glos.rp per definire le risorse che il loro progetto avrebbe impiegato.
Le #glos.rp hanno portata globale e vengono applicate a tutti i _save file_, ovvero su ogni mondo creato. Le cartelle #glos.dp, invece, devono essere collocate nella directory `datapack` dei mondi nei quali si desidera utilizzarle.\
Pertanto, partendo dalla cartella radice di #glos.mc (`.minecraft/`), le #glos.rp si trovano nella directory `.minecraft/resourcepacks`, mentre i #glos.dp sono posizionati in `.minecraft/saves/<world name>/datapacks`.\
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
Ad esempio, per la versione 1.21.10 del gioco, il `pack_format` dei #glos.dp è 88, mentre quello delle #glos.rp è 69. Questi valori possono variare anche settimanalmente durante il rilascio degli _snapshot_~@snapshot, ovvero versioni preliminari di sviluppo che introducono nuove funzionalità e modifiche prima del rilascio ufficiale di un aggiornamento del videogioco.

Ancora più rilevanti sono le cartelle contenute in `data` e `assets`, chiamate #glos.ns~@namespace. Se i progetti Java seguono la struttura `com.package.author`, allora i #glos.ns possono essere visti come la sezione `package`.\

#quote(
    block: true,
    attribution: [Nathan Adams#footnote[Sviluppatore di #glos.mc inglese, membro del team che sviluppa _feature_ inerenti a #glos.dp.]],
    [This isn't a new concept, but I thought I should reiterate what a "namespace" is. Most things in the game has a namespace, so that if we add `something` and a mod (or map, or whatever) adds `something`, they're both different `something`s. Whenever you're asked to name something, for example a loot table, you're expected to also provide what namespace that thing comes from. If you don't specify the namespace, we default to `minecraft`. This means that `something` and `minecraft:something` are the same thing.],
)

I #glos.ns sono fondamentali per evitare che i file omonimi di un #glos.pack sovrascrivano quelli di un altro.
Per questa ragione, in genere un #glos.ns o coincide con il nome stesso del progetto che si sta sviluppando, o è una sua abbreviazione. _Datapack_ e #glos.rp adotteranno lo stesso #glos.ns.\
Tuttavia, si vedrà che operare in #glos.ns distinti non è sufficiente a garantire l'assenza di conflitti tra #glos.pack installati contemporaneamente.

Il namespace `minecraft` è riservato alle risorse native del gioco: sovrascriverle comporta il rischio di rimuovere funzionalità originali o di alterarne il comportamento previsto.
È interessante notare come anche gli sviluppatori di #glos.mc stessi facciano uso dei #glos.dp per definire e organizzare molti comportamenti del gioco, come ad esempio la dichiarazione delle risorse ottenibili dai blocchi scavati (_loot table_), o gli ingredienti necessari per creare un certo oggetto (_recipe_).
In altre parole, i #glos.dp non sono solo uno strumento a disposizione dei giocatori per personalizzare l'esperienza, ma costituiscono anche il meccanismo interno attraverso il quale il gioco stesso struttura e gestisce alcune delle sue funzionalità principali.\
Occorre specificare che i comandi e i file `.mcfunction` non sono utilizzati in alcun modo dagli sviluppatori di #glos.mc per implementare funzionalità del videogioco, dato che tutta la logica è dettata da codice Java.

All'interno dei #glos.ns si trovano directory i cui nomi identificano in maniera univoca la natura e la funzione dei file contenuti al loro interno. Se è presente un file #glos.json nella cartella `recipe`, che non possiede una struttura comune a tutte le ricette, il compilatore solleverà un errore e il file non sarà disponibile nella sessione di gioco.

In `function` si trovano file e sottodirectory contenenti file di testo in formato #glos.mcf. Questi si occupano di far comunicare le parti di un #glos.pack tra loro tramite funzioni contenenti determinati comandi.

Per identificare univocamente le risorse all'interno di #glos.dp e #glos.rp si utilizzano le _resource location_. La loro struttura è composta da due parti separate dal carattere `:`, il #glos.ns seguito dal percorso della risorsa. Rispetto a un _path_ completo, la _resource location_ omette la cartella funzionale che categorizza il tipo di risorsa.\
Ad esempio, per riferirsi alla ricetta situata nel percorso `foo/recipe/my_item.json`, si utilizza la _resource location_ `foo:my_item`, dove `foo` è il namespace e `my_item` è l'identificatore della risorsa.
La cartella `recipe`, che indica la tipologia della risorsa, non compare nella _resource location_ poiché il compilatore determina automaticamente il tipo di risorsa in base al contesto d'uso. Se la _resource location_ viene letta in un contesto che richiede una ricetta, il compilatore cercherà il file nella cartella `recipe`; se invece il contesto richiede una funzione, cercherà nella cartella `function`.

== Comandi

Prima di spiegare la funzione dei comandi, è necessario definire gli elementi basilari su cui essi agiscono.\
#glos.mc permette di creare ed esplorare mondi generati a partire da un _seed_~@seed casuale. Ogni mondo è composto da _chunk_~@chunk, sezioni colonnari aventi base di $16 times 16$ unità e altezza di 320 unità.\
L'unità più piccola all'interno di questa griglia è il blocco, la cui forma corrisponde a quella di un cubo di lato unitario.
Ogni blocco è dotato di collisione, ed individuabile in un mondo tramite coordinate dello spazio tridimensionale.
Si definiscono entità invece tutti gli oggetti dinamici che si spostano in un mondo: sono dotate di una posizione, rotazione e velocità.

I dati persistenti di blocchi ed entità sono compressi e memorizzati in una struttura dati ad albero chiamata _Named Binary Tags_~@nbt (#glos.nbt). Il formato "stringificato", `SNBT` è accessibile agli utenti e si presenta come una struttura molto simile a #glos.json, formata da coppie di chiave e valori.\

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

Un comando è un'istruzione testuale che Minecraft interpreta per eseguire una specifica azione, come assegnare oggetti al giocatore, modificare l'ora del giorno o creare entità. Molti comandi usano selettori per individuare l'entità su cui essere applicati o eseguiti.\

#figure(
    ```mcfunction
    say @e[
      type = player
    ]
    ```,
    caption: [Esempio di comando che tra tutte le entità (`@e`), stampa quelle di tipo giocatore.],
)
Sebbene il sistema dei comandi sia privo delle funzionalità tipiche dei linguaggi di programmazione di alto livello, quali cicli `for` e `while`, strutture dati complesse o variabili generiche, esso fornisce comunque strumenti che consentono di emulare alcuni di questi comportamenti in forma limitata.
Di seguito verranno illustrati i comandi che più si avvicinano a concetti tipici di programmazione.
=== Scoreboard
Il comando `scoreboard` permette di creare dizionari di tipo `<Entità, Objective>`. Un `objective` rappresenta un valore intero a cui è associata una condizione (_criteria_) che ne determina la variazione. Il _criteria_ `dummy` corrisponde ad una condizione vuota, irrealizzabile.
Su questi valori è possibile eseguire operazioni aritmetiche semplici, quali la somma o la sottrazione di un valore prefissato, oppure le quattro operazioni aritmetiche fondamentali#footnote[Le operazioni aritmetiche fondamentali sono somma, sottrazione, moltiplicazione e divisione.] con altri `objective`.
Dunque una #glos.score può essere meglio vista come un dizionario `<Entità,<Intero, Condizione>>`.\
Prima di poter eseguire qualsiasi operazione su di essa, una #glos.score deve essere creata tramite il comando\ `scoreboard objectives add <objective> <criteria>`.\
Per eseguire operazioni che non dipendono da alcuna entità si usano i cosiddetti _fakeplayer_.  Al posto di usare nomi di giocatori o selettori, si prefiggono i nomi con caratteri illegali, quali `$` e `#`. In questo modo ci si assicura che un valore non sia associato ad un vero utente, e quindi sia sempre disponibile.
#figure(
    ```mcfunction
    scoreboard objectives add my_scoreboard dummy
    scoreboard players set #20 my_scoreboard 20
    scoreboard players set #val my_scoreboard 100
    scoreboard players operation #val my_scoreboard /= #20 my_scoreboard
    ```,
    caption: [Esempio di operazioni su una #glos.score, equivalente a `int val = 100; val /= 20;`],
)

Dunque, il sistema delle #glos.score permette di creare ed eseguire operazioni semplici esclusivamente su interi, con _scope_ globale, se e solo se fanno parte di una #glos.score dichiarata.

=== Data
Per ottenere, modificare e combinare i dati #glos.nbt associati a entità, blocchi e #glos.str si usa il comando `data`.
Come precedentemente citato, il formato #glos.nbt, una volta compresso, viene utilizzato per la persistenza dei dati di gioco.
Oltre alle informazioni relative a entità e blocchi, in questo formato vengono salvati anche gli #glos.str.
Essi sono un modo efficiente di immagazzinare dati arbitrari senza dover dipendere dall'esistenza di un certo blocco o entità.
Per prevenire i conflitti, ogni #glos.str dispone di una _resource location_, che convenzionalmente coincide con il #glos.ns. Vengono dunque salvati nel file `command_storage_<namespace>.dat` come dizionario #glos.nbt.

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
Il comando `execute` consente di eseguire un altro comando cambiando valori quali l'entità esecutrice e la posizione. Questi elementi definiscono il contesto di esecuzione: l'insieme dei parametri che determinano le modalità con cui il comando viene eseguito. Si usa il selettore `@s` per fare riferimento all'entità del contesto di esecuzione corrente.\
Tramite `execute` è possibile specificare condizioni preliminari e salvare il risultato dell'esecuzione. Dispone di 14 sottocomandi, raggruppati in 4 categorie:
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
+ sposta l'esecuzione alla loro posizione attuale (`at @s`);
+ salva l'esito della prossima istruzione nello _score_ `on_stone` di quell'entità;
+ controlla se nella posizione del contesto di esecuzione corrente, il blocco sottostante sia di tipo `stone`.
Al termine dell'esecuzione, lo _score_ `on_stone` di ogni entità sarà 1 se si trovava su un blocco di pietra, 0 altrimenti.

== Funzioni
Le funzioni sono insiemi di comandi raggruppati all'interno di un file #glos.mcf. Una funzione non può esistere se non in un file con estensione`.mcfunction`. A differenza di quanto il nome possa suggerire, non prevedono valori di input o di output, ma contengono uno o più comandi che vengono eseguiti in ordine.\

In base alla complessità del branching e alle operazioni eseguite dalle funzioni, il compilatore (o più precisamente, il motore di esecuzione dei comandi) deve allocare una certa quantità di risorse per svolgere tutte le istruzioni durante un singolo _tick_. Il tempo di elaborazione aggiuntivo richiesto per l'esecuzione di un comando o di una funzione è definito _overhead_.

Ci sono più modi in cui le funzioni possono essere invocate da altri file di un datapack:

- tramite comandi: `function namespace:function_name` esegue la funzione immediatamente, mentre `schedule namespace:function_name <delay>` la esegue dopo un intervallo di tempo specificato;
- da _function tag_: una _function tag_ è una lista in formato #glos.json contenente riferimenti a funzioni. #glos.mc ne fornisce due nelle quali inserire le funzioni da eseguire rispettivamente ogni _game loop_~@tick(`tick.json`)#footnote[Il _game loop_ di #glos.mc viene eseguito 20 volte al secondo; di conseguenza, anche le funzioni incluse nel tag `tick.json` vengono eseguite con la stessa frequenza.], e ogni volta che si ricarica da disco il datapack (`load.json`). Queste due _function tag_ sono riconosciute dal compilatore di #glos.mc solo se nel namespace `minecraft`;
- altre risorse di un #glos.dp quali ricompense di `Advancement` (obiettivi) e effetti di `Enchantment` (incantesimi).

Le funzioni vengono eseguite durante un _game loop_, completando tutti i comandi che contengono, inclusi quelli invocati altre funzioni.
Quando un comando `execute` altera il contesto di esecuzione, la modifica non influenza i comandi successivi, ma viene propagata alle funzioni chiamate a partire da quel punto.

Le funzioni possono includere linee _macro_: comandi che, preceduti dal carattere `$`, dispongono di una o più sezioni delimitate da `$(...)`, le quali vengono sostituite al momento dell'invocazione con oggetti #glos.nbt specificati nel comando invocante.

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

L'esecuzione dei comandi di una funzione può essere interrotta dal comando `return`. Funzioni che non contengono questo comando possono essere considerate di tipo `void`. Tuttavia il comando return può solamente restituire la parola chiave `fail` o un valore intero fisso.

Una funzione può essere richiamata ricorsivamente, anche modificando il contesto in cui viene eseguita. Questo comporta il rischio di creare chiamate senza fine, qualora la funzione sia invocata senza alcuna condizione di arresto. È quindi responsabilità del programmatore definire i vincoli alla chiamata ricorsiva.

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

Ogni volta che viene chiamata, questa funzione istanzia una piccola #glos.tex intangibile e temporanea(_particle_~@particle) alla posizione associata al contesto di esecuzione. Successivamente controlla se è presente un giocatore nel raggio di 10 blocchi. In caso positivo sposta il contesto di esecuzione avanti di $1/10$ di blocco e si chiama nuovamente la funzione. Quando il sotto-comando `if` fallisce, ovvero non c'è nessun giocatore nel raggio di 10 blocchi, la funzione non sarà più eseguita.

Un linguaggio di programmazione si definisce Turing completo~@turing-complete se soddisfa tre condizioni fondamentali:
+ Presenta rami condizionali: deve poter eseguire istruzioni diverse in base a una condizione logica. Nel caso di #glos.mcf, ciò è realizzabile tramite il sotto-comando `if`.
+ #e dotato di iterazione o ricorsione: deve consentire la ripetizione di operazioni. In questo linguaggio, tale comportamento è ottenuto attraverso l'utilizzo di funzioni ricorsive.
+ Permette la memorizzazione di dati: deve poter gestire una quantità arbitraria di informazioni. In #glos.mcf, ciò avviene tramite la manipolazione dei dati all'interno dei #glos.str.

Pertanto, #glos.mcf può essere considerato a tutti gli effetti un linguaggio Turing completo. Tuttavia, come verrà illustrato nella sezione successiva, sia il linguaggio stesso sia il sistema di file su cui si basa presentano diverse limitazioni e inefficienze.

In particolare, l'implementazione di funzionalità relativamente semplici richiede un numero considerevole di righe di codice e di file, che in un linguaggio di più alto livello potrebbero essere realizzate in maniera molto più coincisa.

= Problemi Pratici e Limiti Tecnici

Il linguaggio #glos.mcf non è stato originariamente concepito come un linguaggio di programmazione Turing completo.
Infatti, negli anni antecedenti dell'introduzione dei #glos.dp, il comando `scoreboard` veniva utilizzato secondo l'uso previsto dagli sviluppatori, ossia per monitorare le statistiche dei giocatori, quali il tempo di gioco o il numero di blocchi scavati.
Gli sviluppatori di #glos.mc osservarono come questo e altri comandi venivano impiegati dalla comunità per creare nuove meccaniche e giochi rudimentali, e hanno dunque aggiornato progressivamente il sistema, fino ad arrivare, nel 2017 alla nascita dei #glos.dp.

Ancora oggi l'ecosistema dei #glos.dp è in costante evoluzione, con _snapshot_ che introducono nuove funzionalità o ne aggiornano di già esistenti.
Tuttavia, questo ambiente presenta ancora diverse limitazioni di natura tecnica, riconducibili al fatto che non era stato originariamente concepito per supportare logiche di programmazione complesse o per essere impiegato in progetti di grandi dimensioni.

== Limitazioni di Scoreboard
Come è stato precedentemente citato, `scoreboard` è usato per eseguire operazioni su interi. Tuttavia, questo comando presenta numerosi vincoli.

Dopo aver creato un _objective_, è necessario impostare le costanti da utilizzare per le eventuali operazioni di moltiplicazione e divisione.
Inoltre, è ammessa una sola operazione per comando `scoreboard`.

Di seguito viene mostrato come l'espressione `int x = (y*2)/4-2` si calcola in #glos.mcf. Le variabili saranno prefissate da `$`, e le costanti da `#`.

#figure(
    local(
        annotations: (
            (
                start: 4,
                end: 7,
                content: block(
                    width: 2em,
                    rotate(-90deg, reflow: true, align(center)[Operazioni su `$y`]),
                ),
            ),
        ),
        ```mcfunction
        scoreboard objectives add math dummy
        scoreboard players set $y math 10
        scoreboard players set #2 math 2
        scoreboard players set #4 math 4
        scoreboard players operation $y math *= #2 math
        scoreboard players operation $y math /= #4 math
        scoreboard players remove $y math 2
        scoreboard players operation $x math = $y math
        ```,
    ),
    caption: [Esempio con $y=10$],
)<scoreboard_set_const>
Qualora non fossero stati impostati i valori di `#2` e `#4`, il compilatore li avrebbe valutati con valore 0 e l'espressione non sarebbe stata corretta.

Si noti come, nell'esempio precedente, le operazioni vengano eseguite sulla variabile $y$, il cui valore risultante viene successivamente assegnato a $x$.
Di conseguenza, sia `$x` che `$y` conterranno il risultato finale pari a 3. Questo implica che il valore di $y$ viene modificato, a differenza dell'espressione a cui l'esempio si ispira, dove $y$ rimane invariato.
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
        scoreboard players set $y math <some value>
        scoreboard players set #2 math 2
        scoreboard players set #4 math 4
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

Si supponga di voler calcolare il $5%$ di 40. In un linguaggio di programmazione di alto livello, entrambe le espressioni `40/100*5` e `40*5/100` restituiscono correttamente il valore 2. Scomponendo queste operazioni in comandi `scoreboard` si ottiene rispettivamente:

#figure(
    [```mcfunction
        scoreboard players operation set $val math 40
        scoreboard players operation $val math /= #100 math
        scoreboard players operation $val math *= #5 math
        ```
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

Occorre inoltre considerare che tali operazioni sono limitate al dominio dei numeri interi. È dunque richiesto implementare un algoritmo che approssimi queste funzioni, oppure utilizzare una _lookup table_~@lookup-table.

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

La scrittura di algoritmi di questo tipo è impegnativa, e spesso richiede di gestire un input moltiplicato per $10^n$ il cui output è un intero dove sia assume che le ultime $n$ cifre siano decimali#footnote[Solitamente $n=3$.]. Inoltre, questo approccio può facilmente provocare problemi di _integer overflow_.

In seguito all'introduzione delle _macro_, si è dunque iniziato a utilizzare le _lookup table_. Una _lookup table_ consiste in un _array_ memorizzato in uno #glos.str che contiene tutti gli output di una funzione per un intervallo prefissato di input.

Ipotizziamo mi serva la radice quadrata con precisione decimale di tutti gli interi tra 0 e 100. Si può creare uno #glos.str che contiene i valori $sqrt(i) space forall i in [0,100] inter NN$.

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
)
Dunque, data `get storage my_storage sqrt[4]` restituirà il quinto elemento dell'array, ovvero $2.0$, l'equivalente di $sqrt(4)$.

Dato che sono richiesti gli output di decine, se non centinaia di queste funzioni, i comandi per creare le _lookup table_ sono generati con script Python~@python-book, ed eseguiti da #glos.mc solamente quando il #glos.dp è inizializzato (tramite `load.json`). Poiché queste strutture non sono soggette ad operazioni di scrittura, ma solo di lettura, non c'è il rischio che vengano modificate durante la sessione di gioco.

== Alto Rischio di Conflitti

Nella sezione precedente è stato modificato lo #glos.str `my_storage` per inserirvi un array. Si noti che non è stato specificato alcun #glos.ns, per cui il sistema ha assegnato implicitamente quello predefinito, `minecraft:`.

Qualora un mondo contenesse due #glos.dp sviluppati da autori diversi, ed entrambi modificassero `my_storage` senza indicare esplicitamente un #glos.ns, potrebbero verificarsi conflitti.\

Un'altra situazione che può generare conflitti si verifica quando due #glos.dp sovrascrivono la stessa risorsa nel #glos.ns `minecraft`. Se entrambi modificano `minecraft/loot_table/blocks/stone.json`, che determina gli oggetti ottenibili da un blocco di pietra, il compilatore utilizzerà il file del #glos.dp caricato per ultimo.

Il rischio di sovrascrivere o utilizzare in modo improprio risorse appartenenti ad altri #glos.dp non riguarda solo file che prevedono una _resource location_, ma si estende anche a componenti come #glos.score e #glos.tag.

Nell'esempio seguente vengono presentati due frammenti di codice tratti da #glos.dp sviluppati da autori diversi, aventi il medesimo obiettivo: eseguire una funzione sull'entità chiamante (`@s`) al termine di un determinato intervallo di tempo.
In entrambi i casi, le funzioni deputate all'aggiornamento del timer vengono eseguite a ogni _tick_, ossia venti volte al secondo.

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

Le due funzioni modificano il medesimo _fakeplayer_ all'interno della stessa #glos.score. Poiché `timer_a` incrementa `timer` mentre `timer_b` lo decrementa, al termine di un _tick_ il valore rimane invariato.
Qualora entrambe modificassero `timer` nella stessa direzione, ad esempio incrementandolo, la durata effettiva del timer risulterebbe dimezzata.
Questo costituisce uno dei motivi per cui il nome di una _scoreboard_ deve essere prefissato con un #glos.ns, ad esempio `a.timer`#footnote[Come separatore si utilizza `.` anziché `:` in quanto quest'ultimo è un carattere ammesso nel nome di una #glos.score.].

Tra le varie condizioni in base alle quali i selettori possono filtrare entità, vi sono i _tag_, stringhe memorizzate in un array nell'#glos.nbt di un'entità.

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

In entrambi i casi, `@e[tag=has_timer]` seleziona lo stesso insieme di entità. Ciò può risultare problematico se, allo scadere del timer di $b$, vengono eseguiti comandi che determinano comportamenti inaspettati o erronei per le entità del #glos.dp di $a$ (o viceversa).

Dunque, come per i nomi delle #glos.score, è buona norma prefissare i _tag_ con il #glos.ns del proprio progetto.

In conclusione, la convenzione vuole che si utilizzino prefissi anche per i nomi di #glos.str, #glos.score e _tag_, nonostante i #glos.dp compilino correttamente anche senza di essi.

== Assenza di Code Blocks

Nei linguaggi di alto livello quali C o Java, i blocchi di codice che devono essere eseguiti condizionalmente o all'interno di un ciclo vengono racchiusi tra parentesi graffe. In Python, invece, la stessa funzione è ottenuta tramite l'indentazione del codice.

Nelle funzioni #glos.mcf questo costrutto non è supportato. Per eseguire condizionalmente una serie di comandi, è necessario creare un file separato che li contenga, oppure ripetere la medesima condizione su ciascuna riga. Quest'ultima soluzione comporta un maggiore _overhead_, in particolare quando il comando viene eseguito ripetutamente nel corso di più _tick_.

Di seguito viene illustrato un esempio di implementazione di un blocco `if-else` o `switch`, mediante l'utilizzo del comando `return` per interrompere il flusso di esecuzione nella funzione corrente.

#figure(
    local(
        number-format: numbering.with("1"),

        ```mcfunction
        execute if entity @s[type=cow] run return run say I'm a cow
        execute if entity @s[type=cat] run return run say I'm a cat
        say I'm neither a cow or a cat
        ```,
    ),
    caption: [Funzione che in base all'entità esecutrice, stampa un messaggio diverso.],
)
In questa funzione, i comandi dalla riga 2 in avanti non verranno eseguiti qualora il tipo dell'entità sia `cow`. Se la condizione alla riga 1 risulta falsa, l'esecuzione procede alla riga successiva, dove viene effettuato un nuovo controllo sul tipo dell'entità. Anche in questo caso, qualora la condizione sia soddisfatta, l'esecuzione si interrompe.
#figure(
    [```
        switch(entity){
          case "cow" -> print("I'm a cow")
          case "cat" -> print("I'm a cat")
          default -> print("I'm neither a cow or a cat")
        }
        ```
    ],
    caption: [Pseudocodice equivalente alla funzione precedente.],
)

La funzione è abbastanza intuitiva, e corrisponde a qualcosa che si vedrebbe in un linguaggio di programmazione di alto livello. Ipotizziamo ora che si vogliano eseguire due o più comandi in base all'entità.

#figure(
    local(
        number-format: numbering.with("1"),
        ```mcfunction
        execute if entity @s[type=cow] run return run say I'm a cow
        execute if entity @s[type=cow] run return run say moo

        execute if entity @s[type=cat] run return run say I'm a cat
        execute if entity @s[type=cat] run return run say meow

        say I'm neither a cow or a cat
        ```,
    ),
    caption: [Funzione errata per eseguire più comandi data una certa condizione.],
)

Ora, se l'entità è di tipo `cow`, il comando alla riga 2 non verrà mai eseguito, anche se la condizione è soddisfatta. Dunque, è necessario creare una funzione che contenga quei due comandi.

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

Per quanto riguarda i cicli, come mostrato in @funzione_ricorsiva, l'unico modo per ripetere gli stessi comandi più volte è attraverso la ricorsione. Di conseguenza, ogni volta che è necessario implementare un ciclo, è indispensabile creare almeno una funzione dedicata.
Se è invece richiesto un contatore per tenere traccia dell'iterazione corrente (il classico indice `i` dei cicli `for`), è possibile utilizzare funzioni ricorsive che si richiamano passando come parametro una _macro_, il cui valore viene aggiornato all'interno del corpo della funzione. In alternativa, si possono scrivere esplicitamente i comandi necessari a gestire ciascun valore possibile, in modo analogo a quanto avviene con le _lookup table_.

Un entità giocatore dispone di 36 slot che possono contenere oggetti.
Ipotizziamo si voglia determinare in quale _slot_ dell'inventario del giocatore si trovi l'oggetto `diamond`.
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

In questa funzione, la ricerca viene interrotta da `return` appena si trova un diamante, ed è stato provato che abbia un _overhead_ minore della ricorsione. Come nel caso delle _lookup table_, i file che fanno controlli di questo genere sono solitamente creati con script Python.

Il @esempio_macro illustra come l'impiego delle _macro_ imponga la definizione di una funzione dedicata: tale funzione deve essere in grado di accettare parametri esterni e di sostituirli nei comandi contrassegnati dal simbolo `$`. Si tratta verosimilmente dell'unico caso in cui la creazione di una nuova funzione risulta genuinamente giustificata e non causata da vincoli di #glos.mcf.

Dunque, programmando in #glos.mcf, è richiesto creare una funzione, ovvero un file, ogni volta che si necessita di:Dunque, programmando in #glos.mcf, è richiesto creare una funzione, ovvero un file, ogni volta che si necessita di:
- un blocco `if-else` che esegua più comandi;
- un ciclo;
- definire una funzione _macro_.

Ciò comporta un numero di file sproporzionato rispetto alle effettive righe di codice. Tuttavia, ci sono altre problematiche relative alla struttura delle cartelle e dei file nello sviluppo di #glos.dp e #glos.rp.

== Organizzazione e Complessità della Struttura dei File
I problemi mostrati fin'ora sono principalmente legati alla sintassi dei comandi e ai limiti delle funzioni, tuttavia non è da trascurare l'organizzazione e la struttura di un progetto.

Affinché #glos.dp e #glos.rp vengano riconosciuti dal compilatore, essi devono trovarsi rispettivamente nelle directory `.minecraft/saves/<world_name>/datapacks` e `.minecraft/resourcepacks`.
Tuttavia, operare su queste cartelle in modo separato può risultare oneroso, considerando l'elevato grado di interdipendenza tra le due. Lavorare direttamente dalla directory radice `.minecraft/` risulta poco pratico, poiché essa contiene un numero considerevole di file e cartelle non pertinenti allo sviluppo del #glos.pack.

Una possibile soluzione consiste nel creare una directory che contenga sia il #glos.dp sia il #glos.rp e, successivamente, utilizzare _symlink_ o _junction_~@symlink per creare riferimenti dalle rispettive cartelle verso i percorsi in cui il compilatore si aspetta di trovarli.\
I _symlink_ (collegamenti simbolici) e le _junction_ sono riferimenti a file o directory che consentono di accedere a un percorso diverso come se fosse locale, evitando la duplicazione dei contenuti.

Disporre di un'unica cartella radice contenente #glos.dp e #glos.rp semplifica notevolmente la gestione del progetto.
In particolare, consente di creare una sola _repository_~@repository Git~@git, facilitando così il versionamento del codice, il tracciamento delle modifiche e la collaborazione tra più sviluppatori.\
Attraverso il sistema delle _release_ di GitHub~@github è possibile ottenere un link diretto a #glos.dp e #glos.rp pubblicati, che può poi essere utilizzato nei principali siti di hosting.
Queste piattaforme, essendo spesso gestite da piccoli team di sviluppo, tendono ad affidarsi a servizi esterni per la memorizzazione dei file, come GitHub o altri provider.

Ipotizzando di operare in un ambiente di lavoro unificato, come quello illustrato in precedenza, viene presentato un esempio di struttura rappresentante i file necessari per introdurre un nuovo _item_~@item (oggetto).
Nonostante l'_item_ costituisca una delle funzionalità più semplici da implementare, la sua integrazione richiede comunque un numero non trascurabile di file.
#figure(
    grid(
        columns: 2,
        gutter: 5em,
        align(left, tree-list[
            - datapack
                - data
                    - my_namespace
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
            - resourcepack
                - assets
                    - my_namespace
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

Nella sezione _data_, che determina la logica e i contenuti del gioco, _loot\_table_ e _recipe_ definiscono rispettivamente gli attributi
dell'oggetto e la modalità con cui questo può essere creato.
L'_advancement_ `use_my_item` è usato per rilevare quando un giocatore usa l'oggetto, chiamando la funzione `on_item_use` che in questo esempio riprodurrà un suono.

I suoni devono essere collocati nella directory _assets_. Affinché possano essere riprodotti, i file audio in formato `.ogg` devono essere registrati nel file `sounds.json`.
Nella cartella _lang_ sono presenti i file responsabili della gestione delle traduzioni, organizzate come insiemi di coppie chiave-valore.\
Per definire l'aspetto visivo dell'oggetto, si parte dalla sua _item model definition_, situata nella cartella `item`. Questa specifica il modello che l'_item_ utilizzerà. Il modello 3D, collocato in `models/item`, ne definisce la forma geometrica, mentre la #glos.tex associata al modello è contenuta nella directory `textures/item`.

Si osserva quindi che, per implementare anche la _feature_ più semplice, è necessario creare sette file e modificarne due. Pur riconoscendo che ciascun file svolge una funzione distinta e che la loro presenza è giustificata, risulterebbe certamente più comodo poter definire questo tipo di risorse _inline_~@inline.

Con il termine _inline_ si intende la definizione e utilizzo una o più risorse direttamente all'interno dello stesso file in cui vengono impiegate. Questa modalità risulterebbe particolarmente vantaggiosa quando un file gestisce contenuti specifici e indipendenti. Ad esempio, nell'aggiunta di un nuovo item, il relativo modello e la #glos.tex non verrebbero mai condivisi con altri oggetti, rendendo superfluo separarli in file distinti.

Infine, l'elevato numero di file rende l'ambiente di lavoro complesso da navigare. In progetti di grossa portata questo implica, nel lungo periodo, una significativa quantità di tempo dedicata alla ricerca dei singoli file.

== Stato dell'Arte delle Ottimizzazioni del Sistema

Alla luce delle numerose limitazioni di questo sistema, sono state rapidamente sviluppate soluzioni volte a rendere il processo di sviluppo più efficiente e intuitivo.

In primo luogo, gli stessi sviluppatori di #glos.mc dispongono di strumenti interni che automatizzano la generazione dei file #glos.json necessari al corretto funzionamento di determinate _feature_. Durante lo sviluppo, tali file vengono creati automaticamente tramite codice Java eseguito in parallelo alla scrittura del codice sorgente, evitando così la necessità di definirli manualmente.

Un esempio lampante è il file `sounds.json`, che registra i suoni e definisce quali file `.ogg` utilizzare. Questo contiene quasi 25.000 righe di oggetti #glos.json, ed è creato e aggiornato tramite software appositi ogni volta che viene inserita una _feature_ che richiede un nuovo suono.

Tuttavia, questo software non è disponibile al pubblico, e anche se lo fosse, semplificherebbe la creazione solo dei file #glos.json, non di #glos.mcf. Dunque, sviluppatori indipendenti hanno realizzato dei propri precompilatori, progettati per generare automaticamente #glos.dp e #glos.rp con mezzi più pratici e intuitivi.

Un precompilatore è uno strumento che consente di scrivere le risorse e la logica di gioco in un linguaggio più semplice, astratto o strutturato, e di tradurle automaticamente nei numerosi file #glos.json, #glos.mcf e cartelle richieste dal gioco.\
Il precompilatore al momento più completo e potente si chiama _beet_~@beet, e si basa sulla sintassi di Python, integrata con comandi di #glos.mc.\
Questo precompilatore, come molti altri, presenta due criticità principali:
- Elevata barriera d'ingresso: solo gli sviluppatori con una buona padronanza di Python sono in grado di sfruttarne appieno le potenzialità;
- Assenza di documentazione: la mancanza di una guida ufficiale rende il suo utilizzo accessibile quasi esclusivamente a chi è in grado di comprendere direttamente il codice sorgente di _beet_.

Altri precompilatori forniscono un'interfaccia più intuitiva e un utilizzo più immediato al costo di  completezza delle funzionalità, limitandosi dunque a produrre solo una parte delle componenti che costituiscono l'ecosistema dei #glos.pack.
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

== Approccio al Problema

Alla luce del contesto descritto e delle limitazioni degli strumenti esistenti, si è ricercata una soluzione che consentisse di ridurre la complessità d'uso preservando al contempo la completezza delle funzionalità.
Di seguito verranno illustrate le principali decisioni progettuali e le ragioni che hanno portato alla scelta del linguaggio di sviluppo.

Inizialmente si è tentato di progettare un _superset_~@superset di #glos.mcf, ossia un linguaggio che estende quello originale introducendo nuove funzionalità, e mantenendone la compatibilità.
Tale linguaggio avrebbe consentito di dichiarare e utilizzare elementi multipli (#glos.mcf e #glos.json) all'interno di un unico file, arricchendo inoltre la sintassi dei comandi con zucchero sintattico atto a velocizzare la scrittura delle sezioni più verbose.

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
Eseguendo questo codice, non solo si sarebbe creata la funzione dichiarata all'interno delle parentesi graffe, ma inserito il namespace prima di `var`, e creato il comando che assegna allo _score_ costante `#4` il valore 4.
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

Il principale vantaggio di questo approccio consiste nella possibilità di definire più nodi all'interno dello stesso file, evitando così la frammentazione del codice e semplificando la gestione della struttura complessiva del #glos.pack.
Inoltre, l'impiego di un linguaggio ad alto livello consente di sfruttare costrutti quali cicli e funzioni per automatizzare la generazione di comandi ripetitivi (ad esempio le già citate _lookup table_). La rappresentazione a oggetti della struttura permette anche di definire metodi di utilità per accedere e modificare i nodi da qualsiasi punto del progetto.
Ad esempio, si può implementare un metodo `addTranslation(key, value)` che permette di aggiungere, indipendentemente dal contesto in cui viene invocato, una nuova voce nel file delle traduzioni.

Si è dunque valutato quale linguaggio di programmazione, tra Python e Java, fosse più adatto per la realizzazione della libreria.

#figure(
    table(
        align: horizon + left,
        columns: 3,
        [], [Vantaggi], [Svantaggi],
        [Python],
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

        [Java],
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
/ `internal`: Contiene classi astratte e interfacce che riproducono la struttura di un generico _filesystem_. Classi e metodi di questo _package_~@package non saranno mai utilizzate dall'utente finale.
/ `objects`: Contiene le classi che rappresentano gli oggetti utilizzati nei #glos.dp e #glos.rp.
/ `util`: Raccoglie metodi di utilità impiegati sia per il funzionamento del progetto, sia a supporto del programmatore (ponendo attenzione alla visibilità dei singoli metodi).
/ Radice del progetto: Contiene gli oggetti principali che descrivono struttura di un #glos.pack (`Datapack`,`Resourcepack`,#c.ns,#c.p).

== Classi Astratte e Interfacce
=== Buildable
L'obiettivo della libreria sviluppata è delegare la creazione dei file che compongono un #glos.pack al metodo `build()`, della classe di più alto livello, #c.p.
Di conseguenza, ogni oggetto appartenente al progetto deve essere _buildable_, ovvero "costruibile", in modo da poter generare il file corrispondente in base al proprio nome e contenuto.
L'interfaccia #c.b definisce il contratto che stabilisce quali oggetti possono essere costruiti attraverso il metodo `build()`.
#figure(```java
public interface Buildable {
    void build(Path parent);
}
```)
Il parametro `parent` rappresenta un oggetto di tipo `Path`~@path che specifica la directory di destinazione nel file system locale in cui verrà generato il file.
Durante il processo di costruzione del progetto, questo percorso viene progressivamente esteso aggiungendo sottocartelle, fino a individuare la posizione finale del file generato.

L'interfaccia #c.fso estende #c.b con lo scopo di rappresentare file e cartelle del _file system_.
Essa definisce il contratto `getContent()`, che specifica il contenuto associato all'oggetto.
A seconda della classe che lo implementa, tale metodo può restituire un tipo di dato specifico nel caso di un file, oppure un insieme di #c.fso qualora si tratti di cartelle o altri contenitori.

Questa interfaccia definisce il metodo statico `find()` usato per trovare un `file` all'interno di un #c.fso che soddisfa una certa condizione.

Di seguito viene presentato e descritto il metodo `find()`, definito come metodo statico in #c.fso, il quale favorisce la comunicazione tra #c.fso da qualsiasi punto del progetto.

#figure(```java
static <T extends FileSystemObject> Optional<T> find(
            FileSystemObject root,
            Class<T> clazz,
            Predicate<T> condition
    ) {
        if (clazz.isInstance(root)) {
            T casted = clazz.cast(root);
            if (condition.test(casted)) {
                return Optional.of(casted);
            }
        }
        Object content = root.getContent();
        if (content instanceof Set<?> children) {
            for (Object child : children) {
                Optional<T> found = find((FileSystemObject) child, clazz, condition);
                if (found.isPresent()) {
                        return found;
                }
            }
        }
        return Optional.empty();
    }
```) <find>

Questo metodo generico accetta come parametri un #c.fso (senza distinzione tra cartella o file), la classe del tipo ricercato (`clazz`) e un predicato che esprime la condizione da soddisfare.

Il metodo implementa un algoritmo di ricerca ricorsiva in profondità sulla struttura ad albero. Per ogni nodo visitato, verifica innanzitutto se esso è un'istanza del tipo ricercato; in tal caso, valuta il predicato fornito e, se soddisfatto, restituisce un #c.o~@optional contenente l'oggetto. Qualora il nodo corrente non corrisponda al tipo ricercato, il metodo ne recupera il contenuto: se questo è un `Set`~@set, indicando che si tratta di una cartella o una sua sottoclasse, il metodo viene invocato ricorsivamente su ciascun elemento figlio, interrompendo la ricerca non appena viene trovata una corrispondenza. In assenza di risultati, viene restituito un #c.o vuoto.

#c.fso definisce inoltre il contratto `collectByType(Namespace data, Namespace assets)`, il quale viene sovrascritto dalle classi concrete per specificare se l'oggetto appartiene alla categoria _data_ dei #glos.dp o _assets_ dei #glos.rp.

=== AbstractFile e AbstractFolder

Tutti gli oggetti rappresentati file nel progetto, che saranno successivamente scritti in memoria, sono un estensione della classe #c.af.\
`AbstractFile<T>` è una classe astratta parametrizzata con un tipo generico `T`, che rappresenta il contenuto del file, memorizzato nell'attributo `content`.
La classe dispone dell'attributo `name`, che specifica il nome del file associato, privo di estensione.
Possiede inoltre un riferimento al `parent`, ovvero alla sottocartella o cartella delle risorse in cui il file si troverà.
L'oggetto dispone infine di un riferimento al #glos.ns in cui si trova.\
`namespace` è formattato per comporre assieme `name` la stringa che corrisponde alla _resource location_ dell'oggetto corrente. Questa logica è implementata nel metodo `toString()`, così che l'istanza possa essere inserita direttamente in altre stringhe restituendo automaticamente il riferimento completo alla risorsa.
#figure(```java
@Override
public String toString() {
  return String.format("%s:%s", getNamespaceId(), getName());
}
```)
#c.af, oltre ad implementare #c.fso, implementa le interfacce `PackFolder` ed `Extension`.\
`PackFolder` fornisce un solo contratto, `getFolderName()` che definisce il nome della cartella in cui sarà collocato.
`PackFolder` fornisce un unico contratto, `getFolderName()`, che definisce il nome della cartella in cui l'oggetto sarà collocato. Ad esempio, l'oggetto `Function` implementa tale metodo restituendo la stringa `"function"`, poiché tutte le funzioni devono risiedere nella cartella `function`.\
Similmente, l'interfaccia `Extension`, mediante il contratto `getExtension()`, consente agli oggetti che estendono #c.af di specificare la propria estensione (`.json`, `.mcfunction`, `.png`).

L'altra classe astratta che implementa #c.fso è #c.afo, parametrizzata con il tipo generico `<T extends FileSystemObject>`. Tale classe mantiene un attributo `children` di tipo `Set<T>`, usato per memorizzare i riferimenti ai nodi figli garantendo l'unicità degli elementi. Il metodo `build()` implementa un attraversamento ricorsivo invocando `build()` su ciascun nodo contenuto in `children`.\
In maniera analoga, il metodo `collectByType(...)` propaga ricorsivamente la classificazione degli oggetti attraverso l'albero, effettuando chiamate polimorfiche a `collectByType(...)` su ogni nodo figlio.

=== Folder e ContextItem
La classe `Folder` estende `AbstractFolder<FileSystemObject>`.
I suoi `children` saranno dunque #c.fso. Dispone di un metodo `add()` per aggiungere un elemento all'insieme dei figli.
Questo viene usato dalla logica interna della liberia, ma non è pensato per l'utilizzo dell'utente finale.

Nella prima iterazione del progetto, la creazione di una cartella con dei figli richiedeva l'istanza di un oggetto `Folder` e la successiva invocazione del metodo `add(...)`, passando come parametro uno o più oggetti istanziati tramite l'operatore `new`.\
Un sistema basato sulla creazione diretta degli oggetti presenta diverse limitazioni. In primo luogo, introduce un forte accoppiamento tra il codice _client_ e le classi concrete: qualsiasi modifica ai costruttori richiederebbe di aggiornare manualmente ogni punto del codice in cui tali oggetti vengono istanziati. Inoltre, l'utilizzo di espressioni come `myFolder.add(new Function(...))` risulta poco pratico per l'utente finale, soprattutto se l'obiettivo è offrire un'interfaccia più semplice e immediata per la creazione dei file.

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
Invocando `enter()`, si inserisce l'oggetto che implementa #c.ci in cima allo `stack` del contesto, indicando che è la cartella in cui verranno aggiunti tutti i prossimi #c.fso. Per rimuovere l'oggetto dalla cima dello `stack`, si chiama il metodo `exit()`.\
Con questo sistema, il programmatore può spostarsi tra diversi livelli della struttura del _filesystem_ in modo rapido e controllato, senza dover passare manualmente riferimenti ai vari contenitori.

=== Utilizzo delle Factory
Il sistema deve garantire che ogni oggetto che estende #c.fso sia collocato nel #c.ci corretto.
Per gestire automaticamente questo aspetto e al tempo stesso evitare la creazione diretta tramite `new`, si ricorre al #glos.dep #glos.f.

Le #glos.f costituiscono un #glos.dep finalizzato a separare la logica di creazione degli oggetti dal codice che li utilizza.
Anziché istanziare le classi direttamente, il client delega alla #glos.f la creazione dell'oggetto desiderato.
La #glos.f si occupa di selezionare la classe concreta da istanziare e di determinarne lo stato iniziale.
Nell'implementazione proposta, la #glos.f gestisce inoltre l'inserimento dell'oggetto appena creato nel contesto in cima allo stack.

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

Se la stringa `name` passata come parametro contiene uno o più caratteri `/`, questi vengono interpretati come separatori di cartelle, creando una gerarchia di sottocartelle.\ Il nome assegnato all'oggetto non influisce sul funzionamento della libreria, dal momento che, quando l'oggetto viene utilizzato in un contesto testuale, la chiamata implicita al metodo `toString()` restituisca il riferimento alla sua _resource location_.\
Gli oggetti passati come parametro _variable arguments_ (_varargs_~@varargs, `Object... args`) sostituiranno i corrispondenti valori segnaposto (`%s`), interpolando così il contenuto testuale prima che il file venga scritto su disco.

=== Classi File Astratte

L'interfaccia `FileFactory` è implementata come classe annidata all'interno dell'oggetto astratto #c.pf, il quale rappresenta qualsiasi tipo di file che non contiene suoni o immagini (ovvero file di testo o dati generici).\
Questa _nested class_, chiamata #c.f, dispone di due parametri e ha il compito di istanziare le sottoclassi di #c.pf.
#figure(
    ```java
    protected static class Factory<F extends PlainFile<C>, C>
      implements FileFactory<F>
    ```,
    caption: [Intestazione della classe #c.f per #c.pf],
)
`F` è un tipo generico che estende `PlainFile<C>`, rappresenta il tipo di file che la classe istanzierà. Vincolando `F` a `PlainFile<C>`, la #glos.f garantisce che tutti i file creati abbiano un contenuto di tipo `C` e siano sottoclassi di #c.pf.\
Il contenuto `C` del file è determinato dalle sottoclassi che ereditano da #c.pf. Ciò consente alla #glos.f di operare in modo generico, generando file con contenuti eterogenei senza necessità di duplicare codice.

La #glos.f mantiene un riferimento all'oggetto `Class`~@class parametrizzato con il tipo `F`, corrispondente alla classe degli oggetti da istanziare, utilizzato nel metodo `instantiate()`.
Questo restituisce l'oggetto da creare dati due parametri: il nome del file da creare, e il suo contenuto (di tipo `Object`, dato che ancora si sta operando in un contesto generico).

La funzione esegue una sequenza di operazioni per istanziare l'oggetto.
Inizialmente, ottiene un riferimento alla classe del contenuto (`StringBuilder.class` o `JsonObject.class`), necessario per individuare il costruttore della classe `F`. Successivamente, recupera il costruttore tramite _reflection_, verificando che la classe `F` disponga di un costruttore con i parametri `String name` e `C content`. Prima di procedere con l'istanziazione, rende accessibile il costruttore, operazione indispensabile per accedere a costruttori privati o protetti. A questo punto, crea un'istanza della classe e la aggiunge al contesto corrente. Infine, restituisce l'oggetto creato.

Le classi #c.tf e #c.jf estendono #c.af, utilizzando rispettivamente #c.sb~@stringbuilder e #c.jo~@jsonobject come tipo di `content`.

#c.tf rappresenta un file di testo generico, il cui contenuto è gestito tramite un oggetto #c.sb, così da consentire operazioni di concatenazione delle stringhe in modo efficiente. L'unica classe che la estende è `Function`, poiché è l'unico tipo di file nel progetto che prevede la scrittura diretta di testo.

#c.jf è invece la classe astratta ereditata da tutti i file #glos.json di un #glos.pack. Il suo contenuto è di tipo #c.jo, affinché si possano gestire e manipolare facilmente dati in formato #glos.json tramite la libreria _GSON_~@gson di Google.\
La #glos.f di #c.jf eredita quella di #c.pf, aggiungendovi metodi specifici per la creazione di di file #glos.json.
#figure(
    ```java
    protected static class Factory<F extends JsonFile>
      extends PlainFile.Factory<F, JsonObject>
      implements JsonFileFactory<F>
    ```,
    caption: [Intestazione della classe #c.f per #c.jf.],
)
L'estratto di codice riportato definisce la #glos.f incaricata di istanziare esclusivamente classi che estendono #c.jf. Questa classe eredita la factory di #c.pf, specializzandola per gestire contenuti di tipo #c.jo. Inoltre, implementa l'interfaccia `JsonFileFactory`, la quale definisce i metodi di creazione specifici per i file #glos.json, che dunque hanno come parametro #c.jo.\
Nella classe #c.jf viene anche eseguito l'#glos.or del metodo `getExtension()` per restituire la stringa `"json"`.

Nonostante il contenuto richiesto dalle classi sopra descritte non sia di tipo `String`, esso viene comunque convertito in stringa prima della scrittura su file.

Prima della scrittura effettiva, ogni file testuale viene sottoposto a un leggero processo di _parsing_.
Oltre alla già citata sostituzione dei valori segnaposto `%s`, una volta che #c.sb e #c.jo sono stati convertiti in stringhe, il contenuto viene analizzato per individuare pattern specifici.
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

Nella struttura riportata non sono ancora stati definiti metodi o classi specifiche per l'implementazione di un #glos.pack. Ritengo che questo livello di astrazione sia potenzialmente applicabile anche in altri contesti, in quanto permette di generare in modo sistematico più file a partire da un'unica definizione di riferimento. Questo approccio potrebbe risultare particolarmente utile anche in altre DSL caratterizzate da vincoli strutturali, dove la generazione automatizzata di file correlati è un requisito per la scalabilità e la manutenibilità del codice.\
Di seguito invece si esporranno elementi e funzionalità definite appositamente per lo sviluppo dei #glos.pack.

== Classi Concrete

=== File e Module

Le classi astratte #c.dj e #c.aj, sottoclassi di #c.jf, eseguono l'#glos.or del metodo `collectByType()` di #c.fso per specificare se il file rappresentato appartiene rispettivamente alla categoria #glos.dp o #glos.rp.

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

Unica eccezione è la classe #c.fn. Questa estende direttamente #c.tf, indicando la propria estensione (`.mcfunction`) con #glos.or del metodo `getExtension()`, e anche il proprio tipo come visto nell'esempio sopra con #c.dj.
Dal momento che #c.tf non dispone di una #glos.f per file di testo non in formato #glos.json, sarà  la #glos.f di #c.fn stessa a estendere `PlainFile.Factory`, definendo come parametro per il contenuto del file #c.sb, e come oggetto istanziato #c.fn.

Le classi rappresentanti file di alto livello sono dotate di un attributo statico e pubblico di tipo `JsonFileFactory<...>` chiamato `f`, parametrizzato per la classe specifica che istanzia.
Queste classi sono 39 in totale, e ognuna corrisponde a un specifico oggetto utile al funzionamento di un #glos.dp o #glos.rp (30 e 9 rispettivamente).
Poiché ognuna di queste deve disporre di una #glos.f, un costruttore, ed eseguire l'#glos.or del metodo `getFolderName()`, è stata impiegata una libreria per generare il loro codice Java.

Un possibile approccio alternativo avrebbe previsto l'implementazione di un metodo statico generico all'interno di `JsonFile.Factory`, strutturato per accettare come argomenti il tipo della classe da istanziare e la relativa directory di riferimento.
Così facendo non sarebbe stato necessario creare una classe dedicata per ciascun tipo di file, ma sarebbe risultato sufficiente invocare direttamente la funzione `create()` per generare l'istanza desiderata.
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
Dunque ho scritto una classe di utilità `CodeGen` che sfrutta la libreria _JavaPoet_~@javapoet per creare le classi e i metodi al loro interno. In questo modo per creare un modello si può semplicemente scrivere `Model.f.of(json)`.

Classi che rappresentano file binari (immagini, suoni) non ereditano la #c.f di #c.pf, ma usano #glos.f proprie per istanziare #c.t e #c.s.

L'oggetto #c.t estende un #c.af che ha come contenuto una #c.bi~@bufferedimage. Se viene passata una stringa al suo metodo `of()`, verrà convertita in un _path_ che punta alla cartella `resources/texture` del progetto Java. Si può anche passare direttamente una #c.bi, creata dinamicamente tramite codice Java.

I suoni invece usano come contenuto un array di byte. La loro #glos.f, similmente a quella di #c.t, permette di caricare suoni dalle risorse del progetto (`resources/sound`).

È stata definita una sottoclasse astratta di `Folder`, denominata #c.m, con l'obiettivo di promuovere la modularità del codice attraverso una chiara separazione delle responsabilità e l'aggregazione di contenuti affini. Ad esempio, nel contesto dell'implementazione di una feature $A$, tutte le risorse e i dati ad essa correlati possono essere raggruppati all'interno dello specifico #c.m $A$.

La classe dispone di un _entry point_, ovvero una funzione astratta `content()` che verrà sovrascritta da tutte le classi che ereditano #c.m, con lo scopo di fornire un chiaro punto in cui definire la logica interna del modulo.

I moduli vengono istanziati tramite il metodo `register(Class<? extends Module>... classes)`, il quale invoca il costruttore di una o più classi che estendono #c.m.

Quando un nuovo modulo viene istanziato, il costruttore imposta la nuova istanza come contesto corrente. Successivamente viene invocato il metodo `content()`, tramite il quale viene eseguito il codice specifico del modulo. Al termine di questa esecuzione, il costruttore ripristina il contesto precedente chiamando il metodo `exit()` dei #c.ci.
In questo modo si garantisce che l'esecuzione di ciascun modulo avvenga in maniera indipendente, evitando che compili in un contesto non pertinente.

=== Namespace e Project

Le classi concrete di file sono raggruppate all'interno di un #c.ns. Analogamente alla classe `Folder`, quest'ultimo gestisce un `Set` di elementi figli e implementa le interfacce #c.b e #c.ci.
L'implementazione di quest'ultima è necessaria poiché un #c.p può essere composto da molteplici #glos.ns; è pertanto indispensabile tracciare quello corrente destinato ad accogliere i #c.fso appena istanziati.\
Poiché gli elementi figli di #c.ns possono essere di diversa natura (_data_ o _assets_), è necessario dividerli prima che vengano scritti su file. Questi devono essere indirizzati verso i rispettivi contesti: il #glos.ns di competenza del #glos.dp per la componente dati e quello relativo al #glos.rp per le risorse.

La classe presenta una particolarità nel suo metodo `exit()`, usato per segnalare che non si vogliono più creare file su questo #glos.ns.
Oltre a indicare all'oggetto #c.c di chiamare `pop()` sul suo `stack` interno, viene anche chiamato il metodo `addNamespace()` di #c.p  che verrà mostrato in seguito.

La classe #c.p rappresenta la radice del progetto che verrà creato, e contiene informazioni essenziali per l'esportazione del progetto. Queste verranno impostate dall'utente finale tramite un _builder_.

Il _builder pattern_ è un #glos.dep creazionale utilizzato per costruire oggetti complessi progressivamente, separando la logica di costruzione da quella di istanziazione dell'oggetto.
È particolarmente utile quando il costruttore di un oggetto possiede molti parametri opzionali, come nel caso di #c.p.\
Tramite la classe `Builder` di #c.p, si possono specificare:
- nome del mondo, ovvero in quale _save file_ verrà esportato il #glos.dp;
- nome del progetto;
- versione del #glos.pack. Questa verrà usata per comporre il nome delle cartelle #glos.dp e #glos.rp esportate, e anche per ottenere il loro rispettivo `pack_format` richiesto;
- _path_ dell'icona di #glos.dp e #glos.rp, che verrà prelevata dalle risorse;
- descrizione in formato #glos.json o stringa di #glos.dp e #glos.rp, richiesta dal file `pack.mcmeta` di entrambi.
- uno o più _build path_, ovvero la cartella radice in cui saranno esportati il #glos.dp e #glos.rp costruiti. In genere questa coinciderà con la cartella globale di minecraft, nella quale sono raccolti tutti i #glos.rp e i _save file_, tra cui quello in cui si vuole esportare il #glos.dp.

Dopo aver definito questi valori, il progetto sarà in grado di comporre ogni _path_ cui dovrà esportare i file di #glos.dp e #glos.rp.

Un ulteriore #glos.dep creazionale applicato a #c.p è _singleton_, il cui scopo è garantire che una singola istanza di una classe in tutto il programma e renderla accessibile da qualunque punto del codice. Questo viene implementato tramite una variabile statica e privata di tipo #c.p all'interno della classe stessa. Un riferimento ad essa è ottenuto con il metodo `getInstance()`, che solleva un errore nel caso il progetto non sia ancora stato costruito con il `Builder`.

#c.p dispone al suo interno di attributi di tipo #c.dp e #c.rp. Questi hanno il compito di contenere i file che saranno scritti su memoria rigida ed estendono la classe astratta #c.gp.\
#c.gp implementa le interfacce #c.b e `Versionable`. Quest'ultima fornisce i metodi per ottenere i _pack format_ corrispettivi alla versione del progetto.\
Fornisce inoltre l'attributo `namespaces` di tipo `Map`~@map, nel quale verranno salvati i corrispettivi #c.ns.
Tramite il suo metodo `makeMcMeta()` viene generata la struttura #glos.json che indicherà al compilatore di #glos.mc il format (_minor_ e _major_) e la descrizione della corrispettiva cartella.\
Il metodo `build()`, è sovrascritto affinché iteri su tutti i valori del dizionario `namespaces`, propagando la costruzione.

Il metodo `addNamespace()`, accennato precedentemente, non aggiunge direttamente il #glos.ns al progetto. Prima divide i #c.fso che contiene tra quelli inerenti alle risorse (_assets_) e quelli relativi alla logica (_data_). Questa suddivisione viene fatta chiamando il metodo precedentemente citato `collectByType()`. Al termine della divisione si avranno due nuovi #glos.ns omonimi, ma con i contenuti divisi per funzionalità.
Il #glos.ns che contiene i file di _data_ sarà aggiunto alla lista di #c.ns di `datapack`. Se il #glos.ns contenente gli _assets_ non è vuoto, verrà aggiunto a quelli di `resourcepack`.

L'invocazione del metodo `build()` si propaga a cascata partendo da #c.p verso i campi `datapack` e `resourcepack`, i quali delegano l'operazione ai rispettivi `namespace`. Questi ultimi a loro volta estendono l'esecuzione a tutti gli elementi figli (cartelle e file), garantendo così il completo attraversamento dell'albero.

Con gli oggetti descritti fin'ora è possibile costruire un #glos.pack a partire da codice Java, tuttavia si possono sfruttare ulteriormente proprietà del linguaggio di programmazione per implementare funzioni di utilità, che semplificano ulteriormente lo sviluppo.

== Utilità

=== Trova o Crea File

Il metodo `find()`, descritto precedentemente ( @find), è impiegato in metodi di utilità che permettono di modificare i contenuti di file, in particolare quelli soggetti a modifiche da più punti del codice.
Ad esempio, i file `lang` dedicati alla localizzazione richiedono un aggiornamento costante per integrare le nuove voci. Similmente, ogni nuovo suono deve essere registrato nel file `sounds.json`.
Come accennato in precedenza, quando questi file di risorse vengono utilizzati dagli sviluppatori di #glos.mc, non vengono modificati manualmente, ma generati automaticamente tramite codice Java proprietario.

Proprio perché questi file non sono stati concepiti per essere modificati manualmente, sono stati implementati nella classe `Util` metodi dedicati per aggiungere elementi alle risorse in modo programmatico, accessibili da qualunque parte del progetto.\
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
L'esecuzione avvia uno `Stream`~@stream sugli elementi figli del `namespace` di riferimento, mappando ciascuno di essi tramite l'invocazione di `find()`: tale operazione tenta di individuare l'oggetto nel relativo sotto-albero, generando una sequenza di #c.o che risulteranno vuoti ad eccezione dell'eventuale corrispondenza trovata. La pipeline prosegue scartando gli #c.o vuoti ed estraendo il valori di quello valido. Il flusso termina selezionando il primo risultato tramite `findFirst()`; qualora la ricerca non produca alcun esito, viene invocato il `Supplier` per generare e restituire una nuova istanza.

Si garantisce così che il metodo restituisca l'oggetto ricercato o uno nuovo. Il metodo `orElseGet()` di Java rappresenta un'applicazione del #glos.dep _lazy loading_, che differisce dal tradizionale `orElse()` per l'uso di un `Supplier` che viene invocato solo se l'#c.o è vuoto. Questo approccio consente di ritardare la creazione di un oggetto fino al momento in cui è effettivamente necessario, rendendo il sistema leggermente più efficiente in termini di memoria~@lazy-loading@lazy-loading-ex.

La funzione appena mostrata è applicata in numerosi metodi di utilità per inserire rapidamente elementi in dizionari o liste #glos.json, come si può vedere nel frammento di codice seguente.
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
In questo esempio viene aggiunta una nuova traduzione per un determinato #c.l~@locale (lingua). La traduzione è rappresentata da una coppia chiave-valore, in cui la chiave identifica in modo univoco la componente testuale, e il valore ne specifica la traduzione per il #c.l indicato.
Il metodo ottiene il contenuto JSON del file lang corrispondente al #c.l richiesto. Successivamente vi aggiunge la coppia chiave-valore.
Nel caso in cui il file non esista ancora (ad esempio, alla prima esecuzione per quel #c.l), esso viene creato tramite la #glos.f, garantendo comunque l'esistenza del file di traduzione prima dell'inserimento dei dati.

Un'altra applicazione simile sono le funzioni `setOnTick()` e `setOnLoad()`, che permettono di aggiungere o un'intera `Function` o una stringa contenenti comandi alla lista di funzioni da eseguire ogni _tick_ o ad ogni caricamento dei file.

#e stato precedentemente menzionato che nel `Builder` di #c.p, in base alla versione specificata, si ottiene il _pack format_ di #glos.dp e #glos.rp.
Questi valori sono memorizzati in un `Record`~@record chiamato `VersionInfo`.

=== Ottenimento Versioni

Quando il `Builder` chiama `VersionUtils.getVersionInfo(String versionKey)`, dove `versionKey` rappresenta il nome della versione (ad esempio `25w05a`), esegue i seguenti passi:
+ controlla che sia presente nel _path_ del progetto `resources/_generated` il file `versions.json` contenente tutte le versioni e i format associati;
+ controlla che sia passato più di un giorno dall'ultima volta che è stato scritto `versions.json`;
+ Se il file non è presente oppure è passato più di un giorno dall'ultima volta che è stata eseguita la generazione del file, e dunque c'è la possibilità che sia stata pubblicata una nuova versione o _snapshot_, si ricrea il file.
+ carica il file come #c.jo
+ qualora `versionKey` coincida con "latest", indicando la necessità di recuperare la revisione più recente, si istanzia un `Iterator`#footnote[L'utilizzo dell'`Iterator` è indispensabile per accedere al primo elemento, poiché l'interfaccia `Set` non supporta l'accesso posizionale diretto (es. `getFirst()`).] sulla collezione di #c.jo. Il primo elemento estratto viene quindi convertito nel `Record` `VersionInfo`.
+ se `versionKey` corrisponde al nome di una versione, viene restituito l'oggetto `VersionInfo` corrispondente alla chiave richiesta. Questo conterrà il _pack format_ di #glos.dp e #glos.rp.

La generazione di `versions.json` avviene mediante una chiamata HTTP~@http verso un'API~@api dedicata, la quale restituisce un oggetto #glos.json contenente i dati completi di tutte le versioni disponibili.\
Queste vengono poi mappate al nome della versione corrispondente e ordinate dalla più recente alla più vecchia. La mappa cosi creata è avvolta in un #c.o. Se quest'ultimo è vuoto verrà sollevato un errore, altrimenti si scriverà la mappa sul file `versions.json`.

=== Esportazione in File Compressi
_Datapack_ e #glos.rp vengono letti ed eseguiti dal compilatore di #glos.mc anche se compressi in archivi `.zip`. Questo formato è particolarmente adatto alla distribuzione, poiché permette di offrire agli utenti due pacchetti leggeri e separati da scaricare.\
La classe #c.p dispone di un metodo `buildZip()` che, dopo aver ottenuto le cartelle #glos.dp e #glos.rp tramite il metodo `build()`, provvede a comprimerle generando i rispettivi archivi `.zip`. Al termine dell'operazione, le cartelle originali vengono eliminate.

Il metodo `zipDirectory()` si occupa di comprimere il contenuto di una cartella in un archivio `.zip`.
Questo esplora tutte le sottocartelle e file presenti nel percorso specificato, aggiungendo ciascun file all'archivio di destinazione.
Per farlo, utilizza il metodo `Files.walk(folder)`, che genera uno `stream` di tutti i percorsi contenuti nella cartella, escludendo quelli relativi a cartelle. Per ogni file trovato, viene calcolato il percorso relativo rispetto alla cartella base (`basePath`), in modo che all'interno dell'archivio venga mantenuta la stessa struttura del progetto originale.\
Successivamente, il metodo apre uno `stream` di lettura sul file e crea una nuova _entry_ ZIP, ovvero un elemento che rappresenta un singolo file all'interno dell'archivio.
L'oggetto `ZipArchiveOutputStream`~@zaos della libreria `commons-compress`~@commons-compress di _Apache_ si occupa di aprire l'_entry_ per consentire la scrittura dei dati relativi al file.
Il contenuto viene quindi copiato nell'archivio tramite la classe `IOUtils`~@io-utils di _Apache Commons_, dopodiché l'_entry_ viene chiusa per indicare che la scrittura del file è stata completata.

Il metodo `buildZip()` è stato pensato per essere usato in concomitanza con un _workflow_~@workflows di GitHub che, qualora il progetto abbia una _repository_ associata, costruisce le cartelle compresse di #glos.dp e #glos.rp ogni volta che viene creata una nuova _release_~@release. Questi archivi, onde evitare confusione tra le versioni, vengono automaticamente nominati con la versione specificata nel file `pom.xml`~@pom del progetto Java e saranno scaricabili dalla pagina GitHub che contiene gli artefatti associati alla _release_.

== Uso working example
In questa sezione verrà implementato un progetto che utilizza la libreria per modificare un _item_ di #glos.mc. L'obiettivo è fare in modo che, al click con il tasto destro del mouse, l'oggetto consumi uno tra tre diversi tipi di munizioni (anch'esse nuovi _item_), generando un'onda sinusoidale la cui lunghezza varia in base al tipo di munizione utilizzata.

Viene innanzitutto creato il progetto:
#figure(```java
Project myProject = new Project.Builder()
    .projectName("esempio")
    .version("1.21.10")
    .worldName("OOPack test world")
    .icon("icona")
    .description("esempio tesi")
    .addBuildPath("C:\\Users\\Ale\\AppData\\Roaming\\.minecraft")
    .build();
```)

In seguito si dichiara il #glos.ns da utilizzare:
#figure(```java
Namespace namespace = Namespace.of("esempio");
```)

Viene poi scritto il modulo `Munizioni`, che si occuperà di definire il codice e le risorse degli oggetti consumabili. L'_item_ munizione non ha comportamenti propri, tuttavia dispone di una ricetta per poter essere creato a partire da altri _item_. Dunque, un metodo `make()` crea le 3 munizioni diverse in base ai valori primitivi passati.
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

crea i file relativi all'aspetto dell'_item_.

#figure(
    local(
        number-format: numbering.with("1"),
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
La funzione `makeData()` si occupa di creare la _recipe_, ovvero il file #glos.json che indica come ottenere la munizione e le sue proprietà, tra cui la distanza dell'onda. Oltre alla _recipe_, è creato un _advancement_ che si è soliti usare per rilevare quando un giocatore possiede uno degli ingredienti richiesti per la creazione dell'oggetto, e dunque comunicare che la ricetta è disponibile tramite un messaggio sullo schermo.

Il modulo `MostraRaggio` si occupa di aggiungere comportamenti all'oggetto `carrot_on_a_stick`#footnote[`carrot_on_a_stick` è l'unico _item_ che possiede una #glos.score in grado di rilevare quando è cliccato con il tasto destro.], per renderlo in grado di consumare le munizioni sopra create e mostrare l'onda.

Viene innanzitutto invocata una funzione che genera una _lookup table_ contenente i valori necessari alla costruzione dell'onda.
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

Il funzionamento dell'_item_ è implementato con una catena di funzioni annidate. Alla radice c'è una funzione che ogni _tick_ esegue la funzione (@ex-1) che sarà passata come `varargs` della factory, che sostituirà `%s`.

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

I seguenti comandi si occupando di controllare se il giocatore possiede _item_ identificati come `ammo`. In caso negativo viene bloccato il flusso di esecuzione, e in caso positivo viene invocata una funzione il cui contenuto è costruito tramite @ex-3, per ottenere la prima munizione che il giocatore possiede. Se è stata trovata una munizione, viene eseguito @ex-4.

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

Questo metodo genera una #c.fn che controlla i 36 _slot_ del giocatore, incaricata di arrestare l'esecuzione al primo _item_ contrassegnato come `ammo`.

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
+ @ex-4\-2: salva la distanza associata alla munizione nella glos.score _distance_;
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
Si decrementa lo _score_ `distance`, e si memorizza l'esito di questa operazione in uno #glos.str. Se ancora non si è raggiunta la distanza massima, ovvero `$ns$.var matches 1..` si sposta l'esecuzione 0.1 blocchi in avanti e si ripete la funzione.\
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

Questo comando _macro_ invoca un'altra funzione _macro_, passandole il valore corrispondente a $sin(#raw("amount") times 10)$.

#figure(
    ```java
    Function.f.of("""
      $function %s with storage esempio:storage sin[$(amount)]
    """
    ```,
    caption: [],
) <ex-6>

Questo valore è usato per determinare la posizione verticale della _particle_, relativa al contesto di esecuzione, dando quindi l'impressione che si stia muovendo secondo una funzione sinusoidale.

#figure(
    ```java
    Function.f.of("""
      $particle end_rod ^ ^$(value) ^
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

Sarà dunque possibile creare una _repository_ e pubblicare una _release_. In seguito una _GitHub action_ eseguirà il progetto per generare le due cartelle compresse e rinominarle. In questo caso si chiameranno
`datapack-esempio-1.0.0.zip` e `resourcepack-esempio-1.0.0.zip`.

= Conclusione

Il presente lavoro di tesi ha affrontato le criticità intrinseche allo sviluppo di contenuti per #glos.mc tramite la _Domain Specific Language_ nativa, #glos.mcf.
L'analisi preliminare ha evidenziato come questo linguaggio, pur consentendo la modularità, imponga severi vincoli strutturali e sintattici: l'assenza di costrutti di programmazione di alto livello, unita alla necessità di definire ogni funzione in un file separato, comporta la produzione di codice prolisso, frammentato e di difficile manutenibilità.

Per superare tali limitazioni, è stata progettata e implementata una libreria Java (_OOPACK_) che introduce un approccio orientato agli oggetti per consentire la meta-programmazione di #glos.pack.
La soluzione proposta astrae la struttura di #glos.dp e #glos.rp in un albero di oggetti tipizzati, consentendo agli sviluppatori di definire molteplici risorse all'interno di un unico contesto e di sfruttare la sintassi di un linguaggio _general purpose_.
Attraverso l'automazione della generazione del _boilerplate_ e la validazione a tempo di compilazione, il framework riduce drasticamente la complessità di gestione dei file e aumenta la densità di codice, offrendo un ambiente di sviluppo più robusto e scalabile rispetto agli strumenti tradizionali.

Al fine di misurare concretamente l'efficienza della libreria, è stata sviluppata una classe `Metrics` con il compito di registrare il numero di righe e di file generati.
Eseguendo il progetto Java associato al _working example_, si nota che il numero di file prodotti è 31, con un totale di 307 righe di codice.

Il codice sorgente dispone invece dei seguenti file Java#footnote[I valori riportati sono arrotondati al multiplo di dieci inferiore, al fine di escludere eventuali righe vuote o commenti.]:
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
        circle("plot.p2t", radius: 0.02, fill: black, name: "p2o")
        content("p2o.end", [$P_2^t$], anchor: "south", padding: .1)
        content("plot.d1", [$d_1$], anchor: "south", padding: .1)
        content("plot.d2", [$d_2$], anchor: "south", padding: .1)
    }),
    caption: [Numero di righe e file richiesti a confronto.],
)

Si può osservare come la linea blu relativa ai progetti sviluppati con la libreria presenti una pendenza maggiore, evidenziando come il singolo file contenga molte più righe di codice.

Il vantaggio di utilizzare la libreria risulta particolarmente evidente nei progetti di ampia scala ($P_2$): una volta superata la fase iniziale in cui è necessario implementare metodi specifici per il progetto in questione, diventa immediato sfruttare la libreria per automatizzare la creazione di file con contenuti affini.

Se si considera la distanza come il vantaggio tratto dall'utilizzo della libreria, è evidente che automatizzare lo sviluppo sia vantaggioso per i progetti di scala maggiore.
#let pit(p1x, p2x, p1y, p2y) = $sqrt((p1x+p2x)^2+(p1y+p2y)^2)$
Per un progetto piccolo come $P_1$, $d_1=pit(3, 31, 220, 307)=528$.\
Per $P_2$ invece, $d_2=pit(9, 37, 1360, 2451)=3818$.

Se si misura la densità di codice per file come il rapporto tra righe totali e file totali, si vedrà che $p(P_1)=73.7$ e $p(P_2)=151.1$.
Quindi, un raddoppio della densità del codice implica che il beneficio dell'automazione aumenta di oltre 7 volte. Si può dunque affermare che l'efficienza della libreria cresce in modo non lineare con la dimensione del progetto.

Va tuttavia rilevato che l'utilizzo della libreria richiede un considerevole sforzo cognitivo, dovuto alla necessità di operare simultaneamente con due linguaggi diversi per sfruttarne appieno le potenzialità.

Si riconosce inoltre la possibilità di estendere la libreria con ulteriori metodi di utilità, potenzialmente più specifici ma comunque in grado di ridurre il carico di lavoro per lo sviluppatore.
Per esempio, potrebbe essere implementato un metodo che, dati uno o più valori costanti in input, generi automaticamente la funzione contenente i comandi #glos.score necessari per l'inizializzazione delle costanti #glos.score.

Oltre alle conoscenze tecniche acquisite, lo sviluppo del progetto in un arco temporale prolungato ha consentito di riconsiderare alcune scelte implementative, andando oltre il semplice obiettivo di produrre software funzionante.
Si è avuta l'opportunità di ottimizzare porzioni di codice che, pur funzionando correttamente, non rappresentavano la soluzione più efficiente né l'approccio più agevole per l'utente finale.\
Tale processo di revisione ha favorito lo sviluppo di un'analisi più critica verso la qualità complessiva del software, ponendo particolare attenzione alla manutenibilità del codice e all'esperienza d'uso.
