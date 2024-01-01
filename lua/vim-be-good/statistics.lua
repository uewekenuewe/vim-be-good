local log = require("vim-be-good.log")
local types = require("vim-be-good.types")

local default_config =  {
    plugin = 'VimBeGoodStats',
    save_statistics = vim.g["vim_be_good_save_statistics"] or false,
    save_highscore = vim.g["vim_be_good_save_highscore"] or false,
}

local statistics = {}

function statistics:new(config)
    config = config or {}
    config = vim.tbl_deep_extend("force", default_config, config)

    local stats = {
        file = string.format('%s/%s.log', vim.api.nvim_call_function('stdpath', {'data'}), config.plugin),
        saveStats = config.save_statistics,
        saveHighscore = config.save_highscore
    }
    self.__index = self
    return setmetatable(stats, self)
end

function statistics:loadHighscore()
    log.info("save highscore?",self.saveHighscore)
    if self.saveHighscore then
        local out = io.open(self.file, 'r')

        local fLines = {}
        for l in out:lines() do
            table.insert(fLines, l)
        end

        out:close()

        local highscoreTable = {}
        highscoreTable= {}
        for k, v in string.gmatch(fLines[1], "(%w+{*):(%d+%.%d+)") do
            highscoreTable[k] = v
        end
        return highscoreTable
    end
end

function statistics:logHighscore(average,gameType)
    if self.saveHighscore then
        local out = io.open(self.file, 'r')

        local fLines = {}
        for l in out:lines() do
            table.insert(fLines, l)
        end

        out:close()

        -- TODO if gametype is no in list could cause a crash
        -- this inits the line if its not present but does not account for new gameTypes
        if string.find(fLines[1],":") == nil then
            local highscoreLine = ""
            for idx = 1, #types.games - 1 do
                highscoreLine = highscoreLine .. types.games[idx] .. ":10.00,"
            end
            table.insert(fLines,1,highscoreLine)
        end
        --end

        local currHighscore = (string.match(fLines[1],gameType..":".."(%d+%.%d%d)"))
        if tonumber(currHighscore) > average then
            fLines[1] = string.gsub(fLines[1],gameType..":"..currHighscore,gameType..":"..string.format("%.2f",average))
        end

        local out = io.open(self.file, 'w')
        for _, l in ipairs(fLines) do
            out:write(l.."\n")
        end
        out:close()
    end
end

function statistics:logResult(result)
    if self.saveStats then
        local fp = io.open(self.file, "a")
        local str = string.format("%s,%s,%s,%s,%s,%f\n",
        result.timestamp, result.roundNum, result.difficulty, result.roundName, result.success, result.time)
        fp:write(str)
        fp:close()
    end
end

return statistics
