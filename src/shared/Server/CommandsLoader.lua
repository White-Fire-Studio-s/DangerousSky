local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local Commands = script.Parent.Commands

local WEBHOOK_URL = "https://webhook.lewisakura.moe/api/webhooks/1259269358136463380/K6ulxchGU3NgXivOij9ur0jaMgbQHf4ud2h_gnI2OEv4IIuwJsY8m0BMFZK1_4HsbWV8"

for _, command: TextChatCommand in TextChatService:GetChildren() do

    if not Commands:FindFirstChild(command.Name) then
        continue
    end

    local execute = require(Commands[command.Name])

    command.Triggered:Connect(function(textSource: TextSource, text: string)
        local rbxPlayer = Players[textSource.Name]
        local arguments = text:gsub(" +", " "):split(" ")
        table.remove(arguments, 1)

        local data = execute(rbxPlayer, arguments)
        if not data then
            return
        end

        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({
            content = "";
            embeds = {{
                title =  "``🔐`` Cmds Logs",
                description = `**Staff Name (@{rbxPlayer.Name})** used the Command **{command.Name}** on **Name (@{data.TargetName or "Unknown"})**\n**Arguments:** {table.concat(arguments, "/")} \n**Reason:** {data.Reason or "Unknown"}`,
                color = 5814783
            }}
        }))
    end)
end

return nil