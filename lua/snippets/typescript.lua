local ls = require("luasnip")
return {

	---- ############## SVELTEKIT #################
	-- Layout load function
	s(
		{ trig = "lload", desc = "SvelteKit layout load function" },
		fmt(
			[[
import type {{ LayoutServerLoad }} from './$types';

export const load: LayoutServerLoad = async ({{ {} }}) => {{
    return {{
        {}
    }};
}};
]],
			{
				ls.insert_node(1, "/* parameters */"),
				ls.insert_node(2, "/* return values */"),
			}
		)
	),
	-- Server-side load function
	s(
		{ trig = "sload", desc = "SvelteKit server load function" },
		fmt(
			[[
import type {{ PageServerLoad }} from './$types';

export const load: PageServerLoad = async ({{ {} }}) => {{
    return {{
        {}
    }};
}};
]],
			{
				ls.insert_node(1, "/* parameters */"),
				ls.insert_node(2, "/* return values */"),
			}
		)
	),
	-- Client-side load function
	s(
		{ trig = "cload", desc = "SvelteKit client load function" },
		fmt(
			[[
import type {{ PageLoad }} from './$types';

export const load: PageLoad = ({{ {} }}) => {{
    return {{
        {}
    }};
}};
]],
			{
				ls.insert_node(1, "/* parameters */"),
				ls.insert_node(2, "/* return values */"),
			}
		)
	),
	-- Form actions
	s(
		{ trig = "actions", desc = "SvelteKit form actions" },
		fmt(
			[[
export const actions = {{
    default: async ({{ request }}) => {{
        {}
        return {{
            {}
        }};
    }}
}};
]],
			{
				ls.insert_node(1, "/* form data */"),
				ls.insert_node(2, "/* return values */"),
			}
		)
	),
}
