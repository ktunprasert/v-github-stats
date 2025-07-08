module client

pub struct Edge {
	size int
	node struct {
		name string
	}
}

fn (edges []Edge) score(ls LanguagesSkip) map[string]int {
	mut bytes_map := map[string]int{}
	mut count_weight := map[string]int{}
	for edge in edges {
		language := edge.node.name
		if language in ls.blacklist {
			continue
		}

		size := edge.size
		if language in bytes_map {
			bytes_map[language] += size
			count_weight[language] += 1
		} else {
			bytes_map[language] = size
			count_weight[language] = 1
		}
	}

	mut languages := map[string]int{}
	for key, value in bytes_map {
		score := value / count_weight[key]
		languages[key] = score
	}

	return languages
}
