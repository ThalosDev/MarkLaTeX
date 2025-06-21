function Header(el)
    if el.level == 2 then
      return pandoc.RawBlock("latex", "\\chapter{" .. pandoc.utils.stringify(el.content) .. "}")
    elseif el.level == 3 then
      return pandoc.RawBlock("latex", "\\section{" .. pandoc.utils.stringify(el.content) .. "}")
    end
  end  