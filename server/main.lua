local ESX= nil

CreateThread(function()
  if GetResourceState('es_extended') ~= 'missing' and GetResourceState('es_extended') ~= 'unknown' then
    while GetResourceState('es_extended') ~= 'started' do Wait(0) end
    ESX = exports['es_extended']:getSharedObject()
  end
end)

function serverNotif(src, type, msg)
	local xPlayer = ESX.GetPlayerFromId(src)
  if Config.UseMythicNotify then
    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = type, text = msg})
  else
    xPlayer.showNotification(msg)
  end
end

RegisterNetEvent('kc_lumberjack:checkReq')
AddEventHandler('kc_lumberjack:checkReq', function()
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  local reqItem = exports.ox_inventory:GetCurrentWeapon(src)

  if reqItem then 
    local durability = reqItem.metadata.durability
    if reqItem.name == Config.Items.Wood.Need then
      if durability ~= 0 then
        local durabilityUsed = durability - Config.Items.Wood.CountNeed
        exports.ox_inventory:SetDurability(src, reqItem.slot, durabilityUsed)
        TriggerClientEvent('kc_lumberjack:cuttingTrees', src)
      else
        serverNotif(src, 'error', _U('broken_axe'))
      end
    else
      serverNotif(src, 'error', _U('not_battle_axe'))
    end
  else
    serverNotif(src, 'error', _U('not_battle_axe'))
  end
end)

RegisterNetEvent('kc_lumberjack:cuttingDone')
AddEventHandler('kc_lumberjack:cuttingDone', function()
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  local randomCount = math.random(Config.Items.Wood.Add)

  xPlayer.addInventoryItem(Config.Items.Wood.Dbname, randomCount)
end)

RegisterNetEvent('kc_lumberjack:checkingWood')
AddEventHandler('kc_lumberjack:checkingWood', function()
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  local item = xPlayer.getInventoryItem(Config.Items.Wood.Dbname)

  if item.count > (Config.Items.CuttedWood.CountNeed - 1) then
    TriggerClientEvent('kc_lumberjack:prossesWood', src)
  else
    serverNotif(src, 'error', _U('not_enough', Config.Items.Wood.Label))
  end
end)

RegisterNetEvent('kc_lumberjack:prossesWoodDone')
AddEventHandler('kc_lumberjack:prossesWoodDone', function()
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  local randomCount = math.random(Config.Items.CuttedWood.Add)

  xPlayer.removeInventoryItem(Config.Items.Wood.Dbname, Config.Items.CuttedWood.CountNeed)
  xPlayer.addInventoryItem(Config.Items.CuttedWood.Dbname, randomCount)
end)

RegisterNetEvent('kc_lumberjack:checkingCuttenWood')
AddEventHandler('kc_lumberjack:checkingCuttenWood', function()
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  local item = xPlayer.getInventoryItem(Config.Items.CuttedWood.Dbname)

  if item.count > (Config.Items.PackagedPlank.CountNeed - 1) then
    TriggerClientEvent('kc_lumberjack:prossesCuttenWood', src)
  else
    serverNotif(src, 'error', _U('not_enough', Config.Items.CuttedWood.Label))
  end
end)

RegisterNetEvent('kc_lumberjack:prossesCuttenWoodDone')
AddEventHandler('kc_lumberjack:prossesCuttenWoodDone', function()
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

  xPlayer.removeInventoryItem(Config.Items.CuttedWood.Dbname, Config.Items.PackagedPlank.CountNeed)
  xPlayer.addInventoryItem(Config.Items.PackagedPlank.Dbname, Config.Items.PackagedPlank.Add)
end)

RegisterNetEvent('kc_lumberjack:sellConfirm')
AddEventHandler('kc_lumberjack:sellConfirm', function(itemDB, count)
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  local item = xPlayer.getInventoryItem(Config.Items[itemDB].Dbname)

  if not count then
    count = 0
  end

  if item.count == 0 or count > item.count then
    serverNotif(src, 'error', _U('not_enough', Config.Items[itemDB].Label))
    return
  end
  
  if count == 0 then
    xPlayer.removeInventoryItem(Config.Items[itemDB].Dbname, item.count)
    xPlayer.addMoney(item.count * Config.Items[itemDB].Price)
  elseif count > 0 then
    xPlayer.removeInventoryItem(Config.Items[itemDB].Dbname, count)
    xPlayer.addMoney(count * Config.Items[itemDB].Price)
  end
end)
