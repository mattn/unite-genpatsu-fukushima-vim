let s:save_cpo = &cpo
set cpo&vim
scriptencoding utf-8

let s:source_genpatsu_fukushima = { 'name': 'genpatsu_fukushima' }
let s:genpatsu_fukushima = []

function! unite#sources#genpatsu_fukushima#show(entry)
  echo "【".a:entry[0]."】"
  echo "\n"
  echo a:entry[1]
endfunction

function! s:get_news()
  let res = http#get("http://www3.nhk.or.jp/news/genpatsu-fukushima/")
  let dom = html#parse(iconv(res.content, 'utf-8', &encoding))
  for section in dom.findAll('div', {'class': 'section'})
    let node = section.find('h2')
    if has_key(node, 'value')
      let title = node.value()
      let body = substitute(section.find('p').value(), '<br[^>]*>', '\n', 'g')
      call add(s:genpatsu_fukushima, [title, body])
    endif
  endfor
endfunction

function! s:source_genpatsu_fukushima.gather_candidates(args, context)
  call s:get_news()
  return map(copy(s:genpatsu_fukushima), '{
        \ "word": v:val[0],
        \ "source": "genpatsu_fukushima",
        \ "kind": "command",
        \ "action__command": "call unite#sources#genpatsu_fukushima#show(".string(v:val).")"
        \ }')
endfunction

function! unite#sources#genpatsu_fukushima#define()
  return executable('curl') ? [s:source_genpatsu_fukushima] : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
