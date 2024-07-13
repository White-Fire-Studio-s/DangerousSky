--// Services
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zap = require(ReplicatedStorage.Zap)
local Player = require(ReplicatedStorage.Server.Wrappers.Player)

--// Store
local CodesStore = DataStoreService:GetDataStore("Codes")

--// Typing
type CodeData = { 
    rewards: { gems: number };
    createdAt: number;
    expiresAt: number;
}

--// Cache
local Codes: {[string]: CodeData} = {
    TEST = {
        rewards = {gems = 9999999};
        createdAt = DateTime.now();
        expiresAt = math.huge;
    }
}

local InvalidCodes = {}

--// Code Cache Updater
local function onCodeCacheUpdateReceived(data: string)

    local code = data.Data
    local codeData = Codes[code] or CodesStore:GetAsync(code)
    
    InvalidCodes[code] = nil
    Codes[code] = codeData
end

local function onCreateCodeRequested(rbxPlayer: Player, data)
    local player = Player.get(rbxPlayer)

    if not player.isDeveloper then
        return 
    end

    local codeData: CodeData = {
        rewards = data.rewards,
        createdAt = DateTime.now().UnixTimestamp,
        expiresAt = data.expiresAt
    }

    Codes[data.code] = codeData

    CodesStore:SetAsync(data.code, codeData)

    MessagingService:PublishAsync("codes", data.code)
end

local function reedemCode(rbxPlayer: Player, code: string)

    local player = Player.get(rbxPlayer)
    local profile = player.Profile

    if profile.UsedCodes[code] then
        return "Used"
    end

    local codeData = Codes[code]
    if not codeData and not InvalidCodes[code] then
        Codes[code] = CodesStore:GetAsync(code)
        codeData = Codes[code]

        if not codeData then
            InvalidCodes[code] = true
        end
    end

    if InvalidCodes[code] then
        return "Invalid"
    end

    if DateTime.now().UnixTimestamp >= codeData.expiresAt then
        return "Expired"
    end

    profile.Statistics.Gems += codeData.rewards.gems
    _G.ORDERED_STATISTIC[rbxPlayer].Gems.value += codeData.rewards.gems

    profile.UsedCodes[code] = true

    return "Sucess"
end


MessagingService:SubscribeAsync("codes", onCodeCacheUpdateReceived)

Zap.CreateCode.setCallback(onCreateCodeRequested)
Zap.ReedemCode.setCallback(reedemCode)

return nil