-- defs
local U32_SIZE = 32/8
export type u32 = number
export type raw_number = string

-- functions
local read_u32_le = buffer.readu32
local write_u32_le = buffer.writeu32

local function read_u32_be(data: buffer, cursor: number): u32
    return bit32.byteswap(buffer.readu32(data, cursor))
end
local function write_u32_be(data: buffer, cursor: number, number: u32)
    buffer.writeu32(data, cursor, bit32.byteswap(number))
end

local function is_valid(input: string): raw_number?
    return if string.find(input, '^%d+$') then input else nil
end
local function try_parse(input: string): u32?
    return if is_valid(input) then tonumber(input) else nil
end

-- module
return table.freeze {
    write_be = write_u32_be,
    read_be = read_u32_be,

    write_le = write_u32_le,
    read_le = read_u32_le,

    try_parse = try_parse,
    is_valid = is_valid,
    tostring = tostring,

    size = U32_SIZE
}