#import "template.typ": *
#import "util.typ": *
#import "@preview/treet:1.0.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": chart, plot

#show: project.with(
    title: [
        Framework per la\
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
    dedication: [Desidero ringraziare il professor Padovani per la disponibilità e il prezioso supporto a me offerto durante questo percorso. Lo ringrazio anche per avermi dato l'opportunità di approfondire e lavorare con tecnologie a me particolarmente care.
    ],
    abstract: [
        In questo documento tratterò del mio lavoro svolto sotto la supervisione del prof. Padovani nello sviluppare un sistema software che agevola l'utilizzo della _Domain Specific Language_ del videogioco #glos.mc.\
        Inizialmente verranno illustrate la struttura e i principali componenti di questa DSL, evidenziandone gli aspetti sintattici e strutturali che ne determinano le principali criticità.
        Successivamente sarà presentato l'approccio adottato per mitigare tali problematiche, utilizzando una libreria Java sviluppata durante il tirocinio. Tale libreria è stata progettata con l'obiettivo di semplificare le operazioni più ripetitive e onerose, sfruttando i costrutti di un linguaggio ad alto livello, permettendo anche di definire più oggetti all'interno di un unico file, favorendo così uno sviluppo più coerente e strutturato.\
        Attraverso un _working example_ verrà poi mostrato come questa libreria consenta di ridurre la complessità nello sviluppo dei punti più critici, mettendola a confronto con l'approccio tradizionale.\
        Infine, mostrerò la differenza in termini di righe di codice e file creati tra i due sistemi, con l'intento di affermare l'efficienza della mia libreria.
    ],
    final: true,
    locale: "it",
    bibliography_file: "bib.yaml",
)

= Introduzione
Se non fosse per il videogioco #glos.mc@minecraft, non sarei qui ora. Quello che per me nel 2014 era un modo di esprimere la mia creatività costruendo con cubi in un mondo tridimensionale, si è rivelato presto essere il luogo dove per anni ho scritto ed eseguito i miei primi frammenti di codice.\
Motivato dalla mia abilità nel saper programmare in questo linguaggio non banale, ho perseguito una carriera di studio in informatica.

Pubblicato nel 2012 dall'azienda svedese Mojang@mojang, #glos.mc è un videogioco appartenente al genere _sandbox_@sandbox, famoso per l'assenza di una trama predefinita, in cui è il giocatore stesso a costruire liberamente la propria esperienza e gli obiettivi da perseguire.\
Come suggerisce il nome, le attività principali consistono nello scavare per ottenere risorse e utilizzarle per creare nuovi oggetti o strutture. Il tutto avviene all'interno di un ambiente tridimensionale virtualmente infinito.

Proprio a causa dell'assenza di regole predefinite, fin dal suo rilascio #glos.mc era dotato di un insieme rudimentale di comandi@command che consentiva ai giocatori di aggirare le normali meccaniche di gioco, ad esempio ottenendo risorse istantaneamente o spostandosi liberamente nel mondo.\
Con il tempo, tale meccanismo è diventato un articolato linguaggio di configurazione e scripting, basato su file testuali, che costituisce una _Domain Specific Language_@dsl (DSL) attraverso la quale sviluppatori di terze parti possono modificare numerosi aspetti e comportamenti dell'ambiente di gioco.

Con _Domain Specific Language_ si intende un linguaggio di programmazione meno complesso e più astratto rispetto a uno _general purpose_, concepito per essere utilizzato solo in una specifica area di sviluppo. Le DSL sono sviluppate in coordinazione con esperti del campo nel quale verrà utilizzato il linguaggio.
#quote(
    attribution: [JetBrains#footnote[JetBrains è un'azienda specializzata nello sviluppo di ambienti di sviluppo integrati (IDE).]],
    block: true,
)[ In many cases, DSLs are intended to be used not by software people, but instead by non-programmers who are fluent in the domain the DSL addresses.]

#glos.mc è sviluppato in Java@java-book, ma questa DSL, chiamata #glos.mcf@mc-function, adotta un paradigma completamente diverso. Essa non consente di introdurre nuovi comportamenti intervenendo direttamente sul codice sorgente: le funzionalità aggiuntive vengono invece definite attraverso gruppi di comandi, interpretati dal motore interno di #glos.mc (e non dal compilatore Java), ed eseguiti solo al verificarsi di determinate condizioni. In questo modo l'utente percepisce tali funzionalità come parte integrante dei contenuti originali del gioco.
Negli ultimi anni, grazie all'introduzione e all'evoluzione di una serie di file in formato #glos.json@json, è progressivamente diventato possibile creare esperienze di gioco quasi completamente nuove. Tuttavia, il sistema presenta ancora diverse limitazioni, poiché gran parte della logica continua a essere definita e gestita attraverso i file #glos.mcf.

Il tirocinio ha avuto come obiettivo la progettazione e realizzazione di un sistema che semplifica lo sviluppo e la distribuzione di questi file tramite un ambiente di sviluppo unificato.
Esso consiste in una libreria Java che permette di definire la gerarchia dei file in un sistema ad albero tramite oggetti. Una volta definite tutte le _feature_, viene eseguito il programma per ottenere un progetto pronto per l'uso.

Si ottiene così uno sviluppo più coerente e accessibile, che permette di integrare _feature_ di Java in questa DSL, per facilitare la scrittura e gestione dei file.

Nel prossimo capitolo verrà presentata la struttura generale del sistema, descrivendone gli elementi principali e il loro funzionamento. In seguito verrà esposta un'analisi delle principali problematiche e limitazioni del sistema, insieme a una rassegna delle soluzioni proposte nello stato dell'arte. Successivamente sarà illustrata la struttura e l'implementazione della mia libreria, accompagnata da un _working example_ volto a mostrare in modo concreto il funzionamento del progetto. L'ultimo capitolo sarà dedicato all'analisi dei risultati ottenuti.

= Struttura e Funzionalità di un Pack

== Cos'è un Pack
I file #glos.json e #glos.mcf devono trovarsi in specifiche cartelle per poter essere riconosciuti dal compilatore di #glos.mc ed essere integrati nel videogioco. La cartella radice che contiene questi file si chiama #glos.dp@datapack.\
Un #glos.dp può essere visto come la cartella `java` di un progetto Java: contiene la parte che detta i comportamenti dell'applicazione.

Come i progetti Java hanno la cartella `resources`@java-resource, anche #glos.mc dispone di una cartella in cui inserire le risorse. Questa si chiama #glos.rp@resourcepack, e contiene principalmente font, modelli 3D, #glos.tex@game-texture, traduzioni e suoni.\
Con l'eccezione di #glos.tex e suoni, i quali permettono l'estensione `png`@png e `ogg`@ogg rispettivamente, tutti gli altri file sono in formato #glos.json.\
Le #glos.rp sono state concepite e rilasciate prima dei #glos.dp, con lo scopo di dare ai giocatori un modo di sovrascrivere le #glos.tex e altri _asset_@assets del videogioco. Gli sviluppatori di #glos.dp hanno poi iniziato ad utilizzare #glos.rp per definire le risorse che loro il progetto avrebbe richiesto.

Una significativa differenza tra queste due cartelle è che le #glos.rp sono disponibili indipendentemente dal _save file_, ovvero del mondo che si sta utilizzando. Le cartelle #glos.dp invece, devono essere inserite nei mondi in cui devono essere utilizzate.\
Quindi nella cartella radice di minecraft, `.minecraft/`, #glos.rp si troveranno nella directory `.minecraft/resourcepacks`, mentre i #glos.dp in `.minecraft/saves/<world name>/datapacks`.

L'insieme di #glos.dp e #glos.rp è chiamato #glos.pack. Questo, riprendendo il parallelismo precedente, corrisponde all'intero progetto Java, e sarà poi la cartella che verrà pubblicata o condivisa.

== Struttura e Componenti di Datapack e Resourcepack

All'interno di un #glos.pack, #glos.dp e #glos.rp hanno una struttura molto simile.

#figure(
    grid(
        columns: 2,
        gutter: 10em,
        align(left, tree-list[
            - #glos.dp
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
            - #glos.rp
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

Anche se l'estensione non lo indica, il file `pack.mcmeta` è in realtà scritto in formato #glos.json e definisce l'intervallo delle versioni (chiamate _format_) supportate dalla cartella. Queste ad ogni aggiornamento di #glos.mc variano, e non corrispondono all'effettiva _game version_.\
Ad esempio, per la versione 1.21.10 del gioco, il `pack_format` dei #glos.dp è 88 e quello delle #glos.rp è 69. Queste possono cambiare anche settimanalmente, nel caso stiano venendo rilasciati degli _snapshot_@snapshot.

Ancora più rilevanti sono le cartelle contenute in `data` e `assets`, chiamate #glos.ns@namespace. Se i progetti Java seguono la struttura `com.package.author`, allora i #glos.ns possono essere visti come la sezione `package`.\

#quote(
    block: true,
    attribution: [Nathan Adams#footnote[Sviluppatore di #glos.mc parte del team che implementa _feature_ inerenti a #glos.dp.]],
    [This isn't a new concept, but I thought I should reiterate what a "namespace" is. Most things in the game has a namespace, so that if we add `something` and a mod (or map, or whatever) adds `something`, they're both different `something`s. Whenever you're asked to name something, for example a loot table, you're expected to also provide what namespace that thing comes from. If you don't specify the namespace, we default to `minecraft`. This means that `something` and `minecraft:something` are the same thing.],
)

I #glos.ns sono fondamentali per evitare che i file omonimi di un #glos.pack sovrascrivano quelli di un altro. Per questo, in genere i #glos.ns o sono abbreviazioni o coincidono con il nome stesso del progetto che si sta sviluppando, e si usa lo stesso tra #glos.dp e #glos.rp.\
Tuttavia, si vedrà come operare in #glos.ns distinti non sia sufficiente a garantire l'assenza di conflitti tra #glos.pack installati contemporaneamente.

Il namespace `minecraft` è riservato alle risorse native del gioco: sovrascriverle comporta il rischio di rimuovere funzionalità originali o di alterare il comportamento previsto del gioco. È interessante notare che anche gli sviluppatori di #glos.mc stessi fanno uso dei #glos.dp per definire e organizzare molti comportamenti del gioco, come la definizione di risorse ottenibili da un baule, o gli ingredienti necessari per creare un certo oggetto. In altre parole, i #glos.dp non sono solo uno strumento a disposizione dei giocatori per personalizzare l'esperienza, costituiscono anche il meccanismo interno attraverso cui il gioco stesso struttura e gestisce alcune delle sue funzionalità principali.\
Bisogna specificare che i comandi e file `.mcfunction` non sono utilizzati in alcun modo dagli sviluppatori di #glos.mc per implementare funzionalità del videogioco. Come precedentemente citato, tutta la logica è dettata da codice Java.

All'interno dei #glos.ns si trovano directory i cui nomi identificano in maniera univoca la natura e la funzione dei contenuti al loro interno: se è presente un file #glos.json che il compilatore riconosce come `loot_table` nella cartella `recipe`, questo solleverà un errore e il file non sarà disponibile nella sessione di gioco.

In `function` si trovano file e sottodirectory con file di testo in formato #glos.mcf. Questi si occupano di far comunicare tutte le parti di un #glos.pack tra loro tramite funzioni che contengono comandi.

== Comandi

Prima di spiegare cosa fanno i comandi, bisogna definire gli elementi basilari su cui essi agiscono.\
In #glos.mc, si possono creare ed esplorare mondi generati in base a un _seed_@seed casuale. Ogni mondo è composto da _chunk_@chunk, colonne dalla base di 16x16 cubi, e altezza di 320.\
L'unità più piccola in questa griglia è il blocco, la cui forma coincide con quella di un cubo di lato unitario. Ogni blocco in un mondo è dotato di collisione ed individuabile tramite coordinate dello spazio tridimensionale.
Si definiscono entità invece tutti gli oggetti dinamici che si spostano in un mondo: sono dotate di una posizione, rotazione e velocità.

I dati persistenti di blocchi ed entità sono compressi e memorizzati in una struttura dati ad albero chiamata _Named Binary Tags_@nbt (#glos.nbt). Il formato "stringificato", `SNBT` è accessibile agli utenti e si presenta come una struttura molto simile a #glos.json, formata da coppie di chiave e valori.\

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

Sebbene non disponga delle funzionalità tipiche dei linguaggi di programmazione di alto livello come cicli `for` e `while`, strutture dati complesse o variabili generiche, il sistema dei comandi fornisce comunque strumenti che consentono di riprodurre alcuni di questi comportamenti in forma limitata.

A seguire si descriveranno i comandi che più si avvicinano a concetti tipici di programmazione.
=== Scoreboard
`scoreboard` permette di creare dizionari di tipo `<Entità, Objective>`. Un `objective` rappresenta un valore intero a cui è associata una condizione (_criteria_) che ne determina la variazione. Il _criteria_ `dummy` corrisponde ad una condizione vuota, irrealizzabile. Su questi valori è possibile eseguire operazioni aritmetiche semplici, come la somma o sottrazione di un valore prefissato, oppure le quattro operazioni di base#footnote[Le operazioni aritmetiche di base sono somma, sottrazione, divisione e moltiplicazione.] con altri `objective`. Dunque una #glos.score può essere meglio vista come un dizionario `<Entità,<Intero, Condizione>>`.\
Prima di poter eseguire qualsiasi operazione su di essa, una #glos.score deve essere creata. Questo viene fatto con il comando\ `scoreboard objectives add <objective> <criteria>`.\
Per eseguire operazioni che non dipendono da alcuna entità, si usano i cosiddetti _fakeplayer_.  Al posto di usare nomi di giocatori o selettori, si prefiggono i nomi con caratteri illegali, quali `$` e `#`. In questo modo ci si assicura che un valore non sia associato ad un vero utente, e quindi sia sempre disponibile.
#figure(
    ```mcfunction
    scoreboard objectives add my_scoreboard dummy
    scoreboard players set #20 my_scoreboard 20
    scoreboard players set #val my_scoreboard 100
    scoreboard players operation #val my_scoreboard /= #20 my_scoreboard
    ```,
    caption: [Esempio di operazioni su una #glos.score, equivalente a `int val = 100; val /= 20;`],
)

Dunque, il sistema delle #glos.score permette di creare ed eseguire operazioni semplici esclusivamente su interi, con _scope_ globale, se e solo se fanno parte di una #glos.score.

=== Data
`data` consente di ottenere, modificare e combinare i dati #glos.nbt associati a entità, blocchi e #glos.str.
Come menzionato in precedenza, il formato #glos.nbt, una volta compresso, viene utilizzato per la persistenza dei dati di gioco. Oltre alle informazioni relative a entità e blocchi, in questo formato vengono salvati anche gli #glos.str. Questi sono un modo efficiente di immagazzinare dati arbitrari senza dover dipendere dall'esistenza di un certo blocco o entità. Per prevenire i conflitti, ogni #glos.str dispone di una _resource location_, che convenzionalmente coincide con il #glos.ns. Vengono dunque salvati come `command_storage_<namespace>.dat`.

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
`execute` consente di eseguire un altro comando cambiando valori quali l'entità esecutrice e la posizione. Questi elementi definiscono il contesto di esecuzione, ossia l'insieme dei parametri che determinano le modalità con cui il comando viene eseguito. Si usa il selettore `@s` per fare riferimento all'entità del contesto di esecuzione corrente.\
Tramite `execute` è possibile specificare condizioni preliminari e salvare il risultato dell'esecuzione. Dispone inoltre di 14 sottocomandi, che possono essere raggruppati in 4 categorie:
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
+ salva l'esito della prossima istruzione nello score `on_stone` di quell'entità;
+ controlla se nella posizione corrente del contesto di esecuzione, il blocco sottostante sia di tipo `stone`.
Al termine dell'esecuzione, la #glos.score `on_stone` di ogni entità sarà 1 se si trovava su un blocco di pietra, 0 altrimenti.

== Funzioni
Le funzioni sono insiemi di comandi raggruppati all'interno di un file #glos.mcf, una funzione non può esistere se non in un file `.mcfunction`. A differenza di quanto il nome possa suggerire, non prevedono inerentemente valori di input o di output, ma contengono uno o più comandi che vengono eseguiti in ordine.\
Le funzioni possono essere invocate in vari modi da altri file di un datapack:

- tramite comandi: `function namespace:function_name` esegue la funzione subito, mentre `schedule namespace:function_name <delay>` la esegue dopo un certo tempo specificato.
- da _function tag_: una _function tag_ è una lista in formato #glos.json di riferimenti a funzioni. #glos.mc ne fornisce due nelle quali inserire le funzioni da eseguire rispettivamente ogni _game loop_@tick(`tick.json`)#footnote[Il _game loop_ di #glos.mc viene eseguito 20 volte al secondo; di conseguenza, anche le funzioni incluse nel tag `tick.json` vengono eseguite con la stessa frequenza.], e ogni volta che si ricarica da disco il datapack (`load.json`). Queste due _function tag_ sono riconosciute dal compilatore di #glos.mc solo se nel namespace `minecraft`.
- Altri oggetti di un #glos.dp quali `Advancement` (obiettivi) e `Enchantment` (incantesimi).

Le funzioni vengono eseguite durante un _game loop_, completando tutti i comandi che contengono, inclusi quelli invocati altre funzioni. Le funzioni usano il contesto di esecuzione dell'entità che le sta invocando (se presente). Quando un comando `execute` altera il contesto di esecuzione, la modifica non influenza i comandi successivi, ma viene propagata alle funzioni chiamate a partire da quel punto.

In base alla complessità del branching e alle operazioni eseguite dalle funzioni, il compilatore (o più precisamente, il motore di esecuzione dei comandi) deve allocare una certa quantità di risorse per svolgere tutte le istruzioni durante un singolo _tick_. Il tempo di elaborazione aggiuntivo richiesto per l'esecuzione di un comando o di una funzione è definito _overhead_.

Le funzioni possono includere linee _macro_: comandi, che preceduti dal carattere `$`, hanno parte o l'intero corpo sostituito al momento dell'invocazione da un oggetto #glos.nbt indicato dal comando invocante.

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

Una funzione può essere richiamata ricorsivamente, anche modificando il contesto in cui viene eseguita. Questo comporta il rischio di creare chiamate senza fine, qualora la funzione si invochi senza alcuna condizione di arresto. È quindi responsabilità del programmatore definire i vincoli alla chiamata ricorsiva.

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

Questa funzione ogni volta che viene chiamata istanzierà una piccola #glos.tex intangibile e temporanea@particle (_particle_) alla posizione in cui è invocata la funzione. Successivamente controlla se è presente un giocatore nel raggio di 10 blocchi. In caso positivo si sposta il contesto di esecuzione avanti di $1/10$ di blocco e si chiama nuovamente la funzione. Quando il sotto-comando `if` fallisce, la funzione non sarà più eseguita.

Un linguaggio di programmazione si definisce Turing completo@turing-complete se soddisfa tre condizioni fondamentali:
- Presenta rami condizionali: deve poter eseguire istruzioni diverse in base a una condizione logica. Nel caso di #glos.mcf, ciò è realizzabile tramite il sotto-comando `if`.
- #e dotato di iterazione o ricorsione: deve consentire la ripetizione di operazioni. In questo linguaggio, tale comportamento è ottenuto attraverso l'utilizzo di funzioni ricorsive.
- Permette la memorizzazione di dati: deve poter gestire una quantità arbitraria di informazioni. In #glos.mcf, ciò avviene tramite la manipolazione dei dati all'interno dei #glos.str.

Pertanto, #glos.mcf può essere considerato a tutti gli effetti un linguaggio Turing completo. Tuttavia, come verrà illustrato nella sezione successiva, sia il linguaggio stesso sia il sistema di file su cui si basa presentano diverse limitazioni e inefficienze. In particolare, l'esecuzione di operazioni relativamente semplici richiede un numero considerevole di righe di codice e di file, che in un linguaggio di più alto livello potrebbero essere realizzate in modo molto più conciso.

= Problemi Pratici e Limiti Tecnici

Il linguaggio #glos.mcf non è stato originariamente concepito come un linguaggio di programmazione Turing completo. Ad esempio, nel 2012, prima dell'introduzione dei #glos.dp, il comando `scoreboard` veniva utilizzato unicamente per monitorare statistiche dei giocatori, come il tempo di gioco o il numero di blocchi scavati. Gli sviluppatori di #glos.mc osservarono come questo e altri comandi venivano impiegati dalla comunità per creare nuove meccaniche e giochi rudimentali, e hanno dunque aggiornato progressivamente il sistema, fino ad arrivare, nel 2017 alla nascita dei #glos.dp.

Ancora oggi l'ecosistema dei #glos.dp è in costante evoluzione, con _snapshot_ che introducono nuove funzionalità o ne modificano di già esistenti. Tuttavia, il sistema presenta ancora diverse limitazioni di natura tecnica, riconducibili al fatto che non era stato originariamente progettato per supportare logiche di programmazione complesse o essere utilizzato in progetti di grandi dimensioni.

== Limitazioni di Scoreboard
Come è stato precedentemente citato, `scoreboard` è usato per eseguire operazioni su interi. Tuttavia, l'utilizzo di questo comando presenta numerosi problemi.

Dopo che un _objective_ è stato creato, è necessario impostare le costanti che si utilizzeranno, qualora si volessero eseguire operazioni di moltiplicazione e divisione. Inoltre, un singolo comando `scoreboard` prevede una sola operazione.

Di seguito viene mostrato come l'espressione `int x = (y*2)/4-2` si calcola in #glos.mcf. Le variabili saranno prefissate da `$`, e le costanti da `#`.
#codly(
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
)
#figure(
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
    caption: [Esempio con $y=10$],
)<scoreboard_set_const>
Qualora non fossero stati impostati i valori di `#2` e `#4`, il compilatore li avrebbe valutati con valore 0 e l'espressione non sarebbe stata corretta.

Si noti come, nell'esempio precedente, le operazioni vengano eseguite sulla variabile $y$, il cui valore viene poi assegnato a $x$. Di conseguenza, sia `$x` che `$y` conterranno il risultato finale pari a 3. Questo implica che il valore di $y$ viene modificato, a differenza dell'espressione a cui l'esempio si ispira, dove $y$ dovrebbe rimanere invariato.
Per evitare questo effetto collaterale, è necessario eseguire l'assegnazione $x = y$ prima delle altre operazioni aritmetiche.
#codly(
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
)
#figure(
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
    caption: [Esempio di espressione con `scoreboard`],
)

La soluzione è quindi semplice, ma mette in evidenza come in questo contesto non sia possibile scrivere le istruzioni nello stesso ordine in cui verrebbero elaborate da un compilatore tradizionale.

Un ulteriore caso in cui l'ordine di esecuzione delle operazioni e il dominio ristretto agli interi assumono particolare rilevanza riguarda il rischio di errori di arrotondamento nelle operazioni che coinvolgono valori prossimi allo zero.

Si supponga si voglia calcolare il $5%$ di 40. Con un linguaggio di programmazione di alto livello si ottiene 2 calcolando `40/100*5` e `40*5/100`. Scomponendo queste operazioni in comandi `scoreboard` si ottiene rispettivamente:

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
Nel secondo caso invece, si ottiene il risultato corretto pari a 2, poiché le operazioni vengono eseguite nell'ordine $40 times 5 = 200$ e successivamente $200 / 100 = 2$.

== Assenza di Funzioni Matematiche

Poiché tramite #glos.score è possibile eseguire esclusivamente le quattro operazioni aritmetiche di base, il calcolo di funzioni più complesse quali logaritmi, esponenziali, radici quadrate o funzioni trigonometriche risulta particolarmente difficile da implementare.

Bisogna inoltre considerare il fatto che queste operazioni saranno ristrette al dominio dei numeri naturali. Si può dunque cercare un algoritmo che approssimi queste funzioni, oppure creare una _lookup table_@lookup-table.

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

Dunque, in seguito all'introduzione delle _macro_, si sono iniziate ad utilizzare le _lookup table_. Una _lookup table_ consiste in un _array_ salvato in uno #glos.str che contiene tutti gli output di una funzione in un intervallo prefissato.

Ipotizziamo mi serva la radice quadrata con precisione decimale di tutti gli interi tra 0 e 100. Si può creare uno #glos.str che contiene i valori $sqrt(i) space forall i in [0,100] inter NN$.
#codly(
    skips: ((7, 95),),
)
#figure(
    [```mcfunction
        data modify storage my_storage sqrt set value [
          0,
          1.0,
          1.4142135623730951,
          1.7320508075688772,
          2.0,
          10.0
        ]
        ```
    ],
    caption: [_Lookup table_ per $sqrt(x), "con" 0<=x<=100$.],
)
Dunque, data `get storage my_storage sqrt[4]` restituirà il quinto elemento dell'array, ovvero $2.0$, l'equivalente di $sqrt(4)$.

/*
Ipotizziamo mi servano i valori di $sin(x times 10)$. Si può creare uno #glos.str che contiene i valori $sin("rad"(i) times 10) space forall i in [0,360] inter NN$.
#codly(
    skips: ((7, 355),),
)
#figure(
    [```mcfunction
        data modify storage esempio:storage sin set value [
          {value:0.0},
          {value:0.17364817766693033},
          {value:0.3420201433256687},
          {value:0.49999999999999994},
          {value:0.6427876096865393},
          {value:-2.4492935982947065E-15}
        ]
        ```
    ],
    caption: [_Lookup table_ per  $sin(x times 10)$ #ex.],
)
Dunque, data `get storage esempio:storage sin[4].value` restituirà il quinto elemento dell'array, ovvero $0.6427876096865393$, l'equivalente di $sin("rad"(4)times 10)$.
*/

Dato che sono richiesti gli output di decine, se non centinaia di queste funzioni, i comandi per creare le _lookup table_ vengono generati con script Python@python-book, ed eseguiti da #glos.mc solamente quando si ricarica il #glos.dp. Poiché queste strutture non sono soggette ad operazioni di scrittura, ma solo di lettura, non c'è il rischio che vengano modificate durante la sessione di gioco.

== Alto Rischio di Conflitti

Nella sezione precedente è stato modificato lo #glos.str `my_storage` per inserirvi un array. Si noti che non è stato specificato alcun #glos.ns, per cui il sistema ha assegnato implicitamente quello predefinito, `minecraft:`.

Qualora un mondo contenesse due #glos.dp sviluppati da autori diversi, ed entrambi modificassero `my_storage` senza indicare esplicitamente un #glos.ns, potrebbero verificarsi conflitti.\

Un'altra situazione che può portare a conflitti è quando due #glos.dp sovrascrivono la stessa risorsa nel #glos.ns `minecraft`. Se entrambi modificano `minecraft/loot_table/blocks/stone.json`, che determina gli oggetti si possono ottenere da un blocco di pietra, il compilatore utilizzerà il file del #glos.dp che è stato caricato per ultimo.

Il rischio di sovrascrivere o utilizzare in modo improprio risorse appartenenti ad altri #glos.dp non riguarda solo file che prevedono una _resource location_, ma si estende anche a componenti come #glos.score e #glos.tag.

In questo esempio sono presenti due #glos.dp, sviluppati da autori diversi, con lo stesso obiettivo: eseguire una funzione sull'entità chiamante (`@s`) al termine di un determinato intervallo di tempo. In entrambi i casi, le funzioni incaricate dell'aggiornamento del timer vengono eseguite ogni _tick_, ovvero venti volte al secondo.

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

Le due funzioni modificano lo stesso _fakeplayer_ all'interno dello stesso #glos.score. Poiché `timer_a` incrementa `timer` e `timer_b` lo decrementa, al termine di un _tick_ il valore rimane invariato. Se invece entrambe variassero `timer` nello stesso verso, ad esempio incrementandolo, la durata effettiva del timer risulterebbe dimezzata. Questo è uno dei motivi per cui il nome di una _scoreboard_ deve essere prefissato con un #glos.ns, ad esempio `a.timer`#footnote[Come separatore si usa `.` e non `:` in quanto quest'ultimo è un carattere supportato nel nome di una #glos.score.].

Tra le varie condizioni per cui i selettori possono filtrare entità, ci sono i _tag_, ovvero stringhe memorizzate in un array nell'#glos.nbt di un entità.

Di conseguenza, se nell'esempio precedente gli sviluppatori necessitano che la funzione `timer` venga eseguita esclusivamente dalle entità contrassegnate da un determinato _tag_, ad esempio `has_timer`, i comandi per invocare `timer_a` e `timer_b` risulteranno i seguenti:

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

Nei linguaggi come C o Java, i blocchi di codice che devono essere eseguiti condizionalmente o all'interno di un ciclo vengono racchiusi tra parentesi graffe. In Python, invece, la stessa funzione è ottenuta tramite l'indentazione del codice.

In una funzione #glos.mcf, questo non si può fare. Se si vuole eseguire una serie di comandi condizionalmente, è necessario creare un altro file che li contenga, oppure ripetere la stessa condizione su più righe. Quest'ultima opzione comporta maggiore _overhead_, specialmente quando il comando viene eseguito in più _tick_.

Di seguito viene riportato un esempio di come si può scrivere un blocco `if-else`, o `switch`, sfruttando il comando `return` per interrompere il flusso di esecuzione del codice nella funzione corrente.

#figure(
    [```mcfunction
        execute if entity @s[type=cow] run return run say I'm a cow
        execute if entity @s[type=cat] run return run say I'm a cat
        say I'm neither a cow or a cat
        ```
    ],
    caption: [Funzione che in base all'entità esecutrice, stampa un messaggio diverso.],
)
In questa funzione, i comandi dalla riga 2 in poi non verranno mai eseguiti se il tipo dell'entità è cow. Se la condizione alla riga 1 risulta falsa, l'esecuzione invece procede alla riga successiva, dove viene effettuato un nuovo controllo sul tipo dell'entità; anche in questo caso, se la condizione è soddisfatta, l'esecuzione si interrompe.
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
    [```mcfunction
        execute if entity @s[type=cow] run return run say I'm a cow
        execute if entity @s[type=cow] run return run say moo

        execute if entity @s[type=cat] run return run say I'm a cat
        execute if entity @s[type=cat] run return run say meow

        say I'm neither a cow or a cat
        ```
    ],
    caption: [Funzione errata per eseguire più comandi data una certa condizione.],
)

Ora, se l'entità è di tipo `cow`, il comando alla riga 2 non verrà mai eseguito, anche se la condizione è soddisfatta. Dunque, è necessario creare una funzione che contenga quei due comandi.

#codly(
    header: [main.mcfunction],
)
```mcfunction
execute if entity @s[type=cow] run return run function is_cow
execute if entity @s[type=cat] run return run function is_cat

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

Considerando che i #glos.dp si basano sull'esecuzione di funzioni in base a eventi già esistenti, sono numerosi i casi in cui ci si trova a creare più file che contengono un numero ridotto, purché significativo, di comandi.

Per quanto riguarda i cicli, come mostrato in @funzione_ricorsiva, l'unico modo per ripetere gli stessi comandi più volte è attraverso la ricorsione. Di conseguenza, ogni volta che è necessario implementare un ciclo, è indispensabile creare almeno una funzione dedicata.
Se è invece necessario un contatore per tenere traccia dell'iterazione corrente (il classico indice `i` dei cicli `for`), è possibile utilizzare funzioni ricorsive che si richiamano passando come parametro una _macro_, il cui valore viene aggiornato all'interno del corpo della funzione. In alternativa, si possono scrivere esplicitamente i comandi necessari a gestire ciascun valore possibile, in modo analogo a quanto avviene con le _lookup table_.

Ipotizziamo si voglia determinare in quale _slot_ dell'inventario del giocatore si trovi l'oggetto `diamond`. Una possibile soluzione è utilizzare una funzione che iteri da 0 a 35 (un giocatore può tenere fino a 36 oggetti diversi), dove il parametro della _macro_ indica lo _slot_ che si vuole controllare, ma questo approccio comporta un overhead maggiore rispetto alla verifica diretta, caso per caso, dei valori da 0 a 35.

#codly(
    header: [find_diamond.mcfunction],
    skips: ((3, 33),),
)
#figure(
    [```mcfunction
        execute if items entity @s container.0 diamond run return run say slot 0
        execute if items entity @s container.1 diamond run return run say slot 1
        execute if items entity @s container.35 diamond run return run say slot 35
        ```
    ],
)

In questa funzione, la ricerca viene interrotta da `return` appena si trova un diamante, ed è stato provato che abbia un _overhead_ minore della ricorsione. Come nel caso delle _lookup table_, i file che fanno controlli di questo genere sono solitamente creati con script Python.


Infine, @esempio_macro dimostra che, per utilizzare una _macro_, è sempre necessario creare una funzione capace di ricevere i parametri di un'altra funzione e applicarli a uno o più comandi indicati con `$`. Questa è probabilmente una delle ragioni più valide per cui sia richiesto scrivere una nuova funzione. Tuttavia, va comunque considerata tra file la cui creazione non è necessaria in un linguaggio di programmazione ad alto livello.

Dunque, programmando in #glos.mcf è necessario creare una funzione, ovvero un file, ogni volta che si necessita di:
- un blocco `if-else` che esegua più comandi;
- un ciclo;
- utilizzare una _macro_.

Ciò comporta un numero di file sproporzionato rispetto alle effettive righe di codice. Tuttavia, ci sono altre problematiche relative alla struttura delle cartelle e dei file nello sviluppo di #glos.dp e #glos.rp.

== Organizzazione e Complessità della Struttura dei File
I problemi mostrati fin'ora sono prettamente legati alla sintassi dei comandi e ai limiti delle funzioni, tuttavia non sono da trascurare il quantitativo di file di un progetto.

Affinché #glos.dp e #glos.rp vengano riconosciuti dal compilatore, essi devono trovarsi rispettivamente nelle directory `.minecraft/saves/<world_name>/datapacks` e `.minecraft/resourcepacks`. Tuttavia, operare su queste due cartelle in modo separato può risultare oneroso, considerando l'elevato grado di interdipendenza tra i due sistemi. Lavorare direttamente dalla directory radice `.minecraft/` risulta poco pratico, poiché essa contiene un numero considerevole di file e cartelle non pertinenti allo sviluppo del #glos.pack.

Una possibile soluzione consiste nel creare una directory che contenga sia il #glos.dp sia il #glos.rp e, successivamente, utilizzare _symlink_ o _junction_@symlink per creare riferimenti dalle rispettive cartelle verso i percorsi in cui il compilatore si aspetta di trovarli.\
I _symlink_ (collegamenti simbolici) e le _junction_ sono riferimenti a file o directory che consentono di accedere a un percorso diverso come se fosse locale, evitando la duplicazione dei contenuti.

Disporre di un'unica cartella radice contenente #glos.dp e #glos.rp semplifica notevolmente la gestione del progetto. In particolare, consente di creare una sola _repository_@repository Git@git, facilitando così il versionamento del codice, il tracciamento delle modifiche e la collaborazione tra più sviluppatori.\
Attraverso il sistema delle _release_ di GitHub@github è possibile ottenere un link diretto a #glos.dp e #glos.rp pubblicati, che può poi essere utilizzato nei principali siti di hosting. Queste piattaforme, essendo spesso gestite da piccoli team di sviluppo, tendono ad affidarsi a servizi esterni per la memorizzazione dei file, come GitHub o altri provider.

Ipotizzando di operare in un ambiente di lavoro unificato, come quello illustrato in precedenza, viene presentato un esempio di struttura rappresentante i file necessari per introdurre un nuovo _item_@item (oggetto). Sebbene l'_item_ costituisca una delle funzionalità più semplici da implementare, la sua integrazione richiede comunque un numero non trascurabile di file.
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

Nella sezione _data_, che determina la logica e i contenuti, _loot\_table_ e _recipe_ definiscono rispettivamente attributi dell'oggetto, e come questo può essere creato. L'_advancement_ `use_my_item` serve a rilevare quando un giocatore usa l'oggetto, e chiama la funzione `on_item_use` che produrrà un suono.

I suoni devono essere collocati all'interno degli _assets_. Per poter essere riprodotti, ciascun suono deve avere un file audio in formato `.ogg` ed essere registrato nel file `sounds.json`. Nella cartella _lang_ sono invece presenti i file responsabili della gestione delle traduzioni, organizzate come insiemi di coppie chiave-valore.\
Per definire l'aspetto visivo dell'oggetto, si parte dalla sua _item model definition_, situata nella cartella `item`. Questa specifica il modello che l'_item_ utilizzerà. Il modello 3D, collocato in `models/item`, ne definisce la forma geometrica, mentre la #glos.tex associata al modello è contenuta nella directory `textures/item`.

Si osserva quindi che, per implementare anche la _feature_ più semplice, è necessario creare sette file e modificarne due. Pur riconoscendo che ciascun file svolge una funzione distinta e che la loro presenza è giustificata, risulterebbe certamente più comodo poter definire questo tipo di risorse _inline_@inline.

Con il termine _inline_ si intende la definizione e utilizzo una o più risorse direttamente all'interno dello stesso file in cui vengono impiegate. Questa modalità risulterebbe particolarmente vantaggiosa quando un file gestisce contenuti specifici e indipendenti. Ad esempio, nell'aggiunta di un nuovo item, il relativo modello e la #glos.tex non verrebbero mai condivisi con altri oggetti, rendendo superfluo separarli in file distinti.

Infine, l'elevato numero di file rende l'ambiente di lavoro complesso da navigare. In progetti di grossa portata questo implica, nel lungo periodo, una significativa quantità di tempo dedicata alla ricerca dei singoli file.

== Stato dell'Arte delle Ottimizzazioni del Sistema

Alla luce delle numerose limitazioni di questo sistema, sono state rapidamente sviluppate soluzioni volte a rendere il processo di sviluppo più efficiente e intuitiva.

In primo luogo, gli stessi sviluppatori di #glos.mc dispongono di strumenti interni che automatizzano la generazione dei file #glos.json necessari al corretto funzionamento di determinate _feature_. Durante lo sviluppo, tali file vengono creati automaticamente tramite codice Java eseguito in parallelo alla scrittura del codice sorgente, evitando così la necessità di definirli manualmente.

Un esempio lampante è il file `sounds.json`, che registra i suoni e definisce quali file `.ogg` utilizzare. Questo contiene quasi 25.000 righe di codice, ed è creato e aggiornato tramite software appositi ogni volta che viene inserita una _feature_ che richiede un nuovo suono.

Tuttavia, questo software non è disponibile al pubblico, e anche se lo fosse, semplificherebbe la creazione solo dei file #glos.json, non di #glos.mcf. Dunque, sviluppatori indipendenti hanno realizzato dei propri precompilatori, progettati per generare automaticamente #glos.dp e #glos.rp tramite strumenti più intuitivi.

Un precompilatore è uno strumento che consente di scrivere le risorse e la logica di gioco in un linguaggio più semplice, astratto o strutturato, e di tradurle automaticamente nei numerosi file #glos.json, #glos.mcf e cartelle richieste dal gioco.\
Il precompilatore al momento più completo e potente si chiama _beet_@beet, e si basa sulla sintassi di Python, integrata con comandi di #glos.mc.\
Questo precompilatore, come molti altri, presenta due criticità principali:
- Elevata barriera d'ingresso: solo gli sviluppatori con una buona padronanza di Python sono in grado di sfruttarne appieno le potenzialità;
- Assenza di documentazione: la mancanza di una guida ufficiale rende il suo utilizzo accessibile quasi esclusivamente a chi è in grado di interpretare direttamente il codice sorgente di _beet_.

Altri precompilatori forniscono un'interfaccia più intuitiva e un utilizzo più immediato al costo di  completezza delle funzionalità, limitandosi dunque a produrre solo una parte delle componenti che costituiscono l'ecosistema dei #glos.pack. Spesso, inoltre, la sintassi di questi linguaggi risulta più verbosa rispetto a quella dei comandi originali, poiché essi offrono esclusivamente un approccio programmatico alla composizione dei comandi senza portare ad alcun incremento nella loro velocità di scrittura.

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

= La mia Implementazione

== Approccio al Problema

Dato il contesto descritto e le limitazioni degli strumenti esistenti, ho cercato una soluzione che permettesse di ridurre la complessità d'uso senza sacrificare la completezza delle funzionalità.
Di seguito verranno illustrate le principali decisioni progettuali e le ragioni che hanno portato alla scelta del linguaggio di sviluppo.

Inizialmente, su suggerimento del prof. Padovani, ho tentato di progettare un _superset_@superset di #glos.mcf, ossia un linguaggio che estende quello originale introducendo nuove funzionalità mantenendone allo stesso tempo la compatibilità.
Questo linguaggio avrebbe consentito di dichiarare e utilizzare più elementi (#glos.mcf e #glos.json), all'interno di un unico file, arricchendo anche la sintassi con elementi di zucchero sintattico volti a semplificare la scrittura delle parti più verbose.

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
Eseguendo questo codice, non solo si sarebbe creata la funzione dichiarata all'interno delle parentesi graffe, ma inserito il namespace prima di `var`, e creato il comando che assegna alla costante `#4` i valore 4. Come è stato mostrato nel @scoreboard_set_const, per eseguire divisioni e moltiplicazioni per valori costanti, è prima necessario definirli in uno _score_.
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

Ho inizialmente scelto di utilizzare la versione Java della libreria ANTLR@antlr per definire la grammatica del linguaggio. Tuttavia, mi sono presto reso conto che realizzare una grammatica in grado di cogliere tutte le sfumature della sintassi di #glos.mcf, integrandovi al contempo le mie estensioni, avrebbe richiesto un impegno di sviluppo superiore a quello compatibile con un progetto di tirocinio.

Ho quindi pensato di sviluppare una libreria che permetta di definire la struttura di un #glos.pack, dalla radice del progetto fino ai singoli file, sotto forma di oggetti, affinché sia possibile rappresentare l'intero insieme delle risorse come una struttura dati ad albero n-ario. Questa, al momento dell'esecuzione, è attraversata per generare automaticamente i file e le cartelle corrispondenti ai nodi, all'interno delle directory di #glos.dp e #glos.rp.

Il principale vantaggio di questo approccio consiste nella possibilità di definire più nodi all'interno dello stesso file, evitando così la frammentazione del codice e semplificando la gestione della struttura complessiva del #glos.pack. Inoltre, l'impiego di un linguaggio ad alto livello consente di sfruttare costrutti quali cicli e funzioni per automatizzare la generazione di comandi ripetitivi (ad esempio le già citate _lookup table_). La rappresentazione a oggetti della struttura permette anche di definire metodi di utilità per accedere e modificare i nodi da qualsiasi punto del progetto. Ad esempio, si può implementare un metodo `addTranslation(key, value)` che permette di aggiungere, indipendentemente dal contesto in cui viene invocato, una nuova voce nel file delle traduzioni.

Dunque ho pensato a quale linguaggio di programmazione tra Python e Java si potesse usare per realizzare questa libreria.

#figure(
    table(
        align: horizon + left,
        columns: 3,
        [], [Vantaggi], [Svantaggi],
        [Python],
        [
            - Gestione semplice di stringhe (`f-strings`@f-strings) e file JSON;
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

Dopo un'attenta analisi, ho scelto di utilizzare Java per lo sviluppo del progetto, poiché secondo me è lo strumento ideale per applicare _design pattern_ in grado di semplificare e rendere più robusta l'implementazione, anche a costo di sacrificare parzialmente la comodità d'uso per l'utente finale.\
Inoltre, il tipaggio statico di Java permette di identificare in fase di sviluppo eventuali utilizzi impropri di oggetti o metodi della libreria, consentendo anche agli utenti meno esperti di comprendere più facilmente il funzionamento del sistema.

Il progetto, denominato _Object Oriented Pack_ (OOPACK), è organizzato in 4 sezioni principali.
/ `internal`: Contiene classi astratte e interfacce che riproducono la struttura di un generico _filesystem_. Classi e metodi di questo _package_@package non saranno mai utilizzate dal programmatore.
/ `objects`: Contiene le classi che rappresentano gli oggetti utilizzati nei #glos.dp e #glos.rp.
/ `util`: Raccoglie metodi di utilità impiegati sia per il funzionamento del progetto, sia a supporto del programmatore (ponendo attenzione alla visibilità dei singoli metodi).
/ Radice del progetto: Contiene gli oggetti principali che descrivono struttura di un #glos.pack (`Datapack`,`Resourcepack`,#c.ns,#c.p).

== Spiegazione basso livello
=== Buildable
L'obiettivo di questa libreria è delegare la creazione dei file che compongono un #glos.pack al metodo `build()`, definito nella classe di più alto livello, #c.p.
Di conseguenza, ogni oggetto appartenente al progetto deve essere _buildable_, ovvero "costruibile", in modo da poter generare il corrispondente file.
L'interfaccia #c.b definisce il contratto che stabilisce quali oggetti possono essere costruiti attraverso il metodo `build()`.
#figure(```java
public interface Buildable {
    void build(Path parent);
}
```)
Il parametro `parent` rappresenta un oggetto di tipo `Path`@path che indica la directory di destinazione nella memoria locale in cui verrà scritto il file.
Durante il processo di costruzione del progetto, questo percorso viene progressivamente esteso aggiungendo sottocartelle, fino a individuare la posizione finale del file generato.

L'interfaccia #c.fso estende #c.b con lo scopo di rappresentare file e cartelle del _file system_.
Definisce il contratto `getContent()`, che specifica il contenuto associato all'oggetto. In base al tipo di classe che lo implementa, potrà restituire un qualche tipo di dato (file) o una lista di #c.fso (cartella).

Questa interfaccia definisce il metodo statico `find()` usato per trovare un `file` all'interno di un #c.fso che soddisfa una certa condizione.
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
Questo metodo generico prende in input un #c.fso (non sa se si tratta di una cartella o file), la classe del tipo ricercato (`clazz`), e una condizione da soddisfare affinché l'oggetto risulti trovato. Esegue i seguenti passi:
+ controlla se il nodo attuale è un istanza del tipo cercato;
+ in caso positivo:
    + applica la condizione passata come `Predicate`@predicate;
    + se è soddisfatta, l'oggetto è trovato e viene restituito un #c.o@optional contenente l'oggetto.
+ in caso negativo, continua la ricerca nei figli;
+ ottiene il contenuto del nodo corrente;
+ se il contenuto è un `Set`@set (dunque il nodo è una cartella):
    + richiama `find(...)` su ciascun elemento figlio;
    + se uno dei figli contiene l'oggetto cercato, interrompe la ricerca.
+ altrimenti restituisce un #c.o vuoto, indicando che l'elemento non è stato trovato.

#c.fso definisce anche il contratto `collectByType(Namespace data, Namespace assets)`. Questo sarà sovrascritto per indicare se l'oggetto appartiene alla categoria _data_ dei #glos.dp o _assets_ dei #glos.rp.

=== AbstractFile e AbstractFolder

Tutti gli oggetti rappresentati file nel progetto, che saranno successivamente scritti in memoria, sono un estensione della classe #c.af.\
`AbstractFile<T>` è una classe astratta parametrizzata con un tipo generico `T`, che rappresenta il contenuto del file, memorizzato nell'attributo `content`.
La classe dispone dell'attributo `name`, che specifica il nome del file da creare, privo di estensione. Possiede inoltre un riferimento al `parent`, ovvero alla sottocartella o cartella delle risorse in cui il file si troverà.
L'oggetto dispone infine di un riferimento al #glos.ns in cui si trova.\
`namespace` è formattato per comporre assieme `name` la stringa che corrisponde alla _resource location_ dell'oggetto corrente. Questa logica è implementata nel metodo `toString()`, così che l'istanza possa essere inserita direttamente in altre stringhe restituendo automaticamente il riferimento completo alla risorsa.
#figure(```java
@Override
    public String toString() {
        return String.format("%s:%s", getNamespaceId(), getName());
    }
```)
#c.af, oltre ad implementare #c.fso, implementa `PackFolder` ed `Extension`.\
`PackFolder` fornisce un solo contratto, `getFolderName()` che definisce il nome della cartella in cui sarà collocato. Ad esempio l'oggetto `Function` eseguirà l'#glos.or di questo metodo per restituire `"function"`, dal momento che tutte le funzioni devono essere nella cartella `function`.\
Similmente, l'interfaccia `Extension`, tramite il contratto `getExtension()` permetterà agli oggetti che estendono #c.af di indicare la propria estensione (`.json`, `.mcfunction`).

L'altra classe astratta che implementa #c.fso è #c.afo. Questa classe astratta parametrizzata con `<T extends FileSystemObject>` dispone di un attributo `children` di tipo `Set<T>`, usato per mantenere riferimenti a nodi che estendono esclusivamente #c.fso, evitando duplicati. Il suo metodo `build()` invoca a sua volta `build()` per ogni figlio.\
Il metodo `collectByType(...)` esegue invece una chiamata polimorfica a `collectByType` su ogni nodo figlio, propagando la divisione di oggetti attraverso l'intera struttura ad albero.

=== Folder e ContextItem
La classe `Folder` estende `AbstractFolder<FileSystemObject>`. I suoi `children` saranno dunque #c.fso. Dispone di un metodo `add()` per aggiungere un elemento all'insieme dei figli. Questo viene usato dalla logica interna della liberia, ma non è pensato per l'utilizzo dell'utente finale.

Nella fase iniziale di sviluppo del progetto, la creazione di una cartella con dei figli richiedeva l'istanza di un oggetto `Folder` e la successiva invocazione del metodo `add(...)`, passando come parametro uno o più oggetti generati manualmente tramite l'operatore `new`.\
Un sistema basato sulla creazione diretta degli oggetti presenta diverse limitazioni. In primo luogo, introduce un forte accoppiamento tra il codice _client_ e le classi concrete: qualsiasi modifica ai costruttori richiederebbe di aggiornare manualmente ogni punto del codice in cui tali oggetti vengono istanziati. Inoltre, l'utilizzo di espressioni come `myFolder.add(new Function(...))` risulta poco pratico per l'utente finale, soprattutto se l'obiettivo è offrire un'interfaccia più semplice e immediata per la creazione dei file.

Dunque su suggerimento del prof. Padovani, ho modificato il sistema per appoggiarsi su un oggetto #c.c che indica il _parent_, ovvero la cartella in cui si sta lavorando. La classe #c.c contiene un attributo statico e privato di tipo `Stack<ContextItem>`@stack. Questo è usato per tenere traccia del livello di _nesting_ delle cartelle. `stack.peek()` restituisce il #c.ci in cima allo `stack`, ovvero quello in cui si sta lavorando al momento.

L'interfaccia #c.ci fornisce il metodo `add()` che un qualsiasi contenitore di oggetti implementerà (non solo `Folder`, ma come si vedrà successivamente, anche #c.ns in quanto anche esso è contenitore di #c.fso).\
L'interfaccia dispone anche di due metodi `default` per indicare quando si vuole operare nel contesto relativo a quell'oggetto.
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
Invocando `enter()`, si sta aggiungendo l'oggetto che implementa #c.ci in cima allo `stack` del contesto, indicando che è la cartella in cui verranno aggiunti tutti i prossimi #c.fso. Per rimuovere l'oggetto dalla cima dello `stack`, si chiama il metodo `exit()`.\
Con questo sistema, il programmatore può spostarsi tra diversi livelli della struttura del _filesystem_ in modo rapido e controllato, senza dover passare manualmente riferimenti ai vari contenitori.

=== Utilizzo delle Factory
Come fa un oggetto che estende #c.fso a sapere in quale #c.ci deve essere inserito?
Per gestire automaticamente questo aspetto e al tempo stesso evitare la creazione diretta tramite `new`, si ricorre al design pattern #glos.f.

Le #glos.f sono un modello di progettazione che ha lo scopo di separare la logica di creazione degli oggetti dal codice che li utilizza. Invece di istanziare le classi direttamente, il client si limita a chiedere alla #glos.f di creare l'oggetto desiderato. Sarà la #glos.f a occuparsi di scegliere quale classe concreta istanziare e con che stato. Nel nostro caso, si occuperà anche di inserirla nel contesto in cima allo `stack`.

Un'evoluzione di questo concetto è l'_abstract factory_, un pattern che fornisce un'interfaccia per creare famiglie di oggetti correlati o dipendenti tra loro, senza specificare le loro classi concrete.\
L'_abstract factory_ non crea direttamente gli oggetti, ma definisce un insieme di metodi di creazione che le sottoclassi concrete implementano per produrre versioni specifiche di tali oggetti.

Questo risulta particolarmente utile nel nostro contesto, in quanto si vuole dare all'utente la possibilità di istanziare oggetti in modi diversi.
#figure(
    ```java
    public interface FileFactory<F> {
        F ofName(String name, String content, Object... args);
        F of(String content, Object... args);
    }
    ```,
    caption: [Interfaccia `FileFactory`.],
)
L'utente può specificare manualmente il nome del file da costruire, oppure lasciare che sia la libreria a generare un nome casuale.
Se il nome contiene uno o più `/`, verranno letti come cartelle.\ Il nome assegnato all'oggetto non influisce sul funzionamento della libreria, dal momento che, quando l'oggetto viene utilizzato in un contesto testuale, la chiamata implicita al metodo `toString()` restituisca il riferimento alla sua _resource location_.\
Gli oggetti passati come parametro _variable arguments_@varargs (_varargs_, `Object... args`) sostituiranno i corrispondenti valori segnaposto (`%s`), interpolando così il contenuto testuale prima che il file venga scritto su disco.

=== Classi File Astratte

L'interfaccia `FileFactory` è implementata come classe annidata all'interno dell'oggetto astratto #c.pf, il quale rappresenta qualsiasi tipo di file che non contiene suoni o immagini (ovvero file di testo o dati generici).\
Questa _nested class_, chiamata #c.f, dispone di due parametri e serve a istanziare le sottoclassi di #c.pf.
#figure(
    ```java
    protected static class Factory<
      F extends PlainFile<C>,
      C
    > implements FileFactory<F>
    ```,
    caption: [Intestazione della classe #c.f per #c.pf],
)
`F` è un tipo generico che estende `PlainFile<C>` e rappresenta il tipo di file che la classe istanzierà. Vincolando `F` a `PlainFile<C>`, la #glos.f garantisce che tutti i file creati abbiano un contenuto di tipo `C` e siano sottoclassi di #c.pf.\
Il contenuto `C` del file è dettato dalle sottoclassi che ereditano #c.pf. Questo permette alla #glos.f di essere generica, creando file con contenuti diversi senza riscrivere codice.

La #glos.f possiede un riferimento all'oggetto `Class`@class, parametrizzato con il tipo `F`, degli oggetti che istanzierà ed è utilizzato nel metodo `instantiate()`. Questo restituisce l'oggetto da creare dati due parametri: il nome del file da creare, e il suo contenuto (di tipo `Object`, dato che ancora si sta operando in un contesto generico). La funzione esegue le seguenti istruzioni per istanziare l'oggetto:
+ ottiene un riferimento alla classe del contenuto (`StringBuilder.class` o `JsonObject.class`). Questo è usato per individuare il costruttore della classe `F`;
+ recupera il costruttore tramite _reflection_. Controlla che la classe `F` abbia un costruttore che disponga dei seguenti parametri: `String name` e `C content`;
+ rende accessibile il costruttore. Senza questo passo, non sarebbe possibile accedere ai costruttori privati o protetti;
+ crea un'istanza della classe;
+ aggiunge l'istanza al contesto attuale;
+ restituisce l'oggetto creato.

#c.af è esteso da #c.tf, il cui `content` è di tipo #c.sb@stringbuilder, e #c.jf, che utilizza invece #c.jo@jsonobject come contenuto.

#c.tf rappresenta un file di testo generico, il cui contenuto è gestito tramite un oggetto #c.sb, così da consentire operazioni di concatenazione delle stringhe in modo efficiente. L'unica classe che la estende è `Function`, poiché è l'unico tipo di file nel progetto che prevede la scrittura diretta di testo.

#c.jf è invece la classe base ereditata da tutti gli altri file di un #glos.pack. Il suo contenuto è di tipo #c.jo, affinché si possano gestire e manipolare facilmente dati in formato #glos.json tramite la libreria _GSON_@gson di Google.\
La #glos.f di #c.jf eredita quella di #c.pf, aggiungendovi metodi.
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

I costruttori delle classi sopra descritte richiedono un contenuto di tipo diverso da `String`. In entrambi i casi viene fatto un leggero _parsing_ prima della scrittura sul file. Oltre alla già citata sostituzione di valori segnaposto, dopo che #c.sb e #c.jo sono stati convertiti in stringhe, si controlla il contenuto per alcuni pattern.\ La sottostringa `"$ns$"` verrà sostituita con il nome effettivo del #glos.ns attivo al momento della costruzione, mentre `"$name$"` verrà sostituito con la propria _resource location_.\
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

== Struttura dell'Alto Livello

=== File Concreti e Module

Le classi astratte #c.dj e #c.aj sono sottoclassi di #c.jf, e hanno il compito di eseguire un #glos.or del metodo `collectByType()` di #c.fso per indicare se il file che rappresentano appartiene alla categoria #glos.dp o #glos.rp.
#figure(
    ```java
    @Override
    public void collectByType(Namespace data, Namespace assets) {
        data.add(this);
    }
    ```,
    caption: [metodo `collectByType()` di #c.dj.],
)

Queste classi saranno poi ereditate dalle classi concrete dei file che compongono un #glos.pack.

Unica eccezione è la classe #c.fn. Questa estende #c.tf, indicando la propria estensione (`.mcfunction`) con #glos.or del metodo `getExtension()`, e anche il proprio tipo come visto nell'esempio sopra con #c.dj. Dato che #c.tf non dispone di una #glos.f per file di testo non in formato #glos.json, sarà  la #glos.f di #c.fn stessa a estendere `PlainFile.Factory`, definendo come parametro per il contenuto del file #c.sb, e come oggetto istanziato #c.fn.

Le classi rappresentanti file di alto livello sono dotate di attributo statico e pubblico di tipo `JsonFileFactory<...>`, parametrizzato per la classe specifica che istanzia. Queste classi sono 39 in totale, e ognuna corrisponde a un specifico oggetto utile al funzionamento di un #glos.dp o #glos.rp (30 e 9 rispettivamente). Dal momento che ognuna di queste classi deve disporre di una #glos.f, un costruttore, e dell'#glos.or al metodo `getFolderName()`, ho scelto di usare una libreria per generare il loro codice Java.

Un'alternativa possibile sarebbe potuta consistere nel definire un metodo statico generico all'interno di `JsonFile.Factory`, che richiede come parametri il tipo della classe da istanziare e la cartella corrispondente. Così facendo non sarebbe necessario creare una classe dedicata per ciascun tipo di file, ma risulterebbe sufficiente invocare direttamente la funzione `create()` per generare l'istanza desiderata.
#figure(
    ```java
    Advancement adv = JsonFile.Factory.create(Advancement.class, "advancement", json);
    Model model = JsonFile.Factory.create(Model.class, "model", json);
    ```,
    caption: [Esempio di approccio alternativo.],
)

Tuttavia è evidente che non risulta comodo per l'utente finale dover specificare tutti questi parametri ogni volta che si vuole usare la #glos.f.\
Dunque ho scritto una classe di utilità `CodeGen` che sfrutta la libreria _JavaPoet_@javapoet per creare le classi e i metodi al loro interno. In questo modo per creare un modello si può semplicemente scrivere `Model.f.of(json)`.

Sono disponibili anche classi rappresentanti file binari. Queste non ereditano la #c.f di #c.pf, ma usano #glos.f proprie per istanziare #c.t e #c.s.

L'oggetto #c.t estende un #c.af che ha come contenuto una #c.bi@bufferedimage. Se viene passata una stringa al suo metodo `of()`, verrà convertita in un path che punta alla cartella `resources/texture` del progetto Java. Si può anche passare direttamente una #c.bi, creata dinamicamente tramite codice Java.

I suoni invece usano come contenuto un array di byte. La loro #glos.f, similmente a quella di #c.t, permette di caricare suoni dalle risorse del progetto (`resources/sound`).

Ho voluto creare una sottoclasse astratta di `Folder`, chiamata #c.m, con lo scopo di invitare ulteriormente a scrivere codice "modulare", dove c'è una chiara divisione di compiti e raggruppamento di contenuti affini. Ad esempio, se sto implementando una feature $A$, tutte le risorse e dati relative ad $A$, potranno essere inserite nel #c.m $A$.

La classe dispone di un _entry point_, ovvero una funzione astratta `content()` che verrà sovrascritta da tutte le classi che erediteranno #c.m, con lo scopo di fornire un chiaro punto in cui definire la logica interna del modulo.

I moduli vengono istanziati tramite il metodo `register(Class<? extends Module>... classes)`, che invoca il costruttore di una o più classi che estendono #c.m.

Quando un nuovo modulo viene istanziato, il costruttore imposta la nuova istanza come contesto corrente. Successivamente viene invocato il metodo `content()`, tramite il quale viene eseguito il codice specifico del modulo. Al termine di questa esecuzione, il costruttore ripristina il contesto precedente chiamando il metodo `exit()` dei #c.ci.
In questo modo si garantisce che l'esecuzione di ciascun modulo avvenga in maniera indipendente, evitando che compili in un contesto non pertinente.

=== Namespace, Project

Le classi concrete vengono raccolte da #c.ns. Come i `Folder`,  dispongono di un `Set` che contiene i figli, ed implementa le interfacce #c.b e #c.ci. Quest'ultima viene utilizzata perché un #c.p può essere composto da più #glos.ns, quindi bisogna tenere traccia di quello corrente in cui si aggiungono i #c.fso appena creati.\
I _children_ di #c.ns possono essere di natura _data_ o _assets_, dunque prima che vengano scritti su file sarà necessario dividerli nelle cartelle corrispondenti.

La classe presenta una particolarità nel suo metodo `exit()`, usato per dichiarare quando non si vogliono più creare file su questo #glos.ns. Oltre a indicare all'oggetto #c.c di chiamare `pop()` sul suo `stack` interno, viene anche chiamato il metodo `addNamespace()` di #c.p  che verrà mostrato in seguito.

La classe #c.p rappresenta la radice del progetto che verrà creato, e contiene informazioni essenziali per l'esportazione del progetto. Queste verranno impostate dall'utente finale tramite un _builder_.

Il _builder pattern_ è un _design pattern_ creazionale utilizzato per costruire oggetti complessi progressivamente, separando la logica di costruzione da quella di istanziazione dell'oggetto.
È particolarmente utile quando un oggetto ha molti parametri opzionali, come nel caso di #c.p.\
Tramite la classe `Builder` di #c.p, si possono specificare:
- nome del mondo, ovvero in quale _save file_ verrà esportato il #glos.dp;
- nome del progetto;
- versione del #glos.pack. Questa verrà usata per comporre il nome delle cartelle #glos.dp e #glos.rp esportate, e anche per ottenere il loro rispettivo `pack_format` richiesto;
- _path_ dell'icona di #glos.dp e #glos.rp, che verrà prelevata dalle risorse;
- descrizione in formato #glos.json o stringa di #glos.dp e #glos.rp, richiesta dal file `pack.mcmeta` di entrambi.
- uno o più _build path_, ovvero la cartella radice in cui verrà esportato l'intero progetto. In genere questa coinciderà con la cartella globale di minecraft, nella quale sono raccolti tutti i #glos.rp e i _save file_, tra cui quello in cui si vuole esportare il #glos.dp.

Dopo aver definito questi valori, il progetto sarà in grado di identificare il _path_ cui dovrà esportare le cartelle radice di #glos.dp e #glos.rp.

Un altro _design pattern_ creazionale applicato a #c.p è _singleton_, il cui scopo è garantire che una classe abbia una sola istanza in tutto il programma e che sia facilmente accessibile da qualunque punto del codice. Questo viene implementato tramite una variabile statica e privata di tipo #c.p all'interno della classe stessa. Un riferimento ad essa è ottenuto con il metodo `getInstance()`, che solleva un errore nel caso il progetto non sia ancora stato costruito con il `Builder`.

#c.p dispone al suo interno di attributi di tipo #c.dp e #c.rp. Questi hanno il compito di contenere i file che saranno scritti su memoria rigida ed estendono la classe astratta #c.gp.\
#c.gp implementa le interfacce #c.b e `Versionable`. Quest'ultima fornisce i metodi per ottenere i _pack format_ corrispettivi alla versione del progetto.\
Fornisce inoltre l'attributo `namespaces` di tipo `Map`@map, nel quale verranno salvati i corrispettivi #c.ns.
Tramite il suo metodo `makeMcMeta()` viene generata la struttura #glos.json che specifica il format (_minor_ e _major_) e la descrizione della cartella.\
Il metodo `build()`, è sovrascritto per farlo iterare su tutti i valori del dizionario `namespaces`, affinché anch'essi vengano costruiti.

Il metodo `addNamespace()`, accennato precedentemente, non aggiunge direttamente il #glos.ns al progetto. Prima divide i #c.fso contenuti in quelli inerenti alle risorse (_assets_) e quelli relativi alla logica (_data_). Questa suddivisione viene fatta chiamando il metodo precedentemente citato `collectByType()`. Al termine della divisione si avranno due nuovi #glos.ns omonimi, ma con i contenuti divisi per funzionalità.
Il #glos.ns che contiene i file di _data_ sarà aggiunto alla lista di #c.ns di `datapack`. Se il #glos.ns contenente gli _assets_ non è vuoto, verrà aggiunto a quelli di `resourcepack`.

Quindi chiamate al metodo build si propagheranno inizialmente da #c.p, poi ai suoi campi `datapack` e `resourcepack`, questi la invocheranno sui loro `namespace`. Questi a loro volta lo invocheranno su tutti i loro figli (cartelle e file), ricoprendo così l'intero albero.

Con gli oggetti descritti fin'ora è possibile costruire un #glos.pack a partire da codice Java, tuttavia si possono sfruttare ulteriormente proprietà del linguaggio di programmazione per implementare funzioni di utilità, che semplificano ulteriormente lo sviluppo.

== Utilità

=== Trova o Crea File

Il metodo `find()`, descritto precedentemente (@find), è impiegato in metodi di utilità che permettono di modificare i contenuti di file, in particolare quelli soggetti a modifiche da più punti del codice.
Ad esempio i file `lang`, che contengono le traduzioni, devono essere continuamente aggiornati con nuove voci. Similmente, ogni nuovo suono deve essere registrato nel file `sounds.json`. Come accennato in precedenza, quando questi file di risorse vengono utilizzati dagli sviluppatori di #glos.mc, non vengono compilati manualmente, ma generati automaticamente tramite codice Java proprietario.

Poiché questi file non sono stati concepiti per essere modificati manualmente, ho deciso di implementare nella classe `Util` metodi dedicati per aggiungere elementi alle risorse in modo programmatico, accessibili da qualunque parte del progetto.\
Ho prima scritto una funzione che permette di ottenere un riferimento all'oggetto ricercato, o di crearne uno nuovo qualora non fosse trovato.
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
Il metodo richiede la classe del tipo che si sta cercando, il suo nome e un `Supplier`@supplier. Esegue i seguenti passi:
+ ottiene l'insieme dei figli del `namespace` in cui effettuare la ricerca, e ne crea uno `Stream`@stream per l'elaborazione funzionale;
+ ogni `child` è trasformato in un #c.o:
    + per ogni `child` dello `stream`, invoca il metodo `find()`, specificando la classe e una condizione che determina il successo della ricerca (`Predicate`);
    + `find()` restituisce un #c.o. Questo sarà vuoto se la ricerca non ha avuto successo;
+ scarta gli #c.o vuoti;
+ estrae i valori degli #c.o rimasti;
+ ottiene un #c.o contenente il primo elemento trovato (`findFirst()`). Se non è presente alcun elemento, restituisce un #c.o vuoto;
+ se l'#c.o è vuoto, il `Supplier` fornisce una nuova istanza dell'oggetto da restituire.
In questo modo si garantisce che il metodo restituisca sempre o l'oggetto ricercato, oppure ne viene istanziato uno nuovo. Il metodo `orElseGet()` di Java rappresenta un'applicazione del _design pattern_ _lazy loading_, che differisce dal tradizionale `orElse()` per l'uso di un `Supplier` che viene invocato solo se l'#c.o è vuoto. Questo approccio consente di ritardare la creazione di un oggetto fino al momento in cui è effettivamente necessario, rendendo il sistema leggermente più efficiente in termini di memoria@lazy-loading@lazy-loading-ex.

La funzione appena mostrata è applicata in numerosi metodi di utilità per inserire rapidamente elementi in dizionari o liste #glos.json.
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
In questo esempio viene aggiunta una nuova traduzione per un determinato #c.l@locale (lingua). La traduzione è rappresentata da una coppia chiave-valore, in cui la chiave identifica in modo univoco la componente testuale, e il valore ne specifica la traduzione per il #c.l indicato.
Il metodo ottiene il contenuto JSON del file lang corrispondente al #c.l richiesto. Successivamente vi aggiunge la coppia chiave-valore.
Nel caso in cui il file non esista ancora (ad esempio, alla prima esecuzione per quel #c.l), esso viene creato tramite la factory, garantendo comunque l'esistenza del file di traduzione prima dell'inserimento dei dati.

Un'altra applicazione simile sono le funzioni `setOnTick()` e `setOnLoad()`, che permettono di aggiungere o un'intera `Function` o una stringa contenenti comandi alla lista di funzioni da eseguire ogni _tick_ o ad ogni caricamento dei file.

#e stato precedentemente menzionato che nel `Builder` di #c.p, in base alla versione specificata, si ottiene il _pack format_ di #glos.dp e #glos.rp.
Questi valori sono memorizzati in un `Record`@record chiamato `VersionInfo`.

=== Ottenimento Versioni

Quando il `Builder` chiama `VersionUtils.getVersionInfo(String versionKey)`, dove `versionKey` rappresenta il nome della versione (ad esempio `25w05a`), esegue i seguenti passi:
+ controlla che sia presente nel _path_ del progetto `resources/_generated` un file #glos.json contenente tutte le versioni e i format associati (`versions.json`);
+ controlla che sia passato più di un giorno dall'ultima volta che è stato scritto `versions.json`;
+ Se il file non è presente oppure è passato più di un giorno dall'ultima volta che è stata eseguita la generazione del file, e dunque c'è la possibilità che sia stata pubblicata una nuova versione o _snapshot_, si ricrea il file.
+ carica il file come #c.jo
+ se `versionKey=="latest"`, vuol dire che sta cercando la versione più recente,
    + crea un `Iterator`#footnote[Dato che un `Set` non è ordinato, non dispone di un metodo `getFirst()`, e dunque si ricorre all'`Iterator`.] di #c.jo per ottenere il valore del primo elemento;
    + converte l'elemento in un `Record` `VersionInfo`.
+ se invece `versionKey` è una chiave valida, viene restituito l'oggetto `VersionInfo` corrispondente alla chiave richiesta.

Ma come viene creato `versions.json`? Ogni volta che è necessario creare un nuovo file, viene fatta una chiamata HTTP@http ad un'API@api che restituisce un oggetto #glos.json contenente i dati di tutte le versioni.\
Queste vengono poi mappate al nome della versione corrispondente e ordinate dalla più nuova alla più vecchia. La mappa cosi creata è avvolta in un #c.o. Se quest'ultimo è vuoto verrà sollevato un errore, altrimenti si scriverà la mappa sul file `versions.json`.

=== Esportazione in File Compressi
#glos.dp e #glos.rp vengono letti ed eseguiti dal compilatore di #glos.mc anche se compressi in archivi `.zip`. Questo formato è particolarmente adatto alla distribuzione, poiché permette di offrire agli utenti due pacchetti leggeri e separati da scaricare.\
La classe #c.p dispone di un metodo `buildZip()`, che, dopo aver ottenuto le cartelle #glos.dp e #glos.rp tramite il metodo `build()`, provvede a comprimerle generando i rispettivi archivi `.zip`. Al termine dell'operazione, le cartelle originali vengono eliminate.

Il metodo `zipDirectory()` si occupa di comprimere il contenuto di una cartella in un archivio `.zip`. Esplora tutte le sottocartelle e file presenti nel percorso specificato, aggiungendo ciascun file all'archivio di destinazione.\
Per farlo, utilizza il metodo `Files.walk(folder)`, che genera uno `stream` di tutti i percorsi contenuti nella cartella, escludendo le cartelle. Per ogni file trovato, viene calcolato il percorso relativo rispetto alla cartella base (`basePath`), in modo che all'interno dell'archivio venga mantenuta la stessa struttura del progetto originale.\
Successivamente, il metodo apre uno `stream` di lettura sul file e crea una nuova _entry_ ZIP, ovvero un elemento che rappresenta un singolo file all'interno dell'archivio.
L'oggetto `ZipArchiveOutputStream`@zaos della libreria `commons-compress`@commons-compress si occupa di aprire l'_entry_ per consentire la scrittura dei dati relativi al file.
Il contenuto viene quindi copiato nell'archivio tramite la classe `IOUtils`@io-utils di _Apache Commons_, dopodiché l'_entry_ viene chiusa per indicare che la scrittura del file è stata completata.

Il metodo `buildZip()` è stato pensato per essere usato in concomitanza con un _workflow_@workflows di GitHub che, qualora il progetto abbia una _repository_ associata, costruisce le cartelle compresse di #glos.dp e #glos.rp ogni volta che viene creata una nuova _release_@release. Questi archivi, onde evitare confusione tra le versioni, vengono automaticamente nominati con la versione specificata nel file `pom.xml`@pom del progetto e saranno scaricabili dalla pagina GitHub che contiene gli artefatti associati alla _release_.

== Uso working example
In questo capitolo verrà implementato un progetto che utilizza la libreria per modificare un _item_ di #glos.mc. L'obiettivo è fare in modo che, al click con il tasto destro del mouse, l'oggetto consumi uno tra tre diversi tipi di munizioni (anch'esse nuovi item), generando un'onda sinusoidale la cui lunghezza varia in base al tipo di munizione utilizzata.

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

In seguito si dichiara il #glos.ns che verrà utilizzato:
#figure(```java
var namespace = Namespace.of("esempio");
```)

Viene creato il modulo `Munizioni`, che si occuperà di definire il codice e le risorse degli oggetti che saranno consumati. L'_item_ munizione non ha comportamenti propri, tuttavia dispone di una ricetta per poter essere creato a partire da altri _item_. Dunque, ho scritto un metodo `make()` che in base ai parametri passati crea le 3 munizioni diverse.
#figure(```java
@Override
    protected void content() {
        make("blue_ammo", "Munizione Blu", "Blue Ammo", "diamond",20);
        make("green_ammo", "Munizione Verde", "Green Ammo", "emerald",25);
        make("purple_ammo", "Munizione Viola", "Purple Ammo", "amethyst_shard",30);
    }
```)

I parametri passati al metodo sono, nell'ordine: l'ID interno dell'_item_, la sua traduzione in italiano, la sua traduzione in inglese, l'ID di un altro _item_ necessario per la sua creazione, e la distanza in blocchi del raggio generato dall'onda.

Il metodo `make()`, oltre ad aggiungere le traduzioni tramite i metodi di utilità:
#figure(```java
Util.addTranslation("item.esempio.%s".formatted(id), en);
Util.addTranslation(Locale.ITALY, "item.esempio.%s".formatted(id), it);
```)

Crea i file relativi all'aspetto dell'_item_.

#codly(
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
)

#figure(```java
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
```)
La funzione `makeData()` invece, si occupa di creare la _recipe_, ovvero il file #glos.json che indica come ottenere la munizione e le sue proprietà, tra cui la distanza dell'onda. Oltre alla _recipe_, è creato un _advancement_ che si è soliti usare per rilevare quando un giocatore possiede uno degli ingredienti richiesti per la creazione dell'oggetto, e dunque comunica che la ricetta è disponibile tramite un messaggio sullo schermo.

Il modulo `MostraRaggio` si occupa di modificare un `carrot_on_a_stick`#footnote[`carrot_on_a_stick` è l'unico _item_ che possiede una #glos.score in grado di rilevare quando è cliccato con il tasto destro.], per renderlo in grado di consumare le munizioni sopra create e mostrare l'onda.

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


Successivamente si creano gli #glos.score utili al funzionamento del progetto. `click` aumenterà di 1 ogni volta che il giocatore clicca il tasto destro del mouse, mentre `var` è usato per le operazioni matematiche.
#figure(```java
Util.setOnLoad(Function.f.of("""
  scoreboard objectives add $ns$.click minecraft.used:minecraft.warped_fungus_on_a_stick
  scoreboard objectives add $ns$.var dummy
  """));
```)

Il funzionamento dell'_item_ è implementato con una catena di funzioni annidate. Alla radice c'è una funzione che ogni _tick_ esegue la funzione (@ex-1) che sarà passata come `varargs` della factory, che sostituirà `%s`.
#codly(
    skips: ((3, 44),),
)
#figure(
    ```java
    var tick = Function.f.of("""
      execute as @a at @s run function %s""",
    );
    Util.setOnTick(tick);
    ```,
    caption: [],
)

Questa funzione invoca @ex-2 se il giocatore ha cliccato l'_item_, e in seguito azzera il valore dello #glos.score per evitare che nel prossimo _tick_ venga eseguita nuovamente la funzione anche se l'_item_ non è stato usato.

#figure(
    ```java
    Function.f.of("""
      execute if score @s $ns$.click matches 1.. run function %s
      scoreboard players reset @s $ns$.click
    """,
    ```,
    caption: [],
) <ex-1>

I seguenti comandi si occupando di controllare se il giocatore possiede _item_ identificati come `ammo`. In caso negativo viene bloccato il flusso di esecuzione, in caso positivo viene invocata una funzione (@ex-3) per ottenere la prima munizione che il giocatore possiede. Se è stata trovata una munizione, viene eseguito @ex-4.

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

Questo metodo genera una #c.fn che controlla i 36 _slot_ del giocatore, arrestando l'esecuzione al primo _item_ contrassegnato come `ammo`.

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
+ @ex-4:2: salva la distanza associata alla munizione in una #glos.score\;
+ @ex-4:3: viene riprodotto un suono. Tramite il metodo di utilità `addSound()` questo è aggiunto al dizionario di `sounds.json` e `Sound.of()` si occupa di prelevare il file `.ogg` al _path_ indicato;
+ @ex-4:4 chiama una funzione _macro_ che elimina la munizione trovata dallo _slot_ corrispondente;
+ @ex-4:4 sposta l'esecuzione della funzione all'altezza degli occhi del giocatore, e invoca @ex-5.
#figure(
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
    caption: [],
) <ex-4>

La seguente funzione rappresenta il nucleo della logica ricorsiva per creare l'onda.
Si rimuove 1 dallo _score_ `distance`, e si memorizza l'esito di questa operazione in uno #glos.str. Se ancora non si è raggiunta la distanza massima, ovvero `$ns$.var matches 1..` si sposta l'esecuzione 0.1 blocchi più avanti e si ripete la funzione.\
@ex-5:4 invoca la funzione @ex-6, passando l'indice dell'iterazione corrente come parametro.

#figure(
    ```java
    Function.f.of("""
      scoreboard players remove $distance $ns$.var 1
      execute store result storage $ns$:storage distance.amount int 1 run scoreboard players get $distance $ns$.var
      function %s with storage $ns$:storage distance
      execute if score $distance $ns$.var matches 1.. positioned ^ ^ ^0.1 run function $ns$:$name$
    """)
    ```,
    caption: [],
) <ex-5>

Questo comando _macro_ invoca un'altra funzione _macro_, passandole il valore corrispondente a $sin("amount"times 10)$.

#figure(
    ```java
    Function.f.of("""
      $function %s with storage esempio:storage sin[$(amount)]
    """
    ```,
    caption: [],
) <ex-6>

Questo valore è usato per determinare lo spostamento verticale della _particle_, dando quindi l'impressione che si stia disegnando una funzione sinusoidale.

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

Per misurare concretamente l'efficienza della libreria ho scritto una classe `Metrics` che si occupa di registrare il numero di righe e di file generati.
Dopo aver eseguito il progetto associato al _working example_, si nota che il numero di file prodotti è 31, con un totale di 307 righe di codice.

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

Prendendo come riferimento un esempio più articolato, tratto da un progetto personale che implementa nuove piante, sono presenti i seguenti file:
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
            size: (10, 6),
            x-label: [file],
            y-label: [linee],
            x-tick-step: 20,
            y-tick-step: 200,
            axis-style: "school-book",
            {
                plot.add(((3, 220), (9, 1360)), label: [Libreria _OOPACK_])
                plot.add(((31, 307), (137, 2451)), label: [Approccio tradizionale])
                plot.add(((3, 220), (31, 307)), style: (stroke: (paint: black, thickness: 1pt, dash: "dashed")))
                plot.add(((9, 1360), (137, 2451)), style: (stroke: (paint: black, thickness: 1pt, dash: "dashed")))

                plot.annotate({
                    circle((3, 220))
                    circle((9, 1360))
                    circle((31, 307))
                    circle((137, 2451))
                    content((10, 300))[$P_1^o$]
                    content((12, 1500))[$P_2^o$]
                    content((30, 500))[$P_1^t$]
                    content((140, 2600))[$P_2^t$]

                    content((70, 2050))[$d_2$]
                    content((20, 370))[$d_1$]
                })
            },
        )
    }),
    caption: [Numero di righe e file richiesti a confronto.],
)

Si può osservare come la linea blu relativa alla libreria presenti una pendenza maggiore, evidenziando come il singolo file contenga molte più righe di codice.

Il vantaggio di utilizzare la libreria risulta particolarmente evidente nei progetti di ampia scala ($P_2$): una volta superata la fase iniziale in cui è necessario implementare metodi specifici per il progetto in questione, diventa immediato sfruttare la libreria per automatizzare la creazione di file simili.

Se si considera la distanza come il vantaggio tratto dall'utilizzo della libreria, è evidente che automatizzare lo sviluppo sia vantaggioso per i progetti di scala maggiore.
#let pit(p1x, p2x, p1y, p2y) = $sqrt((p1x+p2x)^2+(p1y+p2y)^2)$
Per un progetto piccolo come $P_1$, $d_1=pit(3, 31, 220, 307)=528$.\
Per $P_2$ invece, $d_2=pit(9, 37, 1360, 2451)=3818$, più di 7 volte rispetto a $d_1$.

Devo tuttavia ammettere che, dopo aver iniziato a utilizzare questa libreria, è stato necessario un notevole sforzo mentale per lavorare con due linguaggi diversi contemporaneamente e sfruttarne appieno le potenzialità.

Non nego anche che ci sia la possibilità di aggiungere altri metodi di utilità, magari più specifici ma che potrebbero comunque ridurre la mole di lavoro a carico dello sviluppatore.
Ad esempio un metodo che prende in input uno o più interi e crea la funzione contenente i comandi #glos.score che si occupano di inizializzare le costanti.
