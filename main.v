module main

import veb
import os
import zztkm.vdotenv
import client
import log
import json
import flag
import cacher

@[xdoc: 'Server for GitHub language statistics']
@[name: 'v-gh-stats']
struct Config {
mut:
	user  string = os.getenv('GH_USER') @[long: user; short: u; xdoc: 'GitHub username']
	token string = os.getenv('GH_TOKEN') @[long: token; short: t; xdoc: 'GitHub personal access token']
	debug bool   = os.getenv('DEBUG') == 'true'   @[long: debug; short: d; xdoc: 'Enable debug mode']
	cache bool   = os.getenv('CACHE') == 'true'   @[long: cache; short: c; xdoc: 'Enable caching']
}

fn (c Config) str() string {
	return 'user: ${c.user}, token ${c.token.limit(10)}..., debug: ${c.debug}, cache: ${c.cache}'
}

struct Color {
	color string
	url   string
}

const cmap = json.decode(map[string]Color, $embed_file('assets/colors.json').to_string())!

fn main() {
	vdotenv.load()
	cfg, _ := flag.to_struct[Config](os.args, skip: 1)!
	if cfg.debug {
		log.set_level(.debug)
	}
	log.debug(cfg.str())

	clnt := client.new_client()
	cache := cacher.Cacher{cfg.cache}

	mut app := new_app(cfg, clnt, cache)
	app.use(
		handler: fn (mut ctx Ctx) bool {
			log.info('ctx.query: ${ctx.query}')
			log.info('ctx.url: ${ctx.req.host}${ctx.req.url}')
			return true
		}
	)
	app.use(veb.encode_gzip[Ctx]())
	veb.run[App, Ctx](mut app, 8199)
}
