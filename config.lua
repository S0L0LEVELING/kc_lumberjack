Config                 = {}
Config.Locale          = GetConvar('esx:locale', 'id')
Config.UseMythicNotify = true

Config.Blips = {
  Main    = { Sprite = 85, Colour = 69, Display = 4, Scale = 0.8 },
  Wood    = { Sprite = 77, Colour = 69, Display = 4, Scale = 0.6 },
  Selling = { Sprite = 500, Colour = 69, Display = 4, Scale = 0.8 }
}

Config.Zones = {
  Main = vector3(-552.5441, 5348.7969, 74.7431),
  Selling = vector3(1166.9640, -1347.3405, 34.9095),
  WoodTarget = {
    Coords = vector3(-552.81, 5369.86, 70.21), Size = vector3( 4, 2, 2), Rotation = 341
  }
}

Config.Peds = {
  { x = -552.2930, y = 5348.4502, z = 74.7431, heading = 69.2900, hash = 0xA956BD9E, model = 'S_M_M_Gaffer_01' }, -- Duty
  { x = -565.5827, y = 5325.8916, z = 73.5929, heading = 74.8012, hash = 0xEF785A6A, model = 'CSB_Undercover' }, -- Prosses cutted_wood
  { x = -516.9407, y = 5331.4580, z = 80.2627, heading = 344.9627, hash = 0xA2E86156, model = 'G_M_Y_PoloGoon_02' }, -- Prosses packaged_plank
  { x = 1166.9026, y = -1347.3792, z = 34.9103, heading = 270.3391, hash = 0xA62549C9, model = 'IG_DJTalIgnazio' }, -- Sell wood products
}

Config.Items = {
  Wood = {
    Dbname = 'wood',
    Label = 'Kayu',
    Price = 200,
    Add = 5, -- Random Add 1 - 5
    Need = "WEAPON_BATTLEAXE",
    CountNeed = 0.50, -- Fixed durability weapond remove, 100 = 100%
    Duration = 9000
  },
  CuttedWood = {
    Dbname = 'cutted_wood',
    Label = 'Potongan Kayu',
    Price = 350,
    Add = 10, -- Random Add 1 - 10
    Need = 'wood',
    CountNeed = 5,
    Duration = 12000
  },
  PackagedPlank = {
    Dbname = 'packaged_plank',
    Label = 'Paket Papan',
    Price = 500,
    Add = 5, -- Random Add 1 - 5
    Need = 'cutted_wood',
    CountNeed = 5,
    Duration = 15000
  }
}