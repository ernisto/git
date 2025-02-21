local destruct_captures = require('@utils/destruct_captures')
local regex = require('@lune/regex')

-- defs
export type raw_semver = string
local pattern = regex.new(([[
^v?(?P<major>0|[1-9]\d*)
\.(?P<minor>0|[1-9]\d*)
\.(?P<patch>0|[1-9]\d*)
(?:-(?P<prerelease>
    (?:0|[1-9]\d*|\d*[a-zA-Z][0-9a-zA-Z-]*)
    (?:\.(?:0|[1-9]\d*|\d*[a-zA-Z][0-9a-zA-Z-]*))
*))?
(?:\+(?P<buildmetadata>[0-9a-zA-Z]+
    (?:\.[0-9a-zA-Z]+)*
))?$
]]):gsub('%s', '') :: string)
local schema = table.freeze {
    major = 'major',
    minor = 'minor',
    patch = 'patch',
    prerelease = 'prerelease',
    buildmetadata = 'buildmetadata'
}

-- functions
local function is_valid(input: string): raw_semver?
    return pattern:isMatch(input) and input or nil
end
local function is_latest_pre_release(pre_release1: {string}?, pre_release2: {string}?): boolean
    if not pre_release1 then return true end
    if not pre_release2 then return false end

    for i = 1, math.min(#pre_release1, #pre_release2) do
        local id1 = pre_release1[i]
        local id2 = pre_release2[i]
        local num1 = tonumber(id1)
        local num2 = tonumber(id2)
        if num1 and not num2 then return false end
        if num2 and not num1 then return true end
        if num1 and num2 and num1 ~= num2 then return num1 > num2 end
        if id1 ~= id2 then return id1 > id2 end
    end
    return #pre_release1 > #pre_release2
end

-- constructors
local function new_from(version: version, patch: partial_version): version
    return table.freeze {
        major = patch.major or version.major,
        minor = patch.minor or version.minor,
        patch = patch.patch or version.patch,
        pre_release = if #(patch.pre_release or {}) > 0 then patch.pre_release else version.pre_release,
        build_metadata = if #(patch.build_metadata or {}) > 0 then patch.build_metadata else version.build_metadata,
    }
end
local function try_parse(input: string): version?

    local captures = pattern:captures(input)
    if not captures then return end

    local data = destruct_captures(captures, {}, schema)
    return table.freeze {
        major = tonumber(data.major) :: never,
        minor = tonumber(data.minor) :: never,
        patch = tonumber(data.patch) :: never,
        pre_release = data.prerelease and string.split(data.prerelease, '.'),
        build_metadata = data.buildmetadata and string.split(data.buildmetadata, '.'),
    }
end
local function parse(input: string): version
    return try_parse(input) or error(`couldnt parse version '{input}'`)
end

-- methods
local function is_latest(version1: version, version2: version): boolean
    return if version1.major ~= version2.major then version1.major > version2.major
        elseif version1.minor ~= version2.minor then version1.minor > version2.minor
        elseif version1.patch ~= version2.patch then version1.patch > version2.patch
        else is_latest_pre_release(version1.pre_release, version2.pre_release)
end
local function is_oldest(version1: version, version2: version): boolean
    return not is_latest(version1, version2)
end

local function tostring(version: version)
    return `{version.major}.{version.minor}.{version.patch}`
        .. (if version.pre_release then '-'..table.concat(version.pre_release, '.') else '')
        .. (if version.build_metadata then '+'..table.concat(version.build_metadata, '.') else '')
end

-- types
export type version = {
    major: number,
    minor: number,
    patch: number,
    pre_release: {string}?,
    build_metadata: {string}?,
}
type partial_version = {
    major: number?,
    minor: number?,
    patch: number?,
    pre_release: {string}?,
    build_metadata: {string}?,
}

-- module
return table.freeze {
    is_valid = is_valid,
    new_from = new_from,
    try_parse = try_parse,
    parse = parse,

    is_oldest = is_oldest,
    is_latest = is_latest,
    tostring = tostring,
}