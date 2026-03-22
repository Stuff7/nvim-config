; extends

((style_element
  (start_tag
    (attribute
      (attribute_name) @_lang
      (quoted_attribute_value (attribute_value) @_value)))
  (raw_text) @injection.content)
 (#eq? @_lang "lang")
 (#eq? @_value "postcss")
 (#set! injection.language "css"))
