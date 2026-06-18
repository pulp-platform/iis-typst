# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `ieee-reprint-notice`: bundled, ready-to-use IEEE reprint statement for ETH
  Zurich theses. Pass it to `copyright-notice` instead of hand-writing the text.

### Changed

- Reworked render modes around the output medium: `mode` is now `"digital"`
  (default) or `"booklet"`, replacing `"official"`/`"series"`. `"digital"` uses
  symmetric margins, drops blank filler pages, keeps clickable blue links, and a
  fixed running header; `"booklet"` keeps mirrored binding margins, recto section
  starts (blank versos where needed), black links, and the alternating header.
  Both modes keep the same 108 mm content width.
- Replaced the boolean `show-copyright-notice` with a tri-state `copyright-notice`
  parameter: `auto` (default) shows the reminder page, content renders that notice
  as a front-matter page, and `none` omits it entirely.
- Removed copyright headers from template starter files.
- Figure and table captions still default to left alignment but no longer force
  it, so an individual figure can override it with
  `show figure.caption: set align(center)` (useful for wide, rotated tables).

### Fixed

- Removed extra blank pages around front-matter sections (acknowledgements,
  abstracts, copyright notice).
- Run-in (level-4) headings that directly follow a section heading are no longer
  pulled into the inside margin. The first-line-indent is now cancelled only when
  the heading actually runs into an indented paragraph.

### Removed

- The Hartung-Gorre "series" render mode and its `volume`, `isbn`, `isbn-long`,
  and `published` parameters, along with the series title page (Series in
  Microelectronics / ISBN / ISSN).

## v1.0.0 — 2026-03-31

Initial release on [Typst Universe](https://typst.app/universe/package/ethz-iis-dissertation).

### Added

- PhD dissertation template following ETH Zurich doctoral regulations.
- Two render modes: `"official"` (examination copy) and `"series"` (Hartung-Gorre
  publication copy with volume, ISBN, and series page).
- Running chapter headers with optional short title via the `chapter` helper.
- Front matter: acknowledgements, English and German abstracts, list of acronyms,
  table of contents, list of figures and tables.
- Back matter: bibliography, appendices, curriculum vitae, and copyright notice.
- Example chip gallery appendix and CV page in the template.
- Shared ETH Zurich + PULP group logo header.
- Acronym management via [`acrostiche`](https://typst.app/universe/package/acrostiche).
- [Typst Quick Guide](../shared/typst-guide.typ) included as an example appendix.
