local semver = require('semver')

print(semver.parse('1.2.3-alpha.beta.3.cavalo+build.sha.349F8D04AB'))

local vers = {
    semver.parse "1.0.0-alpha",
    semver.parse "1.0.0-alpha.1",
    semver.parse "1.0.0-alpha.beta",
    semver.parse "1.0.0-beta",
    semver.parse "1.0.0-beta.2",
    semver.parse "1.0.0-beta.11",
    semver.parse "1.0.0-rc.1",
    semver.parse "1.0.0",
    semver.parse "1.0.1",
    semver.parse "2.0.0",
}

table.sort(vers, semver.is_oldest)

local raws = {}
for i, ver in vers do raws[i] = semver.tostring(ver) end

print('output:\t\t', table.concat(raws, ' < '))
print('expected:\t', "1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0 < 1.0.1 < 2.0.0")
assert(table.concat(raws, ' < ') == "1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0 < 1.0.1 < 2.0.0")
return true