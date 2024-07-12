--// Services
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Round = require(ReplicatedStorage.Server.Wrappers.Round).get()
local Atmosphere = Lighting:WaitForChild("Atmosphere")
local AtmosphereProperties = { --> {DEFAULT, FOG}
    Density = {0.337, 0.9};
    Offset = {0.25, 0.5};

    Color = {Color3.fromRGB(101, 103, 250), Color3.fromRGB(185, 163, 153)};
    Decay = { Color3.fromRGB(106, 112, 125), Color3.fromRGB(143, 134, 122)};

    Haze = {0, 10}
}

local function trait()
    
    for property, data in AtmosphereProperties do
        local fogValue = data[2]

        Atmosphere[property] = fogValue
    end

    Round.timerEnded:once(function()
        for property, data in AtmosphereProperties do
            local defaultData = data[1]
    
            Atmosphere[property] = defaultData
        end
    end)
end

return trait 