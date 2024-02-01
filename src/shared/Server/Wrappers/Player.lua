--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Wrappers = ReplicatedStorage:WaitForChild("Server")
    :WaitForChild("Wrappers")

--// Imports
local Inventory = require(Wrappers._Player.Inventory)
local Replicator = require(ServerStorage.Packages.Replicator)
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
    --// Fields
    self.Inventory = Inventory.wrap(inventoryContainer)
    self.Profile = Profile.get(rbxPlayer)

    self.isPrivateServerMod = false
    self.isDeveloper = table.find(DEVS_IDS, rbxPlayer.UserId) ~= nil
    self.isPrivateServerOwner = game.PrivateServerOwnerId == rbxPlayer.UserId
    self.playerJoinedAt = os.clock()

    local settings = Replicator.get(self.Profile.Settings.roblox)

    --// Methods
    function settings:ApplySetting(setting: string, value: any)
        
        warn("HI")
        warn(self.Profile.Settings)

        local oldValue = self.Profile.Settings:GetAttribute(setting)

        assert(oldValue)
        assert(type(oldValue) == type(value))

        self.Profile.Settings:SetAttribute(setting, value)
    end
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
    
    --// Callers
    self:loadCoils()
    self:cleaner(function()
        self.Profile.Statistics.TimePlayed += os.clock() - self.playerJoinedAt
    end)

    --// Death handler
    local function handleDeath(character: Model)
        if not character then
            return
        end

        character.Archivable = true

        local humanoid = character:WaitForChild("Humanoid")

        local function onDeath()
            self.Profile.Statistics.Deaths += 1
    
            rbxPlayer.CharacterAdded:Wait()

            local humanoid = rbxPlayer.Character:WaitForChild("Humanoid")
    
            self:_host(humanoid.Died:Connect(onDeath))
        end

        self:_host(humanoid.Died:Connect(onDeath))
    end

    handleDeath(rbxPlayer.Character)
    rbxPlayer.CharacterAdded:Connect(handleDeath)

    --// Cache
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