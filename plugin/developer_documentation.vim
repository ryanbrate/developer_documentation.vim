" Vim plugin providing some degree of contextually-aware developer documentation
" Last Change: 13 April 2023
" By: Ryan Brate

if exists('g:loaded_developer_documentation_vim') | finish | endif
let g:loaded_developer_documentation_vim = 1

function! CascadeFind(import_patterns, conj, text) abort
    " Return [alias::str, aliased::str] for first pattern that text matches
    " against or return [] if no patterns match against.
    " Note: reports the first matching pattern only
    let returned = []
    for [import_pattern, parts] in a:import_patterns
        let matched_groups = matchlist(a:text, import_pattern)
        if len(matched_groups) > 0
            for [k, v] in items(parts)
                let alias = matched_groups[k]
                let aliased = join(Map({i->matched_groups[i]}, v), a:conj)
                call add(returned, [alias, aliased])
            endfor 
            return returned
        endif
    endfor
    return returned
endfunction

function! BufferAliases(import_patterns, conj) abort
    " Return {alias: aliased, ...} or empty {} corresponding to buffer.
    let buffer_lines = getline(line('^'), line('$'))

    " get alias:aliased according to import_patterns
    let aliases = {}
    for buffer_line in buffer_lines
        for [alias, aliased] in CascadeFind(a:import_patterns, a:conj, buffer_line) 
            let aliases[alias] = aliased
        endfor
    endfor

    return aliases
endfunction

function! UnderCursor(permissible_chars) abort
    """ Return the character sequence under cursor of only 'permissible_chars'
    """

    " Return the token under the cursor or return 0
    let line_ = getline('.')
    let i = col('.')-1
    let char_ = line_[i]

    " proceed only if the char under cursor is a permissible char
    if match(char_, '['.a:permissible_chars.']') != -1

        " get everything permissible to the lhs of the cursor
        if i > 0
            let lhs_cursor = split(line_[:i-1], '[^'.a:permissible_chars.']', 1)[-1]
        else
            let lhs_cursor = ''
        endif

        " get everything permissible to the rhs of the cursor
        let rhs_cursor = split(line_[i+1:], '[^'.a:permissible_chars.']', 1)[0]

        return lhs_cursor.char_.rhs_cursor  
    endif
endfunction

function! ExpandAliases(token, conj, aliases) abort
    " Return a:token with the first namespace expanded by any known alias in
    " the buffer
    let token_parts = split(a:token, escape(a:conj, a:conj))
    let namespace = token_parts[0]
    if In(namespace, keys(a:aliases))
        if len(token_parts) > 1
            return a:aliases[namespace].a:conj.join(token_parts[1:], a:conj)
        else
            return a:aliases[namespace]
        endif
    endif
    return a:token
endfunction

function! DocCommand(token, call_string, conj, extend=0) abort
    " Return an Ex command (str) for generating documentation wrt., 'token'
    " Args:
    "   token (string): token to replace <TOKEN> with in the call_string
    "   call_string (string): the documentation call 
    "   conj (string): the string that conjugates modules, classes, functions

    " <TOKEN> substitution
    if a:extend!=0
        " :DE case
        let extension = input(a:token)
        let call_string = substitute(a:call_string, '<TOKEN>', a:token.extension, '')
        call histadd('cmd', 'DD '.a:token.extension)
    else
        " :DD case
        let call_string = substitute(a:call_string, '<TOKEN>', a:token, '')
        call histadd('cmd', 'DD '.a:token)
    endif

    return call_string
endfunction

command! -nargs=* DD exec len(split(<q-args>))==0 ? 
            \DocCommand(
                \ExpandAliases(
                    \UnderCursor(b:DD_permissible_chars),
                    \b:DD_conj,
                    \BufferAliases(b:DD_import_patterns, b:DD_conj)
                \), 
                \b:DD_call, b:DD_conj
            \) 
            \: 
            \DocCommand(
                \ExpandAliases(
                    \<q-args>, 
                    \b:DD_conj, 
                    \BufferAliases(b:DD_import_patterns, b:DD_conj)
                \), 
                \b:DD_call, b:DD_conj
            \)

command! -nargs=* DE exec DocCommand(
                            \ExpandAliases(
                                \UnderCursor(b:DD_permissible_chars), 
                                \b:DD_conj, 
                                \BufferAliases(b:DD_import_patterns, b:DD_conj)
                            \), 
                            \b:DD_call, 
                            \b:DD_conj, 
                            \1
                         \)

command! -nargs=* DO exec DocCommand(<q-args>, b:DD_call, b:DD_conj)
