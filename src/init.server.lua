local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Keyframe = require(script.Keyframe)
local Tracing = require(script.Tracing)

-- plugin init
local toolbar = plugin:CreateToolbar("Cutscene Editor")
local button = toolbar:CreateButton("Cutscene Editor", "Cutscene Editor", "")

-- get looking cframe
local function getLookingCFrame()
    return workspace.CurrentCamera.CFrame
end

-- handle user inputs
local tracePlaying = false
local currentTrace
local toggle = false
button.Click:Connect(function()
    toggle = not toggle
end)

UserInputService.InputBegan:Connect(function(input: InputObject)
    --[[if not toggle or not RunService:IsEdit() then
        return
    end]]

    if not RunService:IsEdit() then
        if input.KeyCode == Enum.KeyCode.P then
            if not currentTrace then
                Tracing.new(Keyframe.table, {}, {})
            end
            tracePlaying = not tracePlaying
            if tracePlaying then
                Tracing:begin()
            else
                Tracing:stop()
            end
        end
    else
        if input.KeyCode == Enum.KeyCode.K then
            Keyframe.new(getLookingCFrame())
        end
    end
end)