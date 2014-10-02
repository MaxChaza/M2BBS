#!/usr/bin/python
# Copyright 2014 BARRIOT Roland
# This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

import argparse
from os.path import isfile
from scipy.stats import binom

# SCRIPT PARAMETERS
# e.g. ./search_enriched_sets.py --sets EcolA.biocyc.sets --query 'ALAS ARGS ASNS ASPS CYSS GLTX GLYQ GLYS HISS ILES'
parser = argparse.ArgumentParser(description='Search enriched categories in provided gene set')
parser.add_argument('--query', required=True, help='Query set.')
parser.add_argument('--sets', required=True, help='Target sets (categories).')
parser.add_argument('--alpha', required=False, default=0.05, help='Singnificance threshold.')
parser.add_argument('--adjust', required=False, action="store_true", help='Adjust for multiple testing (FDR).')
param = parser.parse_args()

class Identifiers(object) :
	def __init__(self, text = None, filename = None, name = None):
		self.name = name
		self.ids = []
		self.index = {}
		if text is not None:
			self.load(text)
		elif filename is not None:
			self.load(filename)

	def load(self, text):
		if isfile(text):
			with open(text) as f:
				content = f.read()
				lines = content.split('\n')
				i=0
				for l in lines:
					if l!='':
						words = l.split()
						for w in words:
							if w not in self.index:
								self.index[w] = i
								i += 1
								self.ids.append(w)
		else: # parse string
			i=0
			words = text.split()
			for w in words:
				if w not in self.index:
					self.index[w] = i
					i += 1
					self.ids.append(w)

class ComparedSet(object):
	def __init__(self, id, name = '', common = 0, size = 0, pvalue = 1, elements = [], common_elements = []):
		self.id = id
		self.name = name
		self.common = common
		self.size = size
		self.pvalue = pvalue
		self.elements = elements
		self.common_elements = common_elements

# LOAD QUERY
query = Identifiers(param.query)

# LOAD REFERENCE SETS
def load_sets(filename):
	sets = {}
	ids={}
	with open( filename ) as f:
		content = f.read()
		lines = content.split('\n')
		for l in lines:
			words = l.split('\t')
			if len(words) > 2 and not words[0].startswith('#'):
				id = words.pop(0)
				name = words.pop(0)
				sets[ id ] = { 'name': name, 'elements': words}
				for w in words:
					ids[w] = 1
	return [ sets, len( ids.keys() ) ]
(sets, population_size) = load_sets(param.sets)

# EVALUATE SETS
results = []
query_size = len(query.ids)
for id in sets:
	elements = sets[ id ][ 'elements' ]
	common_elements = set(elements).intersection( query.ids )
	# p_success = 384/2064, 152 attempts, 61 success
	#~ pval = binom.pmf(61, 152, 384.0/2064)
	#~ for k in xrange(62,153): pval += binom.pmf(k, 152, 384.0/2064)
	#~ print "sum binom.pmf(61..152,152, 384/2064) = %s" % ( pval )
	#~ print "cdf binom.cdf(>=61,152, 384/2064) = "+str( binom.cdf(152-61,152, 1- (384.0/2064)) )
	pval = binom.cdf( query_size - len(common_elements), query_size, 1 - float(len(elements))/population_size)
	r = ComparedSet( id, sets[id]['name'], len(common_elements), len(elements), pval, elements, common_elements)
	results.append( r )

# PRINT SIGNIFICANT RESULTS
results.sort(key=lambda an_item: an_item.pvalue)
i=1
alpha = float(param.alpha)
for r in results:
	# alpha threshold
	if r.pvalue > alpha: exit(0)
	# FDR
	elif param.adjust and r.pvalue > alpha * i / len(results): exit(0)
	# OUTPUT
	print "%s\t%s\t%s/%s\t%s\t%s" % ( r.id, r.pvalue, r.common, r.size, r.name, ', '.join(r.common_elements))
	i=i+1
