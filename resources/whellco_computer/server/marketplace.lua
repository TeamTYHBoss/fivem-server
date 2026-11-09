local MAX_LISTING_QUANTITY = 100
local MAX_LISTING_PRICE = 1000000

local function getVerifiedMetadata(Player, itemName)
    local item = Player.Functions.GetItemByName(itemName)

    if not item or type(item.metadata) ~= 'table' then
        return {}
    end

    return item.metadata
end

QBCore.Functions.CreateCallback('whellco_computer:getMarketplace', function(source, cb)
    Computer.MySQL.query(
        [[SELECT id, seller, item, quantity, metadata, price, status, buyer, created_at
          FROM whellco_computer_listings
          WHERE status = 'active'
          ORDER BY id DESC
          LIMIT 50]],
        {},
        function(listings)
            local result = {}

            for _, listing in ipairs(listings or {}) do
                result[#result + 1] = {
                    id = listing.id,
                    seller = listing.seller,
                    item = listing.item,
                    quantity = listing.quantity,
                    metadata = Utils.SafeJsonDecode(listing.metadata),
                    price = listing.price,
                    status = listing.status,
                    buyer = listing.buyer,
                    createdAt = listing.created_at
                }
            end

            cb(result)
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:createListing', function(source, cb, data)
    local Player = Computer.GetPlayer(source)
    local itemName = data and data.itemName
    local quantity = data and data.quantity
    local price = data and data.price

    if not Player or type(itemName) ~= 'string' then
        cb(false, 'Invalid listing request.')
        return
    end

    if Computer.Cooldowns.marketplace.IsOnCooldown(source) then
        cb(false, 'Please wait before creating another listing.')
        return
    end

    local listingQuantity = Utils.ValidatePositiveInteger(quantity, 1, MAX_LISTING_QUANTITY)
    local listingPrice = Utils.ValidatePositiveInteger(price, 1, MAX_LISTING_PRICE)

    if not listingQuantity or not listingPrice then
        cb(false, 'Invalid listing quantity or price.')
        return
    end

    local inventoryItem = Player.Functions.GetItemByName(itemName)

    if not inventoryItem or (inventoryItem.amount or 0) < listingQuantity then
        cb(false, 'You do not have enough of that item.')
        return
    end

    Computer.Cooldowns.marketplace.SetCooldown(source)

    local metadata = Utils.SafeJsonEncode(getVerifiedMetadata(Player, itemName))

    Computer.MySQL.insert(
        [[INSERT INTO whellco_computer_listings
            (seller, item, quantity, metadata, price, status)
          VALUES (?, ?, ?, ?, ?, ?)]],
        {
            Player.PlayerData.citizenid,
            itemName,
            listingQuantity,
            metadata,
            listingPrice,
            'active'
        },
        function(insertId)
            if insertId then
                cb(true, 'Listing created.')
            else
                cb(false, 'Could not create listing.')
            end
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:cancelListing', function(source, cb, listingId)
    local Player = Computer.GetPlayer(source)
    local listingIdNumber = Utils.ValidatePositiveInteger(listingId, 1)

    if not Player or not listingIdNumber then
        cb(false, 'Invalid listing request.')
        return
    end

    if Computer.Cooldowns.marketplace.IsOnCooldown(source) then
        cb(false, 'Please wait before making another request.')
        return
    end

    Computer.Cooldowns.marketplace.SetCooldown(source)

    Computer.MySQL.update(
        [[UPDATE whellco_computer_listings
          SET status = 'cancelled'
          WHERE id = ? AND seller = ? AND status = 'active']],
        {
            listingIdNumber,
            Player.PlayerData.citizenid
        },
        function(affectedRows)
            if affectedRows and affectedRows > 0 then
                cb(true, 'Listing cancelled.')
            else
                cb(false, 'Listing could not be cancelled.')
            end
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:buyListing', function(source, cb, listingId)
    local Player = Computer.GetPlayer(source)
    local listingIdNumber = Utils.ValidatePositiveInteger(listingId, 1)

    if not Player or not listingIdNumber then
        cb(false, 'Invalid listing request.')
        return
    end

    if Computer.Cooldowns.marketplace.IsOnCooldown(source) then
        cb(false, 'Please wait before making another purchase.')
        return
    end

    Computer.Cooldowns.marketplace.SetCooldown(source)

    Computer.MySQL.query(
        [[SELECT id, seller, item, quantity, metadata, price
          FROM whellco_computer_listings
          WHERE id = ? AND status = 'active'
          LIMIT 1]],
        { listingIdNumber },
        function(listings)
            local listing = listings and listings[1]

            if not listing then
                cb(false, 'That listing is no longer available.')
                return
            end

            if listing.seller == Player.PlayerData.citizenid then
                cb(false, 'You cannot buy your own listing.')
                return
            end

            if (Player.PlayerData.money.bank or 0) < listing.price then
                cb(false, 'You do not have enough money in your bank account.')
                return
            end

            Computer.MySQL.update(
                [[UPDATE whellco_computer_listings
                  SET status = ?, buyer = ?
                  WHERE id = ? AND status = 'active']],
                {
                    'sold',
                    Player.PlayerData.citizenid,
                    listing.id
                },
                function(affectedRows)
                    if not affectedRows or affectedRows ~= 1 then
                        cb(false, 'That listing is no longer available.')
                        return
                    end

                    if not Player.Functions.AddItem(listing.item, listing.quantity) then
                        Computer.MySQL.update(
                            [[UPDATE whellco_computer_listings
                              SET status = ?, buyer = NULL
                              WHERE id = ?]],
                            {
                                'active',
                                listing.id
                            }
                        )

                        cb(false, 'Your inventory is full.')
                        return
                    end

                    if not Player.Functions.RemoveMoney('bank', listing.price, 'computer-marketplace-purchase') then
                        Player.Functions.RemoveItem(listing.item, listing.quantity)

                        Computer.MySQL.update(
                            [[UPDATE whellco_computer_listings
                              SET status = ?, buyer = NULL
                              WHERE id = ?]],
                            {
                                'active',
                                listing.id
                            }
                        )

                        cb(false, 'Purchase failed.')
                        return
                    end

                    local seller = Utils.GetPlayerByCitizenId(listing.seller)

                    if seller then
                        seller.Functions.AddMoney('bank', listing.price, 'computer-marketplace-sale')

                        Computer.Notify(
                            seller.PlayerData.source,
                            ('Sold %dx %s for %s.'):format(
                                listing.quantity,
                                listing.item,
                                Utils.FormatMoney(listing.price)
                            ),
                            'success'
                        )
                    end

                    cb(true, ('Purchased %dx %s.'):format(listing.quantity, listing.item))
                end
            )
        end
    )
end)
