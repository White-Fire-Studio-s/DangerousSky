--// Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-->>
--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Client = ReplicatedStorage:WaitForChild("Client")
local Wrappers = Client:WaitForChild("Wrappers")
local Interface = Client:WaitForChild("Interface")

--// Imports
local Inventory = require(Wrappers._Player.Inventory)
local wrapper = require(Packages.Wrapper)
local Profile = require(Wrappers._Player.Profile)
local Coil = require(Wrappers.Coil)

task.defer(function()
    require(Wrappers._Player.Profile)
    require(Interface.Components.Button)
    require(Interface.Components.Slider)
end)

--// Player
local Player = {}

function Player.wrap(rbxPlayer: Player)
    if rbxPlayer ~= game.Players.LocalPlayer then
        rbxPlayer:WaitForChild("Profile"):Destroy()

        return
    end

    local self = wrapper(rbxPlayer)
    self.Inventory = Inventory.wrap(rbxPlayer:WaitForChild("Inventory") :: Folder)
    self.Profile = Profile.get(rbxPlayer)

    function self:loadCoils()
        
        for _, coil in CollectionService:GetTagged("Coil") do
            Coil.wrap(coil)
        end

        CollectionService:GetInstanceAddedSignal("Coil"):Connect(Coil.wrap)
    end
    function self:loadInterface()

        for _, interface in Interface:GetChildren() do
            if not interface:IsA("ModuleScript") then
                continue
            end

            require(interface)()
        end
    end

    self:loadCoils()
    self:loadInterface()

    return self
end

return Player