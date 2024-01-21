local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local Commands = script.Parent.Commands

for _, command: TextChatCommand in TextChatService:GetChildren() do

    if not Commands:FindFirstChild(command.Name) then
        continue
    end

    local execute = require(Commands[command.Name])

    command.Triggered:Connect(function(textSource: TextSource, text: string)
        local rbxPlayer = Players[textSource.Name]
        local arguments = text:gsub(" +", " "):split(" ")
        table.remove(arguments, 1)

        execute(rbxPlayer, arguments)
    end)
end

return nil