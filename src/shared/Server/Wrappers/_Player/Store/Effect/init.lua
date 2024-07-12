--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Round = require(ReplicatedStorage.Server.Wrappers.Round).get()
local Zap = require(ReplicatedStorage.Zap.Server)

local TRAITS = {} do

    for _, effectTraiter in script:GetChildren() do

        TRAITS[effectTraiter.Name] = require(effectTraiter)
    end
end

--// Traiter
return function (rbxPlayer: Player, effect: string)
    
    local effectName = effect
    effect = effect:gsub(" ","")

    if Round[effect] then
        return 
    end

    local trait = TRAITS[effect]
    if trait then trait(rbxPlayer) end

    Round[effect] = true


    Zap.DisplayMessage.fireAll({
        Text = `[SYSTEM] {rbxPlayer.Name} bought {effectName}`;
        Font = "FredokaOne";
        Color = Color3.fromRGB(252, 88, 0):ToHex();
        FontSize = "17";
    })

    return true
end