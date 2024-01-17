local Players = game:GetService("Players")
local Player = require(script.Parent.Wrappers.Player)

for _,player in Players:GetPlayers() do 
    Player.wrap(player) 
end
Players.PlayerAdded:Connect(Player.wrap)

return true