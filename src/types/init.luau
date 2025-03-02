local file = require('@utils/file')

-- primitives
local c_str = require('c_str')
export type luau_str = c_str.luau_str
export type c_str = c_str.c_str

local sha1 = require('sha1')
export type sha1 = sha1.sha1

local u32 = require('u32')
export type u32 = u32.u32

local u16 = require('u16')
export type u16 = u16.u16

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
export type ref = remote | head | tag
export type ref_id = string -- "\w+(/\w+)*"
export type remote = head
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
export type object = commit | blob | tree

export type commit = {
	id: sha1,
	tree_id: sha1,
	parent_ids: { sha1 },

	author: user,
	committer: user,
	local_timestamp: number,
	global_timestamp: number,
	message: message,
}
export type tree_child = {
	mode: file.type,
	id: sha1,
}
export type tree = {
	id: sha1,
	size: number,
	children: { [string]: tree_child },
}
export type blob = {
	id: sha1,
	size: number,
	content: string,
}

-- consts
local object_kind: any = table.freeze({ 'commit', 'tree', 'blob', 'tag', 'offset_delta', 'ref_delta' })
export type object_kind = 'commit' | 'tree' | 'blob' | 'tag' | 'offset_delta' | 'ref_delta'

-- module
return table.freeze({
	c_str = c_str,
	sha1 = sha1,
	u32 = u32,
	u16 = u16,

	object_kind = object_kind :: { object_kind },
})
