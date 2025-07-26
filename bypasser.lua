-- Shovel Script - Only works on your alt's farm
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Configuration
local ALT_USERNAME = "YourAltUsernameHere" -- CHANGE THIS
local PROTECTED_PLANTS = {"Carrot", "Sprinkler"}

-- Get references
local LocalPlayer = game.Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Remove_Item = GameEvents:WaitForChild("Remove_Item")
local DeleteObject = GameEvents:WaitForChild("DeleteObject")

-- Create highlight effect
local Highlight = Instance.new("Highlight")
Highlight.Name = "ShovelHighlight"
Highlight.Parent = LocalPlayer.PlayerGui
Highlight.FillColor = Color3.fromRGB(255, 50, 50)
Highlight.FillTransparency = 1
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

-- UI Elements
local ShovelPrompt = LocalPlayer.PlayerGui:WaitForChild("ShovelPrompt")
local ConfirmFrame = ShovelPrompt:WaitForChild("ConfirmFrame")
local FruitName = ConfirmFrame:WaitForChild("FruitName")

local CurrentCamera = workspace.CurrentCamera

local TargetData = {
    Instance = nil,
    IsPlaceableObject = false,
    IsAltFarm = false
}

-- Check if target is in alt's farm
local function IsInAltFarm(instance)
    -- Find the farm model
    local farm = instance:FindFirstAncestorOfClass("Model")
    if not farm then return false end
    
    -- Check if farm belongs to alt (simple name check)
    if string.find(farm.Name, "rr2obly256sf") then
        return true
    end
    
    -- More robust check would go here if needed
    return false
end

-- Modified CanShovel function
local function CanShovel(target)
    -- Check protected plants
    for _, name in pairs(PROTECTED_PLANTS) do
        if string.find(string.lower(target.Name), string.lower(name)) then
            return false, false
        end
    end
    
    -- Check if in alt's farm
    local isAltFarm = IsInAltFarm(target)
    
    return true, isAltFarm
end

-- Raycast function
local function RaycastToPosition(mousePosition)
    local ray = CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    return workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
end

-- Highlight handling
local function UpdateHighlight()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then
        Highlight.Adornee = nil
        return
    end

    local raycastResult = RaycastToPosition(UserInputService:GetMouseLocation())
    if not raycastResult then
        Highlight.Adornee = nil
        return
    end

    local targetModel = raycastResult.Instance:FindFirstAncestorOfClass("Model")
    if not targetModel then
        Highlight.Adornee = nil
        return
    end

    local canShovel, isAltFarm = CanShovel(targetModel)
    
    if canShovel then
        if Highlight.Adornee ~= targetModel then
            Highlight.FillTransparency = 1
            Highlight.FillColor = isAltFarm and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
            TweenService:Create(Highlight, TweenInfo.new(0.2), {
                FillTransparency = 0.7
            }):Play()
        end
        Highlight.Adornee = targetModel
    else
        Highlight.Adornee = nil
    end
end

-- Handle shovel input
local function HandleShovelInput(inputPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then
        return
    end

    local raycastResult = RaycastToPosition(inputPosition)
    if not raycastResult then return end

    local targetModel = raycastResult.Instance:FindFirstAncestorOfClass("Model")
    if not targetModel then return end

    local canShovel, isAltFarm = CanShovel(targetModel)
    if not canShovel then return end

    FruitName.Text = targetModel.Name
    TargetData.Instance = targetModel
    TargetData.IsPlaceableObject = CollectionService:HasTag(targetModel, "PlaceableObject")
    TargetData.IsAltFarm = isAltFarm
    
    -- Only show prompt for alt's farm
    ShovelPrompt.Enabled = isAltFarm
end

-- UI Button Handlers
ConfirmFrame.Confirm.MouseButton1Click:Connect(function()
    if TargetData.Instance and TargetData.IsAltFarm then
        if TargetData.IsPlaceableObject then
            DeleteObject:FireServer(TargetData.Instance)
        else
            Remove_Item:FireServer(TargetData.Instance)
        end
    end
    ShovelPrompt.Enabled = false
    TargetData.Instance = nil
end)

local function CancelShovel()
    ShovelPrompt.Enabled = false
    TargetData.Instance = nil
end

ConfirmFrame.Cancel.MouseButton1Click:Connect(CancelShovel)
ConfirmFrame.ExitButton.MouseButton1Click:Connect(CancelShovel)

-- Input Setup
local function SetupInput()
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            HandleShovelInput(UserInputService:GetMouseLocation())
        end
    end)
end

-- Initialize
RunService.RenderStepped:Connect(UpdateHighlight)
SetupInput()
