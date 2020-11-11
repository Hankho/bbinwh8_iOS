# |------------------------------ 參數 ------------------------------|
# 工程名稱
APP_NAME="wh8app"

# info.plist路徑
PROJECT_INFOPLIST_PATH="$PWD/wh8app/info-$1.plist"

# 取版本號
BUNDLE_SHORT_VERSION=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${PROJECT_INFOPLIST_PATH}")

# 取build值
BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${PROJECT_INFOPLIST_PATH}")

# 配置 .plist 的參數
REPLACE_TARGET="1,\$s/{{Target}}/$1/g"
REPLACE_TARGET_NAME="1,\$s/{{APPName}}/$2/g"
REPLACE_TARGET_VERSION="1,\$s/{{APPVersion}}/$3/g"

# 復原 .plist 的參數
RESET_TARGET="1,\$s/$1/{{Target}}/g"
RESET_TARGET_NAME="1,\$s/$2/{{APPName}}/g"
RESET_TARGET_VERSION="1,\$s/$3/{{APPVersion}}/g"
# |------------------------------ 參數 ------------------------------|


# |------------------------------ 資訊 ------------------------------|
echo "版本號 = ${BUNDLE_SHORT_VERSION}"
echo "開發版本 = ${BUNDLE_VERSION}"
# |------------------------------ 資訊 ------------------------------|


# |------------------------------ 執行 ------------------------------|

echo "================ Clean =================="

xcodebuild clean -configuration Release -alltargets

echo "=============== Archive ================="

xcodebuild -workspace wh8app.xcworkspace -scheme $1 -configuration Release -archivePath $PWD/build/$1.xcarchive CONFIGURATION_BUILD_DIR=$PWD/build/configuration_build archive

echo "================ Export ================="

# 改寫 manifest.plist
vim -c "${REPLACE_TARGET}" -c ":wq" $PWD/manifest.plist
vim -c "${REPLACE_TARGET_NAME}" -c ":wq" $PWD/manifest.plist
vim -c "${REPLACE_TARGET_VERSION}" -c ":wq" $PWD/manifest.plist

xcodebuild -exportArchive -archivePath $PWD/build/$1.xcarchive -exportOptionsPlist $PWD/manifest.plist -exportPath $PWD/build

echo "================ Reset Environment ================="

#mv $PWD/build/$1.ipa $PWD/$1_$3.ipa
# 清除打包過程中產生的build資料夾
#rm -rf build  
# 重置 manifest.plist 
vim -c "${RESET_TARGET}" -c ":wq" $PWD/manifest.plist
vim -c "${RESET_TARGET_NAME}" -c ":wq" $PWD/manifest.plist
vim -c "${RESET_TARGET_VERSION}" -c ":wq" $PWD/manifest.plist

echo Resetting Environment is finished...
Echo "  "
echo "================ Info ================="
echo "Target is $1."
echo "APP Name is $2."
echo "APP Version is $3."
echo " "
