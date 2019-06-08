" Csound REPL functionality
" https://github.com/kunstmusik/csound-vim-repl
" Language: csound
" Maintainer: Steven Yi <stevenyi@gmail.com>
" License: MIT
" Version: 1.0 

if !exists("g:csound_repl_load") || &cp
  let g:csound_repl_load = 1
  if(has('python'))

python << EOF
import socket
import vim
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

server = "127.0.0.1"
port = 10000 
EOF

  elseif(has('python3'))
python3 << EOF
import socket
import vim
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

server = "127.0.0.1"
port = 10000 
EOF

  else
    echom "Error: Csound REPL requires python."
  endif
endif

function! s:send_to_csound(payload)
  if(has('python'))
python << EOF
message = vim.eval("a:payload")
sock.sendto(message, (server, port)) 
EOF
  elseif(has('python3'))

python3 << EOF
message = vim.eval("a:payload").encode()
sock.sendto(message, (server, port)) 
EOF
  else
    echom "Error: csound-repl requires python"
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

function! Csound_eval_orc_n()
  let savepos = getpos(".")
  let start = search("^\s*instr", 'bc')
  let end = search("^\s*endin")

  call setpos('.', [0, savepos[1], 0, 0])
  let startop = search("^\s*opcode", 'bc')
  let endop = search("^\s*endop")

  if savepos[1] > startop && savepos[1] < endop
    call s:send_to_csound(join(getline(startop,endop), "\n"))
    call setpos('.', [0, startop, 0, 0])
    exec "normal V"
    call setpos('.', [0, endop,0,0])
  elseif savepos[1] > start && savepos[1] < end
    call s:send_to_csound(join(getline(start,end), "\n"))
    call setpos('.', [0, start, 0, 0])
    exec "normal V"
    call setpos('.', [0, end,0,0])
  else
    call s:send_to_csound(getline(savepos[1]))
    call setpos('.', [0, savepos[1], 0, 0])
    exec "normal V"
  endif

  redraw
  sleep 200 m
  exec "normal vv"
  call setpos('.', savepos)
endfunction


function! Csound_insert_hexplay()
  let l:fadeCounter = get(b:, "fadeCounter", 5)
  let b:fadeCounter = l:fadeCounter + 1

  "This is depending upon the formatting rules of user's Vim to look alright 
  let l:hexCode = "hexplay(\"8\", \n" .
                \ "    \"Sub5\", p3,\n" . 
                \ "in_scale(-1, 0),\n" . 
                \ "fade_in(" . l:fadeCounter . ", 128) * ampdbfs(-12))\n"
  return l:hexCode
endfunction

function! Csound_insert_euclidplay()
  let l:fadeCounter = get(b:, "fadeCounter", 5)
  let b:fadeCounter = l:fadeCounter + 1

  "This is depending upon the formatting rules of user's Vim to look alright 
  let l:euclidCode = "euclidplay(13, 32,\n" .
                \ "    \"Sub5\", p3,\n" . 
                \ "in_scale(-1, 0),\n" . 
                \ "fade_in(" . l:fadeCounter . ", 128) * ampdbfs(-12))\n"
  return l:euclidCode
endfunction

vnoremap <silent> <leader>eo :<c-u>call Csound_eval_orc()<CR>
nnoremap <silent> <leader>eo :<c-u>call Csound_eval_orc_n()<CR>

vnoremap <silent> <leader>es :call Csound_eval_sco()<CR>
inoremap <silent> <C-h> <C-R>= Csound_insert_hexplay()<CR>
inoremap <silent> <C-j> <C-R>= Csound_insert_euclidplay()<CR>
