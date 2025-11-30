#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.5" as fletcher: edge, node
#import "@preview/numbly:0.1.0": numbly
#import "@preview/codly:1.3.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": chart, plot
#set text(lang: "it")
#let title = [Un Framework per la  Meta-programmazione in _Minecraft_]

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: university-theme.with(
    aspect-ratio: "16-9",
    progress-bar: false,
    config-info(
        title: title,
        subtitle: [Libreria OOPACK],
        author: [Nanni Alessandro],
        date: datetime(
            year: 2025,
            month: 12,
            day: 16,
        ).display("[day]/[month]/[year]"),
        institution: [Alma Mater Studiorum Università di Bologna],
        short-title: title,
    ),
)

#show heading.where(level: 1): it => text(fill: rgb("#04364A"), it)


#title-slide()
== Contenuti <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

#slide[
    = Minecraft come piattaforma di sviluppo

    Minecraft non è solo un gioco, ma un'ambiente programmabile tramite _datapack_ (logica) e _resourcepack_ (risorse). Queste due cartelle costituiscono un _pack_.

    Come linguaggio di programmazione si utilizza _mcfunction_, un Domain Specific Language (DSL) interpretato dal motore di gioco.

    La tesi si propone di analizzare le problematiche del DSL e dell'ecosistema di file sottostante ai _pack_, per poi affrontarle mediante la progettazione e l'implementazione di una libreria Java dedicata alla meta-programmazione.
]
#slide[
    = Limiti di _mcfunction_

    - Assenza di variabili o strutture dati complesse: le operazioni matematiche possono essere eseguite solo su interi;
    - Frammentazione: ogni funzione deve essere definita in un apposito file. I cicli devono essere implementati tramite ricorsione;
    - Gestione matematica: difficoltà nel calcolare con precisione decimale i valori di funzioni quali seno, coseno e radice quadrata che richiedono _lookup table_;
    - Boilerplate: definire un oggetto semplice richiede fino 7 file diversi.
    #figure(
        local(
            skips: ((7, 95),),
            number-format: numbering.with("1"),
            ```
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
]

#slide[
    = Libreria OOPACK

    Questa libreria Java (Object Oriented Pack) astrae la struttura di un _pack_ come un albero di oggetti tipizzati.

    + Lo sviluppatore scrive codice ibrido tra Java e mcfunction, rendendolo in grado di sfruttare costrutti di un linguaggio di alto livello.
    + La libreria valida staticamente la struttura;
    + Il metodo `build()` genera l'intera gerarchia di file, fornendo zucchero sintattico per velocizzare la scrittura di componenti ripetitive.
]

#slide[
    = Architettura del software

    La struttura del progetto è stata raffinata iterativamente per giungere alla scrittura di un API che sia facile da leggere, utilizzare e contribuire in futuro. A tal fine sono stati impiegati numerosi _design pattern_:
    / Composite: `AbstractFolder` sfrutta il polimorfismo per gestire i suoi contenuti, che possono essere altri `AbstractFolder` o `AbstractFile`.
    / Factory: Ogni oggetto rappresentate un file è istanziato tramite una factory. Sono state impiegate _abstract factory_ per definire le modalità con cui un oggetto può essere inizializzato.
    / Builder: Utilizzato per la configurazione del progetto.

    #pagebreak()
    #place[Rappresentazione delle classi\ astratte del progetto.]
    #place(dy: -75pt, figure(
        scale(55%, diagram(
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
        )),
    ))
]

#slide[
    = Metodi di utilità
    Tramite il metodo `find()` è possibile ottenere riferimenti a file specifici da qualsiasi punto del progetto o di istanziarne uno nuovo qualora esso non esista.\ Questo, oltre a rappresentare un esempio di design pattern _lazy loading_, permette di definire metodi di alto livello quali `addTranslation(key, value)` e `addSound()` per inserire coppie chiave valore nell risorse dedicate alla localizzazione e registrazione di suoni.\ Sempre sfruttando questo metodo è possibile dichiarare le funzioni da eseguire ogni _game loop_ o ad ogni ricarica del progetto.
]

#slide[
    = Working Example
]

#slide[
    = Risultati e metriche

    #figure(
        cetz.canvas({
            import cetz.draw: *
            plot.plot(
                name: "plot",
                size: (15, 10),
                x-min: 0,
                y-min: 0,
                x-label: [file],
                y-label: [righe],
                x-tick-step: 20,
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
    )

    Calcolando il rapporto tra il numero di file impiegati, risulta evidente il vantaggio dell'utilizzo della libreria. Per il _working example_ $P_1$ si nota che ogni file sorgente genera circa $31/3=10,3$ file di output. Eseguendo la medesima operazione per $P_2$, di dimensioni maggiori, si ottiene invece $137/9 = 15,2$.

     Da questi valori si può dedurre che maggiore è la portata del progetto, più elevata è la quantità di file gestita automaticamente per ogni singola unità di codice scritta dallo sviluppatore.

     Interpretando la distanza tra il punto di partenza (sorgente) e quello di arrivo (output) come una stima del carico di lavoro automatizzato dalla libreria, è evidente che automatizzare lo sviluppo sia vantaggioso per i progetti di scala maggiore.

     #let dist(p1x, p2x, p1y, p2y) = $sqrt((p1x-p2x)^2+(p1y-p2y)^2)$
Per il progetto minore $P_1$, la distanza è $d_1=91,4$. Per il progetto maggiore $P_2$, tale valore sale a $d_2=1098,5$.

Se si misura la densità di codice del singolo progetto $p$, come il rapporto tra le sue righe totali e file totali, si vedrà che $p(P_1)=73,7$ e $p(P_2)=151,1$.\
Confrontando questi due valori si nota che a fronte di un raddoppio della densità nel progetto più grande ($p(P_2) approx 2 dot p(P_1)$), il beneficio dell'automazione $d$ cresce di un fattore 12 ($d_2/d_1 approx 12$).

]

#slide[
    #align(center + horizon, text(size: 50pt)[*Grazie per l'attenzione*])
]
