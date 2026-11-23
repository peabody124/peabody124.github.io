-- Resolves `.archive-video` blocks, inline Vimeo links (when mapped to YouTube),
-- and `.archive-instagram` blocks using project-root `video-map.yml`.

local video_map = nil

local function find_video_map()
  local candidates = {
    "video-map.yml",
    "../video-map.yml",
    "../../video-map.yml",
    "../../../video-map.yml",
  }
  if quarto and quarto.project and quarto.project.directory then
    table.insert(candidates, 1, quarto.project.directory .. "/video-map.yml")
  end
  for _, path in ipairs(candidates) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      return content
    end
  end
  return nil
end

local function load_video_map()
  if video_map ~= nil then
    return video_map
  end
  video_map = {}
  local raw = find_video_map()
  if not raw then
    return video_map
  end
  local parsed = pandoc.read("---\n" .. raw .. "\n---\n", "markdown")
  local entries = parsed.meta.videos
  if not entries then
    return video_map
  end
  for k, v in pairs(entries) do
    local key = tostring(k)
    local rec = {}
    if type(v) == "table" then
      if v.status then rec.status = pandoc.utils.stringify(v.status) end
      if v.youtube then rec.youtube = pandoc.utils.stringify(v.youtube) end
      if v.title then rec.title = pandoc.utils.stringify(v.title) end
    end
    video_map[key] = rec
  end
  return video_map
end

local function extract_youtube_id(url)
  if not url or url == "" then return nil end
  local id = url:match("youtu%.be/([%w_%-]+)")
    or url:match("[?&]v=([%w_%-]+)")
    or url:match("youtube%.com/embed/([%w_%-]+)")
    or url:match("youtube%.com/shorts/([%w_%-]+)")
  return id
end

local function html_escape(s)
  if not s then return "" end
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

function Div(el)
  if el.classes:includes("archive-video") then
    local map = load_video_map()
    local vid = el.attributes["video-id"] or ""
    local source = el.attributes["source"] or "vimeo"
    local fallback_title = el.attributes["title"] or ""
    local rec = map[vid] or {}
    local title = (rec.title and rec.title ~= "") and rec.title or fallback_title
    local yt_url = rec.youtube or ""
    local yt_id = extract_youtube_id(yt_url)

    if yt_id then
      local caption_html = title ~= "" and ('<p class="video-caption">' .. html_escape(title) .. '</p>') or ""
      local html = string.format(
        '<figure class="archive-video-embed">' ..
        '<div class="ratio ratio-16x9">' ..
        '<iframe src="https://www.youtube.com/embed/%s" title="%s" ' ..
        'allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" ' ..
        'allowfullscreen loading="lazy"></iframe></div>%s</figure>',
        html_escape(yt_id),
        html_escape(title ~= "" and title or ("YouTube video " .. yt_id)),
        caption_html
      )
      return pandoc.RawBlock("html", html)
    elseif source == "vimeo" and rec.status == "live" then
      local caption_html = title ~= "" and ('<p class="video-caption">' .. html_escape(title) .. '</p>') or ""
      local html = string.format(
        '<figure class="archive-video-embed">' ..
        '<div class="ratio ratio-16x9">' ..
        '<iframe src="https://player.vimeo.com/video/%s" title="%s" ' ..
        'allow="autoplay; fullscreen; picture-in-picture" ' ..
        'allowfullscreen loading="lazy"></iframe></div>%s</figure>',
        html_escape(vid),
        html_escape(title ~= "" and title or ("Vimeo video " .. vid)),
        caption_html
      )
      return pandoc.RawBlock("html", html)
    else
      local label = title ~= "" and ("<strong>" .. html_escape(title) .. "</strong> — ") or ""
      local detail
      if source == "mp4" then
        detail = string.format(
          'Archived local video (<code>%s</code>) — pending YouTube upload.',
          html_escape(vid)
        )
      else
        detail = string.format(
          'Archived Vimeo video (<a href="https://vimeo.com/%s" rel="noopener">vimeo.com/%s</a>) — no longer hosted on Vimeo; pending YouTube re-upload.',
          html_escape(vid), html_escape(vid)
        )
      end
      local html = '<div class="archive-media-placeholder" role="note">' .. label .. detail .. '</div>'
      return pandoc.RawBlock("html", html)
    end
  end

  if el.classes:includes("archive-instagram") then
    local url = el.attributes["url"] or ""
    local text = pandoc.utils.stringify(el)
    local html = string.format(
      '<div class="archive-media-placeholder archive-instagram-card" role="note">' ..
      '<strong>Instagram Post</strong> — %s ' ..
      '(<a href="%s" rel="noopener">view original link</a>)' ..
      '</div>',
      html_escape(text),
      html_escape(url)
    )
    return pandoc.RawBlock("html", html)
  end

  return nil
end

function Link(el)
  -- If an inline Vimeo link has been mapped to YouTube, upgrade its URL automatically
  local vid = el.target:match("vimeo%.com/video/(%d+)") or el.target:match("vimeo%.com/(%d+)")
  if vid then
    local map = load_video_map()
    local rec = map[vid]
    if rec and rec.youtube and rec.youtube ~= "" then
      el.target = rec.youtube
      return el
    end
  end
  return nil
end
