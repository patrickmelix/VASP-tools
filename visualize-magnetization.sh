#!/bin/bash
# Uses chgcar2cube.py and VMD to create a visualization of the magnetization density
# Usage: visualize-magnetization <input CHGCAR> <output.cube>
set -e

if [ -f $2 ]; then
   echo "$2 exists, skipping CHGCAR conversion!"
else
   echo "Converting CHGCAR to $2."
   dir=$(dirname $0)
   $dir/chgcar2cube.py $1 ${2%.cube}
   echo "... done."
fi

vmdfile=${2%.cube}.vmd
if [ -f $vmdfile ]; then
   echo "$vmdfile exists, skipping VMD file creation!"
else
   echo "Writing $vmdfile"
   echo "mol new $2 type cube first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all" >> $vmdfile
   echo "mol representation CPK 1.000000 0.000000 32.000000 22.000000" >> $vmdfile
   echo "mol addrep top" >> $vmdfile
   echo "mol representation DynamicBonds 2.100000 0.100000 22.000000" >> $vmdfile
   echo "mol addrep top" >> $vmdfile
   echo "mol representation Isosurface 0.05000 0 0 1 1 1" >> $vmdfile
   echo "mol color ColorID 1" >> $vmdfile
   echo "mol addrep top" >> $vmdfile
   echo "mol representation Isosurface -0.05000 0 0 1 1 1" >> $vmdfile
   echo "mol color ColorID 0" >> $vmdfile
   echo "mol addrep top" >> $vmdfile
   #echo "" >> $vmdfile
fi

echo "Run\n vmd -e $vmdfile"

