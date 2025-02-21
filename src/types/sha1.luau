--[[
    SHA1 is a 160-bit hash value, typically represented as a 40-character hexadecimal number.
    It is used to uniquely identify objects within a repository.
]]

local u32 = require('u32')

-- defs
local SHA1_SIZE = u32.size*5
export type sha1 = string

-- functions
local function read_sha1(data: buffer, cursor: number): sha1
    return string.format("%08x%08x%08x%08x%08x",
        u32.read_be(data, cursor + 0),
        u32.read_be(data, cursor + 4),
        u32.read_be(data, cursor + 8),
        u32.read_be(data, cursor + 12),
        u32.read_be(data, cursor + 16)
    )
end
local function write_sha1(data: buffer, cursor: number, sha1: sha1)

    u32.write_be(data, cursor + 0, tonumber(string.sub(sha1, 1, 8), 16) :: never)
    u32.write_be(data, cursor + 4, tonumber(string.sub(sha1, 9, 16), 16) :: never)
    u32.write_be(data, cursor + 8, tonumber(string.sub(sha1, 17, 24), 16) :: never)
    u32.write_be(data, cursor + 12, tonumber(string.sub(sha1, 25, 32), 16) :: never)
    u32.write_be(data, cursor + 16, tonumber(string.sub(sha1, 33, 40), 16) :: never)
end

local function is_valid(input: string): sha1?
    return if string.find(input, "%x{20}") then input else nil
end

-- module
return table.freeze {
    write = write_sha1,
    read = read_sha1,

    is_valid = is_valid,
    size = SHA1_SIZE,
}