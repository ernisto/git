local fs = require('@lune/fs')
local types = require('@lib/types')

local sha1 = types.sha1
type sha1 = types.sha1

local u32 = types.u32
type u32 = types.u32

-- defs
local V2_SIGNATURE = '\xFFtOc'
export type pack_index = {
	data: buffer,
	version: number,
	objects_amount: number,
	fanout: { u32 },
}

-- constructor
local cache: { [types.path]: pack_index } = {}
local function read_from_path(path: types.path): pack_index
	if cache[path] then return cache[path] end

	local data = buffer.fromstring(fs.readFile(path))
	local cursor = 0

	local sig = buffer.readstring(data, cursor, #V2_SIGNATURE)
	cursor += #V2_SIGNATURE

	-- version
	local version = if sig == V2_SIGNATURE then 2 else 1
	if version == 2 then
		local _version = u32.read_be(data, cursor)
		cursor += u32.size
		assert(_version == 2, `unsupported version '{_version}'`)
	end

	-- fanout
	local fanout = {}
	for first_sha1_byte = 1, 256 do
		fanout[first_sha1_byte] = u32.read_be(data, cursor) -- offset in this file when `object_id` starts with `first_sha1_byte`
		cursor += u32.size
	end

	-- object
	local objects_amount = fanout[256]
	local idx = table.freeze({
		data = data,
		version = version,
		objects_amount = objects_amount,
		fanout = table.freeze(fanout),
	})

	-- end
	cache[path] = idx
	return idx
end
local function read_from_id(pack_id: sha1): pack_index
	return read_from_path(`.git/objects/pack/pack-{pack_id}.idx`)
end

-- functions
local function find_object_id(pack_id: sha1, object_id: sha1): (u32, u32)
	local idx_file = read_from_id(pack_id)
	local objects_amount = idx_file.objects_amount
	local data = idx_file.data
	local fanout = idx_file.fanout

	local seeking_first_byte = tonumber(string.sub(object_id, 1, 2), 16)
		or error(`invalid object id (must to be a string with 40 hex characters)`)
	local index = fanout[seeking_first_byte]

	local sha1_cursor = #V2_SIGNATURE + u32.size + 256 * u32.size
	local crcs_cursor = sha1_cursor + objects_amount * sha1.size
	local offsets_cursor = crcs_cursor + objects_amount * u32.size

	index -= 1
	repeat
		index += 1 -- this statement must to be here for next repetitions
		local first_byte = buffer.readu8(data, sha1_cursor + index * sha1.size)
		if first_byte ~= seeking_first_byte then break end

		local id = sha1.read(data, sha1_cursor + index * sha1.size)
	until id == object_id

	local crc = u32.read_be(data, crcs_cursor + index * u32.size)
	local offset = u32.read_be(data, offsets_cursor + index * u32.size)

	return offset, crc
end
local function search_object_id(object_id: sha1): (sha1?, u32?)
	for _, pack_name in fs.readDir(`.git/objects/pack`) do
		local pack_id = string.match(pack_name, '^pack%-(.-)%.pack$')
		if not pack_id then continue end

		local offset = find_object_id(pack_id, object_id)
		if offset then return pack_id, offset end
	end
	return
end

-- module
return table.freeze({
	search_object_id = search_object_id,
	read_from_path = read_from_path,
	read_from_id = read_from_id,
})
