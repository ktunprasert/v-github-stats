module cacher

import os
import log
import time

pub struct Cacher {
pub:
	should_cache bool
}

const public = './public'

fn init() {
	if !os.exists(public) {
		log.debug('cacher: ensuring ./public exists')
		os.mkdir_all(public) or { log.error('failed to create public directory: ${err}') }
	}
}

pub fn (c Cacher) cache(filename string, content string) ! {
	if !c.should_cache {
		log.debug('cacher: caching is disabled')
		return
	}

	file := c.filename(filename)
	if os.exists(file) {
		return error('file already exists')
	}

	os.write_file(file, content)!
	log.debug('cacher: cached ${file} OK')
}

pub fn (c Cacher) get(filename string) !string {
	if !c.should_cache {
		log.debug('cacher: caching is disabled')
		return error('caching is disabled')
	}

	file := c.filename(filename)
	if !os.exists(file) {
		return error('file does not exist')
	}

	content := os.read_file(file) or { return error('failed to read file: ${err}') }

	log.debug('cacher: cache hit! got ${file}')
	return content
}

// localised to the nearest date
pub fn (c Cacher) filename(filename string) string {
	today := time.now().ymmdd()

	return '${public}/${filename}.${today}.svg'
}
