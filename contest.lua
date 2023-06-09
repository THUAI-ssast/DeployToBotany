period = 3600 * 6 -- 6 小时一场比赛

count_max = period / 2 -- 文档里说每隔2秒触发一次 on_timer

local count = period / 2 - 1 -- 为了在更新赛事脚本后立即触发 on_timer 开始比赛
local su_id = get_id('su')

function on_submission(all, from)
    print('Submission', from)
    -- -- 自己和自己比赛
    -- create_match(from, from)
end

function on_timer(all)
    count = count + 1
    -- 不知道为什么，这里插入了语句就不能正常运行
    if count < count_max then
        return
    end
    count = 0
    print('Timer')
    print('Superuser has ID ' .. tostring(su_id))
    print('Creating matches for contest #3')
    print('Number of participants with delegates ' .. tostring(#all))

    -- 先跑一圈自己和自己比赛，曲线救国清空rating与performance
    for i = 1, #all do
        if all[i].performance ~= "Win: 0, Draw: 0, Lose: 0" then
            create_match(all[i].id, all[i].id) 
        end
    end

    -- 单循环赛. 不得含自己和自己比赛
    for i = 1, #all do
        for j = i + 1, #all do
            create_match(all[i].id, all[j].id)
        end
    end
end

function on_manual(all, arg)
    print('Manual', arg)
end

function update_stats(report, par)
    -- 自己和自己比赛时，清空rating。曲线救国
    if par[1].id == par[2].id then
        par[1].rating = 0
        par[2].rating = 0
        par[1].performance = "Win: 0, Draw: 0, Lose: 0"
        par[2].performance = "Win: 0, Draw: 0, Lose: 0"
        return
    end

    -- 忽略第一个 { 前的内容
    local report_start_idx = report:find("{")
    if not report_start_idx then return end
  	report = report:sub(report_start_idx)

  	print(report)

    local start_idx = report:find("%[") -- 找到第一个 [
    local comma_idx = report:find(",", start_idx) -- 找到第一个 ,
    local end_idx = report:find("%]", comma_idx) -- 找到第一个 ]

    local score_a = tonumber(report:sub(start_idx + 1, comma_idx - 1)) -- 取出 A 队分数
    local score_b = tonumber(report:sub(comma_idx + 1, end_idx - 1)) -- 取出 B 队分数

    -- 从performance中取出胜平负的次数
    local win_1 = tonumber(par[1].performance:match("Win: (%d+)"))
    local win_2 = tonumber(par[2].performance:match("Win: (%d+)"))
    local draw_1 = tonumber(par[1].performance:match("Draw: (%d+)"))
    local draw_2 = tonumber(par[2].performance:match("Draw: (%d+)"))
    local lose_1 = tonumber(par[1].performance:match("Lose: (%d+)"))
    local lose_2 = tonumber(par[2].performance:match("Lose: (%d+)"))

    -- 胜+1，平+0，败-1
    if score_a > score_b then
        par[1].rating = par[1].rating + 1
        win_1 = win_1 + 1
        par[2].rating = par[2].rating - 1
        lose_2 = lose_2 + 1
    elseif score_a < score_b then
        par[1].rating = par[1].rating - 1
        lose_1 = lose_1 + 1
        par[2].rating = par[2].rating + 1
        win_2 = win_2 + 1
    else
        draw_1 = draw_1 + 1
        draw_2 = draw_2 + 1
    end

    -- 更新performance
    par[1].performance = "Win: " .. tostring(win_1) .. ", Draw: " .. tostring(draw_1) .. ", Lose: " .. tostring(lose_1)
    par[2].performance = "Win: " .. tostring(win_2) .. ", Draw: " .. tostring(draw_2) .. ", Lose: " .. tostring(lose_2)
end
