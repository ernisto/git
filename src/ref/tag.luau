local read_descendant_paths = require('@utils/read_descendant_paths')
local future = require('@pkg/future')

local types = require('@lib/types')
local warns = require('@lib/warns')
local ref = require('@lib/ref')

-- functions
local function read_from_id(id: types.ref_id): types.tag
	return ref.read_from_id(id) :: any
end
local function read_from_name(name: string): types.tag
	return read_from_id('refs/tags/' .. name)
end

local function read_all(): { [string]: types.tag }
	local tags = table.clone(ref.load_packeds().tags)
	local futures = {}

	local tag_ids = read_descendant_paths('.git/refs/tags', 'refs/tags')
	warns.so_many_ref_files(#tag_ids, 'tags')

	for _, tag_id in tag_ids do
		table.insert(futures, future.spawn(read_from_id, tag_id))
	end
	for _, tag in future.all(futures):await() do
		tags[tag.name] = tag
	end
	return tags
end

-- module
return table.freeze({
	read_from_name = read_from_name,
	read_from_id = read_from_id,

	read_all = read_all,
})
