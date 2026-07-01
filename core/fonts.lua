local Fonts = {}

function Fonts.setGlobalFont(langCode, size)
  local fontSize = size or 14
  local font

  local function tryLoad(path)
    local ok, result = pcall(love.graphics.newFont, path, fontSize)
    if ok and result then return result end
    return nil
  end

  if langCode == "zh" then
    local candidates = {
      "assets/fonts/NotoSansCJK-VF.ttc",
      "assets/fonts/NotoSansSC-Regular.otf",
      "assets/fonts/wqy-microhei.ttc",
      "C:/Windows/Fonts/msyh.ttc",
      "C:/Windows/Fonts/msyhbd.ttc",
      "C:/Windows/Fonts/simhei.ttf",
      "C:/Windows/Fonts/simsun.ttc",
      "C:/Windows/Fonts/meiryo.ttc",
      "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",
      "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
      "/usr/share/fonts/google-noto-sans-cjk-vf-fonts/NotoSansCJK-VF.ttc",
      "/System/Library/Fonts/PingFang.ttc",
      "/System/Library/Fonts/STHeiti Light.ttc",
    }
    for _, path in ipairs(candidates) do
      font = tryLoad(path)
      if font then break end
    end
  end

  if not font then
    font = love.graphics.newFont(fontSize)
  end

  love.graphics.setFont(font)
  return font
end

return Fonts
