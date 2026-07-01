local Fonts = {}

function Fonts.setGlobalFont(langCode, size)
  local fontSize = size or 14
  local font
  local candidates = {}
  if langCode == "zh" then
    table.insert(candidates, "assets/fonts/NotoSansCJK-VF.ttc")
    table.insert(candidates, "/usr/share/fonts/google-noto-sans-cjk-vf-fonts/NotoSansCJK-VF.ttc")
  end
  table.insert(candidates, fontSize)

  for _, candidate in ipairs(candidates) do
    local ok, result = pcall(love.graphics.newFont, candidate, fontSize)
    if ok and result then
      font = result
      break
    end
  end

  if not font then
    font = love.graphics.newFont(fontSize)
  end

  love.graphics.setFont(font)
  return font
end

return Fonts
