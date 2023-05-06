local count = 2
local su_id = get_id('su')

function on_submission(all, from)
    print('Submission', from)
    -- 自己和自己比赛
    create_match(from, from)
end

function on_timer(all)
    count = count + 1
    -- 不知道为什么，这里插入了语句就不能正常运行
    if count < 3600 * 2 then return end
    count = 0
    print('Timer')
    print('Superuser has ID ' .. tostring(su_id))
    print('Creating matches for contest #3')
    print('Number of participants with delegates ' .. tostring(#all))

    for i = 1, #all do
        all[i].rating = 0
    end

    -- 单循环赛
    for i = 1, #all do
        for j = i + 1, #all do
            create_match(all[i].id, all[j].id)
        end
        print(string.format('Contestant %s (%d), rating %d, performance "%s"',
            all[i].handle, all[i].id, all[i].rating, all[i].performance))
    end
end

function on_manual(all, arg)
    print('Manual', arg)
end

function update_stats(report, par)
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

    -- 胜+2，平+1，败+0
    if score_a > score_b then
        par[1].rating = par[1].rating + 2
    elseif score_a < score_b then
        par[2].rating = par[2].rating + 2
    else
        for i = 1, #par do
            par[i].rating = par[i].rating + 1
        end
    end
end