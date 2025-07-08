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

const blacklist = ['Shell', 'HTML', 'CSS', 'Dockerfile', 'Lua', 'JavaScript', 'PHP', 'MDX']

@[get]
pub fn (app &App) index(mut ctx Ctx) veb.Result {
	user := ctx.query['user'] or { app.cfg.user }
	num_repos := ctx.query['num_repos'] or { '5' }
	num_languages := ctx.query['num_languages'] or { '10' }
	if num_repos.int() > 100 {
		ctx.res.set_status(.bad_request)
		return ctx.text('num_repos of ${num_repos} too high maximum value of 100 allowed')
	}

	if num_languages.int() > 20 {
		ctx.res.set_status(.bad_request)
		return ctx.text('num_languages of ${num_languages} too high maximum value of 20 allowed')
	}

	filename := '${user}-${num_repos}-${num_languages}'
	content := app.cacher.get(filename) or { '' }

	if content.len > 0 {
		log.info('veb.index.query: cache hit for ${filename}')
		ctx.set_content_type(veb.mime_types['.svg'])
		return ctx.text(content)
	}

	search_query := graphql.new_search(
		user:          user
		num_repos:     num_repos.int()
		num_languages: num_languages.int()
	)
	log.info('veb.index.query: (user: ${user}, num_repos: ${num_repos}, num_languages: ${num_languages}) ')

	resp := app.client.query[client.SearchResponseDTO](search_query) or {
		return ctx.text('Error fetching data: ${err}')
	}
	languages := resp.get_languages(blacklist: blacklist)

	stats_svg := svg.build_stats(maps.flat_map[string, int, svg.Language](languages, |key, value| [
		svg.Language{cmap[key].color, value, key},
	]), user)

	app.cacher.cache(filename, stats_svg) or {
		log.error('veb.index.cacher: unable to cache ${filename}, err: ${err}')
	}

	ctx.set_content_type(veb.mime_types['.svg'])
	return ctx.text(stats_svg)
}
