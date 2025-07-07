module main

import os
import zztkm.vdotenv
import graphql
import client
import log

struct Config {
mut:
	user  string = os.getenv('GH_USER')
	token string = os.getenv('GH_TOKEN')
}

fn main() {
	vdotenv.load()
	log.set_level(.debug)
	// cfg := Config{}
	c := client.new_client()
	response := c.query[client.LanguagesResponseDTO](graphql.new_language())!
	log.info(response.get_languages().str())
}
