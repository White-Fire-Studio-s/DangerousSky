--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Imports
local Inventory = require(ReplicatedStorage.Server.Wrappers._Player.Inventory)

local function onHit(rbxPlayer: Player, self, character)

     if character ~= rbxPlayer.Character then return end

     local humanoid = rbxPlayer.Character:FindFirstChild("Humanoid")
     local inventory = Inventory.get(rbxPlayer)

     if not self.damage then

          inventory:unequipEquippedItem()
          humanoid.Health = 0
     else

          humanoid:TakeDamage(self.damage)
     end

     return true
end

return onHit