module main

import log

fn request_logger(mut ctx Ctx) bool {
	log.info('ctx.request.query: ${ctx.query}')
	log.info('ctx.request.url: ${ctx.req.host}${ctx.req.url}')

	return true
}

fn response_logger(mut ctx Ctx) bool {
	log.info('ctx.response.status: ${ctx.res.status()}')
	log.info('ctx.response.header: ${ctx.res.header}')

	return true
}
