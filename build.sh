#!/bin/bash
#
# Copyright (C) 2021 Project Kasumi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

export rom="kasumi"
export target="bandori"
export LINEAGE_BUILDTYPE=OFFICIAL

echo "// Build script for Project Kasumi //"
echo ""

echo "Please give device codename."
read device
echo ""

echo "Now the build type. (user/userdebug/eng)"
echo "/ user is a production build and doesn't allow basic debugging features."
echo "/ userdebug is a debuggable build and enables basic debugging features. It migjt also render SELinux as Permissive for some devices."
echo "/ eng is an engineer build type and is used for extra verbosal in logs. Though, it might block several commands to be run."
read type
echo ""

if [ -d out/target/product/${device} ]
then
    echo "You're going to build for a device you already built, do you want to remove staging images aka do installclean first?"
    read needsinstallclean
    echo ""
fi

echo "Build is starting. Good luck, father!"
echo ""
. build/envsetup.sh
lunch ${rom}_${device}-${type}
make ${target} otatools target-files-package
echo ""

echo "Now I'm going to sign your build. Please wait. :3"
echo ""
export outdir=out/target/product/${device}
export unsigned_finalzip_path=$(ls "${outdir}"/*$(date +%Y)*.zip | tail -n -1)
echo "."

mv "$unsigned_finalzip_path" "${unsigned_finalzip_path}.unsigned"
echo "."

sign_target_files_apks -o -d vendor/priv $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip $OUT/signed-target_files.zip
echo "."

ota_from_target_files -k vendor/priv/releasekey --block --backup=true $OUT/signed-target_files.zip $OUT/$(basename "$unsigned_finalzip_path")
echo "."
echo ""

echo "Now I'm all done~! Do you want me to upload it?"
read upload
echo ""
if [ ${upload} = "yes" ]
then
    gdrive upload $OUT/$(basename "$unsigned_finalzip_path")
    echo ""
    echo "Alright, now it's on your Google Drive root~! Hope tests go well~!"
else
    echo "Alright then, however you want~! :3"
fi
echo ""
