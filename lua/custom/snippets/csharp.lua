-- A self-contained module for managing LuaSnip snippets.
require('luasnip.session.snippet_collection').clear_snippets 'cs'

local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt

-- Short aliases
local s = ls.s
local i = ls.i
local t = ls.t
local f = ls.f
local c = ls.c

-- ls.add_snippets('cs', {
--   -- The postfix foreach snippet (this one was already correct)
--   s(
--     {
--       trigger = '.forea',
--       condition = function(line_to_cursor)
--         return line_to_cursor:match '%w+$'
--       end,
--     },
--     f(function(_, parent)
--       local var_name = parent.captures[1]
--       return fmt(
--         [[
-- foreach (var {} in {}) {{
--   {}
-- }}
-- ]],
--         { i(1, 'item'), t(var_name), i(0) }
--       )
--     end),
--     { word_trigger = true }
--   ),
--
--   -- ### THE CORRECTED SNIPPET ###
--   -- Snippet for a full property with a backing field
--   s(
--     'propfull',
--     fmt(
--       [[
-- private {} _{};
-- public {} {}
-- {{
--   get {{ return _{}; }}
--   set {{ _{} = value; }}
-- }}
-- ]],
--       {
--         -- 1. Define the Type using a single choice node at index 1.
--         c(1, { t 'string', t 'int', t 'bool', t 'double', t 'float' }),
--         -- 2. Define the backing field variable name at index 2.
--         i(2, 'myVar'),
--         -- 3. For the second 'Type' placeholder, use a function node
--         --    that copies the text from the node at index 1.
--         f(function(args)
--           return args[1][1] or ''
--         end, { 1 }),
--         -- 4. Define the public Property name at index 3.
--         i(3, 'MyProperty'),
--         -- 5. & 6. Reuse the backing field name from index 2.
--         f(function(args)
--           return args[1][1] or ''
--         end, { 2 }),
--         f(function(args)
--           return args[1][1] or ''
--         end, { 2 }),
--       }
--     )
--   ),
-- })
