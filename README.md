at the moment this library only is covering reading simple git files api, and i dont
pretend heavily maintain this library beyond what i need, but feel free to submit
a pull request for new features if you thinking about use it too

# Installation
this module officially can be installed only via [pesde](https://github.com/pesde-pkg/pesde)
```bash
pesde install ernisto/git
```

# Documentation (wip)

### querys
```lua
local function is_version_tag(ref: git.ref)
    return ref.kind == 'tags'
        and git.semver.try_parse(ref.name)
end

local current_branch = git.head.read_current()
local result = git.query.read_ref_by_post_commits {
    commit_id = current_branch.commit_id, predicate = is_version_tag
}
local tag = result.ref or error(`no version tag found`)
```

### object (commits, ~~trees~~ and ~~globs~~)

object.read_from_id(object_id: sha1): raw_object
```lua
local raw_object = object.read_from_id("2387d09d9d5e17162cee849db9595255eb0e0d01")
local commit = commit.read_from_id("2387d09d9d5e17162cee849db9595255eb0e0d01")
```

### ref (branches and tags)

head.read_from_id(id: ref_id): ref
tag.read_from_id(id: ref_id): ref
ref.read_from_id(id: ref_id): ref
```lua
local tag = git.tag.read_from_id("refs/tags/v1.0.0")
local same_tag = git.tag.read_from_name("v1.0.0")
```

head.read_all(): ref
tag.read_all(): ref
```lua
for id, branch in git.head.read_all() do
    print('branch', id, branch)
end
```

head.read_current(): ref
```lua
local current_branch = git.head.read_current()
print(current_branch.name)
```