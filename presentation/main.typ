#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.5" as fletcher: edge, node
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#show: show-theorion
#set text(lang: "it")
#let title = [Un Framework per la  Meta-programmazione in _Minecraft_]
// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: university-theme.with(
    aspect-ratio: "16-9",
    // align: horizon,
    // config-common(handout: true),
    config-common(frozen-counters: (theorem-counter,)), // freeze theorem counter for animation
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
        short-title: title
    ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()
== Contenuti <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em))

= Introduzione
= Cos'è un pack
== Datapack
== Resourcepack

= Problemi e Limitazioni dei pack
== Sintassi
=
=
=
=
=
=
=
