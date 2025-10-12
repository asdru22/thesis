#import "/util.typ": *

= Introduzione
Se non fosse per il videogioco #glos.mc, non sarei qui ora. Quello che per me inizialmente era un modo di esprimere la mia creatività piazzando cubi in un mondo tridimensionale, si è rivelato presto essere il luogo dove per anni ho scritto ed eseguito i miei primi frammenti di codice.\
Motivato dalla mia abilità nel saper programmare in questo linguaggio non banale, ho perseguito una carriera di studio in informatica.

Il sistema che inizialmente era stato pensato dagli sviluppatori della piattaforma come un modo di "barare" tramite comandi per ottenere oggetti istantaneamente e senza il minimo sforzo, si è col tempo evoluto in un ecosistema di file e codice che permette agli sviluppatori che decidono di usare questa _Domain Specific Language_ per modificare moltissimi comportamenti dell'ambiente videoludico.

#glos.mc è scritto in Java, ma questa DSL chiamata #glos.mcf è un linguaggio completamente diverso. Non fornisce agli sviluppatori il modo di aggiungere comportamenti nuovi, modificando il codice sorgente. Permette piuttosto di aggiungere _feature_ aggiungendo frammenti di codice che vengono eseguiti solo sotto certe condizioni, dando ad un utilizzatore l'illusione che queste facciano parte dei contenuti classici del videogioco. Negli ultimi anni, in seguito ad aggiornamenti, tramite una serie di file #glos.json sta gradualmente diventando possibile creare esperienze del tutto nuove. Tuttavia questo sistema è ancora limitato, e gran parte della logica è comunque dettata dai file #glos.mcf.

== Cos'è un #glos.pack
I file #glos.json e #glos.mcf devono trovarsi in specifiche cartelle per poter essere riconosciuti dal compilatore di #glos.mc ed essere integrati nel videogioco. La cartella radice che contiene questi file si chiama #glos.dp.\
Un #glos.dp può essere visto come la cartella #r("java") di un progetto Java: contiene la parte che detta i comportamenti dell'applicazione.

Come i progetti Java hanno la cartella #r("resources"), anche #glos.mc dispone di una cartella in cui inserire le risorse. Questa si chiama #glos.rp, e contiene principalmente font, modelli 3D, #glos.tex, traduzioni e suoni#footnote[Con l'eccezione di #glos.tex e suoni, tutti gli altri file sono in formato #glos.json.].\
Le #glos.rp sono state concepite prima dei #glos.dp, e permettevano ai giocatori sovrascrivere le texture e altri asset del videogioco. Gli sviluppatori di #glos.dp hanno poi iniziato ad utilizzarle per definire nuove risorse, inerenti al progetto che stanno sviluppando.

_Datapack_ e #glos.rp formano il #glos.pack che, riprendendo il parallelismo precedente, corrisponde all'intero progetto Java. Questa sarà poi la cartella che verrà pubblicata.

== Struttura di #glos.dp e #glos.rp

All'interno di un #glos.pack, #glos.dp e #glos.rp hanno una struttura molto simile.

#import "@preview/treet:1.0.0": *

#figure(
    grid(
        columns: 2,
        gutter: 10em,
        align(left, tree-list[
            - datapack
                - pack.mcmeta
                - pack.png
                - data
                    - namespaces...
                        - advancement
                        - function
                        - loot_table
                        - recipe
                        - worldgen
                        - ...
        ]),
        align(left, tree-list[
            - resourcepack
                - pack.mcmeta
                - pack.png
                - assets
                    - namespaces...
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

Anche se l'estensione non lo indica, il file è in realtà scritto in formato #glos.json e definisce l'intervallo delle versioni (chiamate _format_) supportate dalla cartella, che con ogni aggiornamento di #glos.mc variano, e non corrispondono all'effettiva _game version_#footnote[Ad esempio, per la versione 1.21.10 del gioco, il #r("pack_format") dei #glos.dp è 88 e quello delle #glos.rp è 69.].

Ancora più rilevanti sono le cartelle al di sotto di #r("data") e #r("assets"), chiamate #glos.ns. Se i progetti Java seguono la seguente struttura #r("com.package.author"), allora i #glos.ns possono essere visti come la sezione #r("package").\
I #glos.ns sono fondamentali per evitare che i file omonimi di un #glos.pack sovrascrivano quelli di un altro. Per questo, in genere i #glos.ns o sono abbreviazioni o coincidono con il nome stesso progetto che si sta sviluppando, e si usa lo stesso per #glos.dp e #glos.rp.\
Tuttavia, in seguito si mostrerà come operare in namespace diversi non è sufficiente l'assenza di conflitti tra i #glos.pack, che spesso vengono utilizzati in gruppo.

All'interno dei #glos.ns si trovano directory i cui nomi identificano in maniera univoca la natura e la funzione dei contenuti al loro interno: se metto un file #glos.json che il compilatore riconosce come #r("loot_table") nella cartella #r("recipe"), il questo segnalerà un errore e il file non sarà disponibile nella sessione di gioco.

In #r("function") si trovano file e sottodirectory con testo in formato #glos.mcf. Questi si occupano di far comunicare tutte le parti di un #glos.pack tra loro tramite una serie di comandi.

== Comandi e Funzioni
Il nome dell'estensione #glos.mcf deriva dal termine #r("Function"), che in #glos.mc rappresenta un insieme di comandi.
