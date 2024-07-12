--// Services
local TweenService = game:GetService("TweenService")

--// Traiter
local function trait(self)
    
    --// Fields
    self.duration = self.duration or 3
    self.transitionDuration  = self.transitionDuration or 0.5

    --// Private Fields
    local tweenInfo = TweenInfo.new(self.transitionDuration, Enum.EasingStyle.Quint)

    local appearTween: Tween = self:_host(TweenService:Create(self.roblox, tweenInfo, { Transparency = self.roblox.Transparency }))
    local disappearTween = self:_host(TweenService:Create(self.roblox, tweenInfo, { Transparency = 1 }))

    local state = true

    --// Loop
    self:_host(task.spawn(function()
        repeat
            local tween = if state then disappearTween else appearTween
            tween:Play()
            tween.Completed:Wait()

            state = not state
            self.roblox.CanCollide = state

        until not task.wait(self.duration)
    end))
end

--// End
return trait