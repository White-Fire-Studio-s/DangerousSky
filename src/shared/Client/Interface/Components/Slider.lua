--// Services
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Signal = require(Packages.Signal)

--// Functions
local function interpolate(start, finish, fade)
    
    return start + fade * (finish - start)
end

--// Vars
local Mouse = Players.LocalPlayer:GetMouse()

--// Constants
local ALLOWED_INPUTS = {
    [Enum.UserInputType.MouseButton1] = true;
    [Enum.UserInputType.Touch] = true;
}

local CONSOLE_INPUTS_FADE = {
    [Enum.KeyCode.DPadRight] = 1/20;
    [Enum.KeyCode.DPadUp] = 1/20;
    [Enum.KeyCode.DPadLeft] = -1/20;
    [Enum.KeyCode.DPadDown] = -1/20;
}

--// Cache
local sliders = setmetatable({}, { __mode = "k" })

--// Module
local Slider = {}

function Slider.wrap(slider: Frame)
    
    local self = Wrapper(slider)
    --// Private
    local start = slider.start.Value
    local finish = slider.finish.Value
    local scroll = slider.scroll.Value
    local bar = slider.bar.Value
    
    local controllerInput;
    
    --// Fields
    self.Min = 0
    self.Max = 1
    
    self.HoldStart = Signal.new("HoldStart")
    self.HoldReleased = Signal.new("HoldReleased")
    self.Changed = Signal.new("Changed")
    self.isHolding = false
    
    --// Functions
    local function getFadeFromMouse()
        
        local startPosition = start.AbsolutePosition
        local finishPosition = finish.AbsolutePosition
        
        local x = math.clamp(Mouse.X, startPosition.X ,finishPosition.X)
        
        local fade = (x - startPosition.X)/(finishPosition.X - startPosition.X)
        
        return fade
    end
    local function holdStart()
        
        self.HoldStart:_emit()
        
        while self.isHolding do
            local fade = getFadeFromMouse()
            local value = interpolate(self.Min, self.Max, fade)
            
            self:set(value, fade)
            
            task.wait()
        end
        
        self.HoldReleased:_emit(self.value)
    end
    local function handleSelection(enable: boolean)
        
        if not enable then
            controllerInput:Disconnect()
            return
        end
        
        controllerInput = UserInputService.InputBegan:Connect(function(input: InputObject)
            
            if not CONSOLE_INPUTS_FADE[input.KeyCode] then
                return
            end
            
            local increment = CONSOLE_INPUTS_FADE[input.KeyCode]
            local actualFade = (self.value - self.Min)/(self.Max - self.Min)
            local fade = math.clamp(actualFade + increment, 0, 1)
            
            local value = interpolate(self.Min, self.Max, fade)
            
            self:set(value, fade)
        end)
    end
    
    --// Methods
    function self:set(value: number, _fade: number?)
        
        value = math.clamp(value, self.Min, self.Max)
        
        local fade = _fade or (value - self.Min)/(self.Max - self.Min)
        
        scroll.Position = UDim2.fromScale(fade, scroll.Position.Y.Scale)
        bar.Size = UDim2.fromScale(fade, bar.Size.Y.Scale)
        
        self.value = value
        
        self.Changed:_emit(value)
    end
    
    --// Listeners
    slider.InputBegan:Connect(function(input: InputObject)
        
        if not ALLOWED_INPUTS[input.UserInputType] then
            return
        end
        
        self.isHolding = true
        
        task.spawn(holdStart)
    end)
    
    slider.InputEnded:Connect(function(input: InputObject)
        
        if not ALLOWED_INPUTS[input.UserInputType] then
            return
        end
        
        self.isHolding = false
    end)
    
    slider.SelectionChanged:Connect(handleSelection)
    
    sliders[slider] = self
    
    return self
end

function Slider.get(slider: Frame)
    
    return sliders[slider] or Slider.wrap(slider)
end

--// Loader
CollectionService:GetInstanceAddedSignal("slider"):Connect(Slider.get)
for _, slider in CollectionService:GetTagged("slider") do Slider.get(slider) end

--// End
return Slider