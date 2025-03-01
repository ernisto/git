local file = require('@utils/file')
local bit_flags = require('bit_flags')

local types = require('@lib/types')
local c_str = types.c_str

local sha1 = types.sha1
type sha1 = types.sha1

local u32 = types.u32
type u32 = types.u32

-- defs
export type entry = {
	path: string,
	object_id: sha1,
	flags: bit_flags.flags,
	mode_perms: file.perms,
	mode_type: file.type,
	size: u32?, -- for some reason sometimes is just 0, so i assuming unavailability

	creation_time: number,
	modification_time: number,

	-- unavailable on windows
	device_id: u32?,
	inode_id: u32?,
	group_id: u32?,
	user_id: u32?,
}

-- functions
function read(buf: buffer, cursor: number): (entry, number)
	local ctime_s = u32.read_be(buf, cursor)
	cursor += u32.size

	local ctime_ns = u32.read_be(buf, cursor)
	cursor += u32.size

	local mtime_s = u32.read_be(buf, cursor)
	cursor += u32.size

	local mtime_ns = u32.read_be(buf, cursor)
	cursor += u32.size

	local device_id = u32.read_be(buf, cursor)
	cursor += u32.size

	local inode_id = u32.read_be(buf, cursor)
	cursor += u32.size

	local mode = u32.read_be(buf, cursor)
	cursor += u32.size

	local mode_type: file.type = file.get_type(bit32.band(mode, 0xF000))
	local mode_perms = file.get_perms(bit32.band(mode, 0x0FFF))

	local user_id = u32.read_be(buf, cursor)
	cursor += u32.size

	local group_id = u32.read_be(buf, cursor)
	cursor += u32.size

	local size = u32.read_be(buf, cursor)
	cursor += u32.size

	local object_id = sha1.read(buf, cursor)
	cursor += sha1.size

	local flags
	flags, cursor = bit_flags.read(buf, cursor)

	local path
	path, cursor = c_str.read(buf, cursor)

	-- object
	local entry = table.freeze {
		path = path,
		flags = flags,
		object_id = object_id,
		mode_type = mode_type,
		mode_perms = mode_perms,
		size = size ~= 0 and size or nil,

		modification_time = mtime_s + mtime_ns / 1e9,
		creation_time = ctime_s + ctime_ns / 1e9,

		device_id = device_id ~= 0 and device_id or nil,
		inode_id = inode_id ~= 0 and inode_id or nil,
		group_id = group_id ~= 0 and group_id or nil,
		user_id = user_id ~= 0 and user_id or nil,
	}

	-- end
	cursor += 8 - (cursor - 12) % 8
	return entry, cursor
end

-- module
return table.freeze {
	read = read,
}
