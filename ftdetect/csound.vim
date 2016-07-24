au BufNewFile,BufRead *.orc,*.sco,*.csd,*.udo setfiletype csound
"au BufNewFile,BufRead	*.csd	runtime! macros/csound.vim

"au FileType csound execute 'setlocal dict=<sfile>:p:h:h/words/csound.txt'
"au FileType csound execute 'setlocal complete=k'
"au FileType csound execute 'setlocal completeopt=longest,menuone'
