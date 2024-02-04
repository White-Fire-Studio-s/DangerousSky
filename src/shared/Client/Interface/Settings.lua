--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// Imports
local Slider = require(script.Parent.Components.Slider)
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
        end)

        slider.Changed:connect(function(value)
            
            slider.roblox.Box.Text = tostring(math.floor(value * 100)) .. "%"
        end)
        slider.HoldReleased:connect(function(value)
            
            playerSettings:invokeApplySettingAsync(settingKey, value)
            :andThenCall(applyVolume, value)
        end)
    end
    
    local musicSlider = Slider.get(Settings.Music.Slider)
    setupVolumeControl(musicSlider, Workspace.Soundtrack.Musics, "Music")
    
    local sfxSlider = Slider.get(Settings.SFX.Slider)
    setupVolumeControl(sfxSlider, Workspace.Soundtrack.SFX, "SFX")
end