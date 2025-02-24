local types = require('@lib/types')

export type user = types.user
export type sha1 = types.sha1

export type ref = types.ref
export type tag = types.tag
export type head = types.head

export type object = types.object
export type commit = types.commit
export type tree = types.tree
export type glob = types.glob

-- module
return table.freeze {
    object = require('object'),
    commit = require('object/commit'),

    ref = require('ref'),
    head = require('ref/head'),
    tag = require('ref/tag'),

    query = require('query'),
    user = require('user'),
}