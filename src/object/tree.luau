local file = require('@utils/file')
local object = require('init')

local types = require('@lib/types')
local c_str = types.c_str
local sha1 = types.sha1

-- constructor
local cache = {}
local function load_tree(tree: types.tree): types.tree
	cache[tree.id] = tree
	return tree
end
local function try_parse(raw: string, id: types.sha1): types.tree?
	local size, content = string.match(raw, 'tree (%d+)\0(.+)')
	if not content then return end

	local data = buffer.fromstring(content)
	local cursor = 0

	local children = {}
	while cursor < buffer.len(data) do
		local str
		str, cursor = c_str.read(data, cursor)

		local mode, file_name = unpack(string.split(str, ' '))
		cursor += 1

		local child_id = sha1.read(data, cursor)
		cursor += sha1.size

		children[file_name] = table.freeze {
			id = child_id,
			mode = file.get_type(tonumber(mode, 8) or -1),
		}
	end

	local tree = table.freeze {
		id = id,
		size = tonumber(size) or -1,
		children = children,
	}
	return tree
end

-- functions
local function read_from_id(id: types.sha1): types.tree
	if cache[id] then return cache[id] end

	local raw = object.read_from_id(id) or error(`couldnt possible read object '{id}'`)
	local tree = try_parse(raw, id) or error(`object '{id}' probably isnt a tree\n{raw}`)

	return load_tree(tree)
end

-- module
return table.freeze {
	read_from_id = read_from_id,
	_load = load_tree,
}
