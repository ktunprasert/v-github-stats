module main

import os
import zztkm.vdotenv
import graphql
import client

struct Config {
mut:
	user  string = os.getenv('GH_USER')
	token string = os.getenv('GH_TOKEN')
}

fn main() {
	vdotenv.load()
	// cfg := Config{}
	c := client.new_client()
	response := c.query[client.LanguagesResponseDTO](graphql.new_language())!

	println(response)
	println(response.get_languages())
}
