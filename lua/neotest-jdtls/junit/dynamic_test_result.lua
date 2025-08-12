local class = require('neotest-jdtls.utils.class')
local get_short_error_message =
	require('neotest-jdtls.junit.common').get_short_error_message
local get_line_number = require('neotest-jdtls.junit.common').get_line_number
local lib = require('neotest.lib')
local log = require('neotest-jdtls.utils.log')
local async = require('neotest.async')
local TestStatus = require('neotest-jdtls.types.enums').TestStatus

---@class DynamicTestResult
---@field is_dynamic_test boolean
---@field errors string[]
---@field output string[]
local DynamicTestResult = class()
function DynamicTestResult:_init()
	self.is_dynamic_test = true
	self.status = nil
	self.errors = {}
	self.output = {}
	self.invocation_lookup = {}
end

function DynamicTestResult:append_invocation(invocation, node)
	assert(invocation)
	assert(node)

	self.invocation_lookup[invocation] = node
end

function DynamicTestResult:get_neotest_result(key)
	local sum = 0
	for invocation, node in pairs(self.invocation_lookup) do
		sum = sum + 1
		self:append(invocation, node, key)
	end
	local results_path = async.fn.tempname()

	table.insert(
		self.output,
		1,
		string.format(
			'Total invocations: %s\nSuccess: %s\nFailed: %s\n',
			sum,
			sum - #self.errors,
			#self.errors
		)
	)
	lib.files.write(results_path, table.concat(self.output, '\n'))
	return {
		status = self.status,
		output = results_path,
		errors = self.errors,
		short = self.errors,
	}
end

function DynamicTestResult:append(invocation, node, key)
	table.insert(
		self.output,
		string.format(
			'\n----------------%s----------------',
			node.result.status or TestStatus.Passed
		)
	)
	table.insert(
		self.output,
		string.format('Invocation %s: %s', invocation, node.display_name)
	)
	table.insert(self.output, '----------------Output----------------')

	if node.result.status == TestStatus.Failed then
		local short_message = get_short_error_message(node.result)
		-- if short_message is a table, convert it to a string
		if type(short_message) == 'table' then
			short_message = table.concat(short_message, '\n')
		end
		self.status = TestStatus.Failed
		local line_number = get_line_number(key, node.result.trace)
		table.insert(
			self.errors,
			{ message = short_message, line = line_number - 1 }
		)
		table.insert(
			self.output,
			string.format(
				'[line %s]: %s', --\n%s',
				tostring(line_number - 1),
				short_message
				--,table.concat(node.result.trace, '\n') or 'No stack trace available.'
			)
		)
	else
		if self.status == nil then
			self.status = TestStatus.Passed
		end
		table.insert(
			self.output,
			'The console output is available in the DAP console.\n'
		)
	end
end

return DynamicTestResult
