module graphql

import os
import json

const gql_lang = 'languages.graphql'

pub fn new_language() Languages {
	return Languages{}
}

struct Languages {
	user          string = os.getenv('GH_USER')
	num_repos     int    = 5
	num_languages int    = 10
}

fn (l Languages) query() string {
	user := l.user
	num_repos := l.num_repos
	num_languages := l.num_languages

	return $tmpl(gql_lang)
}

pub fn (l Languages) to_body() string {
	return json.encode({
		'query': l.query()
	})
}
