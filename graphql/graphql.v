module graphql

import os
import x.json2

const gql_lang = 'languages.graphql'
const gql_search = 'search.graphql'

pub interface Queryable {
	query() string
	to_body() string
}

@[params]
pub struct LanguagesConfig {
pub mut:
	user          string = os.getenv('GH_USER')
	num_repos     int    = 5
	num_languages int    = 10
}

pub fn (l LanguagesConfig) validate() !LanguagesConfig {
	if l.num_repos > 100 {
		return error('num_repos of ${l.num_repos} too high, maximum value of 100 allowed')
	}
	if l.num_languages > 20 {
		return error('num_languages of ${l.num_languages} too high, maximum value of 20 allowed')
	}

	return l
}

struct Search {
	user          string
	num_repos     int
	num_languages int
}

pub fn new_search(l LanguagesConfig) Search {
	return Search{
		user:          l.user
		num_repos:     l.num_repos
		num_languages: l.num_languages
	}
}

pub fn (l Search) query() string {
	user := l.user
	num_repos := l.num_repos
	num_languages := l.num_languages

	return $tmpl(gql_search)
}

pub fn (l Search) to_body() string {
	return json2.encode({
		'query': l.query()
	})
}

struct Languages {
	user          string
	num_repos     int
	num_languages int
}

pub fn new_language(l LanguagesConfig) Languages {
	return Languages{
		user:          l.user
		num_repos:     l.num_repos
		num_languages: l.num_languages
	}
}

fn (l Languages) query() string {
	user := l.user
	num_repos := l.num_repos
	num_languages := l.num_languages

	return $tmpl(gql_lang)
}

pub fn (l Languages) to_body() string {
	return json2.encode({
		'query': l.query()
	})
}
