module client

@[params]
pub struct LanguagesSkip {
pub:
	blacklist []string = ['JavaScript', 'CSS', 'PHP']
}

// as of 2025-07-06T22:59:57 the anonymous struct requires @json attribute
pub struct SearchResponseDTO {
	data struct {
		search struct {
			nodes []struct {
				name      string
				pushed_at string @[json: 'pushedAt']
				languages struct {
					edges []struct {
						size int
						node struct {
							name string
						}
					}
				}
			}
		} @[json: 'search']
	} @[json: 'data']
}

pub fn (dto SearchResponseDTO) get_languages(ls LanguagesSkip) (map[string]int, int) {
	mut total := 0
	mut languages := map[string]int{}
	for repo in dto.data.search.nodes {
		for edge in repo.languages.edges {
			language := edge.node.name
			if language in ls.blacklist {
				continue
			}

			size := edge.size
			total += size
			if language in languages {
				languages[language] += size
			} else {
				languages[language] = size
			}
		}
	}

	return languages, total
}

pub struct LanguagesResponseDTO {
	data struct {
		user struct {
			respositories struct {
				nodes []struct {
					name      string
					pushed_at string @[json: 'pushedAt']
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

pub fn (dto LanguagesResponseDTO) get_languages(ls LanguagesSkip) (map[string]int, int) {
	mut total := 0
	mut languages := map[string]int{}
	for repo in dto.data.user.respositories.nodes {
		for edge in repo.languages.edges {
			language := edge.node.name
			if language in ls.blacklist {
				continue
			}

			size := edge.size

			total += size
			if language in languages {
				languages[language] += size
			} else {
				languages[language] = size
			}
		}
	}

	return languages, total
}
