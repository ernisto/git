local serde = require('@lune/serde')
local fs = require('@lune/fs')

local types = require('@lib/types')
local u32 = types.u32
type u32 = types.u32

-- defs
export type data_index = {
	data: buffer,
	version: number,
	objects_amount: number,
	cache: { [u32]: { types.object_kind | string } },
}

-- constructor
local cache: { [types.path]: data_index } = {}
local function read_from_path(path: types.path): data_index
	if cache[path] then return cache[path] end

	local raw = fs.readFile(path)
	local data = buffer.fromstring(raw)

	local signature = buffer.readstring(data, 0, 4)
	assert(signature == 'PACK', `unsupported pack version (bad signature)`)

	local version = u32.read_be(data, 4)
	assert(version == 2, `unsupported pack version {version}`)

	local objects_amount = u32.read_be(data, 8)
	local content = table.freeze({
		data = data,
		version = version,
		objects_amount = objects_amount,
		cache = {},
	})

	-- end
	cache[path] = content
	return content
end
local function read_from_id(id: types.sha1): data_index
	return read_from_path(`.git/objects/pack/pack-{id}.pack`)
end

-- functions
local function read_addr(id: types.sha1, cursor: u32): (string, types.object_kind)
	local file = read_from_id(id)
	if file.cache[cursor] then return unpack(file.cache[cursor] :: any) end

	local data = file.data

	local byte = buffer.readu8(data, cursor)
	cursor += 1

	local kind_id = bit32.band(bit32.rshift(byte, 4), 0b111)
	local size = bit32.band(byte, 0b1111)

	local kind = types.object_kind[kind_id] or error(`invalid object kind '{kind_id}'`)
	assert(kind ~= 'offset_delta' and kind ~= 'ref_delta', `unsupported object kind '{kind}'`)

	local shift = 4
	while bit32.band(byte, 0b1000_0000) > 0 do
		byte = buffer.readu8(data, cursor)
		cursor += 1

		size = bit32.bor(size, bit32.lshift(bit32.band(byte, 0b0111_1111), shift))
		shift += 7
	end

	local compressed_data = buffer.readstring(data, cursor, size)
	local raw_data = serde.decompress('zlib', compressed_data)

	file.cache[cursor] = { kind, raw_data }
	return raw_data, types.object_kind[kind_id]
end

-- module
return table.freeze({
	read_from_path = read_from_path,
	read_from_id = read_from_id,
	read_addr = read_addr,
})
