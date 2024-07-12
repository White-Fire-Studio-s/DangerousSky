local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Servers = MainScreen:WaitForChild("Servers")

local Zap = require(ReplicatedStorage.Zap.Client)

return function ()
    
    local Round = ReplicatedStorage:WaitForChild("Round")

    Servers.Main.ServerID.Text = `📦 SERVER ID: <font color="#0766ff">{Round:GetAttribute("serverId")}</font>`

    Servers.Main.Button.MouseButton1Click:Connect(function()
        Zap.JoinServer.fire(Servers.Main.TextBox.Text)
    end)
end