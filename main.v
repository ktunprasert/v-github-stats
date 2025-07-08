module main

import os
import zztkm.vdotenv
import client
import log
import json
import veb

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

	mut app := &App{cfg, c}
	veb.run[App, Ctx](mut app, 8199)
}
