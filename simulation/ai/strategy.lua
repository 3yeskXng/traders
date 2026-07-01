local Strategy = {}

function Strategy.new(name)
  return {
    name = name,
    execute = function(trader, world)
    end,
  }
end

return Strategy
