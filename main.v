module main

import os
import zztkm.vdotenv
import graphql
import client
import log
import json
import svg

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
	languages, total := response.get_languages(
		blacklist: ['Shell', 'HTML', 'CSS', 'Dockerfile', 'Lua', 'JavaScript', 'PHP', 'MDX']
	)
	log.info(languages.str())

	mut lang_arr := []svg.Language{}
	for key, bytes in languages {
		log.debug('lang: ${key} - usage: ${bytes}')
		log.debug('percentage: ${f32(bytes) / f32(total) * 100:.2f}%')
		clr := cmap[key]
		lang := svg.Language{
			fill:      clr.color
			num_bytes: bytes
			lang:      key
		}

		lang_arr << lang
	}

	stats_svg := svg.build_stats(lang_arr, cfg.user, total)

	os.write_file('stats.svg', stats_svg) or {
		log.error('Failed to write stats.svg: ${err}')
		return
	}
}
