local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local chatProperty = Instance.new("TextChatMessageProperties")

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
    
    if not message.TextSource then 
        return 
    end

    local rbxPlayer = Players:GetPlayerByUserId(message.TextSource.UserId)

	if rbxPlayer:GetAttribute("isOwner") then
		
		chatProperty.PrefixText = `<b><font color='rgb(63, 235, 255)'>[OWNER]</font></b> {message.PrefixText}`
   	 elseif rbxPlayer:GetAttribute("isDeveloper") then
        
		chatProperty.PrefixText = `<b><font color='rgb(255, 0, 104)'>[DEV]</font></b> {message.PrefixText}`
    elseif rbxPlayer:GetAttribute("isVIP") then

		chatProperty.PrefixText = `<b><font color='rgb(255, 236, 76)'>[VIP]</font></b> {message.PrefixText}`
    elseif rbxPlayer:GetAttribute("isDonator") then

		chatProperty.PrefixText = `<b><font color='rgb(165, 0, 180)'>[DONATOR]</font></b> {message.PrefixText}`
    else
        
        chatProperty.PrefixText = message.PrefixText
    end

    return chatProperty
end

return function() end