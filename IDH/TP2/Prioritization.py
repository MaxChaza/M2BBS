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


from os.path import isfile
import h5py
import numpy as np
import datetime

class ScoreMatrix(object):
	# attributes:
	## datasource
	## date
	## mode = similarity | distance
	## representation = alaR
	## strain
	## comment
	## labels
	# representation alaR
	# alaR=lower triangle column wise
	# index k is n*(i-1) - i*(i-1)/2 + j-i -1
	# i\j 0  1  2  3  4  5  6  7  8  9
	# 0   
	# 1   0 
	# 2   1  9
	# 3   2 10 17
	# 4   3 11 18 24
	# 5   4 12 19 25 30
	# 6   5 13 20 26 31 35
	# 7   6 14 21 27 32 36 39
	# 8   7 15 22 28 33 37 40 42
	# 9   8 16 23 29 34 38 41 43 44
	# class variables
	NA = float("nan")  # float("-inf")

	def __init__(self, filename=None):
		self.filename = filename
		# reset
		self.strain = 'NA'
		self.datasource = 'NA'
		self.date = 'NA'
		self.mode = 'NA'
		self.comment = 'NA'
		self.labels = None
		self.matrix = None
		self.minimum = float("+inf")
		self.maximum = float("-inf")
		self.mean = 0
		self.nb_values = 0
		self.nb_NA = 0
		self.representation = 'alaR'
		self.h5 = None
		# reset
		if filename is not None:
			self.load(filename)
		else:
			self.h5 = None

	def reset(self):
		self.strain = 'NA'
		self.datasource = 'NA'
		self.date = 'NA'
		self.mode = 'NA'
		self.comment = 'NA'
		self.symmetric = True
		self.labels = None
		self.matrix = None
		self.minimum = float("+inf")
		self.maximum = float("-inf")
		self.mean = 0
		self.nb_values = 0
		self.nb_NA = 0
		self.representation = 'alaR'
		self.h5 = None

	def load(self, filename=None):
		self.reset()
		# check filename
		if filename is not None:
			self.filename = filename
		if self.filename is None or not isfile(self.filename):
			return None
		if filename.endswith('.h5') or filename.endswith('.hf5') or filename.endswith('.hdf5'):
			return self.load_hdf5(filename)
		elif filename.endswith('.gz'):
			return self.load_gz(filename)
		else:
			print "Unrecognize file format"
			return None

	def load_parse_meta(self, s):
		if s.startswith('# datasource: '):
			self.datasource = s.replace('# datasource: ', '')
		elif s.startswith('# strain: '):
			self.strain = s.replace('# strain: ', '')
		elif s.startswith('# date: '):
			self.date = s.replace('# date: ', '')
		elif s.startswith('# mode: '):
			self.mode = s.replace('# mode: ', '')
		elif s.startswith('# comment: '):
			self.comment = s.replace('# comment: ', '')
		elif s.startswith('# representation: '):
			self.representation = s.replace('# representation: ', '')

	def load_gz(self, filename=None):
		import gzip
		# check filename
		if filename is not None:
			self.filename = filename
		if self.filename is None or not isfile(self.filename):
			return None
		f = gzip.open(filename,'r')
		s = f.readline().rstrip()
		while s.startswith('#'): # metadata
			self.load_parse_meta(s)
			s = f.readline().rstrip()
		n = int(s) # number of genes
		self.labels = {}
		for i in xrange(n):
			s = f.readline().rstrip()
			self.labels[s] = i
		#~ print self.labels
		self.matrix = np.empty( n*(n-1)/2,  dtype=np.float32)
		for i in xrange( n*(n-1)/2 ):
			s = f.readline().rstrip()
			if s == 'NA':
				self.matrix[i] = np.NAN
			else:
				self.matrix[i] = float(s)
		f.close()
		# process NAs
		m = self.matrix
		# COMPUTE SOME STATS
		if np.isnan(self.NA):
			self.nb_NA = len(m[ np.isnan(m) ])
		else:
			self.nb_NA = len(m[ m==self.NA ])
		self.minimum = np.nanmin(m)
		self.maximum = np.nanmax(m)
		self.mean = np.nanmean(m)

	def load_hdf5(self, filename=None):
		# check filename
		if filename is not None:
			self.filename = filename
		if self.filename is None or not isfile(self.filename):
			return None
		self.h5 = h5py.File(self.filename, 'r+')
		# METADATA
		if 'strain'in self.h5.attrs: self.strain = self.h5.attrs['strain']
		if 'datasource'in self.h5.attrs: self.datasource = self.h5.attrs['datasource']
		if 'date'in self.h5.attrs: self.date = self.h5.attrs['date']
		if 'comment'in self.h5.attrs: self.coment = self.h5.attrs['comment']
		if 'mode'in self.h5.attrs: self.mode = self.h5.attrs['mode']
		if 'comment'in self.h5.attrs: self.comment = self.h5.attrs['comment']
		if 'representation'in self.h5.attrs: self.representation = self.h5.attrs['representation']
		# allocate memory and read entire matrix
		self.matrix = np.empty(self.h5['matrix'].shape,  dtype=np.float32)
		self.h5['matrix'].read_direct(self.matrix)
		# process NAs
		m = self.matrix
		# COMPUTE SOME STATS
		if np.isnan(self.NA):
			self.nb_NA = len(m[ np.isnan(m) ])
		else:
			self.nb_NA = len(m[ m==self.NA ])
		self.minimum = np.nanmin(m)
		self.maximum = np.nanmax(m)
		self.mean = np.nanmean(m)
		# LOAD LABELS
		self.labels = {}
		index = 0
		for i in str(self.h5.attrs['labels']).split(','):
			self.labels[i] = index
			index += 1
		self.h5.close()
		self.h5=None

	def save(self, filename=None, meta=None):
		self.save_hdf5(filename, meta)

	def save_hdf5(self, filename=None, meta=None):
		self.h5 = h5py.File(filename, 'w')
		if meta is not None:
			for attr in meta:
				self.h5.attrs[ attr ] = np.string_(meta[ attr ])
		else:
			self.h5.attrs[ 'strain' ] = np.string_(self.strain)
			self.h5.attrs[ 'datasource' ] = np.string_(self.datasource)
			self.h5.attrs[ 'date' ] = np.string_(self.date)
			self.h5.attrs[ 'mode' ] = np.string_(self.mode)
			self.h5.attrs[ 'comment' ] = np.string_(self.comment)
			#~ self.h5.attrs[ 'symmetric' ] = np.string_(self.symmetric)
		self.h5.attrs['representation'] = np.string_(self.representation)
		labs = sorted( self.labels, key=self.labels.get)
		self.h5.attrs['labels'] = np.string_(','.join( labs ) )
		self.h5.create_dataset('matrix', data=self.matrix)
		self.h5.close()
		self.h5=None

	def print_info(self):
		if self.h5 is not None:
			for j in self.h5.attrs:
				if j!='labels':
					print '%s  : %s' % (j, ''.join(str(self.h5.attrs[j])))
				else:
					print j+': '+self.h5.attrs[j][0:50]+'...'
			print 'matrix: '+str(self.h5['matrix'][0:5])
			print "min: %s, max: %s, mean: %s, NAs: %s" % (self.minimum, self.maximum, self.mean, self.nb_NA)
		else:
			print "strain: "+self.strain
			print "datasource: "+self.datasource
			print "date: "+self.date
			print "mode: "+self.mode
			print "representation: "+self.representation
			print "comment: "+self.comment
			print 'matrix: '+str(self.matrix[0:5])
			print "min: %s, max: %s, mean: %s, NAs: %s" % (self.minimum, self.maximum, self.mean, self.nb_NA)

	def get(self, id1, id2):
		# do we have some data?
		if self.matrix is None:
			return None
		# known ids?
		if id1 not in self.labels or id2 not in self.labels:
			return None
		#~ if self.h5.attrs['representation'] == 'alaR':
		if self.representation == 'alaR':
			# alaR=lower triangle column wise
			# index k is n*(i-1) - i*(i-1)/2 + j-i -1
			# i\j 0  1  2  3  4  5  6  7  8  9
			# 0   
			# 1   0 
			# 2   1  9
			# 3   2 10 17
			# 4   3 11 18 24
			# 5   4 12 19 25 30
			# 6   5 13 20 26 31 35
			# 7   6 14 21 27 32 36 39
			# 8   7 15 22 28 33 37 40 42
			# 9   8 16 23 29 34 38 41 43 44
			i = self.labels[id1]+1
			j = self.labels[id2]+1
			if i > j:
				(i, j) = (j, i)  # sort indices, must have i<j
			# compute index in vector
			k = len(self.labels) * (i-1) - i * (i-1)/2 + j - i - 1
			return self.matrix[k]

	def set(self, id1, id2, val):
		# known ids?
		if id1 not in self.labels or id2 not in self.labels:
			print "unknown ids"
			return None
		if self.representation == 'alaR':
			i = self.labels[id1]+1
			j = self.labels[id2]+1
			if i > j:
				(i, j) = (j, i)  # sort indices, must have i<j
			# compute index in vector
			k = len(self.labels) * (i-1) - i * (i-1)/2 + j - i - 1
			self.matrix[k] = val
			return self.matrix[k]


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


class IdentifierMap(object):
	relationship_order = { 'BeH': 0, 'Ort':1, 'Iso': 2 }
	def __init__(self, filename = None, relationship='BeH', filter_cgdb_prefix=False):
		self.filename = filename
		# reset
		self.forward = None
		self.backward = None
		if filename is not None:
			self.load(filename, relationship=relationship, filter_cgdb_prefix=filter_cgdb_prefix)

	def load(self, filename, relationship='BeH', filter_cgdb_prefix=False):
		self.forward={}
		self.backward={}
		with open(filename) as f:
			line = str(f.readline()).rstrip()
			while line:
				if not line.startswith('#'): # skip comments
					words = line.split()
					id1 = words[0]
					id2 = words[1]
					rel = words[2] if len(words)==3 else words[12] # .map or .par format
					if self.relationship_order[ rel ] >= self.relationship_order[ relationship ]:
						self.forward[words[0]] = words[1]
						self.backward[words[1]] = words[0]
				line = str(f.readline()).rstrip()
		if filter_cgdb_prefix:
			self.remove_cgdb_prefix()

	def remove_prefix(self, pattern='[A-Z][a-z]{3}[A-Z]\d{2}\.'):
		import re
		p = re.compile(pattern)
		an_id = self.backward.keys()[0]
		m = p.match( an_id )
		w = m.group()
		for i in self.backward.keys():
			if not i.startswith(w):
				return
		backward = {}
		for k in self.forward:
			v = self.forward[k][8:]
			backward[ v ] = k
			self.forward[k] = v
		self.backward = backward


class PrioritizedItem(object):
	def __init__(self, id=None, score=None, rank=None, rank_ratio=None, zscore=None, comment=None, mapped=None, data={}):
		self.id = id
		self.score = score
		self.rank = rank
		self.rank_ratio = rank_ratio
		self.zscore = zscore
		self.comment = comment
		self.mapped = mapped
		self.data = data

	def display(self):
		score = self.score
		zscore = self.zscore
		if score==Prioritizer.NA:
			score = 'NA'
			zscore = 'NA'
		mapped = ''
		if self.mapped is not None:
			mapped = self.mapped
		comment = ''
		if self.comment is not None:
			comment = i.comment
		print "%s\t%s\t%s\t%s\t%s\t%s\t%s" % (self.id, score, self.rank, self.rank_ratio, zscore, mapped, comment)

class Prioritizer(object):
	NA = ScoreMatrix.NA

	def __init__(self, matrixfile = None):
		self.matrix = None
		if matrixfile is not None:
			self.load_matrix(matrixfile)

	def load_matrix(self, filename):
		self.matrix = ScoreMatrix(filename)

	def set_distance(self, id, a_list):
		m = self.matrix
		sum = 0
		n = 0
		for i in a_list:
			if id != i: # do not use training gene as candidate
				score = m.get(id, i)
				if score is not None and not np.isnan(score):
					sum += score
					n += 1
		if n==0:
			return np.NaN
		return float(sum)/n

	def prioritize(self, training_set, candidate_set=None, mapping=None):
		res = []
		training = []
		# MAPPING OF TRAINING SET
		if mapping is not None:
			for i in training_set:
				if i in mapping.forward:
					training.append( mapping.forward[i] )
		else:
			training = training_set
		# CANDIDATES AND THEIR MAPPING
		candidates = []
		if candidate_set is None:  # no candidates provided
			if mapping is None:  # no mapping : use matrix ids
				candidates = self.matrix.labels.keys()
			else:  # no cand but mapping provided : use mapped ids
				for i in mapping.forward:
					candidates.append( mapping.forward[i] )
		elif mapping is None: # cand with no map: use cand
			candidates = candidate_set
		else: # cand and mapping provided use mapped cand
			for i in candidate_set:
				if i in mapping.forward:
					candidates.append(mapping.forward[i])
		for i in candidates:
			score = self.set_distance(i, training)
			if mapping is None:
				res.append(PrioritizedItem(i, score))
			else:
				res.append(PrioritizedItem( id=mapping.backward[i], score=score, mapped=i))
		return Prioritizer.rank_list(res)

	def loocvs(self, training_sets, candidate_set=None, mapping=None):
		res = {}
		rank_ratios = []
		for name in training_sets:
			genes = training_sets[ name ]
			# perform prioritization
			pri = self.prioritize(genes, candidate_set, mapping)
			# retrieve training genes rank ratios
			res[ name ] = []
			for pi in pri:
				if pi.id in genes:
					res[ name ].append(pi)
					rank_ratios.append( pi.rank_ratio)
		return { 'sets': res, 'auc': 1.-np.nanmean( rank_ratios ) }

	@classmethod
	def to_prioritizedItem_list(a_list):
		res = []
		size = len(a_list)
		for i in xrange(size):
			res.append( PrioritizedItem(a_list[i], Prioritizer.NA, i, (i-1)/(size-1), Prioritizer.NA))
		return res

	@classmethod
	def rank_list(self,a_list):
		l = len(a_list)
		# z-scores
		scores = []
		for i in a_list:
			if i.score!=float("inf") and not np.isnan(i.score):
				scores.append(i.score)
		if len(scores) > 0:
			the_mean = np.nanmean(scores)
			the_sd = np.nanstd(scores)
		for i in a_list:
			if i.score != Prioritizer.NA and len(scores)>0:
				i.zscore = (i.score - the_mean) / the_sd
			else:
				i.zscore = Prioritizer.NA
		# SORT BY SCORE ASCENDING
		a_list.sort(key=lambda an_item: float("+inf") if np.isnan(an_item.score) else an_item.score)
		# COMPUTE RANK
		# FROM 1..NB_ITEMS e.g. 1, 3, 3, 3, 5
		rank_min = 1;
		rank_max = 1;
		nb_items = len(a_list)
		i=0;
		while i < nb_items:
			j = i+1
			while j < nb_items and a_list[i].score == a_list[j].score:
				j += 1
			# either at end of list or score differs at j
			rank = (rank_min + j) / 2; # ok, since rank_min starts at 1 and is updated to j+1, and j spans 0..n-1
			rank_max = rank
			for k in xrange(i, j):
				a_list[k].rank = rank
			rank_min = j + 1;
			i = j
		# COMPUTE RANK RATIO
		for p in a_list:
			if rank_max > 0:
				p.rank_ratio = (float(p.rank) - 1) / (rank_max - 1)  # 0..1
			else:
				p.rank_ratio = 1
		return a_list

	@classmethod
	def display(self,a_list, lines = None):
		print "id\tscore\trank\trank_ratio\tz-score\tmapped_id\tcomment"
		to_display = a_list
		if lines is not None:
			to_display = a_list[:lines]
		for i in to_display:
			score = i.score
			zscore = i.zscore
			if score==Prioritizer.NA:
				score = 'NA'
				zscore = 'NA'
			mapped = ''
			if i.mapped is not None:
				mapped = i.mapped
			comment = ''
			if i.comment is not None:
				comment = i.comment
			print "%s\t%s\t%s\t%s\t%s\t%s\t%s" % (i.id, score, i.rank, i.rank_ratio, zscore, mapped, comment)

	def save(self, filename, a_list, lines = None, header=True, meta=True, sep='\t', template=['id','score','rank','rank_ratio','zscore', 'mapped', 'comment']):
		f = open(filename, 'w')
		if meta:
			f.write('# strain: '+self.matrix.strain+"\n")
			f.write('# datasource: '+self.matrix.datasource+"\n")
			f.write('# date: '+datetime.date.today().strftime('%Y-%m-%d')+"\n")
			f.write('# comment: '+self.matrix.comment+"\n")
		if header:
			f.write( sep.join(template)+"\n")
		to_display = a_list
		if lines is not None:
			to_display = a_list[:lines]
		for i in to_display:
			if i.score==Prioritizer.NA or np.isnan(i.score):
				i.score = 'NA'
				i.zscore = 'NA'
			if i.mapped is None:
				i.mapped = ''
			if i.comment is None:
				i.comment = ''
			line = []
			attr = dir(i)
			for a in xrange(len(template)):
				if template[a] in attr:
					line.append( str( getattr( i, template[a] )) )
				elif template[a] in i.data:
					line.append( str( i.data[ template[a] ] ) )
				else:
					print template[a]+' not found in PrioritizedItem'
			f.write( sep.join(line)+"\n")
		f.close()

	@classmethod
	def load_pri(self, filename):
		res = []
		with open(filename) as f:
			row = f.readline()
			while row:
				li = str(row)
				if not li.startswith('#') and not (li.startswith('id') or li.startswith('candidate') or li.startswith('gene')): # skip comments and header
					vals = li.rstrip().split('\t')
					res.append (PrioritizedItem(vals[0], vals[1], vals[2], vals[3], vals[4]))
				row = f.readline()
		return res

	@classmethod
	def load_pris(self, filename):
		ids = []
		head = None
		res = []
		with open(filename) as f:
			row = f.readline()
			while row:
				li = str(row).rstrip()
				if li.startswith('candidate') or li.startswith('gene'):  # header
					head = li.split('\t')
					head.pop(0) # remove candidate / gene from datasource names
				elif not li.startswith('#') : # skip comments
					vals = li.rstrip().split('\t')
					ids.append( vals.pop(0) )
					for i in xrange(len(vals)):
						if vals[i]!='NA':
							vals[i] = float(vals[i])
						else:
							vals[i] = float("nan")
					res.append ( vals )
				row = f.readline()
		mat = np.matrix(res)
		return { 'id': ids, 'matrix': mat, 'head': head}

	@classmethod
	def impute(self, mat, method='mean'):
		rows, cols = mat.shape
		means = []
		for j in xrange(cols):
			means.append(np.nanmean( mat[:,j] ))
			for i in xrange(rows):
				if np.isnan(mat[i,j]):
					mat[i,j] = means[j]

	@classmethod
	def fusion(self, ids, training, matrix, colnames, method='lda'):
		from sklearn.lda import LDA
		nbrows, nbcols = matrix.shape
		m=matrix[:,:] # copy matrix
		self.impute(m) # impute missing values
		classes = map(lambda x: 1 if x in training else 2, ids)
		clf = LDA()
		clf.fit(m, classes)
		weights = {}
		for w in xrange(len(colnames)):
			weights[ colnames[w] ] = clf.scalings_[w][0]
		fusion = clf.transform(m)
		# build result structure
		res = []
		for i in xrange(nbrows):
			r = { 'id': ids[i], 'fusion': fusion[i][0] }
			for j in xrange(nbcols):
				r[ colnames[j] ] = matrix[i,j]
			res.append(r)
		res = { 'genes': sorted(res, key=lambda x: x['fusion'], reverse=True), 'weights': weights }
		return res

	@classmethod
	def plot(self, fus, training, colnames, save_as=None):
		import matplotlib.pyplot as plt
		plt.figure()
		plt.rc('xtick', labelsize=6)
		plt.rc('ytick', labelsize=6)
		num_bins = 100
		fused = fus['genes']
		for j in xrange(len(colnames)):
			plt.subplot(len(colnames), 1, j)
			vals = []
			train = []
			train_label = []
			cand = []
			for i in xrange(len(fused)):
				if not np.isnan(fused[i][colnames[j]]):
					if fused[i]['id'] in training:
						train.append(fused[i][colnames[j]])
						train_label.append( fused[i]['id'] )
					else:
						cand.append(fused[i][colnames[j]])
					vals.append(fused[i][colnames[j]])
			n, bins, patches = plt.hist(vals, num_bins, facecolor='gray')
			ymax = -float(max(n))
			ystep = ymax / (len(train)+2)
			if j==0:
				plt.title(colnames[j], size=8)
			else:
				plt.title(colnames[j]+' (w: '+str( fus['weights'][colnames[j]])+')', size=8)
				plt.axis([0, 1, ymax, -ymax] )
			for t in xrange(len(train)):
				plt.plot(train[t], ystep*(t+1), 'g.')
				plt.text(train[t], ystep*(t+1), train_label[t], size=6)
			plt.plot(cand, [ystep * (len(train)+1) ]*len(cand), 'r.')
		if save_as is None:
			plt.show()
		else:
			plt.savefig(save_as, bbox_inches='tight', dpi=150)
		plt.close()

	@classmethod
	def load_training_sets(self, filename):
		sets = {}
		with open(filename) as f:
			row = f.readline()
			while row:
				li = str(row).rstrip()
				vals = li.split('\t')
				set_name = vals.pop(0)
				if set_name != "":
					sets[ set_name] = vals
				row = f.readline()
		return sets


if __name__ == "__main__":
	print

