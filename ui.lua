local screen = UI.ScreenSize()
local center = {x = screen.width / 2, y = screen.height / 2}

-----------------------------
--[[ UI Setting ]]
-----------------------------

local CHAT_SCROLLBAR_FRAMESIZE = 25
local CHAT_SCROLLBAR_COUNT = 5

local CHAT_WIDTH = 400
local CHAT_HEIGHT = CHAT_SCROLLBAR_FRAMESIZE * CHAT_SCROLLBAR_COUNT
local CHAT_X = center.x
local CHAT_Y = center.y
local CHAT_BACKGROUND_STYLE =  {
	COLOR = {r = 50, g = 50, b = 50, a = 150}
}

local CHAT_SCROLLBAR_WIDTH = 10
local CHAT_SCROLLBAR_HEIGHT = CHAT_HEIGHT
local CHAT_SCROLLBAR_X = CHAT_X + CHAT_WIDTH - CHAT_SCROLLBAR_WIDTH
local CHAT_SCROLLBAR_Y = CHAT_Y
local CHAT_SCROLLBAR_STYLE = {
	BAR = {COLOR = {r = 150, g = 150, b = 150, a = 200}}
	, BACKGROUND = {COLOR = {r = 70, g = 70, b = 70, a = 200}}
}

local CHAT_MESSAGE_WIDTH = CHAT_WIDTH - CHAT_SCROLLBAR_WIDTH
local CHAT_MESSAGE_HEIGHT = CHAT_SCROLLBAR_FRAMESIZE
local CHAT_MESSAGE_X = CHAT_X
local CHAT_MESSAGE_Y = CHAT_Y
local CHAT_MESSAGE_STYLE = {
	FONT = "small"
	, ALIGN = "left"
	, COLOR = {r = 240, g = 240, b = 240, a = 255}
}

-----------------------------
--[[ UI Create ]]
-----------------------------

UI_ChatBackground = UI.Box.Create()
UI_ChatBackground:Set({x = CHAT_X, y = CHAT_Y, width = CHAT_WIDTH, height = CHAT_HEIGHT})
UI_ChatBackground:Set(CHAT_BACKGROUND_STYLE.COLOR)

UI_ScrollBar = ScrollBar:Create()
UI_ScrollBar:Set({x = CHAT_SCROLLBAR_X, y = CHAT_SCROLLBAR_Y, width = CHAT_SCROLLBAR_WIDTH, height = CHAT_SCROLLBAR_HEIGHT, frameSize = CHAT_SCROLLBAR_FRAMESIZE, count = CHAT_SCROLLBAR_COUNT})
UI_ScrollBar:Set({style = {bar = {color = CHAT_SCROLLBAR_STYLE.BAR.COLOR}, background = {color = CHAT_SCROLLBAR_STYLE.BACKGROUND.COLOR}}})

UI_ChatMessage = {}
for i = 1, CHAT_SCROLLBAR_COUNT do
	local y = CHAT_MESSAGE_Y + 12 + ((i - 1) * CHAT_SCROLLBAR_FRAMESIZE)
	UI_ChatMessage[i] = UI.Text.Create()
	UI_ChatMessage[i]:Set({font = CHAT_MESSAGE_STYLE.FONT, align = CHAT_MESSAGE_STYLE.ALIGN, x = CHAT_MESSAGE_X, y = y, width = CHAT_MESSAGE_WIDTH, height = CHAT_MESSAGE_HEIGHT})
	UI_ChatMessage[i]:Set(CHAT_MESSAGE_STYLE.COLOR)
end

-----------------------------
--[[ Const Variable ]]
-----------------------------

RADIOTEXTLIST = {
	"掩護我!"
    , "你守住這個據點."
    , "守住這邊."
    , "重整隊形."
    , "跟隨我."
    , "我中彈了...需要援助!"
    
    , "衝衝衝!"
    , "後退!"
    , "團體行動!"
    , "就定位等我."
    , "全力攻擊!"
    , "小隊回報狀況."
    
    , "了解."
    , "收到."
    , "發現敵人."
    , "需要後援."
    , "這個區域安全了."
    , "我就定位了"
    , "回報沒有問題."
    , "離開那邊, 快爆炸了!"
    , "無法執行"
    , "敵人死了."
}

-----------------------------
--[[ Variable ]]
-----------------------------

ChatMessageBufferList = {}

-----------------------------
--[[ Functions ]]
-----------------------------

-- code from AnggaraNothing
function string.explode (source , delimiter)
    local t, l, ll
    t={}
    ll=0
    if(#source == 1) then
        return {source}
    end
    while true do
        l = string.find(source, delimiter, ll, true) -- find the next d in the string
        if l ~= nil then -- if "not not" found then..
            table.insert(t, string.sub(source,ll,l-1)) -- Save it in our array.
            ll = l + 1 -- save just after where we found it for searching next time.
        else
            table.insert(t, string.sub(source,ll)) -- Save what's left in our array.
            break -- Break at end, as it should be, according to the lua manual.
        end
    end
    return t
end

function IsMessageRadio(msg)
	for k,v in pairs(RADIOTEXTLIST) do
		if v == msg then
			return true
		end
	end
	return false
end

function sendSignalToGameFromMsg(msg)
	if IsMessageRadio(msg) then return end
	
	for str in string.gmatch(msg, "(.)") do
		UI.Signal(string.byte(str))
	end
	UI.Signal(-1) -- 傳送完畢
end

function UI_ScrollBar:OnRange(index)
	local start_index = index + 1
	local ent_index = start_index + CHAT_SCROLLBAR_COUNT - 1
	
	local row = 1
	for i = start_index, ent_index do
		UI_ChatMessage[row]:Set({text = ChatMessageBufferList[i]})
		row = row + 1
	end
end

-----------------------------
--[[ SyncValue ]]
-----------------------------

SyncValue_ChatMessage = UI.SyncValue.Create("SyncValue_ChatMessage")
function SyncValue_ChatMessage:OnSync()
	ChatMessageBufferList = string.explode (self.value , ";")
	
	local length = #ChatMessageBufferList
	UI_ScrollBar:Add(length)
	
	if length <= CHAT_SCROLLBAR_COUNT then
		local index = UI_ScrollBar.currentIndex
		UI_ScrollBar:OnRange(index)
	end
	
	UI_ScrollBar:KeyDown()
end

-----------------------------
--[[ CSO UI Functions ]]
-----------------------------

function UI.Event:OnChat(msg)
	sendSignalToGameFromMsg(msg)
end

function UI.Event:OnKeyDown(inputs)
	if inputs[UI.KEY.UP] then
		UI_ScrollBar:KeyUp()
	elseif inputs[UI.KEY.DOWN] then
		UI_ScrollBar:KeyDown()
	end
end