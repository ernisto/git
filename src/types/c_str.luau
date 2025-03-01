--[[
    this type represents a string of programming language C
    where strings terminates with \0 (byte 0)
--]]

-- defs
export type luau_str = string
export type c_str = string

-- functions
local function read(data: buffer, cursor: number): (luau_str, number)
	local len = 0
	while buffer.readu8(data, cursor) ~= 0 do
		cursor += 1
		len += 1
	end

	return buffer.readstring(data, cursor - len, len), cursor
end
local function write(data: buffer, cursor: number, str: luau_str): number
	buffer.writestring(data, cursor, str, #str)
	return #str
end

local function from_luau(luau_str: luau_str): c_str
	return luau_str .. '\0'
end
local function to_luau(c_str: c_str): luau_str
	return string.sub(c_str, 1, -2)
end
local function is_valid(str: string): c_str?
	return if string.sub(str, -1, -1) == '\0' then str else nil
end

-- module
return table.freeze {
	write = write,
	read = read,

	from_luau = from_luau,
	to_luau = to_luau,
	is = is_valid,
}
