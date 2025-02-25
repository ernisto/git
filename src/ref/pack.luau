local fs = require('@lune/fs')

local types = require('@lib/types')
type path = types.path

-- defs
export type packed_refs = { [path]: types.sha1 }

-- functions
local pack: packed_refs?
local function read(): packed_refs

    if pack then return pack end
    local raw_refs = fs.isFile('.git/packed-refs') and fs.readFile('.git/packed-refs') or nil
    local refs = {}

    if raw_refs then
        for _,line in string.split(raw_refs, '\n') do
            local sha, path = string.match(line, "(%S+) (.+)")
            if sha and path then refs[path] = sha end
        end
    end

    pack = table.freeze(refs)
    return pack :: any
end

-- module
return table.freeze {
    read = read,
}