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

# SCRIPT PARAMETERS
parser = argparse.ArgumentParser(description='Prioritize a list of candidate genes with respect to their distance to a set of training genes provided by a dissimilarity matrix')
parser.add_argument('--training', required=True, help='file containing training genes or list of genes.')
parser.add_argument('--matrix', required=True, help='file in hdf5 format containing the dissimilarity matrix.')
parser.add_argument('--mapping', required=False, help='Gene mapping between training and candidates ids with the ids in the matrix.')
parser.add_argument('--candidates', required=False, help='candidates ids.')
param = parser.parse_args()

import Prioritization

# LOAD TRAINING
training = Prioritization.Identifiers(param.training)

# LOAD MAPPING IF PROVIDED
mapping = None
if param.mapping:
	mapping = Prioritization.IdentifierMap(param.mapping, filter_cgdb_prefix=True)

# LOAD CANDIDATES IF PROVIDED
candidates = None
if param.candidates:
	candidates = Prioritization.Identifiers(filename = param.candidates).ids

# LOAD MATRIX
prioritizer = Prioritization.Prioritizer(param.matrix)
pri = prioritizer.prioritize(training.ids, mapping=mapping, candidate_set=candidates)
prioritizer.display(pri)
