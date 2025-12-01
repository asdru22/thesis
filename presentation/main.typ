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

    - Minecraft è un ambiente programmabile tramite:
        - _Datapack_ per la logica
        - _Resourcepack_ per le risorse

    - Linguaggio: _mcfunction_ (DSL interpretato) + file JSON

    - *Obiettivo della tesi:*
        - Analizzare le problematiche del DSL
        - Progettare una libreria Java per la meta-programmazione
        - Semplificare lo sviluppo di _pack_
]

#slide[
    = Limiti di _mcfunction_

    - *Mancanza di strutture avanzate:*
        - Nessuna variabile o struttura dati complessa
        - Solo operazioni su interi
    - *Frammentazione del codice:*
        - Ogni funzione richiede un file separato
        - Assenza di _code blocks_
    - *Elevato boilerplate:*
        - Fino a 7 file per definire un oggetto semplice
    - *Gestione matematica limitata:*
        - Necessità di _lookup table_ per funzioni come seno, coseno, radice quadrata.
        #align(center)[Esempio di _Lookup table_ per $sqrt(x), "con" 0<=x<=100$.]


        #local(
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
        )

]

#slide[
    = Libreria OOPACK

    Astrazione del _pack_ come albero di oggetti tipizzati.

    - *Workflow:*
        1. Scrittura codice ibrido Java + mcfunction
        2. Validazione statica della struttura
        3. Generazione automatica dei file tramite `build()`

    - *Vantaggi:*
        - Utilizzo di costrutti di alto livello
        - Riduzione del codice ripetitivo
        - Semplificazione della struttura del progetto
]

#slide[
    = Architettura del software

    - *Design Pattern utilizzati:*
        - *Composite:* Gestione gerarchica di file e cartelle
        - *Factory:* Istanziazione controllata degli oggetti
        - *Builder:* Configurazione flessibile del progetto

    - *Sistema basato su interfacce:*
        - `Buildable` #sym.arrow oggetto costruibile
        - `FileSystemObject` #sym.arrow l'oggetto ha dei contenuti
        - `PackFolder` #sym.arrow per indicare se l'oggetto è di tipo _data_ o _resource_
        - `Extension` #sym.arrow per indicare l'estensione del file

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

    - *Metodo `find()`:*
        - Ricerca file specifici nel progetto
        - Istanziazione automatica se non esistente (_lazy loading_)

    - *Funzionalità di alto livello:*
        - `addTranslation(key, value)` per localizzazione
        - `addSound()` per registrazione audio
        - `setOnTick()` per le funzioni da eseguire ogni _game loop_.
        - `setOnLoad()` per le funzioni da eseguire ad ogni ricarica del gioco.
]

#slide[
    = Working Example
    - *Obiettivo*: modificare un oggetto renderlo in grado di produrre un onda sinusoidale la cui distanza dipende dalla munizione.
    #figure(
        cetz.canvas({
            plot.plot(size: (25, 3), x-tick-step: 30, axis-style: "school-book", y-tick-step: 1, {
                plot.add(domain: (0, 360), samples: 200, it => calc.sin(it / 10))
            })
        }),
    )

    Metodo scritto per facilitare la creazione di boilerplate per le munizioni.
    ```java
    make("blue_ammo", "Munizione Blu", "Blue Ammo", "diamond",20);
    ```
    Generazione e inizializzazione della _lookup table_ richiesta:
    #block(stroke: 1pt + gray, inset: 4pt, figure(```java
    private void makeSinLookup() {
        StringBuilder sin = new StringBuilder("data modify storage esempio:storage sin set value [");
        for (int i = 0; i <= 360; i++) {
            sin.append("{value:").append(Math.sin(Math.toRadians(i * 10))).append("},");
        }
        sin.append("]");
        Util.setOnLoad(Function.f.of(sin.toString()));
    }
    ```))

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

    - *Efficienza della generazione:*
        - Progetto $P_1$: 1 file sorgente #sym.arrow 10,3 file output
        - Progetto $P_2$: 1 file sorgente #sym.arrow 15,2 file output

    - *Automazione crescente:*
        - Maggiore scala #sym.arrow maggiore automazione
        - Distanza $d_1 = 91,4$ vs $d_2 = 1098,5$
        - A densità di codice raddoppiata, beneficio $d$ aumenta di 12 volte
]

#slide[
    #align(center + horizon, text(size: 50pt)[*Grazie per l'attenzione*])
]
