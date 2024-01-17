local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.Server:Destroy()

for _, feature in ReplicatedStorage.Client:GetChildren() do
    if feature:IsA("ModuleScript") then
        require(feature)
    end
end