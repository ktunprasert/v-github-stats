module main

import veb
import os
import zztkm.vdotenv
import client
import log
import json

struct Config {
mut:
	user  string = os.getenv('GH_USER')
	token string = os.getenv('GH_TOKEN')
}

struct Color {
	color string
	url   string
}

const cmap = json.decode(map[string]Color, $embed_file('assets/colors.json').to_string())!

fn main() {
	vdotenv.load()
	log.set_level(.debug)
	cfg := Config{}
	c := client.new_client()

	mut app := new_app(cfg, c)
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
