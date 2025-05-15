return {
	-- Page component
	s(
		"page",
		fmt(
			[[
<script lang="ts">
    {}
</script>
<svelte:head>
    <title>{}</title>
</svelte:head>
    {}
<style>
    {}
</style>
            ]],
			{
				i(1, "// your script here"),
				i(2, "Page Title"),
				i(3, "<!-- your content here -->"),
				i(4, "/* your styles here */"),
			}
		),
		"SvelteKit page component"
	),
	-- Each block
	s(
		"each",
		fmt(
			[[
{{#each {} as {}}}
    {}
{{/each}}
            ]],
			{
				i(1, "items"),
				i(2, "item"),
				i(3, "{item}"),
			}
		),
		"Svelte each block"
	),
}
