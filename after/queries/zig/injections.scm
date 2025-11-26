; extends

; SQL syntax highlighting in strings
(
  [(multiline_string) @injection.content (string (string_content) @injection.content)]
  (#set! injection.language "sql")
)
