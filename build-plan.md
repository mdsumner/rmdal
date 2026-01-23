# Build plan

## 1.  Get MDAL via conda (easiest)

Gives you libmdal.so + mdalinfo CLI + headers

```bash
conda create -n mdal-dev
conda activate mdal-dev
conda install -c conda-forge mdal
```
## 2. Build from source

```bash
sudo apt-get install libgdal-dev libhdf5-dev libnetcdf-dev libxml2-dev
git clone https://github.com/lutraconsulting/MDAL.git
cd MDAL
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=ON ..
make -j4
sudo make install
```

## 3. Quick sanity check

```bash
mdalinfo --formats   # list drivers
mdalinfo /path/to/some/mesh.2dm  # inspect a file
```


## 4. Grab some test meshes

MDAL's test data: https://github.com/lutraconsulting/MDAL/tree/master/tests/data

```
2dm/ - simple mesh files
ugrid/ - NetCDF UGRID
tuflow/ - various formats
```

## 5. R 

old configure.ac should mostly work - just needs the cpp11
 
minimal cpp11 "hello world" that just calls MDAL_Version() to verify linking

