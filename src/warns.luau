-- functions
local function so_many_tag_files(tags_amount: number)
    if tags_amount < 100 then return end
    warn(`so many tag files at '.git/refs/tags', consider pack them with \`git pack-refs\``)
end
local function so_many_head_files(tags_amount: number)
    if tags_amount < 100 then return end
    warn(`so many head files at '.git/refs/heads', consider pack them with \`git pack-refs\``)
end

-- module
return table.freeze {
    so_many_head_files = so_many_head_files,
    so_many_tag_files = so_many_tag_files,
}