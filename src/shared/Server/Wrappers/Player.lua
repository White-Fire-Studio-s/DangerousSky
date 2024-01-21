--// Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Wrappers = ReplicatedStorage:WaitForChild("Server")
    :WaitForChild("Wrappers")

--// Imports
local Inventory = require(Wrappers._Player.Inventory)
local Profile = require(Wrappers._Player.Profile)
local Coil = require(Wrappers.Coil)
local wrapper = require(Packages.Wrapper)

local CoilsConfiguration = require(ReplicatedStorage.Configuration.Coils)

--// Constants
local DEVS_IDS = { 437810327, 2031076901 }
--// Module
local Player = {}

--// Cache
local players = setmetatable({}, { __mode = "k" })
local blacklistedPlayers = {}

function Player.wrap(rbxPlayer: Player)
    if blacklistedPlayers[rbxPlayer.UserId] then
        rbxPlayer:Kick("A private server moderator banned you from the server")

        return
    end
    local inventoryContainer = Instance.new("Folder", rbxPlayer)
    inventoryContainer.Name = "Inventory"

    local self = wrapper(rbxPlayer)
    self.Inventory = Inventory.wrap(inventoryContainer)
    self.Profile = Profile.get(rbxPlayer)

    self.isPrivateServerMod = false
    self.isDeveloper = table.find(DEVS_IDS, rbxPlayer.UserId) ~= nil
    self.isPrivateServerOwner = game.PrivateServerOwnerId == rbxPlayer.UserId

    function self:loadCoils()
        for coilName: string, coilData in CoilsConfiguration do
            local coilProfile = self.Profile.Coils[coilName]
            if not coilProfile.Obtained then
                continue
            end

            coilData.Level = coilProfile.Level

            local coilContainer = Assets.Coils[coilName]
                :Clone() 

            coilContainer.Parent = inventoryContainer           
            Coil.wrap(coilContainer, coilData)
        end
    end

    function self:turnModerator(enable: boolean?)
        self.isPrivateServerMod = enable or true
    end

    function self:blacklist(enable: boolean)
        blacklistedPlayers[rbxPlayer.UserId] = enable
        Player.wrap(rbxPlayer) --> Kick;
    end
    
    self:loadCoils()

    players[rbxPlayer] = self

    return self
end

function Player.get(rbxPlayer: Player)
    assert(rbxPlayer:IsA("Player"))

    return players[rbxPlayer] or Player.wrap(rbxPlayer)
end

function Player.find(rbxPlayer: Player)
    assert(rbxPlayer:IsA("Player"))

    return players[rbxPlayer]
end

function Player.removeBlacklist(userId: number)
    blacklistedPlayers[userId] = nil
end

return Player