local commit = require('@lib/object/commit')
local ref = require('@lib/ref')

local types = require('@lib/types')
type sha1 = types.sha1
type ref = types.ref

-- util
local refs_by_commit
local function map_refs_by_commit(): { [sha1]: {ref} }
    if refs_by_commit then return refs_by_commit end
    refs_by_commit = {}

    for _,ref in ref.read_all() do
        refs_by_commit[ref.commit_id] = refs_by_commit[ref.commit_id] or {}
        table.insert(refs_by_commit[ref.commit_id], ref)
    end
    return refs_by_commit
end

-- module
type params = {
    commit_id: sha1?,
    predicate: nil|(ref) -> (),
}
type result = {
    ref: ref?,
    post_commit_ids: { sha1 }
}
local function read_ref_by_post_commits(params: params): result

    local refs_by_commit = map_refs_by_commit()
    local post_commit_ids: {sha1} = {}
    local predicate = params.predicate

    local commit_ids = {params.commit_id or nil :: never}
    repeat
        local next_commit_ids = {}
        for _,commit_id in commit_ids do
            local refs = refs_by_commit[commit_id] or {}
            for _,ref in refs :: {ref} do
                if predicate and not predicate(ref) then continue end
                for _,traversed_commit_id in post_commit_ids do refs_by_commit[traversed_commit_id] = ref end
                return table.freeze { ref = ref, post_commit_ids = post_commit_ids }
            end
            for _,parent_id in commit.read_from_id(commit_id).parent_ids do
                table.insert(next_commit_ids, parent_id)
            end
            table.insert(post_commit_ids, commit_id)
        end
        commit_ids = next_commit_ids
    until #commit_ids == 0
    return table.freeze {
        post_commit_ids = post_commit_ids,
    }
end

-- end
return read_ref_by_post_commits