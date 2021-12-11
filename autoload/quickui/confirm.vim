"======================================================================
"
" confirm.vim - 
"
" Created by skywind on 2021/12/11
" Last Modified: 2021/12/11 21:02:59
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" build buttons
"----------------------------------------------------------------------
function! s:button_prepare(choices)
	let choices = quickui#utils#text_list_normalize(a:choices)
	let items = []
	let max_size = 4
	for choice in choices
		let item = quickui#utils#item_parse(choice)
		let items += [item]
		let width = item.text_width
		let max_size = (max_size < width)? width : max_size
	endfor
	for item in items
		let width = item.text_width
		let pad1 = (max_size - width) / 2
		let pad2 = max_size - width - pad1
		let item.text = repeat(' ', pad1) . item.text . repeat(' ', pad2)
		if item.key_pos >= 0
			let item.key_pos += pad1
		endif
		let item.text_width = strwidth(item.text)
	endfor
	return items
endfunc


"----------------------------------------------------------------------
" synthesis button line
"----------------------------------------------------------------------
function! s:button_finalize(items, style)
	let items = a:items
	let final = ''
	let start = 0
	let index = len(a:items) - 1
	for item in a:items
		let text = ' ' . item.text . ' '
		let item.offset = -1
		if item.key_pos >= 0
			let item.offset = start + 1 + item.key_pos
		endif
		let item.start = start
		let item.endup = item.text_width + 2
		let start += item.text_width + 2
		let final .= text
		if index > 0
			let final .= '  '
			let start += 2
		endif
		let index -= 1
	endfor
	return final
endfunc


"----------------------------------------------------------------------
" calculate requirements
"----------------------------------------------------------------------
function! quickui#confirm#init(text, choices, index, title)
	let hwnd = {}
	let hwnd.text = quickui#utils#text_list_normalize(a:text)
	let hwnd.items = s:button_prepare(a:choices)
	let hwnd.final = s:button_finalize(hwnd.items, 0)
	let hwnd.index = a:index
	let button = ''
	let text_size = 40
	for text in hwnd.text
		let ts = strdisplaywidth(text)
		let text_size = (text_size < ts)? ts : text_size
	endfor
	let hwnd.btn_size = strdisplaywidth(hwnd.final)
	let hwnd.text_size = text_size
	let hwnd.w = (hwnd.btn_size > text_size)? hwnd.btn_size : text_size
	let hwnd.h = len(hwnd.text) + 2
	let hwnd.tw = hwnd.w + 4
	let hwnd.th = hwnd.h + 4
	let opts = {}
	let opts.w = hwnd.w
	let opts.h = hwnd.h
	let opts.border = g:quickui#style#border
	let opts.center = 1
	let opts.title = (a:title == '')? '' : (' ' . a:title . ' ')
	let hwnd.opts = opts
	let content = deepcopy(hwnd.text)
	let content += [' ', ' ']
	let hwnd.padding = hwnd.w - hwnd.btn_size
	let content += [repeat(' ', hwnd.padding) . hwnd.final]
	let hwnd.content = content
	let hwnd.win = quickui#window#new()
	return hwnd
endfunc


"----------------------------------------------------------------------
" main entry
"----------------------------------------------------------------------
function! quickui#confirm#open(text, choices, ...)
	let index = (a:0 < 1)? 0 : (a:1)
	let title = (a:0 < 2)? '' : (a:2)
	let hwnd = s:init(text, choices, index, title)
endfunc


