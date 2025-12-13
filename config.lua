Config = {}

Config.UseOxTarget = true
Config.UseProgressBar = true
Config.PoliceJobs = {'police', 'sheriff'}
Config.MinPolice = 0

Config.Keybind = 'F6'

-- Heist Configurations
Config.Heists = {
    ['fleeca_bank'] = {
        name = 'Fleeca Bank',
        description = 'Rob a small Fleeca Bank branch. Easy money for beginners.',
        difficulty = 'Easy',
        icon = 'bank',
        minPlayers = 2,
        maxPlayers = 4,
        payout = {min = 25000, max = 40000},
        requiredItems = {'lockpick', 'drill'},
        cooldown = 1800,
        locations = {
            {coords = vector3(147.04, -1044.94, 29.36), heading = 340.0, name = 'Legion Square'},
            {coords = vector3(-2957.6, 481.45, 15.69), heading = 87.0, name = 'Great Ocean Highway'},
            {coords = vector3(1175.96, 2712.87, 38.09), heading = 180.0, name = 'Route 68'}
        },
        stages = {
            {name = 'Hack Security Panel', type = 'hack', duration = 15000},
            {name = 'Drill Vault Door', type = 'drill', duration = 20000},
            {name = 'Collect Cash', type = 'collect', duration = 10000, reward = {'money'}},
            {name = 'Escape Area', type = 'escape', duration = 5000}
        }
    },
    
    ['paleto_bank'] = {
        name = 'Paleto Bank',
        description = 'Small town bank with moderate security.',
        difficulty = 'Medium',
        icon = 'bank',
        minPlayers = 3,
        maxPlayers = 5,
        payout = {min = 40000, max = 65000},
        requiredItems = {'thermite', 'drill', 'hacking_device'},
        cooldown = 2400,
        locations = {
            {coords = vector3(-105.77, 6472.03, 31.62), heading = 45.0, name = 'Paleto Bay'}
        },
        stages = {
            {name = 'Plant Thermite', type = 'thermite', duration = 10000},
            {name = 'Breach Vault', type = 'drill', duration = 25000},
            {name = 'Disable Alarms', type = 'hack', duration = 15000},
            {name = 'Loot Vault', type = 'collect', duration = 20000, reward = {'money', 'goldbar'}},
            {name = 'Escape', type = 'escape', duration = 5000}
        }
    },
    
    ['jewelry_store'] = {
        name = 'Vangelico Jewelry',
        description = 'Smash and grab at the luxury jewelry store.',
        difficulty = 'Medium',
        icon = 'jewelry',
        minPlayers = 2,
        maxPlayers = 4,
        payout = {min = 35000, max = 55000},
        requiredItems = {'lockpick', 'bag'},
        cooldown = 2100,
        locations = {
            {coords = vector3(-622.74, -230.74, 38.05), heading = 310.0, name = 'Rockford Hills'}
        },
        stages = {
            {name = 'Break Display Glass', type = 'smash', duration = 5000},
            {name = 'Smash Display Cases', type = 'smash', duration = 20000},
            {name = 'Grab Jewelry', type = 'collect', duration = 15000, reward = {'diamond', 'rolex', 'jewelry'}},
            {name = 'Escape', type = 'escape', duration = 5000}
        }
    },
    
    ['pacific_bank'] = {
        name = 'Pacific Standard Bank',
        description = 'The big score. Maximum security, maximum reward.',
        difficulty = 'Hard',
        icon = 'bank',
        minPlayers = 4,
        maxPlayers = 6,
        payout = {min = 80000, max = 150000},
        requiredItems = {'thermite', 'drill', 'hacking_device', 'keycard'},
        cooldown = 3600,
        locations = {
            {coords = vector3(255.001, 225.855, 101.876), heading = 160.0, name = 'Alta'}
        },
        stages = {
            {name = 'Hack Security Grid', type = 'hack', duration = 20000},
            {name = 'Thermite Vault Door', type = 'thermite', duration = 25000},
            {name = 'Drill Safety Boxes', type = 'drill', duration = 30000},
            {name = 'Bypass Laser Grid', type = 'hack', duration = 20000},
            {name = 'Collect Cash', type = 'collect', duration = 25000, reward = {'money', 'goldbar'}},
            {name = 'Escape', type = 'escape', duration = 10000}
        }
    },
    
    ['art_gallery'] = {
        name = 'Art Gallery Heist',
        description = 'Steal priceless paintings from the gallery. High value, low violence.',
        difficulty = 'Hard',
        icon = 'art',
        minPlayers = 3,
        maxPlayers = 5,
        payout = {min = 90000, max = 160000},
        requiredItems = {'hacking_device', 'keycard', 'bag'},
        cooldown = 3300,
        locations = {
            {coords = vector3(-1937.89, -568.02, 11.85), heading = 230.0, name = 'Rockford Hills Gallery', interior = true}
        },
        stages = {
            {name = 'Disable Security System', type = 'hack', duration = 20000},
            {name = 'Cut Laser Grid', type = 'hack', duration = 25000},
            {name = 'Remove Paintings', type = 'collect', duration = 30000, reward = {'painting_rare', 'painting_ancient', 'artifact'}},
            {name = 'Bypass Motion Sensors', type = 'hack', duration = 20000},
            {name = 'Escape Gallery', type = 'escape', duration = 10000}
        }
    },
    
    ['union_depository'] = {
        name = 'Union Depository',
        description = 'Fort Knox of Los Santos. Only for the elite.',
        difficulty = 'Extreme',
        icon = 'vault',
        minPlayers = 6,
        maxPlayers = 8,
        payout = {min = 150000, max = 250000},
        requiredItems = {'c4', 'thermite', 'drill', 'hacking_device', 'keycard'},
        cooldown = 5400,
        locations = {
            {coords = vector3(2.69, -667.01, 16.13), heading = 180.0, name = 'Pillbox Hill'}
        },
        stages = {
            {name = 'Infiltrate Facility', type = 'stealth', duration = 15000},
            {name = 'Plant C4 Charges', type = 'c4', duration = 25000},
            {name = 'Breach Main Vault', type = 'drill', duration = 35000},
            {name = 'Hack Vault Controls', type = 'hack', duration = 30000},
            {name = 'Load Gold Bars', type = 'collect', duration = 40000, reward = {'goldbar', 'money'}},
            {name = 'Escape Route', type = 'escape', duration = 15000}
        }
    },
    
    ['laundromat'] = {
        name = 'Money Laundromat',
        description = 'Clean dirty money and collect the cash stash.',
        difficulty = 'Easy',
        icon = 'laundry',
        minPlayers = 2,
        maxPlayers = 3,
        payout = {min = 20000, max = 35000},
        requiredItems = {'lockpick'},
        cooldown = 1500,
        locations = {
            {coords = vector3(1122.23, -3194.35, -40.39), heading = 90.0, name = 'Elysian Island'}
        },
        stages = {
            {name = 'Pick Lock', type = 'lockpick', duration = 10000},
            {name = 'Find Safe', type = 'search', duration = 15000},
            {name = 'Crack Safe', type = 'hack', duration = 20000},
            {name = 'Collect Cash', type = 'collect', duration = 10000, reward = {'money'}},
            {name = 'Escape', type = 'escape', duration = 5000}
        }
    },
    
    ['casino'] = {
        name = 'Diamond Casino Vault',
        description = 'Hit the casino vault. High risk, high reward.',
        difficulty = 'Hard',
        icon = 'casino',
        minPlayers = 5,
        maxPlayers = 6,
        payout = {min = 100000, max = 180000},
        requiredItems = {'keycard', 'hacking_device', 'drill'},
        cooldown = 4200,
        locations = {
            {coords = vector3(921.32, 48.99, 81.11), heading = 150.0, name = 'Vinewood'}
        },
        stages = {
            {name = 'Infiltrate Casino', type = 'stealth', duration = 15000},
            {name = 'Hack Door System', type = 'hack', duration = 20000},
            {name = 'Navigate Tunnels', type = 'navigate', duration = 15000},
            {name = 'Breach Vault', type = 'drill', duration = 30000},
            {name = 'Loot Vault', type = 'collect', duration = 25000, reward = {'money', 'diamond', 'goldbar'}},
            {name = 'Escape', type = 'escape', duration = 10000}
        }
    },
    
    ['car_dealership'] = {
        name = 'Luxury Car Dealership',
        description = 'Steal high-end vehicles for quick profit.',
        difficulty = 'Medium',
        icon = 'car',
        minPlayers = 2,
        maxPlayers = 4,
        payout = {min = 45000, max = 75000},
        requiredItems = {'lockpick', 'hacking_device'},
        cooldown = 2700,
        locations = {
            {coords = vector3(-33.76, -1102.02, 26.42), heading = 70.0, name = 'Pillbox Hill'}
        },
        stages = {
            {name = 'Disable Alarms', type = 'hack', duration = 15000},
            {name = 'Hack Security', type = 'hack', duration = 20000},
            {name = 'Steal Vehicles', type = 'collect', duration = 25000, reward = {'car_keys'}},
            {name = 'Escape', type = 'escape', duration = 5000}
        }
    },
    
    ['cash_exchange'] = {
        name = 'Cash Exchange Center',
        description = 'Currency exchange with heavy security.',
        difficulty = 'Hard',
        icon = 'money',
        minPlayers = 4,
        maxPlayers = 5,
        payout = {min = 70000, max = 120000},
        requiredItems = {'thermite', 'hacking_device', 'drill'},
        cooldown = 3300,
        locations = {
            {coords = vector3(-1211.42, -336.12, 37.78), heading = 30.0, name = 'San Andreas Ave'}
        },
        stages = {
            {name = 'Breach Entrance', type = 'thermite', duration = 15000},
            {name = 'Hack Security', type = 'hack', duration = 20000},
            {name = 'Access Vault', type = 'drill', duration = 25000},
            {name = 'Collect Currency', type = 'collect', duration = 20000, reward = {'money', 'goldbar'}},
            {name = 'Escape', type = 'escape', duration = 10000}
        }
    }
}

-- Blackmarket items
Config.BlackmarketItems = {
    {item = 'goldbar', price = 5000, label = 'Gold Bar'},
    {item = 'diamond', price = 8000, label = 'Diamond'},
    {item = 'rolex', price = 3500, label = 'Rolex Watch'},
    {item = 'painting_rare', price = 12000, label = 'Rare Painting'},
    {item = 'painting_ancient', price = 18000, label = 'Ancient Painting'},
    {item = 'artifact', price = 7500, label = 'Ancient Artifact'},
    {item = 'jewelry', price = 2500, label = 'Jewelry'},
    {item = 'electronics', price = 1500, label = 'Stolen Electronics'},
    {item = 'laptop', price = 2000, label = 'High-End Laptop'},
    {item = 'phone', price = 800, label = 'Smartphone'},
    {item = 'car_keys', price = 5000, label = 'Luxury Car Keys'}
}

-- Animations for heist stages
Config.Animations = {
    ['hack'] = {dict = 'anim@heists@prison_heiststation@cop_reactions', anim = 'cop_b_idle', flag = 16},
    ['drill'] = {dict = 'anim@heists@fleeca_bank@drilling', anim = 'drill_straight_idle', flag = 16},
    ['thermite'] = {dict = 'anim@heists@ornate_bank@thermal_charge', anim = 'thermal_charge', flag = 16},
    ['lockpick'] = {dict = 'veh@break_in@0h@p_m_one@', anim = 'low_force_entry_ds', flag = 16},
    ['smash'] = {dict = 'melee@large_wpn@streamed_core', anim = 'ground_attack_on_spot', flag = 16},
    ['collect'] = {dict = 'amb@prop_human_bum_bin@idle_b', anim = 'idle_d', flag = 16},
    ['c4'] = {dict = 'anim@heists@ornate_bank@thermal_charge', anim = 'thermal_charge', flag = 16},
    ['stealth'] = {dict = 'move_crouch_proto', anim = 'idle_intro', flag = 1},
    ['search'] = {dict = 'amb@world_human_bum_wash@male@low@idle_a', anim = 'idle_a', flag = 16},
    ['navigate'] = {dict = 'move_m@confident', anim = 'walk', flag = 1},
    ['escape'] = {dict = 'move_m@hurry', anim = 'walk', flag = 1}
}
