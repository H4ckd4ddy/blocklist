#!/usr/bin/env python3

import pandas
import urllib.request
import hashlib
import re

blocklist_file = "blocklist.csv"
sources_file = "sources.csv"

blocklist = pandas.read_csv(blocklist_file, sep=',', encoding='latin-1')
sources = pandas.read_csv(sources_file, sep=',', encoding='latin-1')

BLOCKSIZE = 65536
sha1 = hashlib.sha1()

def sanitize_domain(domain):
	sanitized_domain = domain
	sanitized_domain = re.sub('\r', '', sanitized_domain)
	sanitized_domain = re.sub('\n', '', sanitized_domain)
	sanitized_domain = re.sub('[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3} ', '', sanitized_domain)
	sanitized_domain = re.sub(' ', '', sanitized_domain)
	sanitized_domain = re.sub('#.*', '', sanitized_domain)
	sanitized_domain = re.sub('\t', '', sanitized_domain)
	sanitized_domain = re.sub('^\.', '', sanitized_domain)
	if len(sanitized_domain) <= 1:
		return None
	return sanitized_domain
	
for index, source in sources.iterrows():

	try:
		urllib.request.urlretrieve(source['url'], 'current.list')
	except:
		print('Source unreachable')
		print('Skip : '+source['url'])
		continue

	with open('current.list', 'rb') as current_list:
		lines_count = sum(1 for line in current_list)

	with open('current.list', 'rb') as current_list:
		buf = current_list.read(BLOCKSIZE)
		while len(buf) > 0:
			sha1.update(buf)
			buf = current_list.read(BLOCKSIZE)

		if sha1.hexdigest() == source['hash']:
			print('No change')
			print('Skip : '+source['url'])
			continue

	with open('current.list', 'r') as current_list:
		i = 0
		for line in current_list:
			i += 1
			sanitized_line = sanitize_domain(line)
			if sanitized_line:
				if not len(blocklist.loc[blocklist['domain'] == sanitized_line].to_dict('records')):
					print('Add {}'.format(sanitized_line))
					new_domain = pandas.DataFrame({
						"domain": [sanitized_line],
						"status": ["BLACKLISTED"],
						"comment": ["Merged from {}".format(source['url'])],
						"date": ["now"]
					})
					blocklist = blocklist.append(new_domain, ignore_index=True)
			print('Domain ({}/{}) of source ({}/unknow)'.format(i, lines_count, index))

	sources.loc[(sources.url == source['url']), 'hash'] = sha1.hexdigest()

print('save')

blocklist.to_csv(blocklist_file, index=False, encoding='utf8')
sources.to_csv(sources_file, index=False, encoding='utf8')