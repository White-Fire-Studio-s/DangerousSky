--// Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Signal = require(Packages.Signal)
local Wrapper = require(Packages.Wrapper)
local Frame = require(script.Parent.Frame)

--// Constants
local DECREASE_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, true)
local INCREASE_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Quint)

--// Cache
local buttons = setmetatable({}, { __mode = "k" })

--// Variables
local Mouse = Players.LocalPlayer:GetMouse()

--// Module
local Button = {}

function Button.wrap(button: TextButton | ImageButton)

    local self = Wrapper(button)
    
    local leastClick = 0
    local originalSize = button.Size
    
    local increment = 1.05 
    local increasedSize = UDim2.fromScale(originalSize.X.Scale * increment, originalSize.Y.Scale * increment)
    
    local decrement = 0.95 
    local decreasedSize = UDim2.fromScale(originalSize.X.Scale * decrement, originalSize.Y.Scale * decrement)
    
    local originalTween = TweenService:Create(button, INCREASE_TWEENINFO, { Size = originalSize })
    local hoverTween = TweenService:Create(button, INCREASE_TWEENINFO, { Size = decreasedSize })
    local clickTween = TweenService:Create(button, DECREASE_TWEENINFO, { Size = increasedSize })
    
    local opens = button:FindFirstChild("Opens")
    local closes = button:FindFirstChild("Closes")
    
    self.group = button:GetAttribute("group") or "main"

    self.Clicked = Signal.new('')
    self.canCloseItself = if self.canCloseItself ~= nil then self.canCloseItself else true
    self.clickTween = if self.clickTween ~= nil then self.clickTween else true
    self.cooldown = self.cooldown or 0.2
    
    function self:onClick()
        
        if os.clock() - leastClick <= self.cooldown then
            return
        end
        
        Workspace.Soundtrack.SFX.Click:Play()
        task.spawn(self.circleClick, self)
        
        --// Button Tween
        if self.clickTween then
            clickTween:Play()
        end
        
        --// Frame Tween
        if opens then
            
            local frame = Frame.get(opens.Value, self)
            
            if frame.isOpen then

                if not self.canCloseItself then
                    return
                end

                frame:close()
            else
                frame:open()
            end
        end
        
        if closes then
            
            local frame = Frame.get(closes.Value, self)
            frame:close()
        end
        
        leastClick = os.clock()
        self.Clicked:_emit()
    end

    function self:circleClick()
        
        local X = Mouse.X
        local Y = Mouse.Y

        button.ClipsDescendants = true

		local Circle = game.ReplicatedStorage.Assets:WaitForChild("Circle"):Clone()
		Circle.Parent = button
		local NewX = X - Circle.AbsolutePosition.X
		local NewY = Y - Circle.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, NewX, 0, NewY)

		local Size = 0
		if button.AbsoluteSize.X > button.AbsoluteSize.Y then
			Size = button.AbsoluteSize.X*1.5
		elseif button.AbsoluteSize.X < button.AbsoluteSize.Y then
			Size = button.AbsoluteSize.Y*1.5
		elseif button.AbsoluteSize.X == button.AbsoluteSize.Y then																										Size = Button.AbsoluteSize.X*1.5
		end

		local Time = 0.5
		Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", Time, false, nil)
		for _= 1,10 do
			Circle.ImageTransparency = Circle.ImageTransparency + 0.01
			task.wait(Time/10)
		end
		Circle:Destroy()
    end
    
    --// Listeners
    button.MouseButton1Click:Connect(function() self:onClick() end)
    
    if button:GetAttribute("hoverEnabled") then
        button.MouseEnter:Connect(function() hoverTween:Play() end)
        button.MouseLeave:Connect(function() originalTween:Play() end)
    end
    
    buttons[button] = self
    
    return self
end

function Button.get(button: TextButton | ImageButton)
    return buttons[button] or Button.wrap(button)
end

--// Loader
CollectionService:GetInstanceAddedSignal("button"):Connect(Button.get)
for _, button in CollectionService:GetTagged("button") do
    Button.get(button)
end

return Button