module svg

const svg_width = 360

pub struct Language {
pub:
	fill  string
	score int
	lang  string
}

pub fn (l Language) percent(total int) f32 {
	if total == 0 {
		return 0.0
	}
	return f32(l.score) / f32(total) * 100.0
}

pub fn (l Language) width(total int) int {
	if total == 0 {
		return 0
	}

	return int(l.percent(total) * svg_width / 100.0)
}

pub fn (l Language) svg(total int, offset int) string {
	fill := l.fill
	lang := l.lang
	percent := '${l.percent(total):.2f}'
	width := l.width(total)

	return $tmpl('../assets/lang.svg')
}
