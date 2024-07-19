local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

Players.PlayerAdded:Connect(function(rbxPlayer: Player)

    local attemps = 0
    
    rbxPlayer.CharacterAdded:Connect(function(rbxCharacter: Model)

        rbxCharacter:WaitForChild("Humanoid") 

        task.wait(1)

        local oldPivot = rbxCharacter:GetPivot()
        local oldPosition = Vector2.new(oldPivot.X, oldPivot.Z)

        repeat

            local deltaTime = task.wait(1)

            local pivot = rbxCharacter:GetPivot()
            local position = Vector2.new(pivot.X, pivot.Z)

            local maxVelocity = workspace:GetAttribute("roundSpeed") * 1.4

            local distance = (oldPosition - position).Magnitude
            local velocity = distance/deltaTime

            if velocity > maxVelocity then
                rbxCharacter:PivotTo(oldPivot)

                attemps += 1

                if attemps == 5 then
                    
                    rbxPlayer:Kick("Speed Exploit")
                end

                continue
            end

            oldPivot = pivot
            oldPosition = position

        until not rbxPlayer.Character 
    end)
end)