package.path = package.path .. ";./lua/?.lua" -- Adjust the package path

local jira_linker = require("jira_linker")
jira_linker.setup({
	jira_base_url = "your-jira-instance.atlassian.net",
})

describe("JIRA Linker Plugin", function()
	local mock_buffer

	before_each(function()
		-- Mock the Neovim API
		mock_buffer = {}
		_G.vim = {
			api = {
				nvim_get_current_buf = function()
					return 1
				end,
				nvim_buf_get_lines = function(_, _, _, _)
					return mock_buffer
				end,
				nvim_buf_set_lines = function(_, _, _, _, lines)
					mock_buffer = lines
				end,
				nvim_get_current_line = function()
					return mock_buffer[1] or ""
				end,
				nvim_set_current_line = function(line)
					mock_buffer[1] = line
				end,
			},
			fn = {
				input = function(_)
					return "TEST-123"
				end,
			},
			bo = {
				filetype = "markdown",
			},
			cmd = function(_) end,
			print = function(_) end,
		}
	end)

	-- describe("is broken", function()
	-- 	it("fails always", function()
	-- 		mock_buffer = { "This is a ticket: TEST-123" }
	-- 		jira_linker.replace_jira_links()
	-- 		assert.are.same(
	-- 			{ "This is a ticket: [TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123)" },
	-- 			{ "This should fail" }
	-- 		)
	-- 	end)

	describe("replace_jira_links", function()
		it("replaces JIRA ticket IDs with links", function()
			mock_buffer = { "This is a ticket: TEST-123" }
			jira_linker.replace_jira_links()
			assert.are.same(
				{ "This is a ticket: [TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123)" },
				mock_buffer
			)
		end)

		it("replaces all JIRA ticket IDs with links", function()
			mock_buffer = { "This is a ticket: TEST-123", "This is another ticket: TEST-456" }
			jira_linker.replace_jira_links()
			assert.are.same({
				"This is a ticket: [TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123)",
				"This is another ticket: [TEST-456](https://your-jira-instance.atlassian.net/browse/TEST-456)",
			}, mock_buffer)
		end)

		it("does not replace already linked JIRA ticket IDs", function()
			mock_buffer = { "This is a ticket: [TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123)" }
			jira_linker.replace_jira_links()
			assert.are.same(
				{ "This is a ticket: [TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123)" },
				mock_buffer
			)
		end)
	end)

	describe("remove_jira_link", function()
		it("removes link from JIRA ticket ID on current line", function()
			mock_buffer = { "This is a ticket: [TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123)" }
			jira_linker.remove_jira_link()
			assert.are.same({ "This is a ticket: TEST-123" }, mock_buffer)
		end)

		it("removes multiple link from JIRA ticket ID on current line", function()
			mock_buffer = {
				"This is a ticket: [TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123) and another: [TEST-345](https://your-jira-instance.atlassian.net/browse/TEST-345)",
			}
			jira_linker.remove_jira_link()
			assert.are.same({ "This is a ticket: TEST-123 and another: TEST-345" }, mock_buffer)
		end)

		it("does not remove already linked JIRA ticket IDs", function()
			mock_buffer = { "This is a ticket: TEST-123 with more text" }
			jira_linker.remove_jira_link()
			assert.are.same({ "This is a ticket: TEST-123 with more text" }, mock_buffer)
		end)
	end)

	describe("insert_jira_link", function()
		it("inserts a JIRA link at the end of the current line", function()
			mock_buffer = { "Current line content" }
			jira_linker.insert_jira_link()
			assert.are.same(
				{ "Current line content[TEST-123](https://your-jira-instance.atlassian.net/browse/TEST-123)" },
				mock_buffer
			)
		end)

		it("does nothing if no JIRA ID is entered", function()
			vim.fn.input = function(_)
				return ""
			end
			mock_buffer = { "Current line content" }
			jira_linker.insert_jira_link()
			assert.are.same({ "Current line content" }, mock_buffer)
		end)
	end)
end)
