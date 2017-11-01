local Class = {}
Class.__index = Class

-- default implementation
function Class:new() end

-- create a new Class type from the base class
function Class:derive(classType)
	assert(classType ~= nil, "parameter type must not be nil!")
	assert(type(classType) == "string", "parameter classType must be a string!")
	local cls = {}
	cls["__call"] = Class.__call
	cls.type = classType
	cls.__index = cls
	cls.super = self
	setmetatable(cls, self)
	return cls
end

-- check if the instance is a subclass of the given type
function Class:is(class)
	assert(class ~= nil, "parameter class must not be nil!")
	assert(type(class) == "table", "parameter class must be of type Class!")
	local mt = getmetatable(self)
	while mt do
		if mt == class then return true end
		mt = getmetatable(mt)
	end
	return false
end

function Class:isType(classType)
	assert(classType ~= nil, "parameter classType must not be nil!")
	assert(type(classType) == "string", "parameter classType must be a string!")	
	local base = self
	while base do
		if base.type == classType then return true end
		base = base.super
	end
	return false
end

function Class:__call(...)
	local inst = setmetatable({}, self)
	inst:new(...)
	return inst
end

function Class:getType()
	return self.type
end

return Class