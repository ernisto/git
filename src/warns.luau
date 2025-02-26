-- functions
local function so_many_ref_files(tags_amount: number, ref_kind: string?)
	if tags_amount < 100 then return end
	warn(`so many {ref_kind or 'ref'} files at '.git/refs/{ref_kind or ''}', consider pack them with \`git pack-refs\``)
end

-- module
return table.freeze({
	so_many_ref_files = so_many_ref_files,
})
