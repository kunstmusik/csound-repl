" Csound REPL functionality
" https://github.com/kunstmusik/csound-vim-repl
" Language: csound
" Maintainer: Steven Yi <stevenyi@gmail.com>
" License: MIT
" Version: 1.0 

if !exists("g:csound_repl_load") || &cp
  let g:csound_repl_load = 1
  if(!has('python'))
    echom "Error: Csound REPL requires python."
  else
python << EOF
import socket
import vim
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

server = "127.0.0.1"
port = 10000 
EOF
  endif
endif

function! s:send_to_csound(payload)
  if(!has('python'))
    echom "Error: csound-repl requires python"
  else
python << EOF
message = vim.eval("a:payload")
sock.sendto(message, (server, port)) 
EOF
  endif
endfunction

function! Csound_set_port(port)
  python port = vim.eval("a:port")
endfunction

function! Csound_eval_orc()
  normal! `<v`>y
  call s:send_to_csound(@@)
endfunction


function! Csound_eval_sco()
  normal! `<v`>y
  call s:send_to_csound("$" . @@)
endfunction

vnoremap <silent> <leader>eo :<c-u>call Csound_eval_orc()<CR>
vnoremap <silent> <leader>es :call Csound_eval_sco()<CR>
