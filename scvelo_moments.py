import sys
import subprocess
from glob import glob
import scvelo as scv

input_dir = sys.argv[1]
output_dir = sys.argv[2]
cmd = ['mkdir', '%s'%output_dir]
subprocess.run(cmd)
input_file = glob("%s/*.loom"%input_dir)[0]
output_file = '%s/scvelo.h5ad'%output_dir
adata = scv.read_loom(input_file)
scv.pp.filter_and_normalize(adata, min_shared_counts=20)
scv.pp.moments(adata, n_pcs=30, n_neighbors=30)
scv.tl.umap(adata)
adata.write_h5ad(output_file)
