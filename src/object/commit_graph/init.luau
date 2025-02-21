local header = require('header')

local types = require('@lib/types')
local sha1 = types.sha1

local fs = require('@lune/fs')

-- functions
local function deserialize_commit(data, cursor: number): (string, number, number)

    local id = sha1.read(data, cursor)
    cursor += sha1.size

    -- local parents = {}
    local prev_addr = buffer.readi32(data, cursor + 20)

    -- while prev_addr < 0 do
        -- cursor += 4
    -- end

    local timestamp = bit32.byteswap(buffer.readu32(data, cursor + 24))

    return id, prev_addr, timestamp
end
local function deserialize(data: buffer)
    local head = header.deserialize(data)
    local cursor = header.size --+ 4*head.chunks_count

    print(head)

    local commit_id, b = deserialize_commit(data, cursor)
    print(commit_id, b)
end

-- test
local raw_commits = fs.readFile('.git/objects/info/commit-graph')
local data = buffer.fromstring(raw_commits)

deserialize(data)

return nil