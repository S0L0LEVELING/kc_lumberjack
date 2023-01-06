local ESX, curentJob, targetId = nil, nil, nil
local duty = false
CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Wait(10)
	end 
  PlayerData = ESX.GetPlayerData()
end)

function spawnNPC(x, y, z, heading, hash, model)
  RequestModel(GetHashKey(model))
  while not HasModelLoaded(GetHashKey(model)) do
    Wait(15)
  end
  ped = CreatePed(4, hash, x, y, z - 1, 3374176, false, true)
  SetEntityHeading(ped, heading)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
end

function clientNotif(type, msg)
  if Config.UseMythicNotify then
    exports['mythic_notify']:DoHudText(type, msg)
  else
    ESX.ShowNotification(msg)
  end
end

function removeProps()
  for k, v in pairs(GetGamePool('CObject')) do
    if IsEntityAttachedToEntity(PlayerPedId(), v) then
      SetEntityAsMissionEntity(v, true, true)
      DeleteObject(v)
      DeleteEntity(v)
    end
  end
end

RegisterNetEvent('kc_lumberjack:getjob')
AddEventHandler('kc_lumberjack:getjob', function()
  if not duty and curentJob == nil then
    duty = true
    curentJob = 'lumberjack'
    TriggerEvent('kc_lumberjack:startLumberjack')
    clientNotif('inform', _U('onduty', curentJob))
  end
end)

RegisterNetEvent('kc_lumberjack:finishjob')
AddEventHandler('kc_lumberjack:finishjob', function()
  if duty and curentJob then
    clientNotif('inform', _U('offduty', curentJob))
    duty = false
    curentJob, targetId = nil, nil
    exports.ox_target:removeZone(targetId)
  end
end)

RegisterNetEvent('kc_lumberjack:startLumberjack')
AddEventHandler('kc_lumberjack:startLumberjack', function()
  if curentJob ~= nil and duty then
    targetId = exports.ox_target:addBoxZone({
      coords = Config.Zones.WoodTarget.Coords,
      size = Config.Zones.WoodTarget.Size,
      rotation = Config.Zones.WoodTarget.Rotation,
      debug = false,
      options = {
        {
          name = 'cuttingWood',
          icon = 'fa-solid fa-hand',
          label = _U('cutting_wood'),
          serverEvent = 'kc_lumberjack:checkReq'
        }
      }
    })
  end
end)

RegisterNetEvent('kc_lumberjack:cuttingTrees')
AddEventHandler('kc_lumberjack:cuttingTrees', function(playerId)
  exports['mythic_progbar']:Progress({
    duration = Config.Items.Wood.Duration,
    label = _U('cutting_wood'),
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    },
    animation = {
        animDict = "melee@large_wpn@streamed_core",
        anim = "ground_attack_on_spot",
    },
  }, function(status)
    TriggerServerEvent('kc_lumberjack:cuttingDone', playerId)
  end)
end)

RegisterNetEvent('kc_lumberjack:prossesWood')
AddEventHandler('kc_lumberjack:prossesWood', function()
  exports['mythic_progbar']:Progress({
    duration = Config.Items.CuttedWood.Duration,
    label = _U('prosses', Config.Items.Wood.Label),
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    },
    animation = {
        animDict = "missfam4",
        anim = "base",
    },
    prop = {
      model = 'p_amb_clipboard_01',
      bone = 36029,
      coords = { x = 0.16, y = 0.08, z = 0.1 },
      rotation = { x = -130.0, y = -50.0, z = 0.0 },
    },
  }, function(status)
    if not status then
      TriggerServerEvent('kc_lumberjack:prossesWoodDone')
      removeProps()
    end
  end)
end)

RegisterNetEvent('kc_lumberjack:prossesCuttenWood')
AddEventHandler('kc_lumberjack:prossesCuttenWood', function()
  exports['mythic_progbar']:Progress({
    duration = Config.Items.PackagedPlank.Duration,
    label = _U('prosses', Config.Items.PackagedPlank.Label),
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    },
    animation = {
        animDict = "missfam4",
        anim = "base",
    },
    prop = {
      model = 'p_amb_clipboard_01',
      bone = 36029,
      coords = { x = 0.16, y = 0.08, z = 0.1 },
      rotation = { x = -130.0, y = -50.0, z = 0.0 },
    },
  }, function(status)
    if not status then
      TriggerServerEvent('kc_lumberjack:prossesCuttenWoodDone')
      removeProps()
    end
  end)
end)

RegisterNetEvent('kc_lumberjack:sellWoods')
AddEventHandler('kc_lumberjack:sellWoods', function()
  local cuttedWoodCount = exports.ox_inventory:Search('count', Config.Items.CuttedWood.Dbname)
  local packagedPlankCount = exports.ox_inventory:Search('count', Config.Items.PackagedPlank.Dbname)
  lib.registerContext({
    id = 'selling_woods',
    title = _U('sell_wood_products'),
    canClose = true,
    options =
    {
      {
        title = Config.Items.CuttedWood.Label,
        menu = 'sell_cutted_wood',
        description = _U('have', cuttedWoodCount)
      },
      {
        title = Config.Items.PackagedPlank.Label,
        menu = 'sell_plank',
        description = _U('have', packagedPlankCount)
      },
    }, 
    {
      id = 'sell_cutted_wood',
      title = _U('selling', Config.Items.CuttedWood.Label),
      menu = 'selling_woods',
      options = {
        {
          title = _U('sell_all'),
          onSelect = function()
            TriggerServerEvent('kc_lumberjack:sellConfirm', 'CuttedWood', false)
          end,
        },
        {
          title = _U('sell_some'),
          onSelect = function()
            local input = lib.inputDialog(_U('amount'), {
              {type = 'number', placeholder = "123"}
            })
            if not input then return end
            local countSell = tonumber(input[1])
            TriggerServerEvent('kc_lumberjack:sellConfirm', 'CuttedWood', countSell)
          end
        },
      }
    }, 
    {
      id = 'sell_plank',
      title = _U('selling', Config.Items.PackagedPlank.Label),
      menu = 'selling_woods',
      options = {
        {
          title = _U('sell_all'),
          onSelect = function()
            TriggerServerEvent('kc_lumberjack:sellConfirm', 'PackagedPlank', false)
          end,
        },
        {
          title = _U('sell_some'),
          onSelect = function()
            local input = lib.inputDialog(_U('amount'), {
              {type = 'number', placeholder = "123"}
            })
            if not input then return end
            local countSell = tonumber(input[1])
            TriggerServerEvent('kc_lumberjack:sellConfirm', 'PackagedPlank', countSell)
          end
        },
      }
    }
  })
  lib.showContext('selling_woods')
end)

CreateThread(function()
  -- [[ Get Job ]] --
  exports.ox_target:addModel({"S_M_M_Gaffer_01"}, {
    {
      event = 'kc_lumberjack:getjob',
      icon = "fa-solid fa-file-pen",
      label = _U('get_job'),
    },
    {
      event = 'kc_lumberjack:finishjob',
      icon = "fa-solid fa-file-pen",
      label = _U('finish_job'),
    },
  })
  -- [[ Prosses Cutted Wood ]] --
  exports.ox_target:addModel({"CSB_Undercover"}, {
    {
      serverEvent = 'kc_lumberjack:checkingWood',
      icon = "fa-solid fa-file-pen",
      label = _U('prosses', Config.Items.Wood.Label)
    },
  })
  -- [[ Prosses Pakaged Plank ]]
  exports.ox_target:addModel({"G_M_Y_PoloGoon_02"}, {
    {
      serverEvent = 'kc_lumberjack:checkingCuttenWood',
      icon = "fa-solid fa-file-pen",
      label = _U('prosses', Config.Items.PackagedPlank.Label)
    },
  })
  -- [[ Selling ]] --
  exports.ox_target:addModel({"IG_DJTalIgnazio"}, {
    {
      event = 'kc_lumberjack:sellWoods',
      icon = "fa-solid fa-file-pen",
      label = _U('sell_wood_products'),
    },
  })
end)

CreateThread(function()
  for _, v in pairs(Config.Peds) do
    spawnNPC(v.x, v.y, v.z, v.heading, v.hash, v.model)
  end
end)

CreateThread(function()
  -- Main Blip
  local blip = AddBlipForCoord(Config.Zones.Main)
  SetBlipSprite(blip, Config.Blips.Main.Sprite)
  SetBlipColour(blip, Config.Blips.Main.Colour)
  SetBlipDisplay(blip, Config.Blips.Main.Display)
  SetBlipScale(blip, Config.Blips.Main.Scale)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName('STRING')
  AddTextComponentSubstringPlayerName(_U('job_name'))
  EndTextCommandSetBlipName(blip)

  -- Selling Wood
  local blip = AddBlipForCoord(Config.Zones.Selling)
  SetBlipSprite(blip, Config.Blips.Selling.Sprite)
  SetBlipColour(blip, Config.Blips.Selling.Colour)
  SetBlipDisplay(blip, Config.Blips.Selling.Display)
  SetBlipScale(blip, Config.Blips.Selling.Scale)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName('STRING')
  AddTextComponentSubstringPlayerName(_U('sell_wood_products'))
  EndTextCommandSetBlipName(blip)

end)