local CollectionService = game:GetService("CollectionService")
local Stage = require(script.Parent.Wrappers.Stage)

for _, stage in CollectionService:GetTagged("stage") do
    Stage.wrap(stage)
end

CollectionService:GetInstanceAddedSignal("stage"):Connect(Stage.wrap)

return nil