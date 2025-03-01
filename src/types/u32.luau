-- defs
local U32_SIZE = 32 / 8
local LIMIT = 2 ^ 32

export type u32 = number
export type raw_number = string

-- functions
local read_u32_le = buffer.readu32
local write_u32_le = buffer.writeu32

local function read_u32_be(data: buffer, cursor: number): (u32, number)
	return bit32.byteswap(buffer.readu32(data, cursor)), cursor + U32_SIZE
end
local function write_u32_be(data: buffer, cursor: number, number: u32): number
	buffer.writeu32(data, cursor, bit32.byteswap(number))
	return cursor + U32_SIZE
end

local function from_string(input: string): u32?
	return if string.find(input, '^%d+$') and tonumber(input) < LIMIT then tonumber(input) else nil
end

-- module
return table.freeze({
	write_be = write_u32_be,
	read_be = read_u32_be,

	write_le = write_u32_le,
	read_le = read_u32_le,

	from_string = from_string,
	to_string = tostring,

	huge = LIMIT,
	size = U32_SIZE,
})
