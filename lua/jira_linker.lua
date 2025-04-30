local M = {}

local jira_base_url = "https://your-jira-instance.atlassian.net/browse/" -- Change this to your JIRA instance URL

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
				return string.format("%s[%s](%s%s)%s", space, ticket_id, jira_base_url, ticket_id, space_after)
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
	local new_link = string.format("[%s](%s%s)", ticket_id, jira_base_url, ticket_id)
	local new_line = current_line .. new_link

	vim.api.nvim_set_current_line(new_line)
	vim.cmd("normal $")
end

return M
