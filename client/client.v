module client

import graphql
import os
import net.http
import json

const base_url = 'https://api.github.com/graphql'

@[params]
pub struct ClientConfig {
	token string = os.getenv('GH_TOKEN')
}

pub fn new_client(cc ClientConfig) Client {
	return Client{cc.token}
}

pub struct Client {
	token string
}

pub fn (c Client) query[T](q graphql.Queryable) !T {
	mut request := http.new_request(.post, base_url, q.to_body())
	request.add_header(.authorization, 'Bearer ${c.token}')
	println(request.header)

	response := request.do()!
	if response.status_code > 200 {
		return error('something went wrong - check your environment values or .env')
	}

	dto := json.decode(T, response.body)!
	return dto
}
