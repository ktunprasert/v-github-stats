module main

import os
import net.http
import zztkm.vdotenv
import json

const base_url = 'https://api.github.com/graphql'

struct Config {
mut:
	user  string = os.getenv('GH_USER')
	token string = os.getenv('GH_TOKEN')
}

fn main() {
	vdotenv.load()
	cfg := Config{}
	graphql := get_languages_graphql(cfg)
	println(graphql)

	body_map := {
		'query': graphql
	}
	body := json.encode(body_map)
	println(body)

	mut request := http.new_request(.post, base_url, body)
	request.add_header(.authorization, 'Bearer ${cfg.token}')
	println(request.header)

	response := request.do()!
	println(response)
}

fn get_languages_graphql(cfg Config) string {
	user := cfg.user
	return $tmpl('./graphql/languages.graphql')
}
