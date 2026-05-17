// typst-show.typ: bridge between Quarto metadata and template

#show: doc => glamour(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: ($for(by-author)$(name: [$it.name.literal$]),  $endfor$),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$
  logo-vertical-path: brand-logo-images.at("vertical", default: none).at("path", default: none),
  logo-horizontal-path: brand-logo-images.at("horizontal", default: none).at("path", default: none),
  logo-favicon-path: brand-logo-images.at("favicon", default: none).at("path", default: none),
  purple: brand-color.at("primary", default: rgb("#881ef9")),
  lavender: brand-color.at("light", default: rgb("#ededf4")),
  surface: brand-color.at("background", default: rgb("#f8f8fc")),
  charcoal: brand-color.at("foreground", default: rgb("#2f2f30")),
$if(letterhead)$
  letterhead: $letterhead$,
$endif$
$if(letterhead-details)$
  letterhead-details: [$letterhead-details$],
$endif$
$if(certificate)$
  certificate: $certificate$,
$endif$
$if(certificate-recipient)$
  certificate-recipient: [$certificate-recipient$],
$endif$
$if(certificate-description)$
  certificate-description: [$certificate-description$],
$endif$
$if(certificate-footer)$
  certificate-footer: [$certificate-footer$],
$endif$
$if(title-style)$
  title-style: "$title-style$",
$endif$
  doc,
)
