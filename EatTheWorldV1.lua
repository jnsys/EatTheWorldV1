-- Create a small, transparent dialog
local dialog = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")  -- New label for title
local sellValueInput = Instance.new("TextBox")
local closeButton = Instance.new("TextButton")
local toggleButton = Instance.new("TextButton")
local signatureLabel = Instance.new("TextLabel")  -- New label for signature

dialog.Name = "AutoSellDialog"
dialog.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 200, 0, 190)  -- Increased height for title
frame.Position = UDim2.new(1, -220, 0.5, -95)  -- Adjusted position
frame.BackgroundTransparency = 0.5
frame.Active = true  -- Make the frame active for dragging
frame.Draggable = true  -- Enable dragging
frame.Parent = dialog

titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0.8, 0, 0, 30)
titleLabel.Position = UDim2.new(0.1, 0, 0, 0)
titleLabel.Text = "Eat The World"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = frame

sellValueInput.Name = "SellValueInput"
sellValueInput.Size = UDim2.new(0.8, 0, 0, 30)
sellValueInput.Position = UDim2.new(0.1, 0, 0.2, 0)
sellValueInput.Text = "100000"
sellValueInput.Parent = frame

toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.8, 0, 0, 30)
toggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
toggleButton.Text = "Stop"  -- Changed to "Stop" as it starts automatically
toggleButton.Parent = frame

closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0.8, 0, 0, 30)
closeButton.Position = UDim2.new(0.1, 0, 0.6, 0)
closeButton.Text = "Close"
closeButton.Parent = frame

signatureLabel.Name = "SignatureLabel"
signatureLabel.Size = UDim2.new(0.8, 0, 0, 20)
signatureLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
signatureLabel.Text = "Powered by JN++"
signatureLabel.TextColor3 = Color3.new(1, 1, 1)
signatureLabel.BackgroundTransparency = 1
signatureLabel.Font = Enum.Font.SourceSansBold
signatureLabel.TextSize = 14
signatureLabel.Parent = frame

local autoSellRunning = true  -- Set to true by default
local sellValue = 100000

local function getCurrentLocation()
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            return humanoidRootPart.CFrame
        else
            warn("HumanoidRootPart not found in character.")
        end
    else
        warn("Character not found for LocalPlayer.")
    end
    return nil
end

local function turnRight(currentCFrame)
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local rightRotation = CFrame.Angles(0, math.rad(90), 0)
            local newCFrame = currentCFrame * rightRotation
            character.HumanoidRootPart.CFrame = newCFrame
        else
            warn("Humanoid not found in character.")
        end
    else
        warn("Character not found for LocalPlayer.")
    end
end

local function getPlayerUsername()
    local player = game.Players.LocalPlayer
    if player then
        return player.Name
    else
        warn("LocalPlayer not found.")
        return nil
    end
end

local function autoSell()
    local lastGrabTime = 0
    while autoSellRunning do
        wait(0.001)  -- Wait for 1 millisecond before checking again
        if not dialog.Parent then
            break  -- Stop the loop if the dialog is destroyed
        end
        
        local player = game.Players.LocalPlayer
        if player and player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Size") then
            local currentSize = player.leaderstats.Size.Value
            if currentSize >= sellValue then
                local playerUsername = getPlayerUsername()
                if playerUsername and game.Workspace:FindFirstChild(playerUsername) and game.Workspace[playerUsername]:FindFirstChild("Events") and game.Workspace[playerUsername].Events:FindFirstChild("Sell") then
                    repeat
                        game.Workspace[playerUsername].Events.Sell:FireServer()
                        wait(0.1)  -- Short wait to prevent overwhelming the server
                        currentSize = player.leaderstats.Size.Value
                    until currentSize < sellValue
                    
                    wait(5)  -- Wait for 5 seconds after selling
                    local currentCFrame = getCurrentLocation()
                    if currentCFrame then
                        turnRight(currentCFrame)
                    else
                        warn("Failed to get current location.")
                    end
                else
                    warn("Required game objects for selling not found.")
                end
            end
        else
            warn("Player or required stats not found.")
        end
        
        -- Check if TemplateChunk exists and perform action
        local playerUsername = getPlayerUsername()
        if playerUsername then
            if game.Workspace:FindFirstChild("Chunks") and 
               game.Workspace.Chunks:FindFirstChild("TemplateChunk") then
                game.Workspace[playerUsername].Events.Eat:FireServer()
                lastGrabTime = 0  -- Reset the timer when TemplateChunk exists
            else
                game.Workspace[playerUsername].Events.Grab:FireServer()
                if lastGrabTime == 0 then
                    lastGrabTime = tick()  -- Start the timer
                elseif tick() - lastGrabTime >= 5 then
                    -- If 5 seconds have passed since the last grab and still no TemplateChunk
                    local currentCFrame = getCurrentLocation()
                    if currentCFrame then
                        turnRight(currentCFrame)
                    else
                        warn("Failed to get current location.")
                    end
                    lastGrabTime = 0  -- Reset the timer after turning
                end
            end
        else
            warn("Failed to get player username.")
        end
    end
end

local function startAutoSell()
    autoSellRunning = true
    toggleButton.Text = "Stop"
    spawn(autoSell)
end

local function stopAutoSell()
    autoSellRunning = false
    toggleButton.Text = "Start"
end

sellValueInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newValue = tonumber(sellValueInput.Text)
        if newValue then
            sellValue = newValue
            print("Sell value updated to: " .. sellValue)
        else
            print("Invalid sell value. Using previous value: " .. sellValue)
            sellValueInput.Text = tostring(sellValue)
        end
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    if autoSellRunning then
        stopAutoSell()
    else
        startAutoSell()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    stopAutoSell()
    dialog:Destroy()
end)

-- Reconnect the script when the player changes character
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if dialog.Parent and autoSellRunning then
        spawn(autoSell)
    end
end)

-- Start AutoSell immediately when the script loads
startAutoSell()
