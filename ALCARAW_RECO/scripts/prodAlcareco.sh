#!/bin/bash
source $CMSSW_BASE/src/Calibration/ALCARAW_RECO/scripts/prodFunctions.sh

############################### OPTIONS
#------------------------------ default
SKIM=none
USEPARENT=0
SCHEDULER=caf
USESERVER=1
TYPE=ALCARECO
LUMIS_PER_JOBS=200  # 4000 for ZSkim events is good, WSkim events /=4, SingleElectron /=10
EVENTS_PER_JOB=50000
BLACKLIST=T2_EE_Estonia
CREATE=yes
SUBMIT=yes
OUTPUTFILE=alcareco
crabFile=tmp/alcareco.cfg

usage(){
    echo "`basename $0` options"
    echo "---------- provided by parseDatasetFile (all mandatory)"
    echo "    -r runRange"
    echo "    -d, --datasetpath path"
    echo "    -n, --datasetname name"
    echo "    --store dir"
    echo "    --remote_dir dir"
    echo "---------- optional"
    echo "    --isMC: specify is the dataset is MC"
    echo "    -s skim: ZSkim, WSkim, EleSkim"
    echo "    --scheduler caf,lsf,remoteGlidein (=${SCHEDULER})"
    echo "    --createOnly"
    echo "    --submitOnly"
    echo "    --check"
    echo "    --json_name jsonName: additional name in the folder structure to keep track of the used json"
    echo "    --json jsonFile.root: better to not use a json file for the alcareco production"
    echo "----------"
    echo "    --tutorial: tutorial mode, produces only one sample in you user area"
    echo "    --develRelease: CRAB do not check if the CMSSW version is in production (only if you are sure what you are doing)"
}




#------------------------------ parsing
# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -u -o hd:n:s:r: -l help,datasetpath:,datasetname:,skim:,runrange:,store:,remote_dir:,scheduler:,isMC,submit,white_list:,black_list:,createOnly,submitOnly,check,json:,json_name:,tutorial,develRelease -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

while [ $# -gt 0 ]
do
    case $1 in
	-h|--help) usage; exit 0;;
	-d|--datasetpath) DATASETPATH=$2; shift ;;
	-n|--datasetname) DATASETNAME=$2; shift ;;
	-s|--skim) SKIM=$2 ; shift;;
	-r|--runrange) RUNRANGE=$2; shift;;
	--store) STORAGE_ELEMENT=$2; shift;;
	--remote_dir) USER_REMOTE_DIR_BASE=$2; shift;;
	--scheduler) SCHEDULER=$2; shift;;
	--isMC) TYPE=ALCARECOSIM;;
	--white_list) WHITELIST=$2; shift;;
	--black_list) BLACKLIST=$2; shift;;
	--createOnly) unset SUBMIT;;
	--submitOnly) echo "[OPTION] submitOnly"; unset CREATE;;
	--check)      echo "[OPTION] checking jobs"; unset CREATE; unset SUBMIT; CHECK=y; EXTRAOPTION="--check";;
 	--json) JSONFILE=$2;  shift;;
	--json_name) JSONNAME=$2; shift;;
        --tutorial)   echo "[OPTION] Activating the tutorial mode"; TUTORIAL=y;;
	--develRelease) echo "[OPTION] Request also CMSSW release not in production!"; DEVEL_RELEASE=y;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage >> /dev/stderr; exit 1;;
    (*) break;;
    esac
    shift
done

#------------------------------ checking
if [ -z "$DATASETPATH" ];then 
    echo "[ERROR] DATASETPATH not defined" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
fi

if [ -z "$DATASETNAME" ];then 
    echo "[ERROR] DATASETNAME not defined" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
else
    echo "[INFO] DATASETNAME=${DATASETNAME}"

fi

if [ -z "$RUNRANGE" ];then 
    echo "[ERROR] RUNRANGE not defined" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
fi

if [ -z "$STORAGE_ELEMENT" ];then 
    echo "[ERROR] STORAGE_ELEMENT not defined" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
fi


if [ -z "$USER_REMOTE_DIR_BASE" ];then 
    echo "[ERROR] USER_REMOTE_DIR_BASE not defined" >> /dev/stderr
    usage >> /dev/stderr
    exit 1
else
    echo "[INFO] USER_REMOTE_DIR_BASE=${USER_REMOTE_DIR_BASE}"
fi


if [ -n "${TUTORIAL}" ];then
    case $DATASETPATH in
	/RelVal*)
	    ;;
	*)
	    echo "[ERROR] With the tutorial mode, the only permitted datasetpath is:"
	    echo "        /RelVal*"
	    echo "        Be sure to have it in alcareco_datasets.dat and to have selected it using the parseDatasetFile.sh"
	    exit 1
	    ;;
    esac
    USER_REMOTE_DIR_BASE=${USER_REMOTE_DIR_BASE}/tutorial/$USER
    echo "============================================================"
    echo "= [INFO] With the tutorial mode, the output goes into the directory:"
    echo "=       ${USER_REMOTE_DIR_BASE}"
    echo "= --> Please, remember to remove it after the tests (ask to shervin@cern.ch)"
    /bin/sleep 5s
fi

###############################

#------------------------------

if [ -z "${SKIM}" ];then
    case $DATASETPATH in
	*DoubleElectron*)
	    SKIM=ZSkim
	    ;;
	*SingleElectron*USER)
	    SKIM=fromWSkim
	    ;;
	*SingleElectron*)
	    SKIM=WSkim
	    ;;
	*ZElectron*)
	    SKIM=ZSkim
	    ;;
    esac
fi

case $DATASETPATH in
    *SingleElectron*USER)
	let LUMIS_PER_JOBS=${LUMIS_PER_JOBS}/4
	;;
esac

case $SKIM in
    ZSkim)
	;;
    *)
	EVENTS_PER_JOB=20000
	;;
esac

#Setting the ENERGY variable
setEnergy $DATASETPATH

setStoragePath $STORAGE_ELEMENT $SCHEDULER 

if [ -z "${CHECK}" ];then checkRelease ${DATASETPATH}; fi

USER_REMOTE_DIR=$USER_REMOTE_DIR_BASE/${ENERGY}/${DATASETNAME}/${RUNRANGE:-allRange}
UI_WORKING_DIR=prod_alcareco/${DATASETNAME}/${RUNRANGE}

if [ "$RUNRANGE" == "allRange" -o "`echo $RUNRANGE |grep -c -P '[0-9]+-[0-9]+'`" == "0" ];then
    unset RUNRANGE
fi


#==============================
cat > ${crabFile} <<EOF
[CRAB]
#use_server = $USESERVER
jobtype = cmssw
scheduler = $SCHEDULER

[LSF]
queue = 1nd
[CAF]
queue = cmscaf1nd


[CMSSW]
datasetpath=${DATASETPATH}

pset=python/alcaSkimming.py
pycfg_params=output=${OUTPUTFILE}.root skim=${SKIM} type=$TYPE jsonFile=${JSONFILE}

runselection=${RUNRANGE}
split_by_run=0
EOF

if [ "$TYPE" == "ALCARECOSIM" ];then
    cat >> tmp/alcareco.cfg <<EOF
total_number_of_events = -1
events_per_job=${EVENTS_PER_JOB}
EOF

else
    cat >> tmp/alcareco.cfg <<EOF
total_number_of_lumis = -1
lumis_per_job=${LUMIS_PER_JOBS}
EOF
fi

if [ -n "${DEVEL_RELEASE}" ]; then
cat >> tmp/alcareco.cfg <<EOF
allow_NonProductionCMSSW = 1
EOF
fi

###
cat >> tmp/alcareco.cfg <<EOF
#output_file=${OUTFILES}
get_edm_output=1
check_user_remote_dir=1
use_parent=${USEPARENT}

[USER]
ui_working_dir=$UI_WORKING_DIR
return_data = 0
copy_data = 1
local_stage_out = 1
storage_element=$STORAGE_ELEMENT
user_remote_dir=$USER_REMOTE_DIR
storage_path=$STORAGE_PATH


thresholdLevel=80
eMail = shervin@cern.ch

[GRID]

rb = HC
rb = CERN
proxy_server = myproxy.cern.ch
#se_white_list=$WHITELIST
se_black_list=$BLACKLIST
EOF



if [ -n "${CREATE}" ];then
crab -cfg ${crabFile} -create || exit 1
./scripts/splittedOutputFilesCrabPatch.sh -u ${UI_WORKING_DIR}
#crabMonitorID.sh -r ${RUNRANGE} -n $DATASETNAME -u ${UI_WORKING_DIR} --type ALCARECO
fi

if [ -n "$SUBMIT" ]; then
    crab -c ${UI_WORKING_DIR} -submit all
elif [ -z "${CHECK}" ];then
    echo "##############################"
    echo "To start the crab jobs:"
    echo "crab -c ${UI_WORKING_DIR} -submit all"
fi


if [ -n "${CHECK}" ];then
    resubmitCrab.sh -u ${UI_WORKING_DIR}
    if [ ! -e "${UI_WORKING_DIR}/res/finished" ];then
	#echo $dir >> tmp/$TAG.log 
	echo "[STATUS] Unfinished ${UI_WORKING_DIR}"
#    else
#	mergeOutput.sh -u ${UI_WORKING_DIR}
    fi
#    echo "mergeOutput.sh -u ${UI_WORKING_DIR} -n ${DATASETNAME} -r ${RUNRANGE}"
fi

################
#echo "###############"
#echo "# crab config file created in tmp/alcareco.cfg"
#echo "# now create the crab job and submit it"
#echo "crab -cfg tmp/alcareco.cfg -create -submit"
