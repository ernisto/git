local get_tree_child_by_path = require('tree_child_by_path')
local index = require('@lib/index')
local types = require('@lib/types')

-- module
local function get_staged_files(index: index.index, tree: types.tree): { index.entry }
	local entries = {}
	for _, entry in index.entries do
		local node = get_tree_child_by_path(tree, entry.path)
		if node and entry.object_id == node.id then continue end

		table.insert(entries, entry)
	end
	return entries
end

return get_staged_files
