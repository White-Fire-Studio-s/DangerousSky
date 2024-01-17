local ReplicatedStorage = game:GetService("ReplicatedStorage")

for _, feature in ReplicatedStorage.Server:GetChildren() do
    if feature:IsA("ModuleScript") then
        require(feature)
    end
end

return true