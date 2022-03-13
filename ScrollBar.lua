--------------------------
--[[ Functions ]]
--------------------------

local function setArgs(data, args)
    for k in pairs(data) do
        if type(data[k]) == type(args[k]) then
            if type(data[k]) == "table" then
                setArgs(data[k], args[k])
            else
                data[k] = args[k]
            end
        end
    end
end

local function clone(table)
    local temp = {}
    for k,v in pairs(table) do
        if type(v) == "table" then
            temp[k] = clone(v)
        else
            temp[k] = table[k]
        end
    end
    return temp
end

local function deepCall(table, funcName, args)
    for _,v in pairs(table) do
        if type(v) == "table" then
            deepCall(v)
        elseif type(v) == "userdata" and v[funcName] then
			v[funcName](v, args)
        end
    end
end

--------------------------
--[[ UIModule Class ]]
--------------------------

UIModule = {}
UIModule.__index = UIModule

function UIModule:Set(args)
	if type(args) == "table" then
		setArgs(self.SetArg, args)
	end
	self:Update()
end


function UIModule:Get()
    return clone(self.SetArg)
end


function UIModule:Show()
	deepCall(self.UI, "Show")
	self.visible = true
end


function UIModule:Hide()
	deepCall(self.UI, "Hide")
	self.visible = false
end


function UIModule:IsVisible()
    return self.visible
end

--------------------------
--[[ ScrollBar Class ]]
--------------------------

ScrollBar = setmetatable({}, UIModule)
ScrollBar.__index = ScrollBar

function ScrollBar:Create(frameSize, count)
	local o = {
		SetArg = {
			x = 0
			, y = 0
			, width = 0
			, height = 0
			, frameSize = frameSize or 0
			, count = count or 0
			, style = {
				background = {color = {r = 15, g = 15, b = 15, a = 255}}
				, bar = {color = {r = 50, g = 50, b = 50, a = 255}}
			}
		}
		, currentCount = 0
		, currentIndex = 0
		, UI = {
			background = UI.Box.Create()
			, bar = UI.Box.Create()
		}
		, visible = true
	}
	return setmetatable(o, self)
end

function ScrollBar:Update()
	local arg = self.SetArg
	local frameSize = arg.frameSize
	local count = arg.count
	local currentCount = self.currentCount
	local currentIndex = self.currentIndex
	
	local y = 0
	local height = frameSize * count
	local barHeight = arg.height
	if currentCount > count then
		local max = frameSize * currentCount
		local percent = height / max
		barHeight = (height * percent) * (arg.height / height)
		y = currentIndex * frameSize * percent * (arg.height / height)
	end
	
	local offset = {
		background = {y = 0, height = arg.height}
		, bar      = {y = y, height = barHeight}
	}
	
	for k,v in pairs(self.UI) do
		local temp = {
			r = arg.style[ k ].color.r
			, g = arg.style[ k ].color.g
			, b = arg.style[ k ].color.b
			, a = arg.style[ k ].color.a
			
			, x = arg.x
			, width = arg.width
			
			, y = arg.y + offset[ k ].y
			, height = offset[ k ].height
		}
		v:Set(temp)
	end
end

function ScrollBar:Add()
	self.currentCount = self.currentCount + 1
	self:Update()
end

function ScrollBar:Remove()
	if self.currentCount < 1 then return end
	self.currentCount = self.currentCount + 1
	self:Update()
end

function ScrollBar:KeyUp()
	if self.currentIndex < 1 then return end
	self.currentIndex = self.currentIndex - 1
	
	self:Update()
	self:OnRange(self.currentIndex)
end

function ScrollBar:KeyDown()
	local currentCount = self.currentCount - self.SetArg.count
	if self.currentIndex >= currentCount then return end
	self.currentIndex = self.currentIndex + 1
	
	self:Update()
	self:OnRange(self.currentIndex)
end

function ScrollBar:OnRange(index)
end