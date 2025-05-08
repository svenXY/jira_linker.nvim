local function _fix_base_url(url)
	if url:match("^https://.+/browse/$") then
		return url
	end
	if not url:match("^https?://") then
		url = "https://" .. url
	end
	if not url:match("/$") then
		url = url .. "/"
	end
	if not url:match("browse/$") then
		url = url .. "browse/"
	end
	return url
end

local M = {}

M.config = {
	jira_base_url = "jira.example.com",
}

function M.setup(user_opts)
	M.config = vim.tbl_deep_extend("force", M.config, user_opts)
	M.config.jira_base_url = _fix_base_url(M.config.jira_base_url)
end

-- Function to check if the current buffer is a markdown file
local function is_markdown_file()
	return vim.bo.filetype == "markdown"
end

local escape_magic = function(ticket_id)
	return ticket_id:gsub("%-", "%%-")
end

-- Function to replace all JIRA ticket IDs with links
function M.replace_jira_links()
	if not is_markdown_file() then
		vim.print("This function only applies to markdown files.")
		return
	end

	local current_buffer = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)

	for i, line in ipairs(lines) do
		local new_line = line:gsub("(%s*)(%u+%-%d+)(%s*)", function(space, ticket_id, space_after)
			-- Check if the ticket_id is already part of a link
			if not line:match("%[" .. escape_magic(ticket_id) .. "%]%(") then
				return string.format("%s[%s](%s%s)%s", space, ticket_id, M.config.jira_base_url, ticket_id, space_after)
			end
			return string.format("%s%s%s", space, ticket_id, space_after) -- Return the original if already linked
		end)
		lines[i] = new_line
	end

	-- Set the modified lines back to the buffer
	vim.api.nvim_buf_set_lines(current_buffer, 0, -1, false, lines)
end

-- Function to prompt for a JIRA ID and insert the link
function M.insert_jira_link()
	if not is_markdown_file() then
		vim.print("This function only applies to markdown files.")
		return
	end

	local ticket_id = vim.fn.input("Enter JIRA ID: ")
	if ticket_id == "" then
		vim.print("No JIRA ID entered.")
		return
	end

	local current_line = vim.api.nvim_get_current_line()
	local new_link = string.format("[%s](%s%s)", ticket_id, M.config.jira_base_url, ticket_id)
	local new_line = current_line .. new_link

	vim.api.nvim_set_current_line(new_line)
	vim.cmd("normal $")
end

function M.remove_jira_link()
	local line = vim.api.nvim_get_current_line()
	local updated_line = line:gsub("%[(%u+%-%d+)%]%([^]]+%)", "%1")
	vim.api.nvim_set_current_line(updated_line)
end
return M
