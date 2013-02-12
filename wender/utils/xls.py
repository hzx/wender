import os.path


THIRD_PARTY_PATH = '/home/dem/projects/third_party'
XLSX2CSV_FILE = os.path.join(THIRD_PARTY_PATH, 'xlsx2csv/xlsx2csv.py')

def xlsx2csv(src, dest):
  execute('python', XLSX2CSV_FILE, '-s', '0', '-d', "'x01'", '-p', "'\\u0001'", src, dest)

