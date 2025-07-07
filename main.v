module main

import os
import zztkm.vdotenv
import graphql
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

	c := client.new_client()
	response := c.query[client.SearchResponseDTO](graphql.new_search(num_repos: 50))!
	languages, total := response.get_languages(blacklist: [])
	log.info(languages.str())

	for key, bytes in languages {
		println('lang: ${key} - usage: ${bytes}')
		println('percentage: ${f32(bytes) / f32(total) * 100:.2f}%')
		// clr := cmap[key]
		// println('color: ${clr}')
	}
}
