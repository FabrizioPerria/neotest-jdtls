local log = require('neotest-jdtls.utils.log')
local M = {}

function M.get_short_error_message(result)
	if result.actual and result.expected then
		return string.format(
			'Expected: [%s] but was [%s]',
			result.expected[1],
			result.actual[1]
		)
	end
	local trace_result = ''
	for idx, trace in ipairs(result.trace) do
		trace_result = trace_result .. trace
		if idx > 3 then
			break
		end
	end
	return trace_result
end

function M.get_line_number(key, trace)
	local test_file_name = key:match('([^/\\]+%.java)::')
	local line_number = nil

	if test_file_name then
		for _, line in ipairs(trace) do
			local file, line_str = line:match('%(([%w%._/-]+%.java):(%d+)%)')
			if file and line_str and file:match(test_file_name, 1, true) then
				line_number = tonumber(line_str)
				break
			end
		end
	end
	return line_number
end

return M
