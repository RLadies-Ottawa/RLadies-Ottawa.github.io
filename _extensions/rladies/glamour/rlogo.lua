local rlogo_counter = 0

local paths = {
  'M301.26,98.29c0,49.95-37.39,91.27-85.64,97.5v-47.9c22.13-5.63,38.52-25.75,38.52-49.6,0-28.2-22.98-51.18-51.18-51.18h-74.78v15.01h-47.05V.03C109.64.05,181.81-.05,209.33.03c51.24,3.3,91.93,46.2,91.93,98.26Z',
  'M301.26,230.61v47.12h-44.47c-46.08,0-84.82-31.85-95.43-74.78h50.04c8.5,16.4,25.62,27.66,45.38,27.66h44.47Z',
  'M128.19,201.56v76.17h-47.05v-81.11H0v-47.12h76.13c5.38,26.06,26,46.67,52.06,52.06Z',
  'M209.33,149.5v46.93c-3.4.5-64.91.04-68.58.19-31.98-.54-58-25.9-59.61-57.6v-70.59h47.05v81.07h81.14Z'
}

local function render_paths()
  local result = {}
  for _, d in ipairs(paths) do
    table.insert(result, '    <path d="' .. d .. '"/>')
  end
  return table.concat(result, '\n')
end

function Div(el)
  if not el.classes:includes('rlogo') then
    return nil
  end

  if not quarto.doc.is_format('html') then
    return nil
  end

  rlogo_counter = rlogo_counter + 1
  local id = 'rlogo-' .. rlogo_counter

  local image = el.attributes['image'] or nil
  local color = el.attributes['color'] or '#881ef9'
  local width = el.attributes['width'] or '300px'
  local alt = el.attributes['alt'] or 'RLadies+ submark'
  local shadow = el.attributes['shadow'] or 'true'

  local shadow_style = ''
  if shadow == 'true' then
    shadow_style = 'filter:drop-shadow(0 20px 60px rgba(136,30,249,0.2)) drop-shadow(0 8px 24px rgba(0,0,0,0.1));'
  end

  local svg_parts = {}
  table.insert(svg_parts, '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"')
  table.insert(svg_parts, '     viewBox="0 0 301.26 277.73" role="img" aria-label="' .. alt .. '"')
  table.insert(svg_parts, '     style="width:' .. width .. ';height:auto;' .. shadow_style .. '">')

  if image then
    table.insert(svg_parts, '  <defs>')
    table.insert(svg_parts, '    <pattern id="' .. id .. '-pat" patternUnits="userSpaceOnUse" width="301.26" height="277.73">')
    table.insert(svg_parts, '      <image href="' .. image .. '" xlink:href="' .. image .. '" width="301.26" height="277.73" preserveAspectRatio="xMidYMid slice"/>')
    table.insert(svg_parts, '    </pattern>')
    table.insert(svg_parts, '  </defs>')
    table.insert(svg_parts, '  <g fill="url(#' .. id .. '-pat)">')
  else
    table.insert(svg_parts, '  <g fill="' .. color .. '">')
  end

  table.insert(svg_parts, render_paths())
  table.insert(svg_parts, '  </g>')
  table.insert(svg_parts, '</svg>')

  local html = '<div class="rlogo-frame">\n' .. table.concat(svg_parts, '\n') .. '\n</div>'
  return pandoc.RawBlock('html', html)
end
