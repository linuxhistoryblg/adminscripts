#!/bin/bash
#rpmbuilder

PACKAGE=$1
VERSION=1.0
START_PWD=${PWD}
PACKAGE_OUT=~/${PACKAGE}-BUILD/RPMS

#RPM SHOULD BE BUILD AS A NON-PRIV USER
if [ "${UID}" -eq 0 ];then
	echo "You are currently logged in as root. Please run as a non-privileged user"
	exit 1
fi

#MAKE SURE A TARGET FILE WAS PASSED IN AS AN ARG
if [ -z "$PACKAGE" ] ;then
	echo "Usage: rpmbuilder.sh <FILE TO PACKAGE>"
	exit 1
fi

#CHECK FOR NECESSARY PACKAGES IN DEV ENVIRONMENT
rpm -q rpm-build &>/dev/null
IS_RPM_BUILD_INSTALLED=$(echo $?)

rpm -q rpmdevtools &>/dev/null
IS_RPMDEVTOOLS_INSTALLED=$(echo $?)

#CHECK
if [ "${IS_RPM_BUILD_INSTALLED}" -eq 1 ];then
	echo "Missing: rpm-build"
	echo "Remediate with: yum install rpm-build"
	exit 1
fi

if [ "${IS_RPMDEVTOOLS_INSTALLED}" -eq 1 ];then
	echo "Missing: rpmdevtools"
	echo "Remediate with: yum install rpmdevtools"
	exit 1
fi

#makeenv() SETS UP BUILD ENVIRONMENT IN HOME DIRECTORY

function makeenv(){
	echo "Setting up build environment in your home directory"
	rpmdev-setuptree
}

makeenv

if [ -d ~/rpmbuild/SOURCES ];then
	cd ~/rpmbuild/SOURCES
	echo "Creating Directory ${PACKAGE}-${VERSION} in ~/rpmbuild/"
	mkdir "${PACKAGE}-${VERSION}"
else
	echo "Unable to create build directory at ~/rpmbuild/SOURCES/${PACKAGE}-${VERSION}"
	exit 1
fi

#COPY $PACKAGE INTO THE ~/rpmbuild/SOURCES/${PACKAGE}-${VERSION} DIRECTORY
echo "Copying payload into ~/rpmbuild/SOURCES/${PACKAGE}-${VERSION}/"
cp ${START_PWD}/${PACKAGE} ~/rpmbuild/SOURCES/${PACKAGE}-${VERSION}/
#CREATE A CONFIGURE FILE FOR RPM COMPLIANCE and SET ITS PERMS
touch ~/rpmbuild/SOURCES/${PACKAGE}-${VERSION}/configure && chmod 755 ~/rpmbuild/SOURCES/${PACKAGE}-${VERSION}/configure
#CREATE TARBAL OF PAYLOD
echo "Creating tarbal of payload"
tar czvf ~/rpmbuild/SOURCES/"${PACKAGE}-${VERSION}.tar.gz" "${PACKAGE}-${VERSION}"
#MOVE CLEAN SPEC FILE TO ~/rpmbuild/SPECS/
cp ~/cleanspec ~/rpmbuild/SPECS/${PACKAGE}-${VERSION}.spec
#PERFORM SED TRANSFORMATION ON SPEC FILE
sed -i -e "s/TARGET1/$PACKAGE/g" -e "s/TARGET2/$VERSION/" -e "s/TARGET3/$PACKAGE-$VERSION rpm/" -e "s/TARGET4/${PACKAGE}-${VERSION}.tar.gz/" -e "s/TARGET5/\/opt/" -e "s/TARGET6/$PACKAGE/" -e "s/TARGET7/$PACKAGE-$VERSION rpm/" ~/rpmbuild/SPECS/${PACKAGE}-${VERSION}.spec
#BUILD PACKAGE
echo "Building Package"
rpmbuild --quiet -bb ~/rpmbuild/SPECS/${PACKAGE}-${VERSION}.spec
#CREATE DIRECTORY TO HOLD BUILD RPMS
mkdir -p ${PACKAGE_OUT}
#MOVE NEW RPM TO PREVIOUSLY CREATED DIRECTORY FOR SAFEKEEPING
echo "Moving RPM to ${PACKAGE_OUT}"
mv ~/rpmbuild/RPMS/noarch/*.rpm ${PACKAGE_OUT}

exit 0
