local regex = require('@lune/regex')

-- module
local function destruct_captures<T>(captures: regex.RegexCaptures, mut_output: T, template: T)
	for index: string, name: string in template :: any do
		if typeof(name) == 'table' then
			(mut_output :: any)[index] = destruct_captures(captures, {}, name)
			continue
		end
		local match = captures:group(name)
		if match then (mut_output :: any)[index] = match.text end
	end
	return mut_output
end

return destruct_captures
