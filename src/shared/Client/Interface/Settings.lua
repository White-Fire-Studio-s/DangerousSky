--// Services
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// Imports
local Slider = require(script.Parent.Components.Slider)
local Enum = require(script.Parent.Components.Enum)
local Profile = require(ReplicatedStorage.Client.Wrappers._Player.Profile)

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Settings = MainScreen:WaitForChild("Settings"):WaitForChild("Main")

--// Init
return function () 
    
    local playerProfile = Profile.get(Players.LocalPlayer)
    local playerSettings = playerProfile.Settings
    
    local function setupVolumeControl(slider, soundFolder, settingKey)
        
        --// Setup
        slider.Min = 0
        slider.Max = 2
        slider:set(playerProfile.Settings[settingKey])
        
        local function applyVolume(volume: number)
            
            for _, sound in soundFolder:GetChildren() do
                sound.Volume = volume
            end
        end
        
        applyVolume(slider.value)
        
        --// Listeners
        slider.roblox.Box.FocusLost:Connect(function()
            
            local text = slider.roblox.Box.Text
            local percentValue = text:match("%d+")
            if not percentValue then return end
            
            local value = tonumber(percentValue) / 100
            slider:set(value)

            slider.HoldReleased:_emit(value)
        end)

        slider.Changed:connect(function(value)
            
            slider.roblox.Box.Text = tostring(math.floor(value * 100)) .. "%"
        end)
        slider.HoldReleased:connect(function(value)
            
            playerSettings:invokeApplySettingAsync(settingKey, value)
            :andThenCall(applyVolume, value)
        end)
    end

    local function setupAmbientColorControl(slider, settingKey: string)
        local property = slider.roblox.Parent.Name

        --// Setup
        slider.Min = -1
        slider.Max = 1

        slider:set(playerProfile.Settings[settingKey])

        local function applyColor(value) -->> Brightness, Contrast, Hue
            Lighting.ColorCorrection[property] = value
        end

        applyColor(slider.value)

         --// Listeners
        slider.roblox.Box.FocusLost:Connect(function()
            
            local text = slider.roblox.Box.Text
            local value = tonumber(text)
            if not value then return end 

            value = math.clamp(value, -1, 1)
            slider:set(value)

            slider.HoldReleased:_emit(value)
        end)

        slider.Changed:connect(function(value)
            
            slider.roblox.Box.Text = math.floor(value * 100) / 100
            applyColor(value)
        end)
        slider.HoldReleased:connect(function(value)
            
            playerSettings:invokeApplySettingAsync(settingKey, value)
        end)
    end

    local function setupFOVControl(slider)

        slider.Min = 60
        slider.Max = 120

        slider:set(playerProfile.Settings.FOV)

        local function applyFOV(value) 
            workspace.CurrentCamera.FieldOfView = value
        end

        applyFOV(slider.value)

         --// Listeners
        slider.roblox.Box.FocusLost:Connect(function()
            
            local text = slider.roblox.Box.Text
            local value = tonumber(text)
            if not value then return end 

            value = math.clamp(value, 60, 120)
            slider:set(value)

            slider.HoldReleased:_emit(value)
        end)

        slider.Changed:connect(function(value)
            
            slider.roblox.Box.Text = math.floor(value * 100) / 100
            applyFOV(value)
        end)
        slider.HoldReleased:connect(function(value)
            
            playerSettings:invokeApplySettingAsync("FOV", value)
        end)
    end
    
    local musicSlider = Slider.get(Settings.Music.Slider)
    setupVolumeControl(musicSlider, Workspace.Soundtrack.Musics, "Music")
    
    local sfxSlider = Slider.get(Settings.SFX.Slider)
    setupVolumeControl(sfxSlider, Workspace.Soundtrack.SFX, "SFX")

    local AmbientBrightnessSlider = Slider.get(Settings.Brightness.Slider)
    local AmbientContrastSlider = Slider.get(Settings.Contrast.Slider)
    local AmbientSaturationSlider = Slider.get(Settings.Saturation.Slider)

    setupAmbientColorControl(AmbientSaturationSlider, "AmbientSaturation")
    setupAmbientColorControl(AmbientContrastSlider, "AmbientContrast")
    setupAmbientColorControl(AmbientBrightnessSlider, "AmbientBrightness")

    local FOVSlider = Slider.get(Settings.FOV.Slider)
    setupFOVControl(FOVSlider)

    local dayClockEnum = Enum.get(Settings.ClockTime)
    local dayClock = playerProfile.Settings.DayClock

    dayClockEnum:set(dayClock)
    Lighting.ClockTime = if dayClock == "Day" then 12 else 20

    dayClockEnum.Changed:connect(function(element: string)

        Lighting.ClockTime = if element == "Day" then 12 else 20

        playerSettings:invokeApplySettingAsync("DayClock", element)
    end)
end