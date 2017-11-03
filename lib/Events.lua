local Class = require("lib.Class")

local Events = Class:derive("Events")

function Events:new(eventMustExist)
	self.handlers = {}
	self.eventMustExist = (eventMustExist == nil) or eventMustExist
end

local function indexOf(eventTable, callback)
	if eventTable == nil or callback == nil then return -1 end

	for i = 1, #eventTable do
		if eventTable[i] == callback then return i end
	end

	return -1
end

-- returns true if the event exists
function Events:exists(eventType)
	return self.handlers[eventType] ~= nil
end

-- add a new event eventType to the table
function Events:add(eventType)
	assert(self.handlers[eventType] == nil, "Event of type " .. eventType .. " already exists!")
	self.handlers[eventType] = {}
end

-- remove an event eventType from the table
function Events:remove(eventType)
	self.handlers[eventType] = nil
end

-- subscribe to an Event
function Events:hook(eventType, callback)
	assert(type(callback) == "function", "callback parameter must be a function!")
	if self.eventMustExist then
		assert(self.handlers[eventType] ~= nil, "Event of type " .. eventType .. " does not exist!")
	elseif self.handlers[eventType] == nil then
		self:add(eventType)
	end

	-- if indexOf(self.handlers[eventType], callback) == -1 then return end
	assert(indexOf(self.handlers[eventType], callback) == -1, "callback has already been hooked!")

	local tbl = self.handlers[eventType]
	tbl[#tbl + 1] = callback
end

-- unsubscribe to an Event
function Events:unhook(eventType, callback)
	assert(type(callback) == "function", "callback parameter must be a function!")
	if self.handlers[eventType] == nil then return end
	local index = indexOf(self.handlers[eventType], callback)
	if index > -1 then
		table.remove(self.handlers[eventType], index)
	end
end

-- clears the event handlers for the given eventType
function Events:clear(eventType)
	if eventType == nil then
		for k, v in pairs(self.handlers) do
			self.handlers[k] = {}
		end
	elseif self.handlers[eventType] ~= nil then
		self.handlers[eventType] = {}
	end
end

function Events:invoke(eventType, ...)
	if self.handlers[eventType] == nil then return end
	-- assert(self.handlers[eventType] ~= nil, "Event of type " .. eventType .. " does not exist!")
	local tbl = self.handlers[eventType]
	for i = 1, #tbl do
		tbl[i](...)
	end
end

return Events