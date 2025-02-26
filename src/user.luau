local types = require('@lib/types')

-- defs
export type user = {
	name: string,
	email: types.email,
}

-- constructor
local user_by_email = {}
local function load(name: string, email: types.email): types.user
	local user = user_by_email[email]
	if user and user.name ~= name then
		warn(`a user '{name}' have the same email that user '{user_by_email[email].name}' (email: {email})`)
	else
		user = table.freeze({ name = name, email = email })
		user_by_email[email] = user
	end
	return user
end

-- functions
local function find_loaded_by_email(email: types.email): user?
	return user_by_email[email]
end

-- module
return table.freeze({
	load = load,
	find_loaded_by_email = find_loaded_by_email,
})
