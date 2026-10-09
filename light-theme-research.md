# Light themes for muted, readable Neovim

Research date: 22 September 2026. This is a shortlist for muted colors, simple highlighting, and readable text. Appearance assessments are judgments from project descriptions and palettes, not a controlled readability study. GitHub counts below are approximate snapshots returned by the pages consulted; some pages were cached. They measure interest in whole repositories, including dark variants, rather than usage of individual light themes. A dated commit or release is reported separately from the research date; none of these observations establish a current growth rate.

The existing configuration already declares Nightfox (with Dayfox selected for light mode), Zenbones, Alabaster, Rosé Pine, Catppuccin, Gruvbox, Modus, Tokyo Night, and Koda. Those are useful comparison points rather than new discoveries. Configuration was not changed.

## Best candidates new to this configuration

| Theme | Why consider it | Popularity and availability |
| --- | --- | --- |
| **Kansō Pearl** | Promising match for restrained colors; its optional `minimal = true` setting reduces the highlighting palette. Try the default foreground before increasing saturation. | Approximately **585 stars**; `kanso-pearl` is an explicit light variant. Includes terminal extras for Ghostty, Kitty, Alacritty, iTerm2, WezTerm, and others. [Project](https://github.com/webhooked/kanso.nvim) |
| **Kanagawa Paper Canvas** | Especially close to the request: the author explicitly sought less saturated, less distracting Kanagawa colors. | Approximately **405 stars**; load `kanagawa-paper-canvas`. Matching terminal themes and Lualine support are documented. [Project](https://github.com/thesimonho/kanagawa-paper.nvim) |
| **Everforest Light** | Established warm, green-based alternative. Start with medium or hard background contrast given the reading requirement. | Approximately **4.2k stars**. Supports light and dark backgrounds, Tree-sitter, semantic highlighting, and common plugins. [Project](https://github.com/sainnhe/everforest) |
| **GitHub Light / Light High Contrast** | The practical comparison for a neutral, conventional light theme. Less of a novelty, but useful for deciding whether tinted paper backgrounds actually improve comfort. | Approximately **2.5k stars** observed in the parent research. Explicit light variants and plugin support. [Project](https://github.com/projekt0n/github-nvim-theme) |
| **Flexoki Light** | Attractive paper-and-ink direction, especially for prose as well as code. Evaluate the Neovim implementation separately from the popularity of the palette. | The official Neovim port showed approximately **150 stars** and explicitly warns that common plugin support remains incomplete. Load `flexoki-light`. [Official port](https://github.com/kepano/flexoki-neovim) |

Kansō's commit history records the minimal mode addition on **31 January 2026**, and a Pearl cursor visibility fix on **17 October 2025**. This gives concrete recent development evidence rather than implying that the theme was released this year. Its README claims WCAG AA compliance, but this research did not independently validate every syntax and UI color combination. [Commit history](https://github.com/webhooked/kanso.nvim/commits/main/)

Kanagawa Paper's changelog records **Canvas arriving in version 2.0.0 on 8 March 2025**, updated Canvas colors in August 2025, reduced Canvas brightness in September 2025, and more neutral Canvas gray in **4.0.0 on 28 December 2025**. This is a concretely newer light variant worth trying. The same release removed the old WezTerm integration; the current README still documents matching terminal color files, so do not confuse removal of the integration with removal of all terminal palettes. [Changelog](https://github.com/thesimonho/kanagawa-paper.nvim/blob/master/CHANGELOG.md)

Everforest exposes `g:everforest_background` with `hard`, `medium`, and `soft`, and separately `g:everforest_ui_contrast` with `low` or `high`. The latter affects items such as line numbers and indentation guides. These are useful controls if the overall palette is pleasant but interface details are too faint. [Documentation](https://github.com/sainnhe/everforest/blob/master/doc/everforest.txt)

Flexoki has a maintenance tradeoff: the alternative [cpplain port](https://github.com/cpplain/flexoki.nvim) is archived and says its code moved into the author's dotfiles. The [nuvic port](https://github.com/nuvic/flexoki-nvim) was archived on **8 April 2026**. Neither should be presented as the obvious actively maintained replacement for the official port.

## Strong existing options and a niche alternative

**Zenbones light** is already available in the setup and remains an excellent benchmark for simple highlighting. Its design emphasizes contrast, and `zenwritten` is its zero-hue, zero-saturation variant. The project provides terminal implementations and offers controls such as comment darkening. Approximately **1.1k stars** were observed in the parent research. [Zenbones](https://github.com/zenbones-theme/zenbones.nvim)

**Alabaster** is another existing minimalist comparison. Its Neovim port aims to use very little highlighting and supports light backgrounds. The current GitHub repository returned approximately **204 stars**. Be aware of port/repository differences when finding installation instructions. [Alabaster](https://github.com/dchinmay2/alabaster.nvim)

If near-monochrome looks appealing, **GitHub Monochrome Light** is a smaller discovery: roughly **43 stars**, explicit light and Rosé Pine Dawn styles, plus extras for Ghostty, Kitty, and Alacritty. It fits the simplicity preference, but should be described as niche rather than popular. [GitHub Monochrome](https://github.com/idr4n/github-monochrome.nvim)

Vague was excluded: its light-theme request remained open and marked planned in the consulted source. A popular dark theme is not evidence of a usable light variant. [Vague issue #90](https://github.com/vague-theme/vague.nvim/issues/90)

## Suggested comparison

Start with **Kansō Pearl**, **Kanagawa Paper Canvas**, and existing **Zenbones light**. Compare the same code, comments, search matches, diagnostic text, and completion menu. Then use **GitHub Light High Contrast** as a readability reference and **Everforest Light medium/hard** as the warmer alternative. Muted saturation and low contrast are separate properties: preserving dark enough text matters more than selecting the softest background option.
