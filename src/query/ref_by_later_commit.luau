local commit = require('@lib/object/commit')
local ref = require('@lib/ref')

local types = require('@lib/types')
type sha1 = types.sha1
type ref = types.ref

-- util
local refs_by_commit
local function map_refs_by_commit(): { [sha1]: { ref } }
	if refs_by_commit then return refs_by_commit end
	refs_by_commit = {}

	for _, ref in ref.read_all() do
		refs_by_commit[ref.commit_id] = refs_by_commit[ref.commit_id] or {}
		table.insert(refs_by_commit[ref.commit_id], ref)
	end
	return refs_by_commit
end

-- module
type params = {
	commit_id: sha1,
	predicate: nil | (ref) -> (),
}
type result = {
	ref: ref?,
	later_commit_ids: { sha1 },
}
local function query_ref_by_later_commit(params: params): result
	local refs_by_commit = map_refs_by_commit()
	local traversed_commit_timestamps: { [sha1]: number } = {}
	local predicate = params.predicate

	local ordered_commit_ids = { params.commit_id }
	local commit_ids = { params.commit_id }
	repeat
		local next_commit_ids = {}
		for _, commit_id in commit_ids do
			-- guard
			if traversed_commit_timestamps[commit_id] then continue end
			local this_commit = commit.read_from_id(commit_id)
			local timestamp = this_commit.global_timestamp
			traversed_commit_timestamps[commit_id] = timestamp

			-- ascending sorted insert
			for index = #ordered_commit_ids, 1, -1 do
				local prev_commit_id = ordered_commit_ids[index]
				if timestamp >= traversed_commit_timestamps[prev_commit_id] then continue end

				table.insert(ordered_commit_ids, index, commit_id)
				break
			end

			-- check
			local refs = refs_by_commit[commit_id] or {}
			for _, ref in refs :: { ref } do
				if predicate and not predicate(ref) then continue end
				for _, traversed_commit_id in ordered_commit_ids do
					refs_by_commit[traversed_commit_id] = ref
				end
				return table.freeze({ ref = ref, later_commit_ids = ordered_commit_ids })
			end

			-- queue all parents for next iteration
			for _, parent_id in this_commit.parent_ids do
				table.insert(next_commit_ids, parent_id)
			end
		end
		commit_ids = next_commit_ids
	until #commit_ids == 0

	return table.freeze({ later_commit_ids = ordered_commit_ids })
end

-- end
return query_ref_by_later_commit
