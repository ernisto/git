local fs = require('@lune/fs')

local types = require('@lib/types')
type path = types.path

-- defs
export type packed_refs = { [path]: types.sha1 }

-- constructor
local cache: { [types.path]: packed_refs } = {}
local function read_from_path(path: types.path): packed_refs
	if cache[path] then return cache[path] end
	local raw_refs = fs.readFile(path)

	local refs = {}
	if raw_refs then
		for _, line in string.split(raw_refs, '\n') do
			local sha, ref_path = string.match(line, '^(%w+) (%S+)')
			if sha and ref_path then refs[ref_path] = sha end
		end
	end
	table.freeze(refs)

	cache[path] = refs
	return refs
end

local function read_local(): packed_refs?
	return fs.isFile('.git/packed-refs') and read_from_path('.git/packed-refs') or nil
end

-- module
return table.freeze({
	read = read_local,
})
