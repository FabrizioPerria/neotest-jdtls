local class = require('neotest-jdtls.utils.class')

---@class TestContext
---@field lookup table<string, table<string, table<string, JavaTestItem>>>
---@field project_name string
---@field test_kind TestKind
local TestContext = class()

function TestContext:_init()
	self.lookup = {}
end

---@param test_item JavaTestItem
function TestContext:append_test_item(key, test_item)
	normalize_id = test_item.id:gsub('%s+', '')
	self.lookup[normalize_id] = { key = key, value = test_item }
end

return TestContext
