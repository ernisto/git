local destruct_captures = require('@utils/destruct_captures')
local object = require('.')

local types = require('@lib/types')
local user = require('@lib/user')

local regex = require('@lune/regex')

-- defs
export type raw_commit = string
local matcher = regex.new(table.concat({
	'(?:commit )?(?<size>\\S+)?',
	'(?:tree (?<tree_id>\\S+))\n',
	'(?<parents>(?:parent \\S+\n)*)',
	'(?:author (?<author_name>\\S+) (?<author_email><\\S+?>) (?<timestamp>\\S+) (\\-?(?<timezone_hour>\\d\\d)(?<timezone_minute>\\d\\d))\n)?',
	'(?:committer (?<committer_name>\\S+) (?<committer_email><\\S+?>) \\S+ \\S+\n)',
	'\n?(?<message>(?<title>[^\n]+)\n(?<body>[\\s\\S]+)?)',
}))
local schema = {
	id = '',
	tree_id = 'tree_id',
	parents = 'parents',
	timestamp = 'timestamp',
	timezone_hour = 'timezone_hour',
	timezone_minute = 'timezone_minute',
	author = { name = 'author_name', email = 'author_email' },
	committer = { name = 'committer_name', email = 'committer_email' },
	message = {
		title = 'title',
		body = 'body',
		footer = 'footer',
		raw = 'message',
	},
}

-- constructor
local cache = {}
local function load_commit(commit: types.commit): types.commit
	cache[commit.id] = commit
	return commit
end
local function try_parse(input: raw_commit, id: types.sha1): types.commit?
	local result = matcher:captures(input)
	if not result then return end

	local parent_ids = {}
	local capture_texts = destruct_captures(result, { id = id }, schema)
	for parent_id in string.gmatch(capture_texts.parents or '', 'parent (%S+)') do
		table.insert(parent_ids, parent_id)
	end

	local commit = table.freeze({
		id = id,
		tree_id = capture_texts.tree_id,
		parent_ids = parent_ids,
		local_timestamp = tonumber(capture_texts.timestamp) or error(`couldnt parse timestamp`),
		global_timestamp = capture_texts.timestamp
			+ (tonumber(capture_texts.timezone_hour) or 0) * 60 * 60
			+ (tonumber(capture_texts.timezone_minute) or 0) * 60,

		author = user.load(capture_texts.author.name, capture_texts.author.email),
		committer = user.load(capture_texts.committer.name, capture_texts.committer.email),
		message = capture_texts.message,
	})
	if string.find(commit.message.body or '', '\n') then
		commit.message.body, commit.message.footer = commit.message.body:match('(.*)\n+([^\n]+)\n?$')
	end
	table.freeze(commit.message)
	return commit
end

-- functions
local function read_from_id(id: types.sha1): types.commit
	if cache[id] then return cache[id] end

	local raw = object.read_from_id(id) or error(`couldnt possible read object '{id}'`)
	local commit = try_parse(raw, id) or error(`object '{id}' probably isnt a commit\n{raw}`)

	return load_commit(commit)
end

-- module
return table.freeze({
	read_from_id = read_from_id,
	_load = load_commit,
})
