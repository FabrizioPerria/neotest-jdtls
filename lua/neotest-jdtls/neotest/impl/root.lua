local jdtls = require('neotest-jdtls.utils.jdtls')
local log = require('neotest-jdtls.utils.log')

local M = {}

function M.root(_)
	local file_path = vim.api.nvim_buf_get_name(0)
	if vim.fn.fnamemodify(file_path, ':e') ~= 'java' then
		return nil
	end
	-- Only if jdtls is attached
	local bufnr = vim.fn.bufnr(file_path, true)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'jdtls' })
	if #clients == 0 then
		return nil
	end
	local root_dir = jdtls.root_dir()
	log.debug('root_dir', root_dir)
	return root_dir
end

return M
