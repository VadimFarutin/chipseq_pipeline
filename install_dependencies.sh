#!/bin/bash
# Stop on error
set -e

conda create -n aquas_chipseq --file requirements.txt -y -c defaults -c bioconda -c r
conda create -n aquas_chipseq_py3 --file requirements_py3.txt -y -c defaults -c bioconda -c r

echo === Creating envs successfully done. ===

############ install additional packages
function add_to_activate {
  if [ ! -f $CONDA_INIT ]; then
    echo > $CONDA_INIT
  fi
  for i in "${CONTENTS[@]}"; do
    if [ $(grep "$i" "$CONDA_INIT" | wc -l ) == 0 ]; then
      echo $i >> "$CONDA_INIT"
    fi
  done
}

source activate aquas_chipseq

CONDA_BIN="/home/user/anaconda3/envs/aquas_chipseq/bin"
CONDA_EXTRA="$CONDA_BIN/../extra"
CONDA_ACTIVATE_D="$CONDA_BIN/../etc/conda/activate.d"
CONDA_INIT="$CONDA_ACTIVATE_D/init.sh"
mkdir -p $CONDA_EXTRA $CONDA_ACTIVATE_D

### BDS
mkdir -p $HOME/.bds
cp --remove-destination ./utils/bds_scr ./utils/bds_scr_5min ./utils/kill_scr bds.config $HOME/.bds/
cp --remove-destination -r ./utils/clusterGeneric/ $HOME/.bds/
CONTENTS=("export PATH=\$PATH:\$HOME/.bds")
add_to_activate

## PICARDROOT
cd "$CONDA_BIN/../share/picard-1.97-0/"
ln -s picard-1.97.jar picard.jar
CONTENTS=("export PICARDROOT=$CONDA_BIN/../share/picard-1.97-0")
add_to_activate

#### install Wiggler (for generating signal tracks)
cd $CONDA_EXTRA
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/align2rawsignal/align2rawsignal.2.0.tgz -N
tar zxvf align2rawsignal.2.0.tgz
rm -f align2rawsignal.2.0.tgz
CONTENTS=("export PATH=\$PATH:$CONDA_EXTRA/align2rawsignal/bin")
add_to_activate

#### install MCR (560MB)
# cd $CONDA_EXTRA
# wget http://www.broadinstitute.org/~anshul/softwareRepo/MCR2010b.bin -N
# chmod 755 MCR2010b.bin
# echo '-P installLocation="'${CONDA_EXTRA}'/MATLAB_Compiler_Runtime"' > tmp.stdin
# ./MCR2010b.bin -silent -options "tmp.stdin"
# rm -f tmp.stdin
# rm -f MCR2010b.bin
# CONTENTS=(
# "MCRROOT=${CONDA_EXTRA}/MATLAB_Compiler_Runtime/v714" 
# "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\${MCRROOT}/runtime/glnxa64" 
# "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\${MCRROOT}/bin/glnxa64" 
# "MCRJRE=\${MCRROOT}/sys/java/jre/glnxa64/jre/lib/amd64" 
# "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\${MCRJRE}/native_threads" 
# "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\${MCRJRE}/server" 
# "LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\${MCRJRE}" 
# "XAPPLRESDIR=\${MCRROOT}/X11/app-defaults" 
# "export LD_LIBRARY_PATH" 
# "export XAPPLRESDIR")
# add_to_activate

#### install run_spp.R (Anshul's phantompeakqualtool)
cd $CONDA_EXTRA
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/phantompeakqualtools/ccQualityControl.v.1.1.tar.gz -N
tar zxvf ccQualityControl.v.1.1.tar.gz
rm -f ccQualityControl.v.1.1.tar.gz
chmod 755 -R phantompeakqualtools
CONTENTS=("export PATH=\$PATH:$CONDA_EXTRA/phantompeakqualtools")
add_to_activate

conda deactivate

echo === Installing aquas_chipseq successfully done. ===

source activate aquas_chipseq_py3

if [ $? != 0 ]; then
  echo Anaconda environment not found!
  exit
fi

CONDA_BIN="/home/user/anaconda3/envs/aquas_chipseq_py3/bin"
CONDA_EXTRA="$CONDA_BIN/../extra"
mkdir -p $CONDA_EXTRA

# uninstall IDR 2.0.3 and install the latest one
conda uninstall idr -y
cd $CONDA_EXTRA
git clone https://github.com/nboley/idr
cd idr
python3 setup.py install
cd $CONDA_EXTRA
rm -rf idr

conda deactivate

echo === Installing aquas_chipseq_py3 successfully done. ===
echo === Installing dependencies successfully done. ===
