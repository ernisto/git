local fs = require('@lune/fs')
local pack = require('pack')

local types = require('@lib/types')
type remote = types.remote
type head = types.head
type ref = types.ref
type tag = types.tag

type path = string
type sha1 = string

-- constructor
local cache: { [string]: ref } = {}
local function load_ref(path: types.ref_id, commit_id: sha1): ref

    local elements = string.split(path, '/')
    local kind, name, last_name = elements[2], table.concat(elements, '/', 3), elements[#elements]

    assert(kind and name, `invalid path '{path}'`)
    local ref = table.freeze {
        path = path,
        kind = kind,
        name = name,
        last_name = last_name,
        commit_id = commit_id
    } :: any

    cache[path] = ref
    return ref
end

-- functions
type loaded_pack = { remotes: { [path]: remote }, heads: { [path]: head }, tags: { [path]: tag }, refs: { [path]: ref } }
local loaded
local function load_packeds(): loaded_pack
    if loaded then return loaded end

    local refs = {}
    loaded = table.freeze {
        refs = refs,
        remotes = {},
        heads = {},
        tags = {},
    }

    local raw_pack = pack.read()
    for path, commit_id in raw_pack do
        local ref = load_ref(path, commit_id)
        loaded[ref.kind] = ref
        refs[path] = ref
    end

    table.freeze(loaded.remotes)
    table.freeze(loaded.heads)
    table.freeze(loaded.tags)
    table.freeze(loaded.refs)
    return loaded :: any
end
local function read_from_id(id: types.ref_id): ref

    load_packeds()
    if cache[id] then return cache[id] end

    local commit_id = fs.readFile('.git/'..id):match("%S+")
        or error(`couldnt possible read ref '{id}'`)

    return load_ref(id, commit_id)
end

-- module
return table.freeze {
    load_packeds = load_packeds,
    read_from_id = read_from_id,
    pack = pack,

    _load = load_ref,
}