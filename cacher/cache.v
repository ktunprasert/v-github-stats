module cacher

import os
import log
import time

pub struct Cacher {
}

const public = '../public'

fn init() {
	if !os.exists(public) {
		log.debug('cacher: ensuring ./public exists')
		os.mkdir_all(public) or { log.error('failed to create public directory: ${err}') }
	}
}

pub fn (c Cacher) cache(filename string, content string) ! {
	if os.exists(c.filename(filename)) {
		return error('file already exists')
	}

	log.debug('cacher: caching ${filename}')
	os.write_file(c.filename(filename), content)!
	log.debug('cacher: cached ${filename}.svg')
}

pub fn (c Cacher) get(filename string) !string {
	if !os.exists(c.filename(filename)) {
		return error('file does not exist')
	}

	log.debug('cacher: getting ${filename}.svg')
	content := os.read_file(c.filename(filename)) or {
		return error('failed to read file: ${err}')
	}

	log.debug('cacher: got ${filename}.svg')
	return content
}

// localised to the nearest date
pub fn (c Cacher) filename(filename string) string {
	today := time.now().ymmdd()

	return '${public}/${filename}.${today}.svg'
}
