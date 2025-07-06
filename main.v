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

// as of 2025-07-06T22:59:57 the anonymous struct requires @json attribute
struct LanguagesResponseDTO {
	data struct {
		user struct {
			respositories struct {
				nodes []struct {
					name      string
					pushed_at string        @[json: 'pushedAt']
					languages struct {
						edges []struct {
							size int
							node struct {
								name string
							}
						}
					}
				}
			} @[json: 'repositories']
		} @[json: 'user']
	} @[json: 'data']
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
	println(response.status_code)

	if response.status_code > 200 {
		eprintln('something went wrong - check your environment values or .env')
		exit(1)
	}

	dto := json.decode(LanguagesResponseDTO, response.body)!
	println(dto)
}

fn get_languages_graphql(cfg Config) string {
	user := cfg.user
	return $tmpl('./graphql/languages.graphql')
}
