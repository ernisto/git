-- ported from https://github.com/GitoxideLabs/gitoxide/blob/main/gix-index/src/entry/flags.rs

local types = require('@lib/types')
local u16 = types.u16

-- defs
local flag_masks: { [string]: number } = table.freeze {
	update = 0b0000_0000_0000_0001,
	remove = 0b0000_0000_0000_0010,
	up_to_date = 0b0000_0000_0000_0100,
	added = 0b0000_0000_0000_1000,
	hashed = 0b0000_0000_0001_0000,
	fsmonitor_valid = 0b0000_0000_0010_0000,
	worktree_valid = 0b0000_0000_0100_0000,
	conflicted = 0b0000_0000_1000_0000,
	unpacked = 0b0000_0000_0001_0000,
	new_skip_worktree = 0b0000_0010_0000_0000,
	pathspec_matched = 0b0000_0100_0000_0000,
	update_in_base = 0b0000_1000_0000_0000,
	strip_name = 0b0001_0000_0000_0000,
	intent_to_add = 0b0010_0000_0000_0000,
	skip_worktree = 0b0100_0000_0000_0000,
	extended_2 = 0b1000_0000_0000_0000,
}
export type flags = {
	-- The mask to obtain the length of the path associated with this entry, up to 4095 characters without extension.
	path_size: number,
	-- The mask to apply to obtain the stage number of an entry, encoding three value: 0 = base, 1 = ours, 2 = theirs.
	stage: number,
	-- If set, additional bits need to be written to storage.
	extended: boolean,
	-- If set, the entry be assumed to match with the version on the working tree, as a way to avoid `lstat()`  checks.
	assume_valid: boolean,
	-- Indicates that an entry needs to be updated as it's in-memory representation doesn't match what's on disk.
	update: boolean?,
	-- Indicates an entry should be removed - this typically happens during writing, by simply skipping over them.
	remove: boolean?,
	-- Indicates that an entry is known to be up-to-date.
	up_to_date: boolean?,
	-- Only temporarily used by unpack_trees() (in C).
	added: boolean?,
	-- Whether an up-to-date object hash exists for the entry.
	hashed: boolean?,
	-- Set if the filesystem monitor is valid.
	fsmonitor_valid: boolean?,
	-- Remove in work directory
	worktree_valid: boolean?,
	-- Set to indicate the entry exists in multiple stages at once due to conflicts.
	conflicted: boolean?,
	-- Indicates that the entry was already turned into a tree.
	unpacked: boolean?,
	-- Only temporarily used by unpack_trees() (in C)
	new_skip_worktree: boolean?,
	-- temporarily mark paths matched by a path spec
	pathspec_matched: boolean?,
	-- When the index is split, this indicates the entry is up-to-date in the shared portion of the index.
	update_in_base: boolean?,
	-- Indicates the entry name is present in the base/shared index, and thus doesn't have to be stored in this one.
	strip_name: boolean?,

	-- Created with `git add --intent-to-add` to mark empty entries that have their counter-part in the worktree, but not-- yet in the object database.
	intent_to_add: boolean?,
	-- Stored at rest
	skip_worktree: boolean?,
	-- For future extension
	extended_2: boolean?,
}

-- functions
local function read(data: buffer, cursor: number): (flags, number)
	local num = u16.read_be(data, cursor)
	cursor += u16.size

	local flags = {
		path_size = bit32.band(num, 0b0000_1111_1111_1111),
		stage = bit32.band(num, 0b0011_0000_0000_0000),
		extended = bit32.btest(num, 0b0100_0000_0000_0000),
		assume_valid = bit32.btest(num, 0b1000_0000_0000_0000),
	}

	if flags.extended then
		local extended_flags = u16.read_be(data, cursor)
		cursor += u16.size

		for flag, mask in flag_masks do
			flags[flag] = bit32.btest(extended_flags, mask)
		end
	end

	return table.freeze(flags), cursor
end

-- module
return table.freeze {
	read = read,
}
