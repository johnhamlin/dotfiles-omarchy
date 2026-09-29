" 6502 opcodes/numbers plus vasm oldstyle directives (including -dotdir).
if exists("b:current_syntax")
  finish
endif
runtime! syntax/a65.vim
unlet! b:current_syntax
syn case ignore
syn match vasm6502Directive "\<\.\=\(org\|byte\|word\|dword\|ascii\|asciiz\|text\|include\|incbin\|equ\|set\|align\|even\|space\|ds\|db\|dw\|hex\|macro\|endm\|endmacro\|if\|ifdef\|ifndef\|else\|endif\|repeat\|rept\|endr\|endrepeat\|end\)\>"
syn match vasm6502Directive "\.\(org\|byte\|word\|dword\|ascii\|asciiz\|text\|include\|incbin\|equ\|set\|align\|even\|space\|ds\|db\|dw\|hex\|macro\|endm\|endmacro\|if\|ifdef\|ifndef\|else\|endif\|repeat\|rept\|endr\|endrepeat\|end\)\>"
syn keyword vasm6502Opcode wai stp tsb
syn match vasm6502Opcode "\<\(bbr\|bbs\|rmb\|smb\)[0-7]\>"
hi def link vasm6502Directive PreProc
hi def link vasm6502Opcode Type
let b:current_syntax = "vasm6502"
