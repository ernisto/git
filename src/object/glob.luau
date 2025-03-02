local object = require('init')
local types = require('@lib/types')

-- constructor
local cache = {}
local function load_glob(glob: types.glob): types.glob
	cache[glob.id] = glob
	return glob
end
local function try_parse(raw: string, id: types.sha1): types.glob?
	local size, content = string.match(raw, 'glob (%d+)\0(.+)')
	if not content then return end

	return table.freeze {
		id = id,
		size = tonumber(size) or -1,
		content = content,
	}
end

-- functions
local function read_from_id(id: types.sha1): types.glob
	if cache[id] then return cache[id] end

	local raw = object.read_from_id(id) or error(`couldnt possible read object '{id}'`)
	local glob = try_parse(raw, id) or error(`object '{id}' probably isnt a glob\n{raw}`)

	return load_glob(glob)
end

-- module
return table.freeze {
	read_from_id = read_from_id,
	_load = load_glob,
}
