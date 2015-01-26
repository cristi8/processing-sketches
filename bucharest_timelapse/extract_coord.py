#!/usr/bin/python

from datetime import datetime
from pymongo import MongoClient

dbc = MongoClient().clever.cpos

# Start and end date for the timelapse
date0 = datetime(2015, 01, 26, 10, 30)
date1 = datetime(2015, 01, 26, 21, 30)

constraints = { 'timestamp': {'$gt': date0, '$lt': date1} }
frames_iter = dbc.find(constraints).sort('timestamp', 1)

print 'Found data for %d frames' % frames_iter.count()

g = open('cpositions.txt', 'w')
for frame in frames_iter:
    g.write('%s\n' % frame['timestamp'].strftime('%A, %b %d, %Y   %X'))
    g.write('%s\n' % frame['car_count'])
    pos_list = frame['positions']
    for pos in pos_list:
        g.write('%s %s %s ' % (pos['n'], pos['a'], pos['cid']))
    g.write('\n')

g.close()
print 'DONE'

