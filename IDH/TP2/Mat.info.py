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
from Prioritization import ScoreMatrix 

# SCRIPT PARAMETERS
parser = argparse.ArgumentParser(description='ScoreMatrix information dumper')
parser.add_argument('--file', required=True, help='ScoreMatrix file in HDF5 format.')
param = vars(parser.parse_args())

sm = ScoreMatrix(param['file'])
sm.print_info()
