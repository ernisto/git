export type type = 'symlink' | 'gitlink' | 'directory' | 'regular_file' | 'executable_file'
local function get_file_type(number: number): type
	local modes = {
		[0x1000] = 'symlink',
		[0x2000] = 'gitlink',
		[0x4000] = 'directory',
		[0x8000] = 'regular_file',
		[0xA000] = 'executable_file',
	}
	return modes[number] :: type
end

export type group_perms = { read: boolean, write: boolean, exec: boolean }
export type perms = { owner: group_perms, group: group_perms, others: group_perms }
local function get_perms(mode: number): perms
	return table.freeze {
		owner = table.freeze {
			read = bit32.btest(mode, 0x100),
			write = bit32.btest(mode, 0x80),
			exec = bit32.btest(mode, 0x40),
		},
		group = table.freeze {
			read = bit32.btest(mode, 0x20),
			write = bit32.btest(mode, 0x10),
			exec = bit32.btest(mode, 0x08),
		},
		others = table.freeze {
			read = bit32.btest(mode, 0x04),
			write = bit32.btest(mode, 0x02),
			exec = bit32.btest(mode, 0x01),
		},
	}
end

-- module
return table.freeze {
	get_type = get_file_type,
	get_perms = get_perms,
}
