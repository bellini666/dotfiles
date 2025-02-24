; extends

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#is-mise?)
  (#match? @injection.language "^\"\"\"\n*#!(/\\w+)+/env\\s+\\w+") ; multiline shebang using env
  (#gsub! @injection.language "^.*#!/.*/env%s+([^%s]+).*" "%1") ; extract lang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
)

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content @injection.language

  (#is-mise?)
  (#match? @injection.language "^\"\"\"\n*#!(/\\w+)+\s*\n") ; multiline shebang
  (#gsub! @injection.language "^.*#!/.*/([^/%s]+).*" "%1") ; extract lang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
)

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#is-mise?)
  (#match? @injection.content "^\"\"\"\n*.*") ; multiline
  (#not-match? @injection.content "^\"\"\"\n*#!") ; no shebang
  (#offset! @injection.content 0 3 0 -3) ; rm quotes
  (#set! injection.language "bash") ; default to bash
)

(pair
  (bare_key) @key (#eq? @key "run")
  (string) @injection.content

  (#is-mise?)
  (#not-match? @injection.content "^\"\"\"") ; not multiline
  (#offset! @injection.content 0 1 0 -1) ; rm quotes
  (#set! injection.language "bash") ; default to bash
)
