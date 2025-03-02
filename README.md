at the moment this library only is covering reading simple git files api, and i dont
pretend heavily maintain this library beyond what i need, but feel free to submit
a pull request for new features if you thinking about use it too

# Installation
this module officially can be installed only via [pesde](https://github.com/pesde-pkg/pesde)
```bash
pesde add ernisto/git
```

# Documentation

### querys

```luau
local function query.staged_files(index: git.index, tree: git.tree): { git.entry }

local branch = git.head.read_current()
local last_commit = git.commit.read_from_id(branch.commit_id)
local tree = git.tree.read_from_id(last_commit.tree_id)
local index = git.index.read_local()

local staged_file_entries = git.query.staged_files(index, tree)
lint_files(staged_file_entries)
```

```luau
local function get_tree_child_by_path(root: git.tree, path: string): git.tree_child?

local branch = git.head.read_current()
local last_commit = git.commit.read_from_id(branch.commit_id)
local tree = git.tree.read_from_id(last_commit.tree_id)

local child = query.tree_child_by_path(tree, 'src/server/init.luau')
local blob = git.blob.read_from_id(child.id)
```

```luau
function query.ref_by_later_commit(params: {
    commit_id: sha1,
    predicate: nil|(ref) -> boolean?
}): {
    ref: ref?,
    later_commit_ids: {sha1},
}

local function is_tag(ref: git.ref)
    return ref.kind == 'tags'
end

local current_branch = git.head.read_current()
local result = git.query.read_ref_by_post_commits {
    commit_id = current_branch.commit_id, predicate = is_tag
}
local tag = result.ref or error(`no tag found`)
```

### index

```luau
local function read_local(): index

local index = git.index.read_local()
for _,entry in index.entries do
    print('git are observing', entry.path)
end
```

### object (commits, trees and blobs)

```luau
function object.read_from_id(object_id: sha1): raw_object
function commit.read_from_id(object_id: sha1): commit
function tree.read_from_id(object_id: sha1): tree
function blob.read_from_id(object_id: sha1): blob

local raw_object = object.read_from_id("2387d09d9d5e17162cee849db9595255eb0e0d01")
local commit = commit.read_from_id("2387d09d9d5e17162cee849db9595255eb0e0d01")
local tree = tree.read_from_id(commit.tree_id)
local blob = blob.read_from_id(tree.entries[1].id)
```

### ref (branches and tags)

```luau
function remote.read_from_id(id: ref_id): remote
function head.read_from_id(id: ref_id): head
function tag.read_from_id(id: ref_id): tag
function ref.read_from_id(id: ref_id): ref

local tag = git.tag.read_from_id("refs/tags/v1.0.0")
local same_tag = git.tag.read_from_name("v1.0.0")
```

```luau
function remotes.read_all(): remote
function head.read_all(): head
function tag.read_all(): tag
function ref.read_all(): ref

for id, branch in git.head.read_all() do
    print('branch', id, branch)
end
```

```luau
function head.read_current(): ref

local current_branch = git.head.read_current()
print(current_branch.name)
```