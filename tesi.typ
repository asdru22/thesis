#import "template.typ": *
#import "util.typ": *
#import "@preview/treet:1.0.0": *

#show: project.with(
    title: [
        Framework per la\
        Meta-programmazione\
        di Minecraf#h(0.1pt)t
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
        Successivamente sarà presentato l'approccio adottato per mitigare tali problematiche, utilizzando una libreria Java sviluppata durante il tirocinio. Tale libreria è stata progettata con l'obiettivo di semplificare le operazioni più ripetitive e onerose, sfruttando i costrutti di un linguaggio ad alto livello e consentendo, e anche di definire più oggetti all'interno di un unico file, favorendo così uno sviluppo più coerente e strutturato.\
        Attraverso un _working example_ verrà poi mostrato come tale libreria consenta di ridurre la complessità nello sviluppo dei punti più critici, mettendola a confronto con l'approccio tradizionale.\
        Infine, mostrerò la differenza in termini di righe di codice e file creati tra i due sistemi, con l'intento di affermare l'efficienza della mia libreria.
    ],
    final: false,
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

Con _Domain Specific Language_ si intende un linguaggio di programmazione meno complesso e più astratto di uno _general purpose_, specializzato in uno specifico compito. Le DSL sono sviluppate in coordinazione con esperti del campo nel quale verrà utilizzato il linguaggio.
#quote(attribution: [JetBrains#footnote[JetBrains è un'azienda specializzata nello sviluppo di ambienti di sviluppo integrati (IDE).]],block: true)[ In many cases, DSLs are intended to be used not by software people, but instead by non-programmers who are fluent in the domain the DSL addresses.]

#glos.mc è sviluppato in Java@java-book, ma questa DSL, chiamata #glos.mcf@mc-function, adotta un paradigma completamente diverso. Essa non consente di introdurre nuovi comportamenti intervenendo direttamente sul codice sorgente: le funzionalità aggiuntive vengono invece definite attraverso gruppi di comandi, interpretati dal motore interno di #glos.mc (e non dal compilatore Java), ed eseguiti solo al verificarsi di determinate condizioni. In questo modo l'utente percepisce tali funzionalità come parte integrante dei contenuti originali del gioco.
Negli ultimi anni, grazie all'introduzione e all'evoluzione di una serie di file in formato #glos.json@json, è progressivamente diventato possibile creare esperienze di gioco quasi completamente nuove. Tuttavia, il sistema presenta ancora diverse limitazioni, poiché gran parte della logica continua a essere definita e gestita attraverso i file #glos.mcf.

Il tirocinio ha avuto come obiettivo la progettazione e realizzazione di un sistema che semplifica la creazione, sviluppo e distribuzione di questi file, creando un ambiente di sviluppo unificato.
Esso consiste in una libreria Java che permette di definire la gerarchia dei file in un sistema ad albero tramite oggetti. Una volta definite tutte le _feature_, esegue il programma per ottenere un progetto pronto per l'uso.

Il risultato è un ambiente di sviluppo più coerente e accessibile, che permette di integrare _feature_ di Java in questa DSL, per facilitare la scrittura e gestione dei file.

Nel prossimo capitolo verrà presentata la struttura generale del sistema, descrivendone gli elementi principali e il loro funzionamento. In seguito verrà fatta un'analisi delle principali problematiche e limitazioni del sistema, insieme a una rassegna delle soluzioni proposte nello stato dell'arte. Successivamente sarà illustrata la struttura e implementazione della mia libreria, accompagnata da un _working example_ volto a mostrare in modo concreto il funzionamento del progetto. L'ultimo capitolo sarà dedicato all'analisi dei risultati ottenuti e delle possibili evoluzioni future.

= Struttura e Funzionalità di un Pack

== Cos'è un Pack
I file #glos.json e #glos.mcf devono trovarsi in specifiche cartelle per poter essere riconosciuti dal compilatore di #glos.mc ed essere integrati nel videogioco. La cartella radice che contiene questi file si chiama #glos.dp@datapack.\
Un #glos.dp può essere visto come la cartella `java` di un progetto Java: contiene la parte che detta i comportamenti dell'applicazione.

Come i progetti Java hanno la cartella `resources`@java-resource, anche #glos.mc dispone di una cartella in cui inserire le risorse. Questa si chiama #glos.rp@resourcepack, e contiene principalmente font, modelli 3D, #glos.tex@game-texture, traduzioni e suoni.\
Con l'eccezione di #glos.tex e suoni, i quali permettono l'estensione `png`@png e `ogg`@ogg rispettivamente, tutti gli altri file sono in formato #glos.json.\
Le #glos.rp sono state concepite e rilasciate prima dei #glos.dp, con lo scopo di dare ai giocatori un modo di sovrascrivere le #glos.tex e altri _asset_@assets del videogioco. Gli sviluppatori di #glos.dp hanno poi iniziato ad utilizzare #glos.rp per definire le risorse che il progetto da loro sviluppato avrebbe richiesto.

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

Anche se l'estensione non lo indica, il file `pack.mcmeta` è in realtà scritto in formato #glos.json e definisce l'intervallo delle versioni (chiamate _format_) supportate dalla cartella, che con ogni aggiornamento di #glos.mc variano, e non corrispondono all'effettiva _game version_.\
Ad esempio, per la versione 1.21.10 del gioco, il `pack_format` dei #glos.dp è 88 e quello delle #glos.rp è 69. Queste possono cambiare anche settimanalmente, se si stanno venendo rilasciati degli _snapshot_@snapshot.

Ancora più rilevanti sono le cartelle al di sotto di `data` e `assets`, chiamate #glos.ns@namespace. Se i progetti Java seguono la seguente struttura `com.package.author`, allora i #glos.ns possono essere visti come la sezione `package`.\

#quote(
    block: true,
    attribution: [Nathan Adams#footnote[Sviluppatore di #glos.mc parte del team che implementa _feature_ inerenti a #glos.dp.]],
    [This isn't a new concept, but I thought I should reiterate what a "namespace" is. Most things in the game has a namespace, so that if we add `something` and a mod (or map, or whatever) adds `something`, they're both different `something`s. Whenever you're asked to name something, for example a loot table, you're expected to also provide what namespace that thing comes from. If you don't specify the namespace, we default to `minecraft`. This means that `something` and `minecraft:something` are the same thing.],
)

I #glos.ns sono fondamentali per evitare che i file omonimi di un #glos.pack sovrascrivano quelli di un altro. Per questo, in genere i #glos.ns o sono abbreviazioni o coincidono con il nome stesso progetto che si sta sviluppando, e si usa lo stesso per #glos.dp e #glos.rp.\
Tuttavia, si vedrà come operare in #glos.ns distinti è sia sufficiente a garantire l'assenza di conflitti tra i diversi #glos.pack, poiché questi vengono spesso installati dagli utenti in gruppo.

Il namespace `minecraft` è riservato alle risorse native del gioco: sovrascriverle comporta il rischio di rimuovere funzionalità originali o di alterare il comportamento previsto del gioco. È interessante notare che anche gli sviluppatori di #glos.mc stessi fanno uso dei #glos.dp per definire e organizzare molti comportamenti del gioco, come definire le risorse che si possono ottenere da un baule, o gli ingredienti necessari per creare un certo oggetto. In altre parole, i #glos.dp non sono solo uno strumento a disposizione dei giocatori per personalizzare l'esperienza, ma costituiscono anche il *meccanismo interno attraverso cui il gioco stesso struttura e gestisce alcune delle sue funzionalità principali*.\
Bisogna specificare che i domandi e file `.mcfunction` non sono utilizzati in alcun modo dagli sviluppatori di #glos.mc per implementare funzionalità del videogioco. Come precedentemente citato, tutta la logica è dettata da codice Java.

All'interno dei #glos.ns si trovano directory i cui nomi identificano in maniera univoca la natura e la funzione dei contenuti al loro interno: se metto un file #glos.json che il compilatore riconosce come `loot_table` nella cartella `recipe`, il questo segnalerà un errore e il file non sarà disponibile nella sessione di gioco.

In `function` si trovano file e sottodirectory con testo in formato #glos.mcf. Questi si occupano di far comunicare tutte le parti di un #glos.pack tra loro tramite una serie di funzioni contenenti comandi.

== Comandi

Prima di spiegare cosa fanno i comandi, bisogna definire gli elementi basi su cui essi agiscono.\
In #glos.mc, si possono creare ed esplorare mondi generati in base a un _seed_@seed casuale. Ogni mondo è composto da _chunk_@chunk, colonne dalla base di 16x16 cubi, e altezza di 320.\
L'unità più piccola in questa griglia è il blocco, la cui forma coincide con quella di un cubo di lato unitario. Ogni blocco in un mondo è dotato di collisione ed individuabile tramite coordinate dello spazio tridimensionale.
Si definiscono entità invece tutti gli oggetti dinamici che si spostano in un mondo: sono dotate di una posizione, rotazione e velocità.

I dati persistenti di blocchi ed entità sono memorizzati in una struttura dati ad albero chiamata _Named Binary Tags_@nbt (#glos.nbt). Il formato "stringificato", `SNBT` è accessibile agli utenti e si presenta come una struttura molto simile a #glos.json, formata da coppie di chiave e valori.\

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
    caption: [Esempio di comando che tra tutte le entità, stampa quelle di tipo giocatore.],
)

Sebbene non disponga delle funzionalità tipiche dei linguaggi di programmazione di alto livello come cicli `for` e `while`, strutture dati complesse o variabili generiche, il sistema dei comandi fornisce comunque strumenti che consentono di riprodurre alcuni di questi comportamenti in forma limitata.

I comandi che più si avvicinano ai concetti tipici della programmazione sono:
=== Scoreboard
`scoreboard` permette di creare dizionari di tipo `<Entità, Objective>`. Un `objective` rappresenta un valore intero a cui è associata una condizione (_criteria_) che ne determina la variazione. Il _criteria_ `dummy` corrisponde ad una condizione vuota, irrealizzabile. Su questi valori è possibile eseguire operazioni aritmetiche di base, come l'aggiunta o la rimozione di un valore costante, oppure la somma, sottrazione, moltiplicazione e divisione con altri `objective`. Dunque una #glos.score può essere meglio vista come un dizionario `<Entità,<Intero, Condizione>>`.\
Prima di poter eseguire qualsiasi operazione su di essa, una #glos.score deve essere inizializzata. Questo viene fatto con il comando\ `scoreboard objectives add <objective> <criteria>`.\
Per eseguire operazioni che non dipendono da alcuna entità, si usano i cosiddetti _fakeplayer_.  Al posto di usare nomi di giocatori o selettori, si prefiggono i nomi con caratteri illegali, quali `$` e `#`. In questo modo ci si assicura che un valore non sia associato ad un vero utente.
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
Questi comandi definiscono la stringa `My Cat` nello #glos.str, successivamente combinano il valore dallo #glos.str al campo nome dell'entità gatto più vicina, e infine cancellano i dati impostati.

=== Execute
`execute` consente di eseguire un altro comando cambiando valori quali l'entità esecutrice e la posizione. Questi elementi definiscono il contesto di esecuzione, ossia l'insieme dei parametri che determinano le modalità con cui il comando viene eseguito. Si usa il selettore `@s` per fare riferimento all'entità del contesto di esecuzione corrente.\
Tramite `execute` è anche possibile specificare condizioni preliminari e salvare il risultato dell'esecuzione. Dispone inoltre di 14 sottocomandi, o istruzioni, che posso essere raggruppate in 4 categorie:
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
Questo comando sta definendo una serie di passi da fare;
+ per ogni entità (`execute as @e`);
+ sposta l'esecuzione alla loro posizione attuale (`at @s`);
+ salva l'esito nello score `on_stone` di quell'entità;
+ del controllo che, nella posizione corrente del contesto di esecuzione, il blocco sottostante sia di tipo `stone`.
Al termine dell'esecuzione, la #glos.score `on_stone` di ogni entità sarà 1 se si trovava su un blocco di pietra, 0 altrimenti.

== Funzioni
Le funzioni sono insiemi di comandi raggruppati all'interno di un file #glos.mcf, una funzione non può esistere se non in un file `.mcfunction`. A differenza di quanto il nome possa suggerire, non prevedono inerentemente valori di input o di output, ma contengono uno o più comandi che vengono eseguiti in ordine.\
Le funzioni possono essere invocate in vari modi da altri file di un datapack:

- tramite comandi: `function namespace:function_name` esegue la funzione subito, mentre `schedule namespace:function_name <delay>` la esegue dopo un certo tempo specificato.
- da _function tag_: una _function tag_ è una lista in formato #glos.json di riferimenti a funzioni. #glos.mc ne fornisce due nelle quali inserire le funzioni da eseguire rispettivamente ogni game loop@tick(`tick.json`)#footnote[Il game loop di #glos.mc viene eseguito 20 volte al secondo; di conseguenza, anche le funzioni incluse nel tag `tick.json` vengono eseguite con la stessa frequenza.], e ogni volta che si ricarica da disco il datapack (`load.json`). Queste due _function tag_ sono riconosciute dal compilatore di #glos.mc solo se nel namespace `minecraft`.
- Altri oggetti di un #glos.dp quali `Advancement` (obiettivi) e `Enchantment` (incantesimi).

Le funzioni vengono eseguite durante un game loop, completando tutti i comandi che contengono, inclusi quelli invocati altre funzioni. Le funzioni usano il contesto di esecuzione dell'entità che le sta invocando (se presente). Quando un comando `execute` altera il contesto di esecuzione, la modifica non influenza i comandi successivi, ma viene propagata alle funzioni chiamate a partire da quel punto.

In base alla complessità del branching e alle operazioni eseguite dalle funzioni, il compilatore (o più precisamente, il motore di esecuzione dei comandi) deve allocare una certa quantità di risorse per svolgere tutte le istruzioni durante un singolo tick. Il tempo di elaborazione aggiuntivo richiesto per l'esecuzione di un comando o di una funzione è definito _overhead_.

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

L'esecuzione dei comandi di una funzione può essere interrotta dal comando `return`. Funzioni che non contengono questo comando possono essere considerate di tipo `void`. Tuttavia il comando return può solamente restituire la parola chiave `fail` o un intero predeterminato, a meno che non si usi una _macro_.

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
- #e dotato di iterazione o ricorsione: deve consentire la ripetizione di operazioni. In questo linguaggio, tale comportamento è ottenuto attraverso la ricorsione delle funzioni.
- Permette la memorizzazione di dati: deve poter gestire una quantità arbitraria di informazioni. In #glos.mcf, ciò avviene tramite la manipolazione dei dati all'interno dei #glos.str.

Pertanto, #glos.mcf può essere considerato a tutti gli effetti un linguaggio Turing completo. Tuttavia, come verrà illustrato nella sezione successiva, sia il linguaggio stesso sia il sistema di file su cui si basa presentano diverse limitazioni e inefficienze. In particolare, l'esecuzione di operazioni relativamente semplici richiede un numero considerevole di righe di codice e di file, che in un linguaggio di più alto livello potrebbero essere realizzate in modo molto più conciso.

= Problemi pratici e limiti tecnici

Il linguaggio #glos.mcf non è stato originariamente concepito come un linguaggio di programmazione Turing completo. Nel 2012, prima dell'introduzione dei #glos.dp, il comando `scoreboard` veniva utilizzato unicamente per monitorare statistiche dei giocatori, come il tempo di gioco o il numero di blocchi scavati. In seguito, osservando come questo e altri comandi venissero impiegati dalla comunità per creare nuove meccaniche e giochi rudimentali, gli sviluppatori di #glos.mc iniziarono ampliare progressivamente il sistema, fino ad arrivare, nel 2017, alla nascita dei #glos.dp.

Ancora oggi l'ecosistema dei #glos.dp è in costante evoluzione, con _snapshot_ che introducono periodicamente nuove funzionalità o ne modificano di già esistenti. Tuttavia, il sistema presenta ancora diverse limitazioni di natura tecnica, dovute al fatto che non era stato originariamente progettato per supportare logiche di programmazione complesse o essere utilizzato in progetti di grandi dimensioni.

== Limitazioni di Scoreboard
Come è stato precedentemente citato, `scoreboard` è usato per eseguire operazioni su interi. Operare con questo comando tuttavia presenta numerosi problemi.

Innanzitutto, oltre a dover creare un _objective_ prima di poter eseguire operazioni su di esso, è necessario assegnare le costanti che si utilizzeranno, qualora si volessero eseguire operazioni di moltiplicazione e divisione. Inoltre, un singolo comando `scoreboard` prevede una sola operazione.

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

Si noti come, nell'esempio precedente, le operazioni vengano eseguite sulla variabile $y$, il cui valore viene poi assegnato a $x$. Di conseguenza, sia `#x` che `#y` conterranno il risultato finale pari a 3. Questo implica che il valore di $y$ viene modificato, a differenza dell'espressione a cui l'esempio si ispira, dove $y$ dovrebbe rimanere invariato.
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

Dunque, in seguito all'introduzione delle _macro_, si sono iniziate ad utilizzare delle _lookup table_. Queste sono _array_ salvati in #glos.str che contengono tutti gli output di una certa funzione in un intervallo prefissato.

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

Dato che sono richiesti gli output di decine, se non centinaia di queste funzioni, i comandi per creare le _lookup table_ vengono generati con script Python@python-book, ed eseguiti da #glos.mc solamente quando si ricarica il #glos.dp, dato che queste strutture non sono soggette ad operazioni di scrittura, solo di lettura.

== Alto Rischio di Conflitti

Nella sezione precedente è stato modificato lo #glos.str `my_storage` per inserirvi un array. Si noti che non è stato specificato alcun #glos.ns, per cui il sistema ha assegnato implicitamente quello predefinito, `minecraft:`.

Qualora un mondo contenesse due #glos.dp sviluppati da autori diversi, ed entrambi modificassero `my_storage` senza indicare esplicitamente un #glos.ns, potrebbero verificarsi conflitti.\

Un'altra situazione che può portare a conflitti è quando due #glos.dp sovrascrivono la stessa risorsa nel #glos.ns `minecraft`. Se entrambi modificano `minecraft/loot_table/blocks/stone.json`, che determina gli oggetti si possono ottenere da un blocco di pietra, il compilatore utilizzerà il file del #glos.dp che è stato caricato per ultimo.

Il rischio di sovrascrivere o utilizzare in modo improprio risorse appartenenti ad altri #glos.dp non riguarda solo gli elementi che prevedono un #glos.ns, ma si estende anche a componenti come #glos.score e #glos.tag.

In questo esempio sono presenti due #glos.dp, sviluppati da autori diversi, con lo stesso obiettivo: eseguire una funzione relativa all'entità chiamante (`@s`) al termine di un determinato intervallo di tempo. In entrambi i casi, le funzioni incaricate dell'aggiornamento del timer vengono eseguite ogni _tick_, ovvero venti volte al secondo.

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

Di conseguenza, se nell'esempio precedente gli sviluppatori intendono che la funzione `timer` venga eseguita esclusivamente dalle entità contrassegnate da un determinato _tag_, ad esempio `has_timer`, i comandi per invocare `timer_a` e `timer_b` risulteranno i seguenti:

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

In conclusione, è buona pratica utilizzare prefissi anche per i nomi di #glos.str, #glos.score e _tag_, nonostante i #glos.dp compilano correttamente anche senza di essi.

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

Ora, se l'entità è di tipo `cow`, il comando alla riga 2 non verrà mai eseguito, anche se la condizione sarebbe soddisfatta. Dunque, è necessario creare una funzione che contenga quei due comandi.

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

Considerando che i #glos.dp si basano sull'esecuzione di funzioni *in base a eventi già esistenti*, sono numerosi i casi in cui ci si trova a creare più file che contengono un numero ridotto, purché significativo, di comandi.

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

In questa funzione, la ricerca viene interrotta da `return` appena si trova un diamante, ed è stato provato che abbia un _overhead_ minore della ricorsione. Come nel caso delle _lookup table_, i file che fanno controlli di questo genere vengono creati script Python.


Infine, @esempio_macro dimostra che, per utilizzare una _macro_, è sempre necessario creare una funzione capace di ricevere i parametri di un'altra funzione e applicarli a uno o più comandi indicati con `$`. Questa è probabilmente una delle ragioni più valide per cui scrivere una nuova funzione; tuttavia, va comunque considerata nel conteggio complessivo dei file la cui creazione non è necessaria in un linguaggio di programmazione ad alto livello.

Dunque, programmando in #glos.mcf è necessario creare una funzione, ovvero un file, ogni volta che si necessiti di:
- un blocco `if-else` che esegua più comandi;
- un ciclo;
- utilizzare una _macro_.

Ciò comporta un numero di file sproporzionato rispetto alle effettive righe di codice. Tuttavia, ci sono altre problematiche relative alla struttura delle cartelle e dei file nello sviluppo di #glos.dp e #glos.rp.

== Organizzazione e Complessità della Struttura dei File
I problemi mostrati fin'ora sono prettamente legati alla sintassi dei comandi e ai limiti delle funzioni, tuttavia non sono da trascurare il quantitativo di file di un progetto.

Affinché #glos.dp e #glos.rp vengano riconosciuti dal compilatore, essi devono trovarsi rispettivamente nelle directory `.minecraft/saves/<world_name>/datapacks` e `.minecraft/resourcepacks`. Tuttavia, operare su queste due cartelle in modo separato può risultare oneroso, considerando l'elevato grado di interdipendenza tra i due sistemi. Lavorare direttamente dalla directory radice `.minecraft/` invece inoltre poco pratico, poiché essa contiene un numero considerevole di file e cartelle non pertinenti allo sviluppo del #glos.pack.

Una possibile soluzione consiste nel creare una directory che contenga sia il #glos.dp sia il #glos.rp e, successivamente, utilizzare _symlink_ o _junction_@symlink per creare riferimenti dalle rispettive cartelle verso i percorsi in cui il compilatore si aspetta di trovarli.\
I _symlink_ (collegamenti simbolici) e le _junction_ sono riferimenti a file o directory che consentono di accedere a un percorso diverso come se fosse locale, evitando la duplicazione dei contenuti.

Disporre di un'unica cartella radice contenente #glos.dp e #glos.rp semplifica notevolmente la gestione del progetto. In particolare, consente di creare una sola repository Git@git, facilitando così il versionamento del codice, il tracciamento delle modifiche e la collaborazione tra più sviluppatori.\
Attraverso il sistema delle _release_ di GitHub@github è possibile ottenere un link diretto a #glos.dp e #glos.rp pubblicati, che può poi essere utilizzato nei principali siti di hosting. Queste piattaforme, essendo spesso gestite da piccoli team di sviluppo, tendono ad affidarsi a servizi esterni per la memorizzazione dei file, come GitHub o altri provider.

Ipotizzando di operare in un ambiente di lavoro unificato, come quello illustrato in precedenza, viene presentato un esempio di struttura che mostra i file necessari per introdurre un nuovo _item_@item (oggetto). Sebbene l'_item_ costituisca una delle funzionalità più semplici da implementare, la sua integrazione richiede comunque un numero non trascurabile di file.
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

Alla luce delle numerose limitazioni di questo sistema, sono state rapidamente sviluppate soluzioni volte a rendere il processo di sviluppo più efficiente e accessibile.

In primo luogo, gli stessi sviluppatori di #glos.mc dispongono di strumenti interni che automatizzano la generazione dei file #glos.json necessari al corretto funzionamento di determinate _feature_. Durante lo sviluppo, tali file vengono creati automaticamente tramite codice Java eseguito in parallelo alla scrittura del codice sorgente, evitando così la necessità di definirli manualmente.

Un esempio lampante è il file `sounds.json`, che registra i suoni definisce quali file `.ogg` utilizzare. Questo contiene quasi 25.000 righe di codice, creato tramite software che viene eseguito ogni volta che viene inserita una nuova _feature_ che richiede un nuovo suono.

Tuttavia, questo software non è disponibile al pubblico, e anche se lo fosse, semplificherebbe la creazione solo dei file #glos.json, non #glos.mcf. Dunque, sviluppatori indipendenti hanno realizzato dei propri precompilatori, progettati per generare automaticamente #glos.dp e #glos.rp a partire da linguaggi o formati più intuitivi.

Un precompilatore è uno strumento che consente di scrivere le risorse e la logica di gioco in un linguaggio o formato più semplice, astratto o strutturato, e di tradurle automaticamente nei numerosi file #glos.json, #glos.mcf e cartelle richieste dal gioco.\
Il precompilatore al momento più completo e potente si chiama _beet_@beet, e si basa sulla sintassi di Python, integrata con comandi di #glos.mc.\
Questo precompilatore, come molti altri, presenta due criticità principali:
- Elevata barriera d'ingresso: solo gli sviluppatori con una buona padronanza di Python sono in grado di sfruttarne appieno le potenzialità;
- Assenza di documentazione: la mancanza di una guida ufficiale rende il suo utilizzo accessibile quasi esclusivamente a chi è in grado di interpretare direttamente il codice sorgente di _beet_.

Altri precompilatori forniscono un'interfaccia più intuitiva e un utilizzo più immediato al costo di  completezza delle funzionalità, limitandosi a supportare solo una parte delle componenti che costituiscono l'ecosistema dei #glos.pack. Spesso, inoltre, la sintassi di questi linguaggi risulta più verbosa rispetto a quella dei comandi originali, poiché essi offrono esclusivamente un approccio programmatico alla composizione dei comandi senza portare ad alcun incremento nella loro velocità di scrittura.

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
Questo è più articolato rispetto alla sintassi tradizionale `execute as @a at @s if entity @s[tag=my_entity] run say hello`.

= La mia Implementazione

== Approccio al Problema

Dato il contesto descritto e le limitazioni degli strumenti esistenti, ho cercato una soluzione che permettesse di ridurre la complessità d'uso senza sacrificare la completezza delle funzionalità.
Di seguito verranno illustrate le principali decisioni progettuali e le ragioni che hanno portato alla scelta del linguaggio di sviluppo.

Inizialmente, su suggerimento del prof. Padovani, ho tentato di progettare un _superset_@superset di #glos.mcf, ossia un linguaggio che estende quello originale introducendo nuove funzionalità mantenendone però la compatibilità.
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

Ho quindi pensato di sviluppare una libreria che consentisse di definire la struttura di un #glos.pack, dalla radice del progetto fino ai singoli file, sotto forma di oggetti. In questo modo sarebbe stato possibile rappresentare l'intero insieme delle risorse come una struttura dati ad albero n-ario. Questa, al momento dell'esecuzione, sarebbe stata attraversata per generare automaticamente i file e le cartelle corrispondenti ai nodi, all'interno delle directory di #glos.dp e #glos.rp.

Il principale vantaggio di questo approccio consiste nella possibilità di definire più nodi all'interno dello stesso file, evitando così la frammentazione del codice e semplificando la gestione della struttura complessiva del #glos.pack. Inoltre, l'impiego di un linguaggio ad alto livello consente di sfruttare costrutti quali cicli e funzioni per automatizzare la generazione di comandi ripetitivi (ad esempio le già citate lookup table). Infine, la rappresentazione a oggetti della struttura consente di definire metodi di utilità per accedere e modificare i nodi da qualsiasi punto del progetto. Ad esempio, si può implementare un metodo `addTranslation(key, value)` che permette di aggiungere, indipendentemente dal contesto in cui viene invocato, una nuova voce nel file delle traduzioni.

Dunque ho pensato a quale linguaggio di programmazione si potesse usare per realizzare questa libreria. Le mie opzioni erano Python e Java, e dopo aver valutato i loro punti di forza e debolezza, ho deciso di usare Java.

#figure(
    table(
        align: horizon + left,
        columns: 3,
        [], [Vantaggi], [Svantaggi],
        [Python],
        [
            - Gestione semplice di stringhe (`f-strings`) e file JSON;
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

Dopo un'attenta analisi, ho scelto di utilizzare Java per lo sviluppo del progetto, poiché secondo me è il mezzo ideale per l'applicazione di _design pattern_ in grado di semplificare e rendere più robusta la fase di sviluppo, anche a costo di sacrificare parzialmente la comodità d'uso per l'utente finale.\
Inoltre, il tipaggio statico di Java permette di identificare in fase di sviluppo eventuali utilizzi impropri di oggetti o metodi della libreria, consentendo anche agli utenti meno esperti di comprendere più facilmente il funzionamento del sistema.

Il progetto, denominato _Object Oriented Pack_ (OOPACK), è organizzato in 4 sezioni principali.
/ `internal`: Contiene classi astratte e interfacce che riproducono la struttura di un generico _filesystem_. Classi e metodi di questo _package_@package non saranno mai utilizzate dal programmatore.
/ `objects`: Contiene le classi che rappresentano gli oggetti utilizzati nei #glos.dp e #glos.rp.
/ `util`: Raccoglie metodi di utilità impiegati sia per il funzionamento del progetto, sia a supporto del programmatore (ponendo attenzione alla visibilità dei singoli metodi).
/ Radice del progetto: Contiene gli oggetti principali che descrivono struttura di un #glos.pack (`Datapack`,`Resourcepack`,`Namespace`,`Project`).

== Spiegazione basso livello

== Spiegazione alto livello

== Uso working example

= Conclusione
