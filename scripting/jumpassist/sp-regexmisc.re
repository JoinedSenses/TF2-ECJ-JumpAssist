\n([ \t]),[ \t]*(.*?)(?:[ \t]*(//.*?))*
,\n\1\2

"([ \t]*\/\/.*?)?[ \t]*\n([ \t]*)\.{3}[ \t]*
" ...\1\n\2