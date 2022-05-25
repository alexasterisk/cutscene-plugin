local UserInputService = game:GetService("UserInputService")
local Keyframe = require(script.Keyframe)

-- plugin init
local toolbar = plugin:CreateToolbar("Cutscene Editor")
local button = toolbar:CreateButton("Cutscene Editor", "Cutscene Editor", "")

-- get looking cframe
local function getLookingCFrame()
    return workspace.CurrentCamera.CFrame
end

-- handle user inputs
local toggle = false
button.Click:Connect(function()
    toggle = not toggle
end)

UserInputService.InputBegan:Connect(function(input: InputObject)
    if not toggle then
        return
    end

    if input.KeyCode == Enum.KeyCode.K then
        Keyframe.new(getLookingCFrame())
    end
end)