module main

import os
import net.http
import zztkm.vdotenv
import json

const base_url = 'https://api.github.com/graphql'

fn main() {
	user := 'ktunprasert'
	vdotenv.load()
	pat := os.getenv('TOKEN')

	graphql := $tmpl('./graphql/languages.graphql')
	println(graphql)

	body_map := {
		'query': graphql
	}
	body := json.encode(body_map)
	println(body)

	mut request := http.new_request(.post, base_url, body)
	request.add_header(.authorization, 'Bearer ${pat}')
	println(request.header)

	response := request.do()!
	println(response)
}
