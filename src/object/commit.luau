local destruct_captures = require('@utils/destruct_captures')
local object = require('.')

local types = require('@lib/types')
local user = require('@lib/user')

local regex = require('@lune/regex')

-- defs
export type raw_commit = string
local matcher = regex.new(table.concat {
    "(?:commit (?<random_code>\\S+)(?:tree (?<tree_id>\\S+)|(?<change_id> \\S+)))\n",
    "(?:parent (?<prev_commit_id>\\S+)\n)*",
    "(?:author (?<author_name>\\S+) (?<author_email><\\S+?>) (?<timestamp>\\S+) (\\-?(?<timezone_hour>\\d\\d)(?<timezone_minute>\\d\\d))\n)?",
    "(?:committer (?<committer_name>\\S+) (?<committer_email><\\S+?>) \\S+ \\S+\n)",
    "\n?(?<message>(?<title>[^\n]+)\n(?<body>[\\s\\S]+)?)",
})
local schema = {
    id = '',
    change_id = 'change_id',
    tree_id = 'tree_id',
    prev_commit_id = 'prev_commit_id',
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
    }
}

-- constructor
local cache = {}
local function load_commit(commit: types.commit)

    cache[commit.id] = commit
    return commit
end
local function try_parse(input: raw_commit, id: types.sha1): types.commit?

    local result = matcher:captures(input)
    if not result then return end

    local commit = destruct_captures(result, { id = id }, schema)

    commit.local_timestamp = tonumber(commit.timestamp)
    commit.global_timestamp = commit.local_timestamp
        + (tonumber(commit.timezone_hour) or 0) * 60*60
        + (tonumber(commit.timezone_minute) or 0) * 60

    commit.author = user.load(commit.author.name, commit.author.email)
    commit.committer = user.load(commit.committer.name, commit.committer.email)

    if string.find(commit.message.body or '', '\n') then
        commit.message.body, commit.message.footer = commit.message.body:match('(.*)\n+([^\n]+)\n?$')
    end

    return commit
end

-- functions
local function read_from_id(id: types.sha1): types.commit

    if cache[id] then return cache[id] end

    local raw = object.read_from_id(id)
        or error(`couldnt possible read object '{id}'`)

    local commit = try_parse(raw, id)
        or error(`object '{id}' probably isnt a commit\n{raw}`)

    return load_commit(commit)
end

-- module
return table.freeze {
    read_from_id = read_from_id,
    _load = load_commit,
}