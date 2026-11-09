QBCore.Functions.CreateCallback('whellco_computer:getPosts', function(source, cb)
    Computer.MySQL.query(
        [[SELECT p.id, p.citizenid, p.author, p.content, p.created_at,
                 COUNT(c.id) AS comment_count
          FROM whellco_computer_posts p
          LEFT JOIN whellco_computer_comments c ON c.post_id = p.id
          GROUP BY p.id, p.citizenid, p.author, p.content, p.created_at
          ORDER BY p.id DESC
          LIMIT 50]],
        {},
        function(posts)
            cb(posts or {})
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:createPost', function(source, cb, content)
    local Player = Computer.GetPlayer(source)

    if not Player or type(content) ~= 'string' then
        cb(false, 'Invalid post request.')
        return
    end

    content = Utils.Trim(content)

    local maxLength = Config.MaxPostLength or 500

    if #content == 0 or #content > maxLength then
        cb(false, ('Post must be between 1 and %d characters.'):format(maxLength))
        return
    end

    if Computer.Cooldowns.social.IsOnCooldown(source) then
        cb(false, 'Please wait before posting again.')
        return
    end

    Computer.Cooldowns.social.SetCooldown(source)

    Computer.MySQL.insert(
        'INSERT INTO whellco_computer_posts (citizenid, author, content) VALUES (?, ?, ?)',
        {
            Player.PlayerData.citizenid,
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            content
        },
        function(insertId)
            if insertId then
                cb(true, 'Post created.')
            else
                cb(false, 'Could not create post.')
            end
        end
    )
end)

QBCore.Functions.CreateCallback('whellco_computer:addComment', function(source, cb, postId, content)
    local Player = Computer.GetPlayer(source)
    local postIdNumber = Utils.ValidatePositiveInteger(postId, 1)

    if not Player or not postIdNumber or type(content) ~= 'string' then
        cb(false, 'Invalid comment request.')
        return
    end

    content = Utils.Trim(content)

    local maxLength = Config.MaxCommentLength or 300

    if #content == 0 or #content > maxLength then
        cb(false, ('Comment must be between 1 and %d characters.'):format(maxLength))
        return
    end

    if Computer.Cooldowns.social.IsOnCooldown(source) then
        cb(false, 'Please wait before commenting again.')
        return
    end

    Computer.Cooldowns.social.SetCooldown(source)

    Computer.MySQL.query(
        'SELECT id, citizenid FROM whellco_computer_posts WHERE id = ? LIMIT 1',
        { postIdNumber },
        function(posts)
            local post = posts and posts[1]

            if not post then
                cb(false, 'Post not found.')
                return
            end

            Computer.MySQL.insert(
                [[INSERT INTO whellco_computer_comments
                    (post_id, citizenid, author, content)
                  VALUES (?, ?, ?, ?)]],
                {
                    postIdNumber,
                    Player.PlayerData.citizenid,
                    Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    content
                },
                function(insertId)
                    if not insertId then
                        cb(false, 'Could not create comment.')
                        return
                    end

                    if post.citizenid ~= Player.PlayerData.citizenid then
                        Computer.MySQL.insert(
                            [[INSERT INTO whellco_computer_notifications
                                (citizenid, kind, reference_id, content)
                              VALUES (?, ?, ?, ?)]],
                            {
                                post.citizenid,
                                'comment',
                                postIdNumber,
                                ('%s commented on your post.'):format(Player.PlayerData.charinfo.firstname)
                            }
                        )
                    end

                    cb(true, 'Comment created.')
                end
            )
        end
    )
end)
