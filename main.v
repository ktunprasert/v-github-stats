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

const cmap = json.decode(map[string]Color, $embed_file('colors.json').to_string())!

fn main() {
	vdotenv.load()
	log.set_level(.debug)

	c := client.new_client()
	response := c.query[client.LanguagesResponseDTO](graphql.new_language(num_repos: 1))!
	languages := response.get_languages()
	log.info(languages.str())

	for key, _ in languages {
		println('lang: $key')
		clr := cmap[key]
		println('color: $clr')
	}
}
