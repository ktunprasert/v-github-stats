module main

import os
import net.http
import zztkm.vdotenv

const base_url := "https://api.github.com/graphql"

fn main() {
	user := 'ktunprasert'
	vdotenv.load()
	pat := os.getenv('TOKEN')

	println($tmpl('./graphql/languages.graphql'))
}
