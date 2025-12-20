local DataStoreService = game:GetService("DataStoreService")

local SaveService = {}

local DATASTORE_NAME = "IdleTycoonSave_v1"
local MAX_RETRIES = 2

local store = DataStoreService:GetDataStore(DATASTORE_NAME)

function SaveService.Load(player)
  local key = tostring(player.UserId)
  local ok, result = pcall(function()
    return store:GetAsync(key)
  end)

  if not ok then
    warn("[SaveService] Load failed for", player.Name, result)
    return nil
  end

  return result
end

function SaveService.Save(player, data)
  local key = tostring(player.UserId)
  local attempts = 0

  while attempts <= MAX_RETRIES do
    local ok, err = pcall(function()
      store:SetAsync(key, data)
    end)

    if ok then
      return true
    end

    warn("[SaveService] Save failed for", player.Name, err)
    attempts += 1
    task.wait(2)
  end

  return false
end

return SaveService
