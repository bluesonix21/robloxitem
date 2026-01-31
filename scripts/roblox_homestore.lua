local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local SUPABASE_FUNCTION_URL = "https://YOUR_PROJECT.functions.supabase.co/asset-fetch"
local ASSET_FETCH_KEY = "YOUR_ASSET_FETCH_KEY"

local function safeJsonDecode(payload)
  local ok, result = pcall(function()
    return HttpService:JSONDecode(payload)
  end)
  if ok then
    return result
  end
  return nil
end

local function fetchAssetInfo(assetId)
  local url = SUPABASE_FUNCTION_URL .. "?id=" .. HttpService:UrlEncode(assetId)
  local ok, response = pcall(function()
    return HttpService:RequestAsync({
      Url = url,
      Method = "GET",
      Headers = {
        ["x-asset-fetch-key"] = ASSET_FETCH_KEY
      },
    })
  end)
  if not ok then
    warn("Asset fetch failed: " .. tostring(response))
    return nil
  end
  if not response.Success then
    warn("Asset fetch failed: " .. tostring(response.StatusCode))
    return nil
  end
  return safeJsonDecode(response.Body)
end

local function applyTextureToCharacter(character, textureUrl)
  if not textureUrl then return end
  local success = false
  for _, descendant in ipairs(character:GetDescendants()) do
    if descendant:IsA("Decal") then
      descendant.Texture = textureUrl
      success = true
    end
  end
  if not success then
    warn("No decal found to apply texture")
  end
end

Players.PlayerAdded:Connect(function(player)
  local joinData = player:GetJoinData()
  local launchData = joinData and joinData.LaunchData
  if not launchData then
    return
  end

  local data = safeJsonDecode(launchData)
  if not data or not data.id then
    warn("LaunchData missing id")
    return
  end

  local assetInfo = fetchAssetInfo(data.id)
  if not assetInfo then
    return
  end

  local character = player.Character or player.CharacterAdded:Wait()
  applyTextureToCharacter(character, assetInfo.texture_url)
end)
