module main

import os
import zztkm.vdotenv
import graphql
import client
import log
import json
import strings

struct Config {
mut:
	user  string = os.getenv('GH_USER')
	token string = os.getenv('GH_TOKEN')
}

struct Color {
	color string
	url   string
}

const svg_width = 360

struct Language {
	fill      string
	num_bytes int
	// percent   f32
	lang string
}

fn (l Language) percent(total int) f32 {
	if total == 0 {
		return 0.0
	}
	return f32(l.num_bytes) / f32(total) * 100.0
}

fn (l Language) width(total int) int {
	if total == 0 {
		return 0
	}

	return int(l.percent(total) * svg_width / 100.0)
}

fn (l Language) svg(total int, offset int) string {
	fill := l.fill
	lang := l.lang
	percent := '${l.percent(total):.2f}'
	width := l.width(total)

	return $tmpl('./assets/lang.svg')
}

const cmap = json.decode(map[string]Color, $embed_file('assets/colors.json').to_string())!

fn main() {
	vdotenv.load()
	log.set_level(.debug)

	c := client.new_client()
	response := c.query[client.SearchResponseDTO](graphql.new_search(num_repos: 50))!
	languages, total := response.get_languages(blacklist: ['Shell', 'HTML', 'CSS', 'Dockerfile', 'Lua', 'JavaScript', 'PHP'])
	log.info(languages.str())

	mut langs_builder := strings.new_builder(1000)
	mut offset := 20

	mut lang_arr := []Language{}
	for key, bytes in languages {
		log.debug('lang: ${key} - usage: ${bytes}')
		log.debug('percentage: ${f32(bytes) / f32(total) * 100:.2f}%')
		clr := cmap[key]
		lang := Language{
			fill:      clr.color
			num_bytes: bytes
			lang:      key
		}

		lang_arr << lang
	}

	lang_arr.sort(|a, b| b.num_bytes < a.num_bytes)
	lang_arr.trim(10)
	height := (lang_arr.len * 40) + 20 + 25
	foot := height - 15
	println(lang_arr)

	for lang in lang_arr {
		langs_builder.write_string(lang.svg(total, offset))
		offset += 40
	}

	langs := langs_builder.str()
	log.debug(langs)
	println($tmpl('./assets/stats.svg'))
}
