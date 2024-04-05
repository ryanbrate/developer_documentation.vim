A vim plugin to provide some facilitate a degree of contextually aware documentation.

    What does it do? 

    i) scans the buffer for alias:aliased pairs according to import pattern 

    ii) for token under cursor, looks to replace the namespace (i.e., first sub-token separated by conjuction operator) with aliased, where it's an alias 

    iii) passed the alias->aliased replaced string to a documentation program and reports the output.

Note: relies on https://github.com/ryanbrate/functional.vim

To install, e.g., via vim-plug

    Plug 'ryanbrate/functional.vim'
    Plug 'ryanbrate/developer_documentation.vim'

## Example .vimrc additions for python3

```
au FileType python let b:DD_conj = '.'
au FileType python let b:DD_permissible_chars = 'a-zA-Z0-9\._'
au FileType python let b:DD_import_patterns = [
    \['from\s\+\(\S\+\)\s\+import\s\+\(\S\+\)\s\+as\s\+\(\S\+\)', {3:[1,2]}, 0],
    \['from\s\+\(\S\+\)\s\+import\s\+\(\S\+\)\s*,\s*\(\S\+\)\s*,\s*\(\S\+\)', {2:[1,2], 3:[1,3], 4:[1,4], 5:[1,5]}, 0],
    \['from\s\+\(\S\+\)\s\+import\s\+\(\S\+\)\s*,\s*\(\S\+\)\s*,\s*\(\S\+\)', {2:[1,2], 3:[1,3], 4:[1,4]}, 0],
    \['from\s\+\(\S\+\)\s\+import\s\+\(\S\+\)\s*,\s*\(\S\+\)', {2:[1,2], 3:[1,3]}, 0],
    \['from\s\+\(\S\+\)\s\+import\s\+\(\S\+\)', {2:[1, 2]}, 0],
    \['from\s\+\(\S\+\)\s\+import\s\+\(\S\+\)\s*as\(\S\+\)', {3:[1, 2]}, 0],
    \['import\s\+\(\S\+\)\s\+as\s\+\(\S\+\)', {2:[1]}, 0],
    \['\(\S\+\)\s*:\s*\(\S\+\)', {1:[2]}, 1]
\]
au FileType python let b:DD_call = '!python3 -m pydoc <TOKEN>'
au FileType python nnoremap <buffer> K :DD<CR>
```

## Example .vimrc additions for julia

```
au FileType julia let b:DD_conj = '.'
au FileType julia let b:DD_permissible_chars = 'a-zA-Z0-9\._'
au FileType julia let b:DD_import_patterns = [
    \['using\s\+\(\S\+\)\s*:\s*\(\S\+\)', {2:[1, 2]}, 0],
    \]
au FileType julia let b:DD_call = "!julia -E 'try; using <1>; catch; end; @doc <TOKEN>' | less"
```
