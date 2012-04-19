let s:save_cpo = &cpo
set cpo&vim
scriptencoding utf-8

let s:source_genpatsu_fukushima = { 'name': 'genpatsu_fukushima' }
let s:genpatsu_fukushima = []

function! unite#sources#genpatsu_fukushima#show(no)
  echo "【".s:genpatsu_fukushima[a:no][1]."】"
  echo "\n"
  echo s:genpatsu_fukushima[a:no][2]
endfunction

function! s:get_news()
  let res = webapi#http#get("http://www3.nhk.or.jp/news/genpatsu-fukushima/")
  let dom = webapi#html#parse(iconv(res.content, 'utf-8', &encoding))
  let no = 0
  for section in dom.findAll('div', {'class': 'section'})
    let node = section.find('h2')
    if has_key(node, 'value')
      let title = node.value()
      let body = section.find('p').value()
      " remove <br //> <img //>
      let body = substitute(body, '<img[^>]*>', '[画像]', 'g')
      let body = substitute(body, '<br\s*/\+>', '\n', 'g')
      call add(s:genpatsu_fukushima, [no, title, body])
	  let no += 1
    endif
  endfor
endfunction

function! s:source_genpatsu_fukushima.gather_candidates(args, context)
  call s:get_news()
  return map(copy(s:genpatsu_fukushima), '{
        \ "word": v:val[1],
        \ "source": "genpatsu_fukushima",
        \ "kind": "command",
        \ "action__command": "call unite#sources#genpatsu_fukushima#show(".v:val[0].")"
        \ }')
endfunction

function! unite#sources#genpatsu_fukushima#define()
  return executable('curl') ? [s:source_genpatsu_fukushima] : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
