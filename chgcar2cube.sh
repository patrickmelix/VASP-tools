#!/bin/bash
# Wrapper script for TST chg2cube.sh script
# Usage: chgcar2cube.sh <input CHGCAR> <output.cube>
set -e

if [ -z "${2}" ]; then
	echo "Usage: ${0} <input CHGCAR>"\
	"<output.cube>"
	exit 1
fi

if [ ! -f "${1}" ]; then
	echo "File ${1} not found!"
	exit 1
fi
if [ -f "${2}" ]; then
	echo "File ${2} exists!"
	exit 1
fi
if [ ! -f "POSCAR" ]; then
	echo "I need a POSCAR file in $(pwd)!"
	exit 1
fi

PYCMD=$(cat <<EOF
from ase import io
mol = io.read('POSCAR')
numbers = []
for i,atom in enumerate(mol):
   if i == 0:
      numbers.append(atom.number)
   else:
      n = atom.number
      if numbers[-1] == n:
         continue
      else:
         numbers.append(n)
#numbers = list(set(mol.get_atomic_numbers()))
n = len(numbers)
s = "{:} "*n
print(s.format(*numbers))
EOF
)

echo "Reading POSCAR."
numbers=$(python3 -c "$PYCMD")
echo "Found the following elements: $numbers"

echo -n "Running chg2cube.pl, no need to interfere. Just be patient..."
chg2cube.pl $1 $2 <<EOF > /dev/null
1
$numbers
EOF
echo "... done!"
