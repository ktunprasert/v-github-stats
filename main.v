module main

import os
import zztkm.vdotenv
import graphql
import client
import log
import json
import svg
import maps

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
	response := c.query[client.SearchResponseDTO](graphql.new_search(num_repos: 50))!
	languages := response.get_languages(
		blacklist: ['Shell', 'HTML', 'CSS', 'Dockerfile', 'Lua', 'JavaScript', 'PHP', 'MDX']
	)
	log.info(languages.str())

	stats_svg := svg.build_stats(maps.flat_map[string, int, svg.Language](languages, |key, value| [
		svg.Language{cmap[key].color, value, key},
	]), cfg.user)!

	os.write_file('stats.svg', stats_svg) or {
		log.error('Failed to write stats.svg: ${err}')
		return
	}
}
