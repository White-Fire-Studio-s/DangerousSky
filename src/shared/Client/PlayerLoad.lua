local Players = game:GetService("Players")
local Player = require(script.Parent.Wrappers.Player)

for _, rbxPlayer in Players:GetPlayers() do Player.wrap(rbxPlayer) end
Players.PlayerAdded:Connect(Player.wrap)

return true