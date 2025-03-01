--[[
    SHA1 is a 160-bit hash value, typically represented as a 40-character hexadecimal number.
    It is used to uniquely identify objects within a repository.
]]

local u32 = require('u32')

-- defs
local SHA1_SIZE = u32.size * 5
export type sha1 = string

-- functions
local function read_sha1(data: buffer, cursor: number): (sha1, number)
	return string.format(
		'%08x%08x%08x%08x%08x',
		u32.read_be(data, cursor + 0),
		u32.read_be(data, cursor + 4),
		u32.read_be(data, cursor + 8),
		u32.read_be(data, cursor + 12),
		u32.read_be(data, cursor + 16) :: number
	),
		cursor + SHA1_SIZE
end
local function write_sha1(data: buffer, cursor: number, sha1: sha1): number
	u32.write_be(data, cursor + 0, tonumber(string.sub(sha1, 1, 8), 16) or error(`bad char at pos 1..8`))
	u32.write_be(data, cursor + 4, tonumber(string.sub(sha1, 9, 16), 16) or error(`bad char at pos 9..16`))
	u32.write_be(data, cursor + 8, tonumber(string.sub(sha1, 17, 24), 16) or error(`bad char at pos 17..24`))
	u32.write_be(data, cursor + 12, tonumber(string.sub(sha1, 25, 32), 16) or error(`bad char at pos 25..32`))
	u32.write_be(data, cursor + 16, tonumber(string.sub(sha1, 33, 40), 16) or error(`bad char at pos 33..40`))
	return cursor + SHA1_SIZE
end

local function from_string(input: string): sha1?
	return if not string.find(input, '%X') and #input == 40 then input else nil
end

-- module
return table.freeze({
	write = write_sha1,
	read = read_sha1,

	from_string = from_string,
	to_string = tostring,

	size = SHA1_SIZE,
})
