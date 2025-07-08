module client

import arrays

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
					edges []Edge
				}
			}
		} @[json: 'search']
	} @[json: 'data']
}

pub fn (dto SearchResponseDTO) edges() []Edge {
	return arrays.flatten(dto.data.search.nodes.map(it.languages.edges))
}

pub fn (dto SearchResponseDTO) get_languages(ls LanguagesSkip) (map[string]int, int) {
	return dto.edges().score(ls)
}

pub struct LanguagesResponseDTO {
	data struct {
		user struct {
			respositories struct {
				nodes []struct {
					name      string
					pushed_at string @[json: 'pushedAt']
					languages struct {
						edges []Edge
					}
				}
			} @[json: 'repositories']
		} @[json: 'user']
	} @[json: 'data']
}

pub fn (dto LanguagesResponseDTO) edge() []Edge {
	return arrays.flatten(dto.data.user.respositories.nodes.map(it.languages.edges))
}

pub fn (dto LanguagesResponseDTO) get_languages(ls LanguagesSkip) (map[string]int, int) {
	return dto.edge().score(ls)
}
