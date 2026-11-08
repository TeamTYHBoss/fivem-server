Config = {}

Config.Currency = '£'

-- Main casino entrance and interaction area.
Config.Casino = {
    entrance = vector3(925.65, 46.05, 81.11),
    casinoName = 'WhellCo Casino & Resort'
}

-- Casino staff and interactive NPCs.
Config.NPCs = {
    host = {
        model = 's_m_m_highsec_01',
        coords = vector4(925.65, 46.05, 81.11, 180.0),
        label = 'Casino Host'
    },
    valet = {
        model = 's_m_y_xmech_02',
        coords = vector4(931.02, 43.42, 81.11, 250.0),
        label = 'Casino Valet'
    },
    dealer = {
        model = 's_m_m_casino_01',
        coords = vector4(950.51, 39.89, 72.64, 60.0),
        label = 'Table Games Dealer'
    },
    concierge = {
        model = 'ig_nervousron',
        coords = vector4(963.62, 57.03, 71.64, 270.0),
        label = 'Penthouse Concierge'
    }
}

-- Slot machines. Add or remove machines here; each has its own position.
Config.SlotMachines = {
    { id = 'slot_1', coords = vector3(936.10, 45.20, 71.00), heading = 90.0 },
    { id = 'slot_2', coords = vector3(937.20, 45.20, 71.00), heading = 90.0 },
    { id = 'slot_3', coords = vector3(938.30, 45.20, 71.00), heading = 90.0 },
    { id = 'slot_4', coords = vector3(939.40, 45.20, 71.00), heading = 90.0 },
    { id = 'slot_5', coords = vector3(940.50, 45.20, 71.00), heading = 90.0 },
    { id = 'slot_6', coords = vector3(941.60, 45.20, 71.00), heading = 90.0 },
    { id = 'slot_7', coords = vector3(942.70, 45.20, 71.00), heading = 90.0 },
    { id = 'slot_8', coords = vector3(943.80, 45.20, 71.00), heading = 90.0 }
}

Config.SlotSymbols = { 'CHERRY', 'LEMON', 'BELL', 'STAR', 'DIAMOND', 'SEVEN' }

-- Base win chance before membership multiplier. 0.25 means 25%.
Config.SlotBaseWinChance = 0.25

-- Slot payout multipliers for a winning spin.
Config.SlotPayouts = {
    CHERRY = 2,
    LEMON = 3,
    BELL = 4,
    STAR = 6,
    DIAMOND = 10,
    SEVEN = 20
}

Config.SlotBetOptions = { 100, 250, 500, 1000, 2500, 5000 }

-- Wheel spin prizes. Weight is relative probability.
Config.WheelPrizes = {
    { label = 'Nothing', amount = 0, weight = 30 },
    { label = 'Small Win', amount = 250, weight = 25 },
    { label = 'Cash Prize', amount = 750, weight = 18 },
    { label = 'Big Cash Prize', amount = 2500, weight = 12 },
    { label = 'Jackpot', amount = 10000, weight = 8 },
    { label = 'Mega Jackpot', amount = 50000, weight = 4 },
    { label = 'Grand Jackpot', amount = 250000, weight = 2 },
    { label = 'WhellCo Jackpot', amount = 1000000, weight = 1 }
}

Config.WheelSpinCost = 5000

-- Membership passes. Discounts and win-rate effects apply only inside the casino.
Config.Memberships = {
    free = {
        label = 'Free Membership',
        price = 0,
        winRateMultiplier = 1.0,
        discount = 0.0,
        garageSpaces = 0
    },
    standard = {
        label = 'Standard Membership',
        price = 250000,
        winRateMultiplier = 1.05,
        discount = 0.05,
        garageSpaces = 1
    },
    vip = {
        label = 'VIP Membership',
        price = 2500000,
        winRateMultiplier = 25.0,
        discount = 0.25,
        garageSpaces = 3
    }
}

-- Penthouse purchase and customisation.
Config.Penthouse = {
    price = 5000000,
    coords = vector3(-787.75, 339.15, 215.84),
    heading = 200.0
}

Config.PenthouseOptions = {
    lighting = {
        label = 'Lighting',
        options = {
            warm = { label = 'Warm Lighting', price = 250000 },
            modern = { label = 'Modern Lighting', price = 500000 },
            luxury = { label = 'Luxury Lighting', price = 1000000 }
        }
    },
    flooring = {
        label = 'Flooring',
        options = {
            marble = { label = 'Marble Flooring', price = 350000 },
            wood = { label = 'Wood Flooring', price = 400000 },
            premium = { label = 'Premium Flooring', price = 750000 }
        }
    },
    furniture = {
        label = 'Furniture',
        options = {
            standard = { label = 'Standard Furniture', price = 500000 },
            modern = { label = 'Modern Furniture', price = 1000000 },
            luxury = { label = 'Luxury Furniture', price = 2000000 }
        }
    },
    security = {
        label = 'Security',
        options = {
            standard = { label = 'Standard Security', price = 250000 },
            advanced = { label = 'Advanced Security', price = 750000 },
            elite = { label = 'Elite Security', price = 1500000 }
        }
    }
}

-- Purchasable garage spaces inside the casino.
Config.GarageSpaces = {
    standard = { label = 'Standard Garage Space', price = 1000000, vehicleLimit = 1 },
    deluxe = { label = 'Deluxe Garage Space', price = 2500000, vehicleLimit = 2 },
    vip = { label = 'VIP Garage Space', price = 5000000, vehicleLimit = 4 }
}
