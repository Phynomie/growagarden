-- Shovel Script (Client) - Works on any farm
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Get references to game elements
local LocalPlayer = game.Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Remove_Item = GameEvents:WaitForChild("Remove_Item")
local DeleteObject = GameEvents:WaitForChild("DeleteObject")

-- Create Highlight effect
local Highlight = Instance.new("Highlight")
Highlight.Name = "ShovelHighlight"
Highlight.Parent = LocalPlayer.PlayerGui
Highlight.FillColor = Color3.fromRGB(255, 50, 50)
Highlight.FillTransparency = 1
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

-- UI Elements
local ShovelPrompt = LocalPlayer.PlayerGui:WaitForChild("ShovelPrompt")
local ConfirmFrame = ShovelPrompt:WaitForChild("ConfirmFrame")
local FruitName = ConfirmFrame:WaitForChild("FruitName")

local CurrentCamera = workspace.CurrentCamera

-- Configuration
local PROTECTED_PLANTS = {"Carrot", "Sprinkler"}
local BLACKLISTED_TAGS = {"NoShovel", "Protected"}

local TargetData = {
    Instance = nil,
    IsPlaceableObject = false
}

-- Raycast function
local function RaycastToPosition(mousePosition)
    local ray = CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    return workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
end

-- Check if target is shovelable
local function CanShovel(target)
    -- Check protected names
    for _, name in pairs(PROTECTED_PLANTS) do
        if string.find(string.lower(target.Name), string.lower(name)) then
            return false
        end
    end
    
    -- Check tags
    for _, tag in pairs(BLACKLISTED_TAGS) do
        if CollectionService:HasTag(target, tag) then
            return false
        end
    end
    
    return true
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

    if CanShovel(targetModel) then
        if Highlight.Adornee ~= targetModel then
            Highlight.FillTransparency = 1
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
    if not targetModel or not CanShovel(targetModel) then return end

    FruitName.Text = targetModel.Name
    TargetData.Instance = targetModel
    TargetData.IsPlaceableObject = CollectionService:HasTag(targetModel, "PlaceableObject")
    ShovelPrompt.Enabled = true
end

-- UI Button Handlers
ConfirmFrame.Confirm.MouseButton1Click:Connect(function()
    if TargetData.Instance then
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
    if UserInputService.TouchEnabled then
        UserInputService.TouchTapInWorld:Connect(function(_, position)
            HandleShovelInput(position)
        end)
    else
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                HandleShovelInput(UserInputService:GetMouseLocation())
            end
        end)
    end
end

-- Initialize
RunService.RenderStepped:Connect(UpdateHighlight)
SetupInput()
