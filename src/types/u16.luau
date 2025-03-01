-- defs
local U16_SIZE = 16 / 8
local LIMIT = 2 ^ 16

export type u16 = number
export type raw_number = string

-- functions
local read_u16_le = buffer.readu16
local write_u16_le = buffer.writeu16

local function read_u16_be(data: buffer, cursor: number): u16
	return bit32.rshift(bit32.byteswap(buffer.readu16(data, cursor)), 16)
end
local function write_u16_be(data: buffer, cursor: number, number: u16)
	buffer.writeu16(data, cursor, bit32.byteswap(bit32.lshift(number, 16)))
end

local function from_string(input: string): u16?
	return if string.find(input, '^%d+$') and tonumber(input) < LIMIT then tonumber(input) else nil
end

-- module
return table.freeze({
	write_be = write_u16_be,
	read_be = read_u16_be,

	write_le = write_u16_le,
	read_le = read_u16_le,

	from_string = from_string,
	to_string = tostring,

	huge = LIMIT,
	size = U16_SIZE,
})
