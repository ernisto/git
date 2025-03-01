local fs = require('@lune/fs')

local types = require('@lib/types')
local u32 = types.u32
type u32 = types.u32

local index_entry = require('entry')
export type entry = index_entry.entry

-- defs
local SIGNATURE = 'DIRC'
export type index = {
	entry_amount: number,
	entries: { entry },
	data: buffer,
}

-- constructor
local cache: { [types.path]: index } = {}
local function read_from_path(path: types.path): index
	if cache[path] then return cache[path] end

	local data = buffer.fromstring(fs.readFile(path))
	local offset = 0

	-- header
	local signature = buffer.readstring(data, offset, 4)
	offset += u32.size

	assert(signature == SIGNATURE, `invalid index file: signature mismatch`)

	-- version
	local version = u32.read_be(data, offset)
	offset += u32.size

	if version ~= 2 then warn('This parser is designed for version 2, found version ' .. version) end

	-- body
	local entry_amount = u32.read_be(data, offset)
	local entries = {}
	offset += u32.size

	for i = 1, entry_amount do
		local entry, newOffset = index_entry.read(data, offset)
		offset = newOffset
		table.insert(entries, entry)
	end

	-- object
	local index = table.freeze {
		entry_amount = entry_amount,
		entries = entries,
		data = data,
	}

	-- end
	cache[path] = index
	return cache[path]
end
local function read_local(): index
	return read_from_path('.git/index')
end

-- functions
function find_entry(path: types.path): entry?
	local index = read_local()
	for _, entry in index.entries do
		if entry.path == path then return entry end
	end
	return
end

-- module
return table.freeze {
	read_local = read_local,
	read_from_path = read_from_path,
	find_entry = find_entry,
}
