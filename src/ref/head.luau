local read_descendant_paths = require('@utils/read_descendant_paths')
local future = require('@pkg/future')
local fs = require('@lune/fs')

local types = require('@lib/types')
local warns = require('@lib/warns')
local ref = require('@lib/ref')

-- functions
local function read_from_id(path: types.ref_id): types.head
	return ref.read_from_id(path) :: any
end
local function read_from_name(name: string): types.head
	return read_from_id('refs/heads/' .. name)
end
local function read_current(): types.head
	local id = fs.readFile('.git/HEAD'):match('^ref: (%S+)') or error(`couldnt possible read HEAD`)

	return read_from_id(id)
end

local function read_all(): { [string]: types.head }
	local heads = table.clone(ref.load_packeds().heads)
	local futures = {}

	local head_paths = read_descendant_paths('.git/refs/heads', 'refs/heads')
	warns.so_many_ref_files(#head_paths, 'heads')

	for _, path in head_paths do
		table.insert(futures, future.spawn(read_from_id, path))
	end
	for _, head in future.all(futures):await() do
		heads[head.name] = head
	end
	return heads
end

-- module
return table.freeze({
	read_from_name = read_from_name,
	read_from_id = read_from_id,

	read_current = read_current,
	read_all = read_all,
})
