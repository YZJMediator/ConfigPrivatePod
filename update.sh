#!/bin/bash

Cyan='\033[0;36m'
Default='\033[0;m'

projectName=""
httpsRepo=""
sshRepo=""
homePage=""
confirmed="n"

getProjectName() {
    read -p "Enter Project Name: " projectName

    if test -z "$projectName"; then
        getProjectName
    fi
}

getInfomation() {
    getProjectName

    echo -e "\n${Default}================================================"
    echo -e "  Project Name  :  ${Cyan}${projectName}${Default}"
    echo -e "================================================\n"
}

echo -e "\n"
git pull origin master --tags
echo -e "\n"
echo -e "\n"

while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
do
    if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
        getInfomation
    fi
    read -p "confirm? (y/n):" confirmed
done

uploadFilePath="../${projectName}/upload.sh"
uploadExtensionFilePath="../${projectName}/upload_extension.sh"
specFilePath="../${projectName}/${projectName}.podspec"
extensionSpecFilePath="../${projectName}/${projectName}_Extension.podspec"

echo "copy to $uploadFilePath"
cp -f ./templates/upload.sh    "$uploadFilePath"
echo "copy to $uploadExtensionFilePath"
cp -f ./templates/upload_extension.sh    "$uploadExtensionFilePath"

echo "editing..."
sed -i "" "s%__ProjectName__%${projectName}%g" "$gitignoreFilePath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$uploadFilePath"
sed -i "" "s%__ProjectName__%${projectName}%g" "$uploadExtensionFilePath"

sed -i '' -e "8s/^//p; 8s/^.*/# version.gray = 0/" ${specFilePath}
sed -i '' -e "8s/^//p; 8s/^.*/# version.gray = 0/" ${extensionSpecFilePath}

sed -i '' -e "8s/^//p; 8s/^.*/# version.test = 0/" ${specFilePath}
sed -i '' -e "8s/^//p; 8s/^.*/# version.test = 0/" ${extensionSpecFilePath}

sed -i '' -e "8s/^//p; 8s/^.*/# version.develop = 0/" ${specFilePath}
sed -i '' -e "8s/^//p; 8s/^.*/# version.develop = 0/" ${extensionSpecFilePath}

echo "edit finished"

echo "finished"
