vim.api.nvim_create_user_command("JiraLinkerReplace", function()
	require("jira_linker").replace_jira_links()
end, { desc = "Replace JIRA ticket IDs with links in the current buffer" })

vim.api.nvim_create_user_command("JiraLinkerInsert", function()
	require("jira_linker").insert_jira_link()
end, { desc = "Insert a JIRA ticket link at the current cursor position" })

vim.api.nvim_create_user_command("JiraLinkerRemove", function()
	require("jira_linker").remove_jira_link()
end, { desc = "Remove a JIRA ticket link under the cursor" })
