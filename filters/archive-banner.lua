-- Prepends a clear archival notice banner to posts with `archive: true`
function Pandoc(doc)
  local meta = doc.meta
  if not meta.archive then
    return doc
  end

  local source = "Build and Crash (Blogspot, 2010–2017)"
  if meta["archive-source"] then
    source = pandoc.utils.stringify(meta["archive-source"])
  end

  local orig_link = ""
  if meta.original_url then
    local url = pandoc.utils.stringify(meta.original_url)
    if url ~= "" then
      orig_link = string.format(' (<a href="%s" rel="noopener">original post</a>)', url)
    end
  end

  local html = string.format(
    '<div class="archive-banner" role="note">' ..
    '<strong>Archived Post</strong> — Originally published on <em>%s</em>%s. ' ..
    'Some older external videos or links may no longer be available.' ..
    '</div>',
    source,
    orig_link
  )

  table.insert(doc.blocks, 1, pandoc.RawBlock("html", html))
  return doc
end
