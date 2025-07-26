-- Modified Shovel Script - Works only on alt farm
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Configuration
local ALT_USERNAME = "rr2obly256sf" -- Your alt username
local PROTECTED_PLANTS = {"Carrot", "Sprinkler"}
local VALUABLE_PLANTS = {"Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn", "Daffodil", 
    "Chocolate Carrot", "Red Lollipop", "Blue Lollipop", "Nightshade", "Glowshroom", "Mint", "Rose", 
    "Foxglove", "Crocus", "Delphinium", "Manuka Flower", "Lavender", "Nectarshade", "Peace Lily", 
    "Wild Carrot", "Pear", "Horsetail", "Monoblooma", "Dezen"}

-- Get references
local LocalPlayer = game.Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Remove_Item = GameEvents:WaitForChild("Remove_Item")
local DeleteObject = GameEvents:WaitForChild("DeleteObject")
local GetFarm = require(ReplicatedStorage.Modules.GetFarm)
local Notification = require(ReplicatedStorage.Modules.Notification)

-- UI Elements
local ShovelPrompt = LocalPlayer.PlayerGui:WaitForChild("ShovelPrompt")
local ConfirmFrame = ShovelPrompt:WaitForChild("ConfirmFrame")
local FruitName = ConfirmFrame:WaitForChild("FruitName")

-- Create highlight effect
local Highlight = Instance.new("Highlight")
Highlight.Name = "ShovelHighlight"
Highlight.Parent = LocalPlayer.PlayerGui
Highlight.FillColor = Color3.fromRGB(255, 50, 50)
Highlight.FillTransparency = 1
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

local CurrentCamera = workspace.CurrentCamera

local TargetData = {
    Instance = nil,
    IsPlaceableObject = false,
    IsAltFarm = false
}

-- Check if target is in alt's farm (modified from original GetFarm check)
local function IsInAltFarm(instance)
    -- First check if it's in our own farm (original behavior)
    local myFarm = GetFarm(LocalPlayer)
    if instance:IsDescendantOf(myFarm) then
        return false -- This is our main account's farm
    end
    
    -- Then check if it's in alt's farm by name
    local farm = instance:FindFirstAncestorOfClass("Model")
    if farm and string.find(farm.Name, ALT_USERNAME) then
        return true
    end
    
    return false
end

-- Modified from original CheckIfCantShovel
local function CanShovel(target)
    local name = target.Name
    
    -- Check protected plants (original functionality)
    for _, protected in pairs(PROTECTED_PLANTS) do
        if string.find(string.lower(name), string.lower(protected)) then
            return false, false
        end
    end
    
    -- Check if in alt's farm (our modification)
    local isAltFarm = IsInAltFarm(target)
    
    return true, isAltFarm
end

-- Raycast function (similar to original)
local function RaycastToPosition(mousePosition)
    local ray = CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {CollectionService:GetTagged("ShovelIgnore")}
    return workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
end

-- Highlight handling (modified from original)
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

    local targetModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
    if not targetModel then
        Highlight.Adornee = nil
        return
    end

    local canShovel, isAltFarm = CanShovel(targetModel)
    
    -- Only highlight if it's shovelable and in alt farm
    if canShovel and isAltFarm then
        if Highlight.Adornee ~= targetModel then
            Highlight.FillTransparency = 1
            TweenService:Create(Highlight, TweenInfo.new(0.25), {
                FillTransparency = 0.65
            }):Play()
        end
        Highlight.Adornee = targetModel
    else
        Highlight.Adornee = nil
    end
end

-- Handle shovel input (modified from original handleShovelInput)
local function HandleShovelInput(inputPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then
        return
    end

    local raycastResult = RaycastToPosition(inputPosition)
    if not raycastResult then return end

    local targetModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
    if not targetModel then return end

    local canShovel, isAltFarm = CanShovel(targetModel)
    if not canShovel then
        Notification:CreateNotification(`You cannot shovel {targetModel.Name}!`)
        return
    end
    
    -- Only proceed if it's in alt farm
    if not isAltFarm then
        Notification:CreateNotification("You can only shovel plants in your alt farm!")
        return
    end

    FruitName.Text = targetModel.Name
    TargetData.Instance = targetModel
    TargetData.IsPlaceableObject = CollectionService:HasTag(targetModel, "PlaceableObject")
    TargetData.IsAltFarm = isAltFarm
    ShovelPrompt.Enabled = true
end

-- UI Button Handlers (same as original)
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

-- Input Setup (similar to original)
local inputConnection
local function SetupInput()
    if inputConnection then
        inputConnection:Disconnect()
    end
    
    if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
        inputConnection = UserInputService.TouchTapInWorld:Connect(function(_, position)
            HandleShovelInput(position)
        end)
    else
        inputConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                HandleShovelInput(UserInputService:GetMouseLocation())
            end
        end)
    end
end

-- Initialize
RunService.RenderStepped:Connect(UpdateHighlight)
UserInputService.LastInputTypeChanged:Connect(SetupInput)
SetupInput()
