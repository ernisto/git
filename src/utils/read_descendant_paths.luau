local fs = require('@lune/fs')
local future = require('@pkg/future')

export type path = string

local function read_descendants_paths(
	path: string,
	local_path: string,
	out: { string },
	futures: { future.Future<any> }
)
	for _, name in fs.readDir(path) do
		table.insert(
			futures,
			future.spawn(function()
				if fs.isFile(path .. '/' .. name) then
					table.insert(out, local_path .. '/' .. name)
				else
					read_descendants_paths(path .. '/' .. name, local_path .. '/' .. name, out, futures)
				end
				return nil
			end)
		)
	end
	return out
end

local function _read_descendants_paths(path: path, local_path: path?): { path }
	local_path = local_path or ''
	assert(local_path)

	local futures = {}
	local out = {}

	read_descendants_paths(path, local_path, out, futures)
	future.all(futures):await()

	return out
end

return _read_descendants_paths
