local object = require('init')
local types = require('@lib/types')

-- constructor
local cache = {}
local function load_blob(blob: types.blob): types.blob
	cache[blob.id] = blob
	return blob
end
local function try_parse(raw: string, id: types.sha1): types.blob?
	local size, content = string.match(raw, 'blob (%d+)\0(.+)')
	if not content then return end

	return table.freeze {
		id = id,
		size = tonumber(size) or -1,
		content = content,
	}
end

-- functions
local function read_from_id(id: types.sha1): types.blob
	if cache[id] then return cache[id] end

	local raw = object.read_from_id(id) or error(`couldnt possible read object '{id}'`)
	local blob = try_parse(raw, id) or error(`object '{id}' probably isnt a blob\n{raw}`)

	return load_blob(blob)
end

-- module
return table.freeze {
	read_from_id = read_from_id,
	_load = load_blob,
}
