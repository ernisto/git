-- types
type u8 = number
type u16 = number
type byte = number

export type header = {
    signature: string, -- char[4]
    version: u8,
    chunks_count: u8,
    offset: u16,
}

-- functions
local function deserialize(data: buffer): header

    local signature = buffer.readstring(data, 0, 4)
    assert(signature == 'CGPH', `invalid format`)

    local version = buffer.readu8(data, 4)
    local chunks_count = buffer.readu8(data, 5)
    local offset = buffer.readu16(data, 8)

    return {
        signature = signature,
        version = version,
        chunks_count = chunks_count,
        offset = offset,
    }
end

-- module
return table.freeze {
    deserialize = deserialize,
    size = 8 :: byte,
}