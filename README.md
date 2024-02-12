A vim plugin to provide some facilitate a degree of contextually aware documentation.

    What does it do? i) scans the buffer for alias:aliased pairs according to import pattern ii) for token under cursor, looks to replace the namespace (i.e., first sub-token separated by conjuction operator) with aliased, where it's an alias iii) passed the alias->aliased replaced string to a documentation program and reports the output.

Note: relies on https://github.com/ryanbrate/functional.vim

To install, e.g., via vim-plug

    Plug 'ryanbrate/functional.vim'
    Plug 'ryanbrate/developer_documentation.vim'
