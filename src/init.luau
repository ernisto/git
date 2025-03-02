local types = require('@lib/types')
local index = require('index')

export type user = types.user
export type sha1 = types.sha1
export type entry = index.entry
export type index = index.index

export type ref_id = types.ref_id
export type ref = types.ref
export type tag = types.tag
export type head = types.head
export type remote = types.remote

export type tree_child = types.tree_child
export type object = types.object
export type commit = types.commit
export type tree = types.tree
export type blob = types.blob

-- module
return table.freeze({
	object = require('object'),
	commit = require('object/commit'),
	tree = require('object/tree'),
	blob = require('object/blob'),

	ref = require('ref'),
	remote = require('ref/remote'),
	head = require('ref/head'),
	tag = require('ref/tag'),

	index = require('index'),
	query = require('query'),
	user = require('user'),
	mock = require('mock'),
})
