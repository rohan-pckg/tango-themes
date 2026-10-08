-- tango.lua -- Custom Neovim colorscheme ported directly from the Emacs
-- tangotango theme (Tango Palette). See ../docs/palette.md for origin,
-- palette notes, and Emacs -> Neovim face mapping decisions.
--
-- Load with `:colorscheme tango` or `vim.cmd.colorscheme("tango")`.
-- Dark background only; enables true color (`termguicolors`) automatically.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
-- The palette below is expressed entirely in 24-bit hex, so true color is a
-- hard requirement rather than a preference. Without this, every hex value is
-- silently dropped and the scheme falls back to the terminal's colors.
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "tango"

-- ---------------------------------------------------------------------------
-- 1. Centralized palette.
-- Exact hex values taken from ~/Downloads/tangotango-theme.el wherever the
-- Emacs file specifies one. X11 named colors used by that file are resolved
-- to their standard hex equivalents and marked with (X11) below.
-- ---------------------------------------------------------------------------
local c = {
  -- Core editor tones (Emacs `default`, `fringe`, `org-block-*`)
  -- Darkened off the Emacs originals (bg #2e3434) to a neutral #1e1e1e base
  -- per user request; bg_dark/bg_darker/bg_cursorln keep the same relative
  -- depth offsets the Emacs theme had (floats darker, cursor line lighter).
  bg           = "#1e1e1e", -- default background
  bg_dark      = "#171717", -- org-block background (floats, popups)
  bg_darker    = "#141414", -- mode-line background / cursor fg
  bg_cursorln  = "#282828", -- derived: bg lightened for CursorLine
  bg_sel       = "#483D8B", -- region = "dark slate blue" (X11)

  fg           = "#eeeeec", -- default foreground
  fg_dim       = "#bbbbbc", -- mode-line / org-block foreground
  grey         = "#888a85", -- comments, context text
  grey_dark    = "#5f625d", -- mode-line-inactive bg, ediff bg (nudged up for contrast on darker bg)
  grey_light   = "#babdb6", -- tango aluminium (borders, delimiters)

  -- Tango accents (Emacs font-lock / search / paren faces)
  yellow       = "#edd400", -- functions, custom tags
  yellow_light = "#fce94f", -- cursor background
  orange       = "#f57900", -- warnings, isearch bg, diff-removed
  orange_light = "#e9b96e", -- lazy-highlight / match bg
  green        = "#8ae234", -- constants, types, diff-added
  green_dark   = "#6ac214", -- org-level-2, term green
  green_bright = "#73d216", -- show-paren-match bg
  blue         = "#729fcf", -- builtins, keywords, links-visited info
  blue_dark    = "#3465a4", -- tango sky-blue dark (selection328+)
  blue_darker  = "#204a87", -- tango sky-blue darkest
  blue_named   = "#1E90FF", -- "dodger blue" (X11): links, org-level-1
  plum         = "#ad7fa8", -- strings, paren-mismatch bg
  red          = "#ef2929", -- term red / scarlet
  tomato       = "#FF6347", -- variable names (X11 "tomato")

  -- Supporting tones
  ink          = "#2e3436", -- isearch / match foreground (near-bg dark)
  cyan_light   = "#34e2e2", -- tango light sky-blue accent for UI killed
  magenta      = "#CD00CD", -- "magenta3" (X11): org-date/footnote
  brown        = "#8B4513", -- org-special-keyword "brown" (X11 saddle)
  gold         = "#FFD700", -- eshell-ls-special "Gold" (X11)
  coral        = "#FF7F50", -- eshell-ls-executable "Coral" (X11)
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function link(group, target)
  vim.api.nvim_set_hl(0, group, { link = target })
end

-- ---------------------------------------------------------------------------
-- 2. Core UI
-- ---------------------------------------------------------------------------
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalNC", { fg = c.fg, bg = c.bg }) -- explicit: inactive windows keep the same bg, they are only dimmed by the statusline
hl("NormalFloat", { fg = c.fg, bg = c.bg_dark })
hl("FloatBorder", { fg = c.grey, bg = c.bg_dark })
hl("FloatTitle", { fg = c.yellow, bg = c.bg_dark, bold = true })
hl("FloatFooter", { fg = c.grey, bg = c.bg_dark })

hl("Cursor", { fg = c.bg_darker, bg = c.yellow_light })
hl("lCursor", { fg = c.bg_darker, bg = c.yellow_light })
hl("CursorIM", { fg = c.bg_darker, bg = c.yellow_light })
hl("TermCursor", { fg = c.bg_darker, bg = c.yellow_light }) -- :terminal windows use a separate group from Cursor
hl("TermCursorNC", { fg = c.bg_darker, bg = c.yellow_light })
hl("CursorLine", { bg = c.bg_cursorln })
hl("CursorColumn", { bg = c.bg_cursorln })
hl("ColorColumn", { bg = c.bg_cursorln })
hl("SignColumn", { fg = c.grey, bg = c.bg })
hl("FoldColumn", { fg = c.grey, bg = c.bg })
hl("LineNr", { fg = c.grey, bg = c.bg })
hl("CursorLineNr", { fg = c.yellow, bg = c.bg_cursorln, bold = true })
hl("CursorLineSign", { fg = c.grey, bg = c.bg_cursorln })
hl("CursorLineFold", { fg = c.grey, bg = c.bg_cursorln })

hl("StatusLine", { fg = c.fg_dim, bg = c.bg_darker })
hl("StatusLineNC", { fg = c.fg_dim, bg = c.grey_dark })
link("StatusLineTerm", "StatusLine")
link("StatusLineTermNC", "StatusLineNC")
hl("WinSeparator", { fg = c.grey_dark, bg = c.bg })
link("VertSplit", "WinSeparator")
hl("TabLine", { fg = c.fg_dim, bg = c.bg_darker })
hl("TabLineFill", { fg = c.fg_dim, bg = c.bg_darker })
hl("TabLineSel", { fg = c.yellow, bg = c.bg, bold = true })
hl("WinBar", { fg = c.fg_dim, bg = c.bg })
hl("WinBarNC", { fg = c.grey, bg = c.bg })

hl("Visual", { fg = c.fg, bg = c.bg_sel })
link("VisualNOS", "Visual")
hl("Search", { fg = c.ink, bg = c.orange_light }) -- lazy-highlight
hl("IncSearch", { fg = c.ink, bg = c.orange })    -- isearch
hl("CurSearch", { fg = c.ink, bg = c.orange, bold = true })
hl("Substitute", { fg = c.ink, bg = c.orange })
hl("MatchParen", { fg = c.ink, bg = c.green_bright, bold = true })

hl("Pmenu", { fg = c.fg, bg = c.bg_dark })
hl("PmenuSel", { fg = c.fg, bg = c.blue_dark, bold = true })
hl("PmenuSbar", { bg = c.grey_dark })
hl("PmenuThumb", { bg = c.grey })
hl("PmenuKind", { fg = c.blue, bg = c.bg_dark })
hl("PmenuKindSel", { fg = c.fg, bg = c.blue_dark })
hl("PmenuExtra", { fg = c.grey, bg = c.bg_dark })
hl("PmenuExtraSel", { fg = c.fg_dim, bg = c.blue_dark })
hl("CmpNormal", { fg = c.fg, bg = c.bg }) -- referenced by nvim-cmp winhighlight
hl("WildMenu", { fg = c.fg, bg = c.blue_dark, bold = true })

hl("Folded", { fg = c.blue, bg = c.bg_dark })
hl("Conceal", { fg = c.grey_dark }) -- hidden markup (:h conceal); grey_dark keeps it out of the way of code
hl("QuickFixLine", { fg = c.fg, bg = c.blue_dark, bold = true }) -- same treatment as TelescopeSelection / PmenuSel
hl("Directory", { fg = c.blue, bold = true })
hl("Title", { fg = c.yellow, bold = true })
hl("Question", { fg = c.yellow, bold = true })
hl("MoreMsg", { fg = c.green, bold = true })
hl("ModeMsg", { fg = c.fg, bold = true })
hl("MsgArea", { fg = c.fg }) -- explicit, so plugins that set hl groups cannot pull in a stale default
hl("WarningMsg", { fg = c.orange, bold = true }) -- font-lock-warning-face
hl("ErrorMsg", { fg = c.red, bold = true })
hl("NonText", { fg = c.grey_dark })
hl("SpecialKey", { fg = c.grey_dark })
hl("Whitespace", { fg = c.grey_dark })
hl("EndOfBuffer", { fg = c.bg }) -- hide ~ markers against bg

hl("SpellBad", { undercurl = true, sp = c.red })
hl("SpellCap", { undercurl = true, sp = c.yellow })
hl("SpellLocal", { undercurl = true, sp = c.blue })
hl("SpellRare", { undercurl = true, sp = c.plum })

-- Diagnostics (native; Emacs has only warning-face + isearch-fail red4)
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.orange })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.plum })
hl("DiagnosticOk", { fg = c.green })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.orange })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.plum })
hl("DiagnosticUnderlineOk", { undercurl = true, sp = c.green })
link("DiagnosticSignError", "DiagnosticError")
link("DiagnosticSignWarn", "DiagnosticWarn")
link("DiagnosticSignInfo", "DiagnosticInfo")
link("DiagnosticSignHint", "DiagnosticHint")
link("DiagnosticSignOk", "DiagnosticOk")
link("DiagnosticFloatingError", "DiagnosticError")
link("DiagnosticFloatingWarn", "DiagnosticWarn")
link("DiagnosticFloatingInfo", "DiagnosticInfo")
link("DiagnosticFloatingHint", "DiagnosticHint")
link("DiagnosticVirtualTextError", "DiagnosticError")
link("DiagnosticVirtualTextWarn", "DiagnosticWarn")
link("DiagnosticVirtualTextInfo", "DiagnosticInfo")
link("DiagnosticVirtualTextHint", "DiagnosticHint")

-- Diff / version control (Emacs `diff-*` faces)
hl("DiffAdd", { fg = c.green })
hl("DiffChange", { fg = c.blue })
hl("DiffDelete", { fg = c.orange })
hl("DiffText", { fg = c.ink, bg = c.blue })
hl("Added", { fg = c.green })
hl("Removed", { fg = c.orange })
hl("Changed", { fg = c.blue })

-- ---------------------------------------------------------------------------
-- 3. Syntax (Emacs font-lock-* faces)
-- ---------------------------------------------------------------------------
hl("Comment", { fg = c.grey })               -- font-lock-comment-face
link("CommentBold", "Comment")
hl("Constant", { fg = c.green })             -- font-lock-constant-face
hl("String", { fg = c.plum, italic = true }) -- font-lock-string-face
hl("Character", { fg = c.plum })
hl("Number", { fg = c.green })
hl("Boolean", { fg = c.green })
hl("Float", { fg = c.green })
hl("Identifier", { fg = c.tomato })            -- font-lock-variable-name-face
hl("Function", { fg = c.yellow, bold = true }) -- font-lock-function-name-face
hl("Statement", { fg = c.blue, bold = true })  -- font-lock-keyword-face
hl("Conditional", { fg = c.blue, bold = true })
hl("Repeat", { fg = c.blue, bold = true })
hl("Label", { fg = c.blue })
hl("Operator", { fg = c.fg })
hl("Keyword", { fg = c.blue, bold = true })
hl("Exception", { fg = c.orange, bold = true })
hl("PreProc", { fg = c.blue }) -- preprocessor = builtin
hl("Include", { fg = c.blue })
hl("Define", { fg = c.blue })
hl("Macro", { fg = c.blue })
hl("PreCondit", { fg = c.blue })
hl("Type", { fg = c.green, bold = true }) -- font-lock-type-face
hl("StorageClass", { fg = c.blue, bold = true })
hl("Structure", { fg = c.green, bold = true })
hl("Typedef", { fg = c.green, bold = true })
hl("Special", { fg = c.orange })
hl("SpecialChar", { fg = c.orange })
hl("Tag", { fg = c.blue })
hl("Delimiter", { fg = c.grey_light })
hl("SpecialComment", { fg = c.grey, italic = true })
hl("Debug", { fg = c.orange })
hl("Underlined", { fg = c.blue_named, underline = true }) -- link face
hl("Error", { fg = c.red, bold = true })
hl("Todo", { fg = c.ink, bg = c.yellow, bold = true })
hl("Bold", { bold = true })
hl("Italic", { italic = true })

-- Legacy vim syntax links that should follow the above
link("Quote", "String")
link("Noise", "Delimiter")

-- ---------------------------------------------------------------------------
-- 4. Treesitter (restrained: link to syntax groups, no rainbow)
-- ---------------------------------------------------------------------------
hl("@comment", { fg = c.grey })
hl("@comment.documentation", { fg = c.grey, italic = true })
hl("@comment.error", { fg = c.red, bold = true })
hl("@comment.warning", { fg = c.orange, bold = true })
hl("@comment.todo", { fg = c.ink, bg = c.yellow, bold = true })
hl("@comment.note", { fg = c.blue, bold = true })

hl("@string", { fg = c.plum, italic = true })
hl("@string.documentation", { fg = c.plum, italic = true })
hl("@string.regexp", { fg = c.orange })
hl("@string.escape", { fg = c.orange, bold = true })
hl("@string.special", { fg = c.orange })
link("@string.special.symbol", "@string.special")
link("@string.special.url", "Underlined")
hl("@character", { fg = c.plum })
hl("@character.special", { fg = c.orange, bold = true })

hl("@number", { fg = c.green })
hl("@boolean", { fg = c.green })
hl("@float", { fg = c.green })
hl("@constant", { fg = c.green })
hl("@constant.builtin", { fg = c.blue })
hl("@constant.macro", { fg = c.blue })

-- Variables stay quiet (Normal fg); only special roles take color.
hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.blue })
hl("@variable.parameter", { fg = c.tomato })
hl("@variable.member", { fg = c.blue })

hl("@function", { fg = c.yellow, bold = true })
hl("@function.builtin", { fg = c.blue })
hl("@function.call", { fg = c.yellow })
hl("@function.method", { fg = c.yellow, bold = true })
hl("@function.method.call", { fg = c.yellow })
hl("@function.macro", { fg = c.blue })
hl("@constructor", { fg = c.yellow, bold = true }) -- was green; now shares the "callable" color with functions instead of piling onto @type's green

hl("@keyword", { fg = c.blue, bold = true })
hl("@keyword.function", { fg = c.blue, bold = true })
hl("@keyword.operator", { fg = c.blue })
hl("@keyword.import", { fg = c.blue })
hl("@keyword.return", { fg = c.orange, bold = true })
hl("@keyword.exception", { fg = c.orange, bold = true })
hl("@keyword.conditional", { fg = c.blue, bold = true })
hl("@keyword.repeat", { fg = c.blue, bold = true })
hl("@keyword.debug", { fg = c.orange })
hl("@conditional", { fg = c.blue, bold = true })
hl("@repeat", { fg = c.blue, bold = true })
hl("@operator", { fg = c.fg })
hl("@type", { fg = c.green })                         -- unbolded: type *usages* stay calm, only declarations (below) are bold
hl("@type.builtin", { fg = c.blue })
hl("@type.definition", { fg = c.green, bold = true }) -- interface/class/type-alias declarations still pop
hl("@type.qualifier", { fg = c.blue, bold = true })
hl("@property", { fg = c.blue })
hl("@field", { fg = c.blue })
hl("@parameter", { fg = c.tomato })
hl("@punctuation.bracket", { fg = c.grey_light })
hl("@punctuation.delimiter", { fg = c.grey_light })
hl("@punctuation.special", { fg = c.orange })
hl("@tag", { fg = c.blue })
hl("@tag.attribute", { fg = c.orange }) -- was green; keeps markup from reading as all-green next to @tag/blue
hl("@tag.delimiter", { fg = c.grey_light })
hl("@namespace", { fg = c.blue })
hl("@module", { fg = c.blue })
hl("@label", { fg = c.blue })
hl("@attribute", { fg = c.blue })
hl("@markup.heading", { fg = c.yellow, bold = true })
hl("@markup.link", { fg = c.blue_named, underline = true })
hl("@markup.link.url", { fg = c.blue_named, underline = true })
hl("@markup.raw", { fg = c.plum })
hl("@markup.list", { fg = c.grey_light })
hl("@markup.strong", { bold = true })
hl("@markup.italic", { italic = true })
hl("@markup.strikethrough", { strikethrough = true })
hl("@diff.plus", { fg = c.green })
hl("@diff.minus", { fg = c.orange })
hl("@diff.delta", { fg = c.blue })

-- ---------------------------------------------------------------------------
-- 5. LSP semantic tokens (link to Treesitter roles; modifiers stay subtle)
-- ---------------------------------------------------------------------------
link("@lsp.type.function", "@function")
link("@lsp.type.method", "@function.method")
link("@lsp.type.variable", "@variable")
link("@lsp.type.parameter", "@variable.parameter")
link("@lsp.type.property", "@property")
link("@lsp.type.type", "@type")
link("@lsp.type.class", "@type")
link("@lsp.type.interface", "@type")
link("@lsp.type.enum", "@type")
hl("@lsp.type.enumMember", { fg = c.orange })                 -- was linked to green @constant; separates enum values from type names
hl("@lsp.type.typeParameter", { fg = c.plum, italic = true }) -- generics (<A, In, L, E, R>), previously unstyled/inherited green
link("@lsp.type.namespace", "@namespace")
link("@lsp.type.keyword", "@keyword")
link("@lsp.type.comment", "@comment")
link("@lsp.type.string", "@string")
link("@lsp.type.number", "@number")
link("@lsp.type.operator", "@operator")
link("@lsp.type.decorator", "@attribute")
link("@lsp.type.macro", "@function.macro")
link("@lsp.type.struct", "@type")

hl("@lsp.mod.deprecated", { strikethrough = true, fg = c.red })
hl("@lsp.mod.readonly", { italic = true })
hl("@lsp.mod.static", { bold = true })
hl("@lsp.mod.async", { bold = true, italic = true })
hl("@lsp.mod.abstract", { italic = true })
hl("@lsp.mod.defaultLibrary", { fg = c.blue })

link("@lsp.typemod.function.readonly", "@function")
link("@lsp.typemod.variable.readonly", "@lsp.mod.readonly")
link("@lsp.typemod.variable.static", "@lsp.mod.static")

-- Legacy LSP highlight links (for servers/clients using vim.lsp.buf.document_highlight)
hl("LspReferenceText", { bg = c.bg_cursorln })
hl("LspReferenceRead", { bg = c.bg_cursorln })
hl("LspReferenceWrite", { bg = c.bg_cursorln, bold = true })
hl("LspSignatureActiveParameter", { fg = c.yellow, bold = true })
hl("LspCodeLens", { fg = c.grey })
hl("LspCodeLensSeparator", { fg = c.grey_dark })
hl("LspInlayHint", { fg = c.grey, bg = c.bg_dark, italic = true })

-- ---------------------------------------------------------------------------
-- 6. Plugin / UI compatibility (only plugins present in this config)
-- ---------------------------------------------------------------------------

-- Telescope (telescope.nvim)
hl("TelescopeNormal", { fg = c.fg, bg = c.bg_dark })
hl("TelescopeBorder", { fg = c.grey, bg = c.bg_dark })
hl("TelescopeTitle", { fg = c.yellow, bg = c.bg_dark, bold = true })
hl("TelescopePromptNormal", { fg = c.fg, bg = c.bg_dark })
hl("TelescopePromptBorder", { fg = c.grey, bg = c.bg_dark })
hl("TelescopePromptTitle", { fg = c.ink, bg = c.yellow, bold = true })
hl("TelescopePromptPrefix", { fg = c.yellow, bg = c.bg_dark, bold = true })
hl("TelescopePromptCounter", { fg = c.grey, bg = c.bg_dark })
hl("TelescopeResultsNormal", { fg = c.fg, bg = c.bg_dark })
hl("TelescopeResultsBorder", { fg = c.grey, bg = c.bg_dark })
hl("TelescopeResultsTitle", { fg = c.yellow, bg = c.bg_dark, bold = true })
hl("TelescopePreviewNormal", { fg = c.fg, bg = c.bg_dark })
hl("TelescopePreviewBorder", { fg = c.grey, bg = c.bg_dark })
hl("TelescopePreviewTitle", { fg = c.yellow, bg = c.bg_dark, bold = true })
hl("TelescopeSelection", { fg = c.fg, bg = c.blue_dark, bold = true })
hl("TelescopeSelectionCaret", { fg = c.yellow, bg = c.blue_dark, bold = true })
hl("TelescopeMatching", { fg = c.yellow, bold = true })
hl("TelescopeMultiSelection", { fg = c.green })
hl("TelescopeMultiIcon", { fg = c.green })

-- fzf-lua
hl("FzfLuaNormal", { fg = c.fg, bg = c.bg_dark })
hl("FzfLuaBorder", { fg = c.grey, bg = c.bg_dark })
hl("FzfLuaTitle", { fg = c.yellow, bg = c.bg_dark, bold = true })
hl("FzfLuaPreviewNormal", { fg = c.fg, bg = c.bg_dark })
hl("FzfLuaPreviewBorder", { fg = c.grey, bg = c.bg_dark })
hl("FzfLuaCursorLine", { fg = c.fg, bg = c.blue_dark, bold = true })
hl("FzfLuaSearch", { fg = c.yellow, bold = true })
hl("FzfLuaScrollBorderEmpty", { fg = c.grey_dark, bg = c.bg_dark })
hl("FzfLuaScrollBorderFull", { fg = c.grey, bg = c.bg_dark })

-- nvim-cmp + lspkind pictograms
hl("CmpGhostText", { fg = c.grey_dark, italic = true }) -- inline ghost text; same tone as LspInlayHint
hl("SnippetTabstop", { fg = c.ink, bg = c.yellow, bold = true }) -- active tabstop while a snippet is being filled in
hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrDeprecated", { fg = c.grey, strikethrough = true })
hl("CmpItemAbbrMatch", { fg = c.yellow, bold = true })
hl("CmpItemAbbrMatchFuzzy", { fg = c.yellow })
hl("CmpItemMenu", { fg = c.grey })
hl("CmpItemKind", { fg = c.blue })
hl("CmpItemKindFunction", { fg = c.yellow })
hl("CmpItemKindMethod", { fg = c.yellow })
hl("CmpItemKindVariable", { fg = c.tomato })
hl("CmpItemKindField", { fg = c.blue })
hl("CmpItemKindProperty", { fg = c.blue })
hl("CmpItemKindClass", { fg = c.green })
hl("CmpItemKindInterface", { fg = c.green })
hl("CmpItemKindStruct", { fg = c.green })
hl("CmpItemKindEnum", { fg = c.green })
hl("CmpItemKindConstant", { fg = c.green })
hl("CmpItemKindConstructor", { fg = c.green })
hl("CmpItemKindKeyword", { fg = c.blue })
hl("CmpItemKindSnippet", { fg = c.orange })
hl("CmpItemKindFile", { fg = c.blue })
hl("CmpItemKindFolder", { fg = c.blue })
link("CmpDocumentation", "NormalFloat")
link("CmpDocumentationBorder", "FloatBorder")

-- which-key.nvim
hl("WhichKey", { fg = c.blue })
hl("WhichKeyGroup", { fg = c.yellow })
hl("WhichKeyDesc", { fg = c.fg })
hl("WhichKeySeperator", { fg = c.grey })
hl("WhichKeySeparator", { fg = c.grey })
hl("WhichKeyFloat", { fg = c.fg, bg = c.bg_dark })
hl("WhichKeyBorder", { fg = c.grey, bg = c.bg_dark })
hl("WhichKeyValue", { fg = c.grey })

-- Neo-tree (neo-tree.nvim)
hl("NeoTreeNormal", { fg = c.fg, bg = c.bg_darker }) -- darker than the editor so the sidebar reads as its own panel
hl("NeoTreeNormalNC", { fg = c.fg, bg = c.bg_darker })
hl("NeoTreeEndOfBuffer", { fg = c.bg_darker, bg = c.bg_darker })
hl("NeoTreeWinSeparator", { fg = c.bg_darker, bg = c.bg_darker }) -- blends into the panel bg to hide the vertical border line
hl("NeoTreeDirectoryName", { fg = c.blue })
hl("NeoTreeDirectoryIcon", { fg = c.blue })
hl("NeoTreeRootName", { fg = c.yellow, bold = true })
hl("NeoTreeFileName", { fg = c.fg })
hl("NeoTreeFileIcon", { fg = c.grey_light })
hl("NeoTreeGitAdded", { fg = c.green })
hl("NeoTreeGitDeleted", { fg = c.red })
hl("NeoTreeGitModified", { fg = c.orange })
hl("NeoTreeGitConflict", { fg = c.red, bold = true })
hl("NeoTreeGitUntracked", { fg = c.grey })
hl("NeoTreeGitIgnored", { fg = c.grey_dark })
hl("NeoTreeGitStaged", { fg = c.green })
hl("NeoTreeModified", { fg = c.orange })
hl("NeoTreeIndentMarker", { fg = c.grey_dark })
hl("NeoTreeExpander", { fg = c.grey })
hl("NeoTreeCursorLine", { fg = c.fg, bg = c.bg })
hl("NeoTreeTitleBar", { fg = c.ink, bg = c.yellow, bold = true })
link("NeoTreeFloatBorder", "FloatBorder")
link("NeoTreeFloatTitle", "FloatTitle")

-- Gitsigns (gitsigns.nvim)
hl("GitSignsAdd", { fg = c.green })
hl("GitSignsChange", { fg = c.blue })
hl("GitSignsDelete", { fg = c.red })
hl("GitSignsTopdelete", { fg = c.red })
hl("GitSignsChangedelete", { fg = c.orange })
hl("GitSignsUntracked", { fg = c.grey })
link("GitSignsAddNr", "GitSignsAdd")
link("GitSignsChangeNr", "GitSignsChange")
link("GitSignsDeleteNr", "GitSignsDelete")
link("GitSignsAddLn", "DiffAdd")
link("GitSignsChangeLn", "DiffChange")
link("GitSignsDeleteLn", "DiffDelete")
hl("GitSignsCurrentLineBlame", { fg = c.grey, italic = true })

-- Lazy.nvim
hl("LazyNormal", { fg = c.fg, bg = c.bg_dark })
hl("LazyButton", { fg = c.fg, bg = c.grey_dark })
hl("LazyButtonActive", { fg = c.ink, bg = c.yellow, bold = true })
hl("LazyH1", { fg = c.ink, bg = c.yellow, bold = true })
hl("LazyH2", { fg = c.yellow, bold = true })
hl("LazyComment", { fg = c.grey })
hl("LazyCommit", { fg = c.green })
hl("LazyReasonPlugin", { fg = c.blue })
hl("LazyReasonEvent", { fg = c.orange })
hl("LazyReasonKeys", { fg = c.tomato })
hl("LazyReasonStart", { fg = c.fg })
hl("LazyReasonRuntime", { fg = c.plum })
hl("LazyTaskOutput", { fg = c.fg })
hl("LazyError", { fg = c.red })
hl("LazyWarning", { fg = c.orange })
hl("LazyInfo", { fg = c.blue })
hl("LazyProp", { fg = c.grey })
link("LazyFloatBorder", "FloatBorder")

-- Mason (mason.nvim)
hl("MasonNormal", { fg = c.fg, bg = c.bg_dark })
hl("MasonHeader", { fg = c.ink, bg = c.yellow, bold = true })
hl("MasonHeaderSecondary", { fg = c.ink, bg = c.blue, bold = true })
hl("MasonHighlight", { fg = c.blue })
hl("MasonHighlightBlock", { fg = c.ink, bg = c.blue })
hl("MasonHighlightBlockBold", { fg = c.ink, bg = c.blue, bold = true })
hl("MasonHighlightSecondary", { fg = c.orange })
hl("MasonMuted", { fg = c.grey })
hl("MasonMutedBlock", { fg = c.fg_dim, bg = c.grey_dark })
hl("MasonError", { fg = c.red })
hl("MasonWarning", { fg = c.orange })

-- Trouble (trouble.nvim)
hl("TroubleNormal", { fg = c.fg, bg = c.bg })
hl("TroubleText", { fg = c.fg })
hl("TroubleCount", { fg = c.ink, bg = c.yellow, bold = true })
hl("TroubleLocation", { fg = c.grey })
hl("TroubleFilename", { fg = c.blue })
hl("TroubleCode", { fg = c.grey })
hl("TroubleSource", { fg = c.plum })
hl("TroubleSignError", { fg = c.red })
hl("TroubleSignWarning", { fg = c.orange })
hl("TroubleSignInformation", { fg = c.blue })
hl("TroubleSignHint", { fg = c.plum })
hl("TroubleSignOther", { fg = c.grey })

-- todo-comments.nvim
hl("TodoBgTODO", { fg = c.ink, bg = c.blue, bold = true })
hl("TodoFgTODO", { fg = c.blue })
hl("TodoBgFIX", { fg = c.ink, bg = c.red, bold = true })
hl("TodoFgFIX", { fg = c.red })
hl("TodoBgHACK", { fg = c.ink, bg = c.orange, bold = true })
hl("TodoFgHACK", { fg = c.orange })
hl("TodoBgWARN", { fg = c.ink, bg = c.orange, bold = true })
hl("TodoFgWARN", { fg = c.orange })
hl("TodoBgPERF", { fg = c.ink, bg = c.plum, bold = true })
hl("TodoFgPERF", { fg = c.plum })
hl("TodoBgNOTE", { fg = c.ink, bg = c.green, bold = true })
hl("TodoFgNOTE", { fg = c.green })
hl("TodoBgTEST", { fg = c.ink, bg = c.plum, bold = true })
hl("TodoFgTEST", { fg = c.plum })
link("TodoSignTODO", "TodoFgTODO")
link("TodoSignFIX", "TodoFgFIX")
link("TodoSignHACK", "TodoFgHACK")
link("TodoSignWARN", "TodoFgWARN")
link("TodoSignPERF", "TodoFgPERF")
link("TodoSignNOTE", "TodoFgNOTE")
link("TodoSignTEST", "TodoFgTEST")

-- Hop (hop.nvim)
hl("HopNextKey", { fg = c.yellow_light, bold = true })
hl("HopNextKey1", { fg = c.yellow, bold = true })
hl("HopNextKey2", { fg = c.green })
hl("HopUnmatched", { fg = c.grey_dark })
hl("HopPreview", { fg = c.orange, bold = true })
hl("HopCursor", { fg = c.ink, bg = c.yellow_light })

-- Bufferline (bufferline.nvim)
hl("BufferLineFill", { fg = c.grey, bg = c.bg_darker })
hl("BufferLineBackground", { fg = c.grey, bg = c.bg_darker })
hl("BufferLineBufferVisible", { fg = c.fg_dim, bg = c.bg_darker })
hl("BufferLineBufferSelected", { fg = c.fg, bg = c.bg, bold = true })
hl("BufferLineTab", { fg = c.grey, bg = c.bg_darker })
hl("BufferLineTabSelected", { fg = c.yellow, bg = c.bg, bold = true })
hl("BufferLineTabClose", { fg = c.grey, bg = c.bg_darker })
hl("BufferLineSeparator", { fg = c.bg_darker, bg = c.bg_darker })
hl("BufferLineSeparatorVisible", { fg = c.bg_darker, bg = c.bg_darker })
hl("BufferLineSeparatorSelected", { fg = c.bg_darker, bg = c.bg })
hl("BufferLineIndicatorVisible", { fg = c.grey_dark, bg = c.bg_darker })
hl("BufferLineIndicatorSelected", { fg = c.yellow, bg = c.bg })
hl("BufferLineCloseButton", { fg = c.grey, bg = c.bg_darker })
hl("BufferLineCloseButtonVisible", { fg = c.fg_dim, bg = c.bg_darker })
hl("BufferLineCloseButtonSelected", { fg = c.fg, bg = c.bg })
hl("BufferLineModified", { fg = c.orange, bg = c.bg_darker })
hl("BufferLineModifiedVisible", { fg = c.orange, bg = c.bg_darker })
hl("BufferLineModifiedSelected", { fg = c.orange, bg = c.bg })
hl("BufferLineError", { fg = c.red, bg = c.bg_darker })
hl("BufferLineErrorSelected", { fg = c.red, bg = c.bg })
hl("BufferLineWarning", { fg = c.orange, bg = c.bg_darker })
hl("BufferLineWarningSelected", { fg = c.orange, bg = c.bg })
hl("BufferLineInfo", { fg = c.blue, bg = c.bg_darker })
hl("BufferLineInfoSelected", { fg = c.blue, bg = c.bg })
hl("BufferLineHint", { fg = c.plum, bg = c.bg_darker })
hl("BufferLineHintSelected", { fg = c.plum, bg = c.bg })
hl("BufferLineDuplicate", { fg = c.grey, bg = c.bg_darker, italic = true })
hl("BufferLineDuplicateSelected", { fg = c.fg_dim, bg = c.bg, italic = true })

-- mini.icons / nvim-web-devicons (devicons color by extension; keep neutral base)
link("MiniIconsGrey", "NonText")

-- nvim-colorizer / color-preview has no highlight groups to theme.

-- Netrw (used by <leader>pv -> :Ex)
link("netrwDir", "Directory")
link("netrwClassify", "Directory")

-- ---------------------------------------------------------------------------
-- Terminal palette (Emacs `term-color-*` faces)
-- ---------------------------------------------------------------------------
vim.g.terminal_color_0  = c.bg_darker    -- black
vim.g.terminal_color_1  = c.red          -- red (#ef2929)
vim.g.terminal_color_2  = c.green_dark   -- green (#6ac214)
vim.g.terminal_color_3  = c.yellow       -- yellow (#edd400)
vim.g.terminal_color_4  = c.blue_named   -- blue (dodger blue)
vim.g.terminal_color_5  = c.plum         -- magenta-ish (plum keeps Tango feel)
vim.g.terminal_color_6  = c.cyan_light   -- cyan
vim.g.terminal_color_7  = c.fg           -- white (#eeeeec)
vim.g.terminal_color_8  = c.grey_dark    -- bright black
vim.g.terminal_color_9  = c.tomato       -- bright red
vim.g.terminal_color_10 = c.green        -- bright green (#8ae234)
vim.g.terminal_color_11 = c.yellow_light -- bright yellow (#fce94f)
vim.g.terminal_color_12 = c.blue         -- bright blue (#729fcf)
vim.g.terminal_color_13 = c.magenta      -- bright magenta
vim.g.terminal_color_14 = "#8cc4ff"      -- bright cyan (tango sky-blue light)
vim.g.terminal_color_15 = "#ffffff"      -- bright white
