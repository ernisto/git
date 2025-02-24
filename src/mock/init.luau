local commit = require('@lib/object/commit')
local object = require('@lib/object')
local ref = require('@lib/ref')

return table.freeze {
    commit = table.freeze {
        load = commit._load
    },
    object = table.freeze {
        load = object._load
    },

    ref = table.freeze {
        load = ref._load
    }
}