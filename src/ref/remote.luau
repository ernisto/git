local read_descendant_paths = require('@utils/read_descendant_paths')
local future = require('@pkg/future')

local types = require('@lib/types')
local warns = require('@lib/warns')
local ref = require('@lib/ref')

-- functions
local function read_from_id(path: types.ref_id): types.remote
	return ref.read_from_id(path) :: any
end
local function read_from_name(name: string): types.remote
	return read_from_id('refs/remotes/' .. name)
end
-- local function read_current(): types.remote
--     local id = fs.readFile('.git/HEAD'):match("^ref: (%S+)")
--         or error(`couldnt possible read HEAD`)

--     return read_from_id(id)
-- end

local function read_all(): { [string]: types.remote }
	local remotes = table.clone(ref.load_packeds().remotes)
	local futures = {}

	local remote_paths = read_descendant_paths('.git/refs/remotes', 'refs/remotes')
	warns.so_many_ref_files(#remote_paths, 'remotes')

	for _, path in remote_paths do
		table.insert(futures, future.spawn(read_from_id, path))
	end
	for _, remote in future.all(futures):await() do
		remotes[remote.name] = remote
	end
	return remotes
end

-- module
return table.freeze({
	read_from_name = read_from_name,
	read_from_id = read_from_id,

	-- read_current = read_current,
	read_all = read_all,
})
