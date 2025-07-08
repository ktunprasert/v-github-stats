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
	user  string = os.getenv('GH_USER') @[short: u; long: user; xdoc: 'GitHub username']
	token string = os.getenv('GH_TOKEN') @[short: t; long: token; xdoc: 'GitHub personal access token']
	debug bool  = os.getenv('DEBUG') == 'true' @[short: d; long: debug; xdoc: 'Enable debug mode']
}

fn (c Config) str() string {
	return 'user: ${c.user}, token ${c.token.limit(10)}..., debug: ${c.debug}'
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
	cache := cacher.Cacher{}

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
