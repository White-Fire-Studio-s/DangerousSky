--// Services
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Wrappers = ReplicatedStorage:WaitForChild("Server")
    :WaitForChild("Wrappers")

--// Globals

--// Imports
local Inventory = require(Wrappers._Player.Inventory)
local Store = require(Wrappers._Player.Store)
local Replicator = require(ServerStorage.Packages.Replicator)
local Profile = require(Wrappers._Player.Profile)
local Coil = require(Wrappers.Coil)
local Market = require(script.Parent._Player.Market)
local Leaderboard = require(Wrappers.Leaderboard)
local wrapper = require(Packages.Wrapper)

local CoilsConfiguration = require(ReplicatedStorage.Configuration.Coils)

--// Constants
local DEVS_IDS = { 437810327, 2031076901, 569919343 }
local GEM_PRODUCT_ID = {
    [1812516364] = 75;
    [1812515960] = 150;
    [1812517775] = 250;
    [1812518059] = 500;
    [1812519562] = 2250;
}

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

    local self = wrapper(rbxPlayer)
    --// Fields
    self.Inventory = Inventory.wrap(rbxPlayer)
    self.Profile = Profile.get(rbxPlayer)
    self.Market = Market(rbxPlayer)

    self.isPrivateServerMod = false
    self.isDeveloper = table.find(DEVS_IDS, rbxPlayer.UserId) ~= nil
    self.isPrivateServerOwner = game.PrivateServerOwnerId == rbxPlayer.UserId
    self.playerJoinedAt = os.clock()

    --// Private Methods
    local function sycronizeOrderedDataAsync()

        local key = rbxPlayer.UserId

        local function setOrderedData()

            for _,data: {store: OrderedDataStore, value: number } in _G.ORDERED_STATISTIC[rbxPlayer] do

                data.store:SetAsync(key, data.value // 1)
            end
        end

        setOrderedData()

        for _,leaderboard in CollectionService:GetTagged("leaderboard") do
            Leaderboard.wrap(leaderboard)
        end
        
        CollectionService:GetInstanceAddedSignal("leaderboard"):Connect(Leaderboard.wrap)

        local thread = task.delay(60, function()
            repeat

                setOrderedData()
            until not task.wait(60)
        end)

        self:_host(thread)
    end

    local function loadGemsProductAsync()
        task.spawn(function()
            for productId: number, gems: number in GEM_PRODUCT_ID do
                local product = self.Market:getProduct(productId)

                product:bind(function()
                    self.Profile.Statistics.Gems += gems
                    _G.ORDERED_STATISTIC[rbxPlayer].Gems.value += gems

                end)
            end
        end)
    end

    local function loadGamepassesAsync()
        task.spawn(function()

            self.Market:getPass(729919308)

            --// VIP
            local vip = self.Market:getPass(731206303)
            if vip.isOwned then
                self.isVIP = true
            end

            vip:bind(function() self.isVIP = true end)

            --// Donator
            local donator = self.Market:getPass(767864718)
            if donator.isOwned then
                self.isDonator = true
            end

            donator:bind(function() self.isDonator = true end)
        end)
    end

    --// Methods
    local settings = Replicator.get(self.Profile.Settings.roblox)

    function settings:ApplySetting(setting: string, value: any)

        local oldValue = self.Profile.Settings:GetAttribute(setting)

        assert(oldValue)
        assert(type(oldValue) == type(value))

        self.Profile.Settings:SetAttribute(setting, value)
    end
    function self:loadCoils()

        for name, data in CoilsConfiguration do
            local coilProfile = self.Profile.Coils[name]
            if not coilProfile.Obtained then
                continue
            end

            data.Level = coilProfile.Level

            local coilContainer = Assets.Coils[name]:Clone() 
            coilContainer.Parent = rbxPlayer.Backpack

            self.Inventory:addItem(coilContainer)

            Coil.wrap(coilContainer, data)
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
        workspace.PlayersPositions:SetAttribute(rbxPlayer.Name, nil)
        local time = os.clock() - self.playerJoinedAt

        self.Profile.Statistics.TimePlayed += time
        _G.ORDERED_STATISTIC[rbxPlayer].TimePlayed.value = time
    end)

    --// Callers
    sycronizeOrderedDataAsync()
    loadGemsProductAsync()
    loadGamepassesAsync()

    --// Functions
    local function applyCollision(part: BasePart)
        if not part:IsA("BasePart") then return end

        part.CollisionGroup = "character"
    end

    local function handleCharacter(character: Model)
        if not character then return end

        local humanoid = character:WaitForChild("Humanoid")
    
        self:_host(humanoid.Died:Once(function()
            self.Profile.Statistics.Deaths += 1
            _G.ORDERED_STATISTIC[rbxPlayer].Deaths.value += 1

        end))
    
        for _, part: BasePart in character:GetDescendants() do
            applyCollision(part)
        end
    
        character.DescendantAdded:Connect(applyCollision)
    end
    
    handleCharacter(rbxPlayer.Character)
    rbxPlayer.CharacterAdded:Connect(handleCharacter)
    
    self:_host(RunService.Heartbeat:Connect(function()

        local character = rbxPlayer.Character
        if not character then return end

        workspace.PlayersPositions:SetAttribute(rbxPlayer.Name, character:GetPivot().Position)
    end))

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