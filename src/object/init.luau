local serde = require('@lune/serde')
local fs = require('@lune/fs')

local types = require('@lib/types')
local pack = require('pack')

export type raw_object = string

-- constructor
local global_cache = {}
local function read_from_path(path: types.path): raw_object
	if global_cache[path] then return global_cache[path] end
	local raw_object = serde.decompress('zlib', fs.readFile(path))

	global_cache[path] = raw_object
	return raw_object
end

local cache = {}
local function load_object(id: types.sha1, object: raw_object): raw_object
	cache[id] = object
	return object
end
local function read_from_id(id: types.sha1): raw_object?
	if cache[id] then return cache[id] end
	local path = `.git/objects/{string.sub(id, 1, 2)}/{string.sub(id, 3)}`

	local exists = fs.isDir(`.git/objects/{string.sub(id, 1, 2)}`) and fs.isFile(path)
	local raw_object = if exists then read_from_path(path) else pack.read_object_id(id)

	if not raw_object then return end
	return load_object(id, raw_object)
end

-- module
return table.freeze({
	read_from_path = read_from_path,
	read_from_id = read_from_id,

	_load = load_object,
})
