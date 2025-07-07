module client

// as of 2025-07-06T22:59:57 the anonymous struct requires @json attribute
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

pub fn (dto LanguagesResponseDTO) get_languages() map[string]int {
	mut languages := map[string]int{}
	for repo in dto.data.user.respositories.nodes {
		for edge in repo.languages.edges {
			language := edge.node.name
			size := edge.size
			if language in languages {
				languages[language] += size
			} else {
				languages[language] = size
			}
		}
	}

	return languages
}

