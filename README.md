# IIS Typst Templates

Typst templates for student theses and task descriptions at the
[Integrated Systems Laboratory (IIS)](https://iis.ee.ethz.ch), ETH Zurich.

## Templates

| Template | Description | Audience |
|---|---|---|
| `templates/thesis.typ` | Master thesis / semester project report | Students |
| `templates/assignment.typ` | Assignment description handed to students | Advisors |
| `templates/research_plan.typ` | PhD research plan (first-year report) | PhD students |

## Getting Started

### Prerequisites

Install the [Typst CLI](https://github.com/typst/typst):

```sh
# macOS
brew install typst

# or via cargo
cargo install typst-cli
```

### Thesis

Copy `examples/thesis.typ` and `examples/acronyms.typ` to your project and
adapt them:

```sh
typst compile --root . your_thesis.typ
```

The `--root .` flag is required so that absolute imports like
`#import "/templates/thesis.typ": *` resolve from the repository root.

A minimal thesis file looks like this:

```typ
#import "/templates/thesis.typ": *
#import "acronyms.typ": acronyms

#show: thesis.with(
  title: "My Thesis Title",
  author: "Jane Doe",
  email: "jdoe@iis.ee.ethz.ch",
  reporttype: "Master Thesis",
  advisors: (
    (name: "Dr. Alice Smith", mail: "asmith@iis.ee.ethz.ch"),
    (name: "Bob Jones",       mail: "bjones@iis.ee.ethz.ch"),
  ),
  professors: (
    (name: "Prof. Dr. Carol Miller", mail: "cmiller@iis.ee.ethz.ch"),
  ),
  acronyms: acronyms,
  bibliography: bibliography("references.bib", style: "ieee", full: true),
)

= Introduction

Your thesis starts here.
```

Missing fields show a highlighted placeholder clue in the compiled PDF rather
than an error, so you can compile at any stage of writing.

## Acronyms

Define acronyms in a separate file and pass them to the template:

```typ
#let acronyms = (
  "IC":  ("Integrated Circuit",),
  "SoC": (
    short: "SoC", long: "System-on-Chip",
    short-pl: "SoCs", long-pl: "Systems-on-Chip",
  ),
)
```

Use them in text with `#acr("IC")`, `#acrpl("SoC")`, or `#acrfull("IC")`.

## Including PDFs

Use `include-pdf` (re-exported from the template) to embed scanned documents
such as the signed declaration of originality:

```typ
declaration-of-originality: include-pdf("/figures/declaration.pdf"),
```

## For Advisors and PhD Students

- **Assignment description** (`templates/assignment.typ`): handed to students at the start of a project. See `examples/assignment.typ` for a working example.
- **Research plan** (`templates/research_plan.typ`): written by PhD candidates at the end of their first year, covering motivation, completed work, project definition, and a tentative timeline. See `examples/research_plan.typ` for a working example.

## License

Apache 2.0 — see [LICENSE](LICENSE).
