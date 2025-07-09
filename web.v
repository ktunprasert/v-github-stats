module main

import veb
import log
import graphql
import client
import svg
import maps
import cacher

struct App {
	veb.Middleware[Ctx]
	cfg    Config
	client client.Client
	cacher cacher.Cacher
}

fn new_app(cfg Config, c client.Client, cache cacher.Cacher) &App {
	return &App{
		cfg:    cfg
		client: c
		cacher: cache
	}
}

struct Ctx {
	veb.Context
}

pub fn (mut ctx Ctx) not_found() veb.Result {
	ctx.res.set_status(.not_found)
	return ctx.html('Page not found!')
}

const blacklist = ['Shell', 'HTML', 'CSS', 'Dockerfile', 'Lua', 'JavaScript', 'PHP', 'MDX', 'SCSS',
	'Less']

@[get]
pub fn (app &App) index(mut ctx Ctx) veb.Result {
	mut query_cfg := graphql.LanguagesConfig{}
	if 'user' in ctx.query {
		query_cfg.user = ctx.query['user']
	}
	if 'num_repos' in ctx.query {
		query_cfg.num_repos = ctx.query['num_repos'].int()
	}
	if 'num_languages' in ctx.query {
		query_cfg.num_languages = ctx.query['num_languages'].int()
	}

	query_cfg = query_cfg.validate() or {
		ctx.res.set_status(.bad_request)
		return ctx.text('Invalid query parameters: ${err}')
	}

	filename := '${query_cfg.user}-${query_cfg.num_repos}-${query_cfg.num_languages}'
	content := app.cacher.get(filename) or { '' }

	if content.len > 0 {
		log.info('veb.index.query: cache hit for ${filename}')
		ctx.set_content_type(veb.mime_types['.svg'])
		return ctx.text(content)
	}

	search_query := graphql.new_search(query_cfg)
	log.info('veb.index.query: (user: ${query_cfg.user}, num_repos: ${query_cfg.num_repos}, num_languages: ${query_cfg.num_languages}) ')

	resp := app.client.query[client.SearchResponseDTO](search_query) or {
		ctx.res.set_status(.internal_server_error)
		return ctx.text('Error fetching data: ${err}')
	}
	languages := resp.get_languages(blacklist: blacklist)

	stats_svg := svg.build_stats(maps.flat_map[string, int, svg.Language](languages, |key, value| [
		svg.Language{cmap[key].color, value, key},
	]), query_cfg.user)

	app.cacher.cache(filename, stats_svg) or {
		log.error('veb.index.cacher: unable to cache ${filename}, err: ${err}')
	}

	ctx.set_content_type(veb.mime_types['.svg'])
	return ctx.text(stats_svg)
}
