#import "/util.typ": *
#import "@preview/codly:1.3.0": *

= Introduzione
Se non fosse per il videogioco #glos.mc, non sarei qui ora. Quello che per me inizialmente era un modo di esprimere la mia creatività piazzando cubi in un mondo tridimensionale, si è rivelato presto essere il luogo dove per anni ho scritto ed eseguito i miei primi frammenti di codice.\
Motivato dalla mia abilità nel saper programmare in questo linguaggio non banale, ho perseguito una carriera di studio in informatica.

Il sistema che inizialmente era stato pensato dagli sviluppatori della piattaforma come un modo di "barare" tramite comandi per ottenere oggetti istantaneamente e senza il minimo sforzo, si è col tempo evoluto in un ecosistema di file e codice che permette agli sviluppatori che decidono di usare questa _Domain Specific Language_ per modificare moltissimi comportamenti dell'ambiente videoludico.

#glos.mc è scritto in Java, ma questa DSL chiamata #glos.mcf è un linguaggio completamente diverso. Non fornisce agli sviluppatori il modo di aggiungere comportamenti nuovi, modificando il codice sorgente. Permette piuttosto di aggiungere _feature_ aggiungendo frammenti di codice che vengono eseguiti solo sotto certe condizioni, dando ad un utilizzatore l'illusione che queste facciano parte dei contenuti classici del videogioco. Negli ultimi anni, in seguito ad aggiornamenti, tramite una serie di file #glos.json sta gradualmente diventando possibile creare esperienze del tutto nuove. Tuttavia questo sistema è ancora limitato, e gran parte della logica è comunque dettata dai file #glos.mcf.

== Cos'è un #glos.pack
I file #glos.json e #glos.mcf devono trovarsi in specifiche cartelle per poter essere riconosciuti dal compilatore di #glos.mc ed essere integrati nel videogioco. La cartella radice che contiene questi file si chiama #glos.dp.\
Un #glos.dp può essere visto come la cartella #r("java") di un progetto Java: contiene la parte che detta i comportamenti dell'applicazione.

Come i progetti Java hanno la cartella #r("resources"), anche #glos.mc dispone di una cartella in cui inserire le risorse. Questa si chiama #glos.rp, e contiene principalmente font, modelli 3D, #glos.tex, traduzioni e suoni.\
Con l'eccezione di #glos.tex e suoni, i quali permettono l'estensione #r("png") e #r("ogg") rispettivamente, tutti gli altri file sono in formato #glos.json.\
Le #glos.rp sono state concepite prima dei #glos.dp, e permettevano ai giocatori sovrascrivere le #glos.tex e altri asset del videogioco. Gli sviluppatori di #glos.dp hanno poi iniziato ad utilizzarle per definire nuove risorse, inerenti al progetto che stanno sviluppando.

_Datapack_ e #glos.rp formano il #glos.pack che, riprendendo il parallelismo precedente, corrisponde all'intero progetto Java. Questa sarà poi la cartella che verrà pubblicata.

== Struttura di #glos.dp e #glos.rp

All'interno di un #glos.pack, #glos.dp e #glos.rp hanno una struttura molto simile.

#import "@preview/treet:1.0.0": *

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

Anche se l'estensione non lo indica, il file è in realtà scritto in formato #glos.json e definisce l'intervallo delle versioni (chiamate _format_) supportate dalla cartella, che con ogni aggiornamento di #glos.mc variano, e non corrispondono all'effettiva _game version_.\
Ad esempio, per la versione 1.21.10 del gioco, il #r("pack_format") dei #glos.dp è 88 e quello delle #glos.rp è 69. Queste possono cambiare anche settimanalmente, se si stanno venendo rilasciati degli _snapshot_#footnote[Con il termine snapshot si indicano le versioni di sviluppo intermedie del gioco, rilasciate periodicamente per testare le modifiche in arrivo nei futuri aggiornamenti.].

Ancora più rilevanti sono le cartelle al di sotto di #r("data") e #r("assets"), chiamate #glos.ns. Se i progetti Java seguono la seguente struttura #r("com.package.author"), allora i #glos.ns possono essere visti come la sezione #r("package").\
I #glos.ns sono fondamentali per evitare che i file omonimi di un #glos.pack sovrascrivano quelli di un altro. Per questo, in genere i #glos.ns o sono abbreviazioni o coincidono con il nome stesso progetto che si sta sviluppando, e si usa lo stesso per #glos.dp e #glos.rp.\
Tuttavia, in seguito si mostrerà come operare in namespace diversi non è sufficiente l'assenza di conflitti tra i #glos.pack, che spesso vengono utilizzati in gruppo.

All'interno dei #glos.ns si trovano directory i cui nomi identificano in maniera univoca la natura e la funzione dei contenuti al loro interno: se metto un file #glos.json che il compilatore riconosce come #r("loot_table") nella cartella #r("recipe"), il questo segnalerà un errore e il file non sarà disponibile nella sessione di gioco.

In #r("function") si trovano file e sottodirectory con testo in formato #glos.mcf. Questi si occupano di far comunicare tutte le parti di un #glos.pack tra loro tramite una serie di comandi.

== Comandi

Prima di spiegare cosa fanno i comandi, bisogna definire gli elementi basi su cui essi agiscono.\
In #glos.mc, si possono creare ed esplorare mondi generati in base a un _seed_ casuale. Ogni mondo è composto da _chunk_, colonne dalla base di 16x16 cubi, e altezza di 320.\
L'unità più piccola in questa griglia è il blocco, la cui forma coincide con quella di un cubo di lato unitario. Ogni blocco in un mondo è dotato di collisione ed individuabile tramite coordinate dello spazio tridimensionale.
Si definiscono entità invece tutti gli oggetti dinamici che si spostano in un mondo: sono dotate di una posizione, rotazione e velocità.

I dati persistenti di blocchi ed entità sono memorizzati in una struttura dati ad albero chiamata _Named Binary Tags_ (#glos.nbt). Il formato "stringificato", #r("SNBT") è accessibile agli utenti e si presenta come una struttura molto simile a #glos.json, formata da coppie di chiave e valori.\

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
    caption: [Esempio di #r("SNBT").],
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
Sebbene non disponga delle funzionalità tipiche dei linguaggi di programmazione di alto livello — come cicli for e while, strutture dati complesse o variabili generiche — il sistema dei comandi fornisce comunque strumenti che consentono di riprodurre alcuni di questi comportamenti in forma limitata.

I comandi che più si avvicinano ai concetti tipici della programmazione sono:
=== Scoreboard
#r("scoreboard") permette di creare dizionari di tipo #r("<Entità, Objective>"). Un #r("objective") rappresenta un valore intero a cui è associata una condizione (_criteria_) che ne determina la variazione. Il _criteria_ `dummy` corrisponde ad una condizione vuota, irrealizzabile. Su questi valori è possibile eseguire operazioni aritmetiche di base, come l'aggiunta o la rimozione di un valore costante, oppure la somma, sottrazione, moltiplicazione e divisione con altri #r("objective").\
Prima di poter eseguire qualsiasi operazione su di essa, una #glos.score deve essere inizializzata. Questo viene fatto con il comando\ #r("scoreboard objectives add <objective> <criteria>").\
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
#r("data") consente di ottenere, modificare e combinare i #glos.nbt associati a entità, blocchi e #glos.str.
Come menzionato in precedenza, il formato #glos.nbt — una volta compresso — viene utilizzato per la persistenza dei dati di gioco. Oltre alle informazioni relative a entità e blocchi, in questo formato vengono salvati anche gli #glos.str. Questi sono un modo efficiente di immagazzinare dati arbitrari senza dover dipendere dall'esistenza di un certo blocco o entità. Per prevenire i conflitti, ogni #glos.str dispone di una _resource location_, che convenzionalmente coincide con il #glos.ns. Vengono dunque salvati come `command_storage_<namespace>.dat`.

#figure(
    ```mcfunction
    data modify storage my_namespace:storage name set value "My Chicken"
    data merge entity @n[type=chicken] CustomName from storage my_namespace:storage name
    data remove storage my_namespace:storage name
    ```,
    caption: [Esempio di operazioni su dati #glos.nbt],
)
Questi comandi definiscono la stringa `My Chicken` nello #glos.str, successivamente combinano il valore dallo #glos.str al campo nome della gallina più vicina, e infine cancellano i dati impostati.

=== Contesto di Esecuzione e Command Stack
Prima di parlare dei prossimi comandi, bisogna spiegare in che modo #glos.mc esegue gruppi di comandi.

=== Execute
#r("execute") consente di eseguire un altro comando cambiando valori quali l'entità esecutrice e la posizione. Questi elementi definiscono il contesto di esecuzione, ossia l'insieme dei parametri che determinano le modalità con cui il comando viene eseguito.\
Tramite #r("execute") è anche possibile specificare condizioni preliminari e salvare il risultato dell'esecuzione. Dispone inoltre di 14 sottocomandi, o istruzioni, che posso essere raggruppate in 4 categorie:
- modificatori: cambiano il contesto di esecuzione;
- condizionali: controllano se certe condizioni sono rispettate;
- contenitori: salvano i valori di output di un comando in una #glos.score, o in un contenitore di NBT;
- #r("run"): esegue un altro comando.
Tutti questi sottocomandi possono essere concatenati e usati più volte all'interno di uno stesso comando #r("execute").

#figure(
    ```mcfunction
    execute as @e
      at @s
      store result score @s on_stone
      if block ~ ~-1 ~ stone
    ```,
    caption: [Esempio di comando #r("execute").],
)
Questo comando sta definendo una serie di passi da fare;
+ per ogni entità (`execute as @e`);
+ sposta l'esecuzione alla loro posizione attuale (`at @s`);
+ salva l'esito nello score `on_stone` di quell'entità;
+ del controllo che, nella posizione corrente del contesto di esecuzione, il blocco sottostante sia di tipo `stone`.
Al termine dell'esecuzione, il valore `on_stone` di ogni entità sarà 1 se si trovava su un blocco di pietra, 0 altrimenti.

== Funzioni
Le funzioni sono insiemi di comandi raggruppati all'interno di un file #glos.mcf. A differenza di quanto il nome possa suggerire, non prevedono parametri di input o di output, ma contengono contengono uno o più comandi che vengono eseguiti in ordine.\
Le funzioni possono essere invocate in vari modi da altri file di un datapack:

- tramite comandi: `function namespace:function_name` esegue la funzione subito, mentre `schedule namespace:function_name <delay>` la esegue dopo un certo tempo specificato.
- da _function tag_: una _function tag_ è una lista in formato #glos.json di funzioni. #glos.mc ne fornisce due nelle quali inserire le funzioni da eseguire ogni game loop (`tick.json`)#footnote[Il game loop di #glos.mc viene eseguito 20 volte al secondo; di conseguenza, anche le funzioni incluse nel tag `tick.json` vengono eseguite con la stessa frequenza.], e ogni volta che si ricarica da disco il datapack (`load.json`). Queste due _function tag_ sono riconosciute dal compilatore di #glos.mc solo se nel namespace `minecraft`.
- Altri oggetti di un #glos.dp quali `Advancement` (obiettivi) e `Enchantment` (condizioni).

Le funzioni vengono eseguite durante un game loop, completando tutti i comandi che contengono, inclusi quelli invocati altre funzioni. Le funzioni usano il contesto di esecuzione dell'entità che sta invocando la funzione. un comando `execute` può cambiare il contesto, ma non si applicherà a tutti i comandi a seguirlo.

Le funzioni possono includere linee _macro_, ovvero comandi che preceduti dal simbolo `$`, hanno parte o l'intero corpo sostituito al momento dell'invocazione da un termine #glos.nbt indicato dal comando invocante.

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
)
Il primo comando di `main.mcfunction` stamperà `my value is bar`, il secondo `my value is 123`.

L'esecuzione dei comandi di una funzione può essere interrotta dal comando `return`. Funzioni che non contengono questo comando possono essere considerate di tipo `void`. Tuttavia il comando return può solamente restituire `fail` o un intero predeterminato, a meno che non si usi una _macro_.

Una funzione può essere richiamata ricorsivamente, anche modificando il contesto in cui viene eseguita. Questo comporta il rischio di creare chiamate senza fine, qualora la funzione si invochi senza alcuna condizione di arresto. È quindi responsabilità del programmatore definire i vincoli alla chiamata ricorsiva.

#codly(
    header: [iterate.mcfunction],
)
#figure(
    ```mcfunction
    particle flame ~ ~ ~
    execute if entity @p[distance=..10] positioned ^ ^ ^0.1 run function foo:iterate
    ```,
    caption: [Esempio di comando #r("execute").],
)

Questa funzione ogni volta che viene chiamata creerà una piccola texture intangibile e temporanea (_particle_), alla posizione in cui è invocata la funzione. Successivamente controlla se è presente un giocatore nel raggio di 10 blocchi. In caso positivo si sposta il contesto di esecuzione avanti di $1/10$ di blocco e si chiama nuovamente la funzione. Quando il sotto-comando `if`fallisce, la funzione non sarà più eseguita.

Un linguaggio di programmazione si definisce Turing completo se:
- dispone di rami condizionali;
- è possibile ripetere la stessa azione più volte;
- può memorizzare una quantità arbitraria di dati.
`
