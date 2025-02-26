local types = require('@lib/types')
local index = require('index')
local data = require('data')

-- functions
local function read_object_id(object_id: types.sha1): (string, types.object_kind)
	local pack_id, addr = index.search_object_id(object_id)
	assert(pack_id and addr, `object not found with id '{object_id}'`)

	return data.read_addr(pack_id, addr)
end

-- module
return table.freeze({
	read_object_id = read_object_id,
})
