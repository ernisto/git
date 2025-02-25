local fs = require('@lune/fs')

local types = require('@lib/types')
type path = types.path

-- defs
export type packed_refs = {
    heads: { [path]: types.sha1 },
    tags: { [path]: types.sha1 },
    refs: { [path]: types.sha1 },
}

-- functions
local pack: packed_refs?
local function read(): packed_refs

    if pack then return pack end

    local raw_refs = fs.readFile('.git/packed-refs')
        or error(`couldnt possible read '.git/packed-refs'`)

    local heads = {}
    local tags = {}
    local refs = {}

    for _,line in string.split(raw_refs, '\n') do
        local sha, path, kind = string.match(line, "(%S+) (refs/([^/]+).+)")
        if not sha or not path then continue end

        refs[path] = sha
        ;(if kind == 'heads' then heads else tags)[path] = sha
    end

    pack = table.freeze {
        heads = table.freeze(heads),
        tags = table.freeze(tags),
        refs = table.freeze(refs),
    }
    return pack :: any
end

-- module
return table.freeze {
    read = read,
}