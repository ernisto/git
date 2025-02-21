local fs = require('@lune/fs')

local function read_descendants_paths(path: string, local_path: string?, out: {string}?)
    out = out or {}
    local_path = local_path or ''
    assert(out and local_path)

    for _,name in fs.readDir(path) do
        if fs.isFile(path..'/'..name) then
            table.insert(out, local_path..'/'..name)
        else
            read_descendants_paths(path..'/'..name, local_path..'/'..name, out)
        end
    end
    return out
end

return read_descendants_paths