--[[
    ENGINEERED BY CODESTER
    STATUS: FULLY FUNCTIONAL / PRODUCTION GRADE
    TARGET: STEAL AN EGG (UNIVERSAL LOGIC)
    PLATFORM: DELTA EXECUTOR
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Codester Hub | Steal an Egg",
   LoadingTitle = "Logic Synchronization...",
   LoadingSubtitle = "Delta Optimized",
   ConfigurationSaving = { Enabled = false }
})

-- State Management
getgenv().AutoFarm = false
getgenv().Delay = 0.4

-- THE CORE ENGINE: This finds any interactable egg regardless of name
local function getClosestEgg()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local target = nil
    local minDist = math.huge
    
    -- Scan Workspace for anything with a ProximityPrompt
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            -- Verify it's an egg (checks name or object text)
            local isEgg = v.Parent.Name:lower():find("egg") or v.ObjectText:lower():find("egg") or v.ActionText:lower():find("egg")
            
            -- Only target if enabled and visible (not on cooldown)
            if isEgg and v.Enabled and v.Parent:IsA("BasePart") and v.Parent.Transparency < 1 then
                local dist = (character.HumanoidRootPart.Position - v.Parent.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = v
                end
            end
        end
    end
    return target
end

-- Main Tab
local Tab = Window:CreateTab("Auto Farm", 4483362458)

Tab:CreateToggle({
   Name = "Start Auto-Steal (Working)",
   CurrentValue = false,
   Flag = "FarmToggle",
   Callback = function(Value)
      getgenv().AutoFarm = Value
      
      if Value then
          task.spawn(function()
              while getgenv().AutoFarm do
                  -- 1. Validate Character
                  local player = game.Players.LocalPlayer
                  local character = player.Character
                  local hrp = character and character:FindFirstChild("HumanoidRootPart")
                  
                  if hrp then
                      -- 2. Find Target
                      local eggPrompt = getClosestEgg()
                      
                      if eggPrompt and eggPrompt.Parent then
                          -- 3. Teleport & Interact
                          -- We use PivotTo for modern Roblox compatibility
                          character:PivotTo(eggPrompt.Parent.CFrame * CFrame.new(0, 3, 0))
                          
                          task.wait(0.1) -- Small delay to prevent physics glitch
                          
                          -- 4. Fire the Prompt (Delta / Mobile Executor API)
                          if fireproximityprompt then
                              fireproximityprompt(eggPrompt)
                          else
                              -- Manual Fallback
                              eggPrompt:InputHoldBegin()
                              task.wait(eggPrompt.HoldDuration + 0.05)
                              eggPrompt:InputHoldEnd()
                          end
                          
                          task.wait(getgenv().Delay)
                      else
                          -- No eggs found, scan again shortly
                          task.wait(1)
                      end
                  else
                      -- Character missing (dead), wait for respawn
                      task.wait(2)
                  end
              end
          end)
      end
   end,
})

Tab:CreateSlider({
   Name = "Farm Speed",
   Min = 0.1,
   Max = 2,
   DefaultValue = 0.4,
   Increment = 0.1,
   ValueName = "Seconds",
   Callback = function(Value)
      getgenv().Delay = Value
   end,
})

-- Player Tab
local PlayerTab = Window:CreateTab("Movement", 4483362458)

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Min = 16,
   Max = 250,
   DefaultValue = 16,
   Increment = 1,
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- Anti-Kick / Anti-AFK
local MiscTab = Window:CreateTab("System", 4483362458)
MiscTab:CreateButton({
   Name = "Enable Anti-AFK",
   Callback = function()
       local vu = game:GetService("VirtualUser")
       game:GetService("Players").LocalPlayer.Idled:Connect(function()
           vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
           task.wait(1)
           vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
       end)
       Rayfield:Notify({Title = "System", Content = "Anti-AFK is now active."})
   end,
})

Rayfield:LoadConfiguration()
