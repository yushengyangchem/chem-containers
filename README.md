# Build SIF Files

A collection of scripts to build Singularity Image Format (SIF) files for various applications.

## Included Build Scripts

```bash
g09/
g16/
orca601/
orca611/
vasp642/
vasp642-intel/
lammps22Jul2025/
molpro202420/
psi4-191/
wannier90-develop/
xtb-crest-edge/
qe75/
```

## Usage

Navigate to the desired application directory:

```bash
cd [directory_name]
```

For most directories, run the build script (need `sudo` or `root`):

```bash
./build.sh
```

For `qe75/`, build the Docker image:

```bash
docker build -t qe75 .
```

## License
This project is licensed under the **MIT** License - see the LICENSE file for details.
