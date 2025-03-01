local tree = require('@lib/object/tree')
local types = require('@lib/types')

local function get_tree_child_by_path(root: types.tree, path: string): types.tree_child?
	local node = root
	local ancestry = path:split('/')
	local file_name = table.remove(ancestry)
	if not file_name then return end

	for _, child_name in ancestry do
		local child = node.children[child_name]
		if not child then return end

		if child.mode ~= 'directory' then return end
		node = tree.read_from_id(child.id)
	end
	return node.children[file_name]
end

return get_tree_child_by_path
