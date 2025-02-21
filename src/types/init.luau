-- primitives
local semver = require('semver')
export type semver = semver.version

local sha1 = require('sha1')
export type sha1 = sha1.sha1

local u32 = require('u32')
export type u32 = u32.u32

-- misc
export type email = string
export type path = string

export type message = {
    raw: string,
    title: string,
    body: string?,
    footer: string?,
}
export type user = {
    name: string,
    email: email,
}

-- git refs
export type ref = head | tag
export type ref_id = string -- "\w+(/\w+)*"
export type head = {
    kind: 'heads',
    path: path,
    name: string,
    last_name: string,
    commit_id: sha1,
}
export type tag = {
    kind: 'tags',
    path: path,
    name: string,
    last_name: string,
    commit_id: sha1,
}

-- git objects
export type object = commit | glob | tree

export type commit = {
    id: sha1,
    change_id: sha1,
    prev_commit_id: sha1?,

    author: user,
    committer: user,
    timestamp: number,
    message: message,
}
export type tree = {}
export type glob = {}

-- consts
local V2_SIGNATURE = "\xFFtOc"

local object_kind: any = table.freeze { 'commit', 'tree', 'blob', 'tag', 'offset_delta', 'ref_delta' }
export type object_kind = 'commit' | 'tree' | 'blob' | 'tag' | 'offset_delta' | 'ref_delta'

-- module
return table.freeze {
    semver = semver,
    sha1 = sha1,
    u32 = u32,

    v2_signature = V2_SIGNATURE,
    object_kind = object_kind :: {object_kind},
}