#!/bin/bash

Cyan='\033[0;36m'
Default='\033[0;m'

projectName=""
httpsRepo=""
sshRepo=""
homePage=""
confirmed="n"

# 1.获取projectName、httpsRepo、sshRepo、homePage
getProjectName() {
  read -p "Enter Project Name: " projectName

  if test -z "$projectName"; then
    getProjectName
  fi

  projectNameLength=${#projectName}
  if [ $projectNameLength -ge 31 ]; then
    echo "项目名称的长度不能大于30"
    getProjectName
  fi
}

getHTTPSRepo() {
  read -p "Enter HTTPS Repo URL: " httpsRepo

  if test -z "$httpsRepo"; then
    getHTTPSRepo
  fi
}

getSSHRepo() {
  read -p "Enter SSH Repo URL: " sshRepo

  if test -z "$sshRepo"; then
    getSSHRepo
  fi
}

getHomePage() {
  read -p "Enter Home Page URL: " homePage

  if test -z "$homePage"; then
    getHomePage
  fi
}

getInfomation() {
  getProjectName
  getHTTPSRepo
  getSSHRepo
  getHomePage

  echo -e "\n${Default}================================================"
  echo -e "  Project Name  :  ${Cyan}${projectName}${Default}"
  echo -e "  HTTPS Repo    :  ${Cyan}${httpsRepo}${Default}"
  echo -e "  SSH Repo      :  ${Cyan}${sshRepo}${Default}"
  echo -e "  Home Page URL :  ${Cyan}${homePage}${Default}"
  echo -e "================================================\n"
}

# 拉取ConfigPrivatePod仓库最新代码
echo -e "\n"
git pull origin master --tags
echo -e "\n"
echo -e "\n"

# 调用getInfomation方法获取projectName、httpsRepo、sshRepo、homePage
while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
do
  if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
    getInfomation
  fi
  read -p "confirm? (y/n):" confirmed
done

licenseFilePath="../${projectName}/FILE_LICENSE"
gitignoreFilePath="../${projectName}/.gitignore"
specFilePath="../${projectName}/${projectName}.podspec"
extensionSpecFilePath="../${projectName}/${projectName}_Extension.podspec"
readmeFilePath="../${projectName}/readme.md"
uploadFilePath="../${projectName}/upload.sh"
uploadExtensionFilePath="../${projectName}/upload_extension.sh"
podfilePath="../${projectName}/Podfile"

targetHeaderPath="../${projectName}/${projectName}/Source/Target/Target_${projectName}.h"
targetPath="../${projectName}/${projectName}/Source/Target/Target_${projectName}.m"

extensionHeaderPath="../${projectName}/${projectName}/Category/CTMediator+${projectName}.h"
extensionPath="../${projectName}/${projectName}/Category/CTMediator+${projectName}.m"

vcHeaderPath="../${projectName}/${projectName}/ViewController.h"
vcPath="../${projectName}/${projectName}/ViewController.m"

mkdir -p "../${projectName}/${projectName}/Source/Target"
mkdir -p "../${projectName}/${projectName}/Category"

echo "copy to $licenseFilePath"
cp -f ./templates_objc/FILE_LICENSE "$licenseFilePath"
echo "copy to $gitignoreFilePath"
cp -f ./templates_objc/gitignore    "$gitignoreFilePath"
echo "copy to $specFilePath"
cp -f ./templates_objc/pod.podspec  "$specFilePath"
echo "copy to $extensionSpecFilePath"
cp -f ./templates_objc/pod_extension.podspec  "$extensionSpecFilePath"
echo "copy to $readmeFilePath"
cp -f ./templates_objc/readme.md    "$readmeFilePath"
echo "copy to $uploadFilePath"
cp -f ./templates_objc/upload.sh    "$uploadFilePath"
echo "copy to $uploadExtensionFilePath"
cp -f ./templates_objc/upload_extension.sh    "$uploadExtensionFilePath"
echo "copy to $podfilePath"
cp -f ./templates_objc/Podfile      "$podfilePath"

echo "copy to $targetHeaderPath"
cp -f ./templates_objc/Target.h      "$targetHeaderPath"
echo "copy to $targetPath"
cp -f ./templates_objc/Target.m      "$targetPath"

echo "copy to $extensionHeaderPath"
cp -f ./templates_objc/Extension.h      "$extensionHeaderPath"
echo "copy to $extensionPath"
cp -f ./templates_objc/Extension.m      "$extensionPath"

echo "copy to $vcHeaderPath"
cp -f ./templates_objc/ViewController.h      "$vcHeaderPath"
echo "copy to $vcPath"
cp -f ./templates_objc/ViewController.m      "$vcPath"

echo "editing..."
sed -i "" "s%__ProjectName__%${projectName}%g" "$gitignoreFilePath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$readmeFilePath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$podfilePath"

sed -i "" "s%__ProjectName__%${projectName}%g" "$uploadFilePath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$uploadExtensionFilePath"

sed -i "" "s%__ProjectName__%${projectName}%g" "$specFilePath"
sed -i "" "s%__HomePage__%${homePage}%g"      "$specFilePath"
sed -i "" "s%__HTTPSRepo__%${httpsRepo}%g"    "$specFilePath"

sed -i "" "s%__ProjectName__%${projectName}%g" "$extensionSpecFilePath"
sed -i "" "s%__HomePage__%${homePage}%g"      "$extensionSpecFilePath"
sed -i "" "s%__HTTPSRepo__%${httpsRepo}%g"    "$extensionSpecFilePath"

sed -i "" "s%__ProjectName__%${projectName}%g" "$targetHeaderPath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$targetPath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$extensionHeaderPath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$extensionPath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$vcHeaderPath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$vcPath"

ruby add_files.rb $projectName oc 1
echo "edit finished"

echo "cleaning..."

# init初始化
cd ../$projectName
git init
git remote add origin $sshRepo  &> /dev/null
git rm -rf --cached ./Pods/     &> /dev/null
git rm --cached Podfile.lock    &> /dev/null
git rm --cached .DS_Store       &> /dev/null
git rm -rf --cached $projectName.xcworkspace/           &> /dev/null
git rm -rf --cached $projectName.xcodeproj/xcuserdata/`whoami`.xcuserdatad/xcschemes/$projectName.xcscheme &> /dev/null
git rm -rf --cached $projectName.xcodeproj/project.xcworkspace/xcuserdata/ &> /dev/null
pod update --verbose --no-repo-update
echo "clean finished"
echo "finished"

# 拷贝模板代码，上传git代码，上传到私有库
./upload.sh
