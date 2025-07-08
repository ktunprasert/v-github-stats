module main

import veb
import graphql
import client
import svg
import maps

struct App {
	cfg    Config
	client client.Client
}

struct Ctx {
	veb.Context
}

const blacklist = ['Shell', 'HTML', 'CSS', 'Dockerfile', 'Lua', 'JavaScript', 'PHP', 'MDX']

@[get]
pub fn (app &App) index(mut ctx Ctx) veb.Result {
	user_name := ctx.query['name'] or { app.cfg.user }
	num_repos := ctx.query['num_repos'] or { '5' }
	num_languages := ctx.query['num_languages'] or { '10' }

	search_query := graphql.new_search(
		user:          user_name
		num_repos:     num_repos.int()
		num_languages: num_languages.int()
	)

	resp := app.client.query[client.SearchResponseDTO](search_query) or {
		return ctx.text('Error fetching data: ${err}')
	}
	languages := resp.get_languages(blacklist: blacklist)

	stats_svg := svg.build_stats(maps.flat_map[string, int, svg.Language](languages, |key, value| [
		svg.Language{cmap[key].color, value, key},
	]), user_name)

	ctx.set_content_type('image/svg+xml')
	return ctx.text(stats_svg)
}
