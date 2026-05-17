// ── WCAG contrast utilities ──

#let luminance(c) = {
  let r = c.components().at(0) / 100%
  let g = c.components().at(1) / 100%
  let b = c.components().at(2) / 100%
  let linearize(v) = if v <= 0.03928 { v / 12.92 } else { calc.pow((v + 0.055) / 1.055, 2.4) }
  0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
}

#let contrast-ratio(c1, c2) = {
  let l1 = calc.max(luminance(c1), luminance(c2))
  let l2 = calc.min(luminance(c1), luminance(c2))
  (l1 + 0.05) / (l2 + 0.05)
}

#let ensure-contrast(fg, bg, min-ratio: 4.5) = {
  if contrast-ratio(fg, bg) >= min-ratio { fg }
  else if luminance(bg) > 0.5 { fg.darken(40%) }
  else { fg.lighten(40%) }
}

// ── Branded callout override ──

#let callout(
  body: [],
  title: "Callout",
  background_color: rgb("#dddddd"),
  icon: none,
  icon_color: black,
  body_background_color: rgb("#f8f8fc"),
) = {
  block(
    breakable: false,
    fill: background_color,
    stroke: (left: 3pt + icon_color),
    width: 100%,
    radius: 0.5em,
    block(
      inset: 1pt,
      width: 100%,
      below: 0pt,
      block(
        fill: background_color,
        width: 100%,
        radius: (top: 0.5em),
        inset: 10pt,
      )[#text(icon_color, weight: 700)[#icon] #title]) +
    if body != [] {
      block(
        inset: 1pt,
        width: 100%,
        block(
          fill: body_background_color,
          width: 100%,
          radius: (bottom: 0.5em),
          inset: 10pt,
          body,
        ),
      )
    }
  )
}

// RLadies+ Typst template
// Modes:
//   default              — title page + clean header on subsequent pages
//   title-style: elaborate — decorative title page with certificate-style elements
//   letterhead: true     — branded header/footer bands on every page
//   certificate: true    — landscape certificate of completion

#let glamour(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  logo-vertical-path: none,
  logo-horizontal-path: none,
  logo-favicon-path: none,
  purple: rgb("#881ef9"),
  lavender: rgb("#ededf4"),
  surface: rgb("#f8f8fc"),
  charcoal: rgb("#2f2f30"),
  letterhead: false,
  letterhead-details: none,
  certificate: false,
  certificate-recipient: none,
  certificate-description: none,
  certificate-footer: none,
  title-style: "default",
  doc,
) = {

  // ── Shared show rules (apply to all modes) ──

  show heading.where(level: 1): set text(fill: purple, weight: 500)
  show heading.where(level: 2): set text(fill: purple, weight: 600)
  show heading.where(level: 3): set text(fill: charcoal, weight: 600)
  show heading.where(level: 4): set text(fill: charcoal, weight: 600)

  show emph: set text(weight: 700, style: "normal")

  show quote: it => {
    block(
      width: 100%,
      inset: (left: 1.2em, rest: 0.8em),
      fill: purple.lighten(92%),
      stroke: (left: 4pt + purple),
      radius: (right: 0.75em),
      it.body
    )
  }

  set table(
    stroke: 0.5pt + lavender,
    inset: 8pt,
    fill: (_, y) => {
      if y == 0 { purple }
      else if calc.odd(y) { surface }
    },
  )
  show table.cell.where(y: 0): set text(fill: ensure-contrast(lavender, purple), weight: 600)

  if certificate {
    // ── Certificate mode ──
    // Landscape page with branded decorative elements

    set page(
      paper: "a4",
      flipped: true,
      margin: (left: 3cm, right: 3cm, top: 2.5cm, bottom: 2cm),
      numbering: none,
      background: {
        // Full lavender background
        rect(width: 100%, height: 100%, fill: lavender)

        // Top-right: white rounded area for logo
        place(top + right,
          circle(
            radius: 5.5cm,
            fill: surface,
          )
        )

        // Top-right: purple corner accent above white area
        place(top + right,
          rect(
            width: 2.5cm,
            height: 3cm,
            fill: purple,
            radius: (bottom-left: 1.2cm),
          )
        )

        // Right edge: purple vertical bar with rounded ends
        place(right + horizon, dx: -0.3cm,
          rect(
            width: 1cm,
            height: 40%,
            fill: purple,
            radius: 0.5cm,
          )
        )

        // Bottom-left: purple curved decorative corner
        place(bottom + left,
          rect(
            width: 3cm,
            height: 2.5cm,
            fill: purple,
            radius: (top-right: 2cm),
          )
        )
      },
    )

    // Logo in the top-right white area
    place(top + right, dx: -3cm, dy: 1.5cm,
      if logo-favicon-path != none {
        image(logo-favicon-path, height: 6cm)
      } else if logo-vertical-path != none {
        image(logo-vertical-path, height: 3.5cm)
      }
    )

    // Certificate content (left-aligned)
    v(0.5cm)
    text(size: 42pt, weight: 700, fill: charcoal)[Certificate of\ Completion]
    v(0.8cm)
    text(size: 13pt, weight: 400, fill: charcoal)[Proudly presented to]
    v(0.5cm)
    if certificate-recipient != none {
      text(size: 28pt, weight: 600, fill: ensure-contrast(purple, lavender), certificate-recipient)
    }
    v(0.5cm)
    if certificate-description != none {
      text(size: 12pt, weight: 400, fill: charcoal, certificate-description)
    } else if subtitle != none {
      text(size: 12pt, weight: 400, fill: charcoal, subtitle)
    }
    v(1fr)
    if certificate-footer != none {
      text(size: 10pt, weight: 600, fill: purple, certificate-footer)
    } else [
      #text(size: 10pt, weight: 600, fill: purple)[Rladies.org #sym.dot.c info\@rladies.org]
    ]
    v(0.5cm)

  } else if letterhead {
    // ── Letterhead mode ──
    // Every page gets branded header and footer bands

    set page(
      margin: (top: 3.8cm, bottom: 3.2cm, x: 2.5cm),
      numbering: none,
      background: {
        // Header: lavender band with rounded bottom-left corner
        place(top + left,
          rect(
            width: 100%,
            height: 2.6cm,
            fill: lavender,
            radius: (bottom-left: 1.2cm),
          )
        )
        // Header: purple accent in top-right corner
        place(top + right,
          rect(
            width: 35%,
            height: 1cm,
            fill: purple,
            radius: (bottom-left: 0.8cm, bottom-right: 0cm),
          )
        )
        // Header: purple stripe with rounded left end
        place(top + left, dy: 2.6cm,
          rect(width: 100%, height: 5pt, fill: purple, radius: (top-left: 2.5pt, bottom-left: 2.5pt))
        )
        // Header: logo on the left
        place(top + left, dx: 2.5cm, dy: 1.0cm,
          if logo-horizontal-path != none {
            image(logo-horizontal-path, height: 24pt)
          }
        )
        // Header: details text on the right
        place(top + right, dx: -2.5cm, dy: 1.15cm,
          text(size: 8pt, fill: luma(100))[
            #if letterhead-details != none {
              letterhead-details
            }
          ]
        )
        // Footer: lavender band with rounded top-left corner
        place(bottom + left,
          rect(
            width: 100%,
            height: 2cm,
            fill: lavender,
            radius: (top-left: 1.2cm),
          )
        )
        // Footer: purple stripe with rounded left end
        place(bottom + left, dy: -2cm,
          rect(width: 100%, height: 5pt, fill: purple, radius: (top-left: 2.5pt, bottom-left: 2.5pt))
        )
        // Footer: centered details text
        place(bottom + center, dy: -0.85cm,
          text(size: 8pt, fill: luma(100))[
            #if letterhead-details != none {
              letterhead-details
            } else [
              rladies.org
            ]
          ]
        )
      },
    )

    // Title block (no separate title page in letterhead mode)
    if title != none {
      text(size: 24pt, weight: 500, fill: charcoal, title)
      v(0.6cm)
    }

    doc

  } else {
    // ── Report mode (default) ──
    // Title page + clean header on subsequent pages

    set page(
      background: context {
        let curr = counter(page).get().first()
        if curr == 1 and title-style == "elaborate" {
          rect(width: 100%, height: 100%, fill: lavender)

          place(top + right,
            circle(radius: 4.5cm, fill: surface)
          )

          place(top + right,
            rect(width: 2cm, height: 2.5cm, fill: purple, radius: (bottom-left: 1cm))
          )

          place(right + horizon, dx: -0.25cm,
            rect(width: 0.8cm, height: 30%, fill: purple, radius: 0.4cm)
          )

          place(bottom + left,
            rect(width: 2.5cm, height: 2cm, fill: purple, radius: (top-right: 1.5cm))
          )
        }
      },
      header: context {
        let curr = counter(page).get().first()
        if curr > 1 {
          grid(
            columns: (auto, 1fr),
            column-gutter: 12pt,
            align: (left + horizon, right + horizon),
            if logo-horizontal-path != none {
              image(logo-horizontal-path, height: 18pt)
            },
            text(size: 8pt, fill: luma(120))[
              #if title != none { title }
            ],
          )
          v(4pt)
          line(length: 100%, stroke: 0.5pt + lavender)
        }
      },
      footer: context {
        let curr = counter(page).get().first()
        if curr == 1 {
          line(length: 100%, stroke: 4pt + purple)
        } else {
          line(length: 100%, stroke: 0.5pt + lavender)
          v(4pt)
          grid(
            columns: (1fr, auto),
            align: (left + horizon, right + horizon),
            text(size: 8pt, fill: luma(120))[rladies.org],
            text(size: 8pt, fill: luma(120))[
              #counter(page).display("1 / 1", both: true)
            ],
          )
        }
      },
    )

    // Title page
    if title-style == "elaborate" {
      // Elaborate: certificate-style decorative title page
      v(2.5cm)

      // Logo in the top-right surface circle
      place(top + right, dx: -1.8cm, dy: 0.8cm,
        if logo-favicon-path != none {
          image(logo-favicon-path, height: 4cm)
        } else if logo-vertical-path != none {
          image(logo-vertical-path, height: 3cm)
        }
      )

      // Left-aligned content (within left ~60% to avoid right decorations)
      block(width: 60%)[
        #if title != none {
          text(size: 28pt, weight: 500, fill: charcoal, title)
        }
        #v(0.4cm)
        #if subtitle != none {
          text(size: 13pt, weight: 400, fill: charcoal, subtitle)
        }
        #v(0.8cm)
        #if authors != none {
          for author in authors {
            let name = if type(author) == str {
              author
            } else if type(author) == dictionary {
              author.at("name", default: "")
            } else {
              str(author)
            }
            text(size: 11pt, weight: 400, fill: charcoal, name)
            linebreak()
          }
        }
        #v(0.3cm)
        #if date != none {
          text(size: 10pt, fill: luma(100), date)
        }
      ]
      v(1fr)
      text(size: 9pt, weight: 600, fill: purple)[rladies.org]
      pagebreak()
    } else {
      // Default: simple centered title page
      v(2fr)
      if logo-vertical-path != none {
        align(center, image(logo-vertical-path, width: 25%))
        v(1.2cm)
      }
      align(center)[
        #if title != none {
          text(size: 26pt, weight: 500, fill: charcoal, title)
        }
      ]
      v(0.4cm)
      align(center)[
        #if subtitle != none {
          text(size: 13pt, weight: 400, fill: luma(100), subtitle)
        }
      ]
      v(0.8cm)
      align(center)[
        #if authors != none {
          for author in authors {
            let name = if type(author) == str {
              author
            } else if type(author) == dictionary {
              author.at("name", default: "")
            } else {
              str(author)
            }
            text(size: 11pt, weight: 400, fill: charcoal, name)
            linebreak()
          }
        }
      ]
      v(0.3cm)
      align(center)[
        #if date != none {
          text(size: 10pt, fill: luma(120), date)
        }
      ]
      v(3fr)
      pagebreak()
    }

    // Abstract
    if abstract != none {
      block(
        width: 100%,
        fill: surface,
        inset: 16pt,
        radius: 6pt,
        stroke: 0.5pt + lavender,
      )[
        #text(weight: 600, size: 1.1em)[Abstract]
        #v(0.3em)
        #abstract
      ]
      v(1em)
    }

    doc
  }
}
