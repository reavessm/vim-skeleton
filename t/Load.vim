let g:skeleton_test_dir = 't'
let g:skeleton_template_dir = g:skeleton_test_dir . '/templates'

function! SkeletonFiletypeTemplate_custom(filename)
  let g:skeleton_called_custom_template_func = 1
  return 'custom.txt'
endfunction

let skeleton_replacements = {}

function! skeleton_replacements.CUSTOM()
  let g:skeleton_called_custom_replace_func = 1
endfunction

let skeleton_replacements_custom = {}

function! skeleton_replacements_custom.CUSTOM()
  let g:skeleton_called_custom_replace_filetype_func = 1
endfunction

describe 'skeleton#Load'
  before
    new
    let g:skeleton_called_custom_template_func = 0
    let g:skeleton_called_custom_replace_func = 0
    let g:skeleton_called_custom_replace_filetype_func = 0
  end

  after
    bdelete!
  end

  it 'returns -1 when it aborts'
    0put = 'Existing text'
    let result = skeleton#Load('txt', 'test.txt', 0, '')
    Expect result == -1
  end

  it 'returns 0 when no template exists'
    Expect filereadable(g:skeleton_template_dir.'/skel.xxx') == 0
    let result = skeleton#Load('xxx', 'test.xxx', 0, '')
    Expect result == 0
  end

  it 'returns 1 when it loads a template'
    Expect filereadable(g:skeleton_template_dir.'/skel.txt') == 1
    let result = skeleton#Load('txt', 'test.txt', 0, '')
    Expect result == 1
  end

  it 'does nothing if the buffer is not empty'
    0put = 'Existing text'
    call skeleton#Load('txt', 'test.txt', 0, '')
    Expect line('$') == 2
    Expect getline(1) ==# 'Existing text'
    Expect getline('$') ==# ''
  end

  it 'does nothing if the file exists on disk'
    let test_file = g:skeleton_test_dir . '/exists.txt'
    Expect filereadable(test_file) == 1
    call skeleton#Load('txt', test_file, 0, '')
    Expect getline(1) ==# ''
  end

  it 'does nothing if no template exists'
    Expect filereadable(g:skeleton_template_dir.'/skel.xxx') == 0
    call skeleton#Load('xxx', 'test.xxx', 0, '')
    Expect getline(1) ==# ''
  end

  it 'replaces the contents of the buffer with "force" parameter'
    0put = 'Existing text'
    call skeleton#Load('txt', 'test.txt', 1, '')
    Expect getline(1) ==# 'Default template: skel.txt'
  end

  it 'calls a custom template function if it exists'
    call skeleton#Load('custom', 'test.custom', 0, '')
    Expect g:skeleton_called_custom_template_func == 1
  end

  it 'reads a custom template if possible'
    Expect filereadable(g:skeleton_template_dir.'/custom.txt') == 1
    call skeleton#Load('custom', 'test.txt', 0, '')
    Expect getline(1) ==# 'Custom template: custom.txt'
  end

  it 'reads a template based on the parent dir if possible'
    Expect filereadable(g:skeleton_template_dir.'/dir.txt') == 1
    call skeleton#Load('txt', 'dir/test.txt', 0, '')
    Expect getline(1) ==# 'Directory template: dir.txt'
  end

  it 'reads a default skel.ext template'
    Expect filereadable(g:skeleton_template_dir.'/skel.txt') == 1
    call skeleton#Load('txt', 'test.txt', 0, '')
    Expect getline(1) ==# 'Default template: skel.txt'
  end

  it 'reads a specific template when specified'
    Expect filereadable(g:skeleton_template_dir.'/custom.txt') == 1
    call skeleton#Load('txt', 'test.txt', 0, 'custom.txt')
    Expect getline(1) ==# 'Custom template: custom.txt'
  end

  it 'calls a custom replace function if it exists'
    call skeleton#Load('txt', 'test.txt', 0, '')
    Expect g:skeleton_called_custom_replace_func == 1
  end

  it 'calls a custom filetype replace function if it exists'
    call skeleton#Load('custom', 'test.txt', 0, '')
    Expect g:skeleton_called_custom_replace_filetype_func == 1
  end
end
