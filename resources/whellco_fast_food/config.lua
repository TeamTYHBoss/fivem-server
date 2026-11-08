Config = {}

Config.Debug = false

Config.Restaurants = {
    {
        id = 'burger_barn',
        label = 'Burger Barn',
        coords = vector3(-1193.0, -899.0, 14.0),
        heading = 210.0
    },
    {
        id = 'cluckin_good',
        label = 'Cluckin Good',
        coords = vector3(-355.0, -132.0, 39.0),
        heading = 270.0
    },
    {
        id = 'taco_bout_it',
        label = 'Taco Bout It',
        coords = vector3(292.0, -1338.0, 30.0),
        heading = 90.0
    },
    {
        id = 'pita_pan',
        label = 'Pita Pan',
        coords = vector3(-719.0, -916.0, 19.0),
        heading = 180.0
    },
    {
        id = 'noodle_ood',
        label = 'Noodle Ood',
        coords = vector3(-1834.0, -1193.0, 13.0),
        heading = 315.0
    },
    {
        id = 'pizza_over_it',
        label = 'Pizza Over It',
        coords = vector3(806.0, -980.0, 26.0),
        heading = 90.0
    },
    {
        id = 'sub_lime',
        label = 'Sub-lime',
        coords = vector3(24.0, -1347.0, 29.0),
        heading = 270.0
    },
    {
        id = 'fry_day',
        label = 'Fry-Days',
        coords = vector3(-1300.0, -838.0, 16.0),
        heading = 180.0
    },
    {
        id = 'wrap_star',
        label = 'Wrap Star',
        coords = vector3(-551.0, -214.0, 38.0),
        heading = 45.0
    },
    {
        id = 'donut_worry',
        label = 'Donut Worry',
        coords = vector3(195.0, -924.0, 30.0),
        heading = 90.0
    }
}

Config.Menu = {
    burger = {
        label = 'Burger',
        price = 25,
        hunger = 25,
        restaurants = {'burger_barn', 'fry_day'}
    },
    fries = {
        label = 'Fries',
        price = 10,
        hunger = 10,
        restaurants = {'burger_barn', 'fry_day'}
    },
    chicken = {
        label = 'Fried Chicken',
        price = 30,
        hunger = 30,
        restaurants = {'cluckin_good'}
    },
    taco = {
        label = 'Taco',
        price = 20,
        hunger = 20,
        restaurants = {'taco_bout_it'}
    },
    pita = {
        label = 'Pita Wrap',
        price = 22,
        hunger = 22,
        restaurants = {'pita_pan', 'wrap_star'}
    },
    noodles = {
        label = 'Noodles',
        price = 28,
        hunger = 28,
        restaurants = {'noodle_ood'}
    },
    pizza = {
        label = 'Pizza Slice',
        price = 18,
        hunger = 18,
        restaurants = {'pizza_over_it'}
    },
    sub = {
        label = 'Sub Sandwich',
        price = 26,
        hunger = 26,
        restaurants = {'sub_lime'}
    },
    donut = {
        label = 'Donut',
        price = 8,
        hunger = 8,
        restaurants = {'donut_worry'}
    },
    soda = {
        label = 'Soda',
        price = 5,
        hunger = 5,
        restaurants = {'burger_barn', 'cluckin_good', 'taco_bout_it', 'pita_pan', 'noodle_ood', 'pizza_over_it', 'sub_lime', 'fry_day', 'wrap_star', 'donut_worry'}
    }
}

Config.AdminJobs = {
    admin = true,
    manager = true
}