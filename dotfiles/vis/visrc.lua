require('vis')

require('plugins/vis-cursors') -- Cursorposition pro Datei merken
local fzf = require('plugins/vis-fzf-open/fzf-open') -- :fzf
fzf.fzf_args = '--height=40%'

-- Kommentare umschalten: gc{motion}, gcc für die aktuelle Zeile, gc im Visual-Mode
local comment_prefix = {
	c = '//', cpp = '//', go = '//', javascript = '//', typescript = '//', rust = '//',
	lua = '--', haskell = '--', sql = '--',
	latex = '%',
}

vis:operator_new('gc', function(file, range, pos)
	-- auf ganze Zeilen erweitern
	local s = range.start
	while s > 0 and file:content(s - 1, 1) ~= '\n' do s = s - 1 end
	range = { start = s, finish = range.finish }

	local prefix = comment_prefix[vis.win.syntax] or '#'
	local esc = prefix:gsub('%p', '%%%0')
	local text = file:content(range)

	local commented = true
	for line in text:gmatch('[^\n]+') do
		if not line:match('^%s*$') and not line:match('^%s*' .. esc) then commented = false end
	end

	local new = text:gsub('[^\n]+', function(line)
		if line:match('^%s*$') then return line end
		if commented then return (line:gsub('^(%s*)' .. esc .. ' ?', '%1')) end
		return (line:gsub('^(%s*)', function(ws) return ws .. prefix .. ' ' end))
	end)

	file:delete(range)
	file:insert(range.start, new)
	return pos
end, 'Toggle comment')

vis.events.subscribe(vis.events.INIT, function()
	vis:command('set theme default')
	vis:command('set autoindent on')

	vis:map(vis.modes.NORMAL, 'gcc', 'Vgc<Escape>')
	vis:map(vis.modes.NORMAL, '<C-p>', ':fzf<Enter>')
	vis:map(vis.modes.NORMAL, '<C-s>', ':w<Enter>')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
	vis:command('set number on')
	vis:command('set relativenumbers on')
	vis:command('set cursorline on')
	vis:command('set colorcolumn 100')
	vis:command('set show-tabs on')
	vis:command('set tabwidth 4')
end)
