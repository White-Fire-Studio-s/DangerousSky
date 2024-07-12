local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local chatProperty = Instance.new("TextChatMessageProperties")

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
    
    if not message.TextSource then 
        return 
    end

    local rbxPlayer = Players:GetPlayerByUserId(message.TextSource.UserId)

    if rbxPlayer:GetAttribute("isDeveloper") then
        
        chatProperty.PrefixText = `<b><font color='rgb(255, 0, 0)'>[🔨]</font></b> {message.PrefixText}`
    elseif rbxPlayer:GetAttribute("isVIP") then

        chatProperty.PrefixText = `<b><font color='rgb(255, 176, 0)'>[👑]</font></b> {message.PrefixText}`
    elseif rbxPlayer:GetAttribute("isDonator") then

        chatProperty.PrefixText = `<b><font color='rgb(177, 229, 166)'>[💸]</font></b> {message.PrefixText}`
    else
        
        chatProperty.PrefixText = message.PrefixText
    end

    return chatProperty
end

return function() end