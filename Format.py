lines = [line.rstrip('\n') for line in open('hosts')]

output = '[{"trigger":{"url-filter":".*","if-domain":['
for line in lines:
	output += '"' + line + '",'

output = output[:-1]
output += ']},"action":{"type":"block"}}]'

print output
