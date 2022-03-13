-----------------------------
--[[ Game Rule ]]
-----------------------------

Game.Rule.respawnTime  =     0 -- 玩家復活時間
Game.Rule.respawnable  =  true -- 玩家是否復活
Game.Rule.enemyfire    = false -- 是否傷害敵人
Game.Rule.friendlyfire = false -- 是否傷害對友
Game.Rule.breakable    = false -- 是否破壞地圖

-----------------------------
--[[ Variable ]]
-----------------------------

ChatMessageBuffer = ""
ChatMessageBufferList = {}

-----------------------------
--[[ SyncValue ]]
-----------------------------

SyncValue_ChatMessage = Game.SyncValue.Create("SyncValue_ChatMessage")

-----------------------------
--[[ Functions ]]
-----------------------------

function addChatMessage(msg)
	table.insert(ChatMessageBufferList, msg)
end

function sendSyncValueToUIFromMessageList()
	local messages = table.concat(ChatMessageBufferList, ";")
	SyncValue_ChatMessage.value = messages
end

-----------------------------
--[[ CSO Game Functions ]]
-----------------------------

function Game.Rule:OnPlayerSignal(player, signal)
	if signal == -1 then
		ChatMessageBuffer = player.name .. ": " .. ChatMessageBuffer
		addChatMessage(ChatMessageBuffer)
		sendSyncValueToUIFromMessageList()
		
		ChatMessageBuffer = ""
	else
		local char = string.char(signal)
		ChatMessageBuffer = ChatMessageBuffer .. char
	end
end



