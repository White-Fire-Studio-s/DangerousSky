local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = workspace:WaitForChild("Server")
Server:SetAttribute("startTime", os.time())

for _, feature in ReplicatedStorage.Server:GetChildren() do
    if feature:IsA("ModuleScript") then
        task.spawn(require, feature)
    end
end

return true