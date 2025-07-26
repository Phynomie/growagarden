-- FINAL WORKING Shovel Script for Alt Farm
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- CONFIGURATION (MUST SET THESE)
local ALT_PLAYER_NAME = "rr2obly256sf" -- Your alt's exact username
local DEBUG_MODE = true -- Set to true to see debug prints

-- Services and references
local LocalPlayer = game.Players.LocalPlayer
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Remove_Item = GameEvents:WaitForChild("Remove_Item")
local DeleteObject = GameEvents:WaitForChild("DeleteObject")
local Notification = require(ReplicatedStorage.Modules.Notification)

-- UI Setup
local ShovelPrompt = LocalPlayer.PlayerGui:WaitForChild("ShovelPrompt")
local ConfirmFrame = ShovelPrompt:WaitForChild("ConfirmFrame")
local FruitName = ConfirmFrame:WaitForChild("FruitName")

-- Highlight effect
local Highlight = Instance.new("Highlight")
Highlight.Name = "ShovelHighlight"
Highlight.Parent = LocalPlayer.PlayerGui
Highlight.FillColor = Color3.fromRGB(255, 50, 50)
Highlight.FillTransparency = 1
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

local CurrentCamera = workspace.CurrentCamera

local TargetData = {
    Instance = nil,
    IsPlaceableObject = false
}

-- DEBUG FUNCTION
local function DebugPrint(message)
    if DEBUG_MODE then
        print("[Shovel Debug]: "..message)
    end
end

-- IMPROVED FARM DETECTION
local function IsAltFarmObject(instance)
    -- Walk up the hierarchy to find farm or plot
    local current = instance
    while current and current ~= workspace do
        -- Check for common farm indicators
        if current:FindFirstChild("Owner") then
            if tostring(current.Owner.Value) == ALT_PLAYER_NAME then
                DebugPrint("Found alt farm by Owner value")
                return true
            end
        elseif string.find(current.Name, ALT_PLAYER_NAME) then
            DebugPrint("Found alt farm by name match")
            return true
        elseif string.find(current.Name, "Farm") and current:FindFirstChildWhichIsA("Model") then
            -- Additional check for farm structure
            DebugPrint("Found potential farm structure")
            for _,v in pairs(game.Players:GetPlayers()) do
                if v.Name == ALT_PLAYER_NAME and current:IsDescendantOf(v) then
                    DebugPrint("Confirmed alt farm by player hierarchy")
                    return true
                end
            end
        end
        current = current.Parent
    end
    return false
end

-- SIMPLIFIED SHOVEL CHECK
local function CanShovel(target)
    -- Skip protection checks for alt farm
    if IsAltFarmObject(target) then
        DebugPrint("Alt farm object - allowing shovel")
        return true
    end
    
    -- Original protection checks for non-alt farms
    local name = target.Name
    if string.find(string.lower(name), "carrot") then
        DebugPrint("Protected plant detected")
        return false
    end
    if string.find(string.lower(name), "sprinkler") then
        DebugPrint("Protected object detected")
        return false
    end
    
    DebugPrint("Not alt farm and not protected - default deny")
    return false
end

-- RAYCAST FUNCTION
local function RaycastToPosition(mousePosition)
    local ray = CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    return workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
end

-- HIGHLIGHT LOGIC
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

    if CanShovel(targetModel) then
        if Highlight.Adornee ~= targetModel then
            Highlight.FillTransparency = 1
            TweenService:Create(Highlight, TweenInfo.new(0.2), {
                FillTransparency = 0.7
            }):Play()
        end
        Highlight.Adornee = targetModel
        DebugPrint("Highlighting valid target: "..targetModel.Name)
    else
        Highlight.Adornee = nil
    end
end

-- INPUT HANDLER
local function HandleShovelInput(inputPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then
        DebugPrint("Shovel not equipped")
        return
    end

    local raycastResult = RaycastToPosition(inputPosition)
    if not raycastResult then
        DebugPrint("Raycast failed")
        return 
    end

    local targetModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
    if not targetModel then
        DebugPrint("No model found")
        return
    end

    if not CanShovel(targetModel) then
        DebugPrint("Cannot shovel: "..targetModel.Name)
        Notification:CreateNotification("You can only shovel plants in your alt farm!")
        return
    end

    DebugPrint("Valid shovel target: "..targetModel.Name)
    FruitName.Text = targetModel.Name
    TargetData.Instance = targetModel
    TargetData.IsPlaceableObject = CollectionService:HasTag(targetModel, "PlaceableObject")
    ShovelPrompt.Enabled = true
end

-- CONFIRM/CANCEL HANDLERS
ConfirmFrame.Confirm.MouseButton1Click:Connect(function()
    if TargetData.Instance then
        DebugPrint("Attempting to remove: "..TargetData.Instance.Name)
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

-- INPUT SETUP
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

-- INITIALIZATION
RunService.RenderStepped:Connect(UpdateHighlight)
SetupInput()

DebugPrint("Shovel script initialized successfully")
Notification:CreateNotification("Alt Farm Shovel Ready!")
