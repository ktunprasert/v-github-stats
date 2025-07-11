module svg

import log
import time
import strings
import arrays

@[params]
pub struct StatsConfig {
pub:
	limit int = 10
}

pub fn build_stats(ls []Language, name string, sc StatsConfig) string {
	total := arrays.sum(ls.map(it.score)) or { 0 }

	mut lang_arr := ls.clone()
	mut offset := 20

	lang_arr.sort(|a, b| b.score < a.score)
	lang_arr.trim(sc.limit)
	height := (lang_arr.len * 40) + 20 + 25
	foot := height - 15
	log.debug('svg.langs: ${lang_arr.map(it.lang)}')
	log.debug('svg.score: ${lang_arr.map(it.score)}')
	log.debug('svg.percent: ${lang_arr.map(it.percent(total))}')

	mut langs_builder := strings.new_builder(1000)
	for lang in lang_arr {
		langs_builder.write_string(lang.svg(total, offset))
		offset += 40
	}

	langs := langs_builder.str()
	date := time.now().ddmmy()
	stats_svg := $tmpl('../assets/stats.svg')

	return stats_svg
}
