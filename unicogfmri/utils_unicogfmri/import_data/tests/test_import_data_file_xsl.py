"""
Test script to import data from the 3T at Neurospin
xsl version
:Author: Denghien Isabelle
"""

import os

from unicogfmri.import_data import import_and_convert_dicom


######  Parameters to change ###############################################
#path where you want to put data
main_dir = '/neurospin/unicog/protocols/IRMf/Unicogfmri/test'
xls_file = '/neurospin/unicog/protocols/IRMf/Unicogfmri/localizer/importation_data/acquisitions_summary_localizer.xls'
scanner='3T'
############################################################################


if not os.path.exists(main_dir):
  os.makedirs(main_dir)

# fetch information for subject
acquisitions = ""
if os.path.isfile(xls_file):
    acquisitions = import_and_convert_dicom.init_xls(xls_file, scanner)
    print acquisitions
    
#importation and conversion    
if acquisitions:   
  acquisitions = import_and_convert_dicom.fetch_acquisitions(acquisitions, main_dir)
  import_and_convert_dicom.convert_all_dicoms(acquisitions, main_dir)
else:
    print "Nothing to do "
    
