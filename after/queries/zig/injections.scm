; extends

; SQL syntax highlighting in strings
(call_expression
  function: (field_expression
    member: (identifier) @_method)
  [(multiline_string) @injection.content (string (string_content) @injection.content)]
  (#set! injection.language "sql"))
