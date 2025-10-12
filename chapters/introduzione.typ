#import "/util.typ": *

= Introduzione
Se non fosse per il videogioco #glos.mc, non sarei qui ora. Quello che per me inizialmente era un modo di esprimere la mia creatività piazzando cubi in un mondo tridimensionale, si è rivelato presto essere il luogo dove per anni ho scritto ed eseguito i miei primi frammenti di codice.\
Motivato dalla mia abilità nel saper programmare in questo linguaggio non banale, ho perseguito una carriera di studio in informatica.

Il sistema che inizialmente era stato pensato dagli sviluppatori della piattaforma come un modo di "barare" tramite comandi per ottenere oggetti istantaneamente e senza il minimo sforzo, si è col tempo evoluto in un ecosistema di file e codice che permette agli sviluppatori che decidono di usare questa _Domain Specific Language_ per modificare moltissimi comportamenti dell'ambiente videoludico.

#glos.mc è scritto in Java, ma questa DSL chiamata #glos.mcf è un linguaggio completamente diverso. Non fornisce agli sviluppatori il modo di aggiungere comportamenti nuovi, modificando il codice sorgente. Permette piuttosto di aggiungere _feature_ aggiungendo frammenti di codice che vengono eseguiti solo sotto certe condizioni, dando ad un utilizzatore l'illusione che queste facciano parte dei contenuti classici del videogioco. Negli ultimi anni, in seguito ad aggiornamenti, tramite una serie di file #glos.json sta gradualmente diventando possibile creare esperienze del tutto nuove. Tuttavia questo sistema è ancora limitato, e gran parte della logica è comunque dettata dai file #glos.mcf.

== Cos'è un _pack_
I file #glos.json e #glos.mcf devono trovarsi in specifiche cartelle per poter essere riconosciuti dal compilatore di #glos.mc ed essere integrati nel videogioco. La cartella radice che contiene questi file si chiama #glos.dp.\
Un #glos.dp può essere visto come la cartella #r("java") di un progetto Java: contiene la parte che detta i comportamenti dell'applicazione.

Come i progetti Java hanno la cartella #r("resources"), anche #glos.mc dispone di una cartella in cui inserire le risorse. Questa si chiama #glos.rp, e contiene principalmente font, modelli 3D, #glos.tex, traduzioni e suoni#footnote[Con l'eccezione di #glos.tex e suoni, tutti gli altri file sono in formato #glos.json.].\
Le #glos.rp sono state concepite prima dei #glos.dp, per permettere ai giocatori sovrascrivere le texture e altri asset del videogioco. Gli sviluppatori di #glos.dp hanno poi iniziato ad utilizzarle per definire nuove risorse, inerenti al progetto che stanno sviluppando.

_Datapack_ e #glos.rp formano il #glos.pack che, riprendendo il parallelismo precedente, corrisponde all'intero progetto Java. Questa sarà poi la cartella che verrà pubblicata.
