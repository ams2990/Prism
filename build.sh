#!/bin/sh

if [ $# -ne 2 ]; then
	echo 1>&2 Usage: ./build.sh branch release|none
	exit 0
fi

# checkout the latest code from trunk
#git clone git@github.com:botskonet/Prism.git
#cd Prism

# checkout the proper branch
git checkout $1

# get the git revision number
gitvers=`git describe`

cp src/main/resources/plugin.yml src/main/resources/plugin-new.yml
mv src/main/resources/plugin.yml /tmp/plugin-old.yml

name=""
if [ "$1" == "master" ]; then
	name=$gitvers
else
	name="$gitvers"
fi

nameNoV=`echo $name | cut -c 2-`

# add in revision
sed -e "s/nightly/$nameNoV/g" src/main/resources/plugin-new.yml > src/main/resources/plugin.yml
rm -f src/main/resources/plugin-new.yml

# make the jar
# handled by maven
#jar cf Prism-$name.jar README.md LICENSE items.yml languages plugin.yml -C bin .

# Build maven
mvn package

# remove the build yml
rm src/main/resources/plugin.yml

# replace the old one
mv /tmp/plugin-old.yml src/main/resources/plugin.yml

# correct jar name
mv target/prism-1.6.6-SNAPSHOT.jar target/Prism-$name.jar

# send file to amazon bucket
s3cmd put --acl-public target/Prism-$name.jar s3://botsko/Prism/Prism-$name.jar

# Create a new version file
echo $name > versions.txt

if [ "$2" == "release" ]; then

	# send file to amazon bucket
	s3cmd put --acl-public versions.txt s3://botsko/Prism/versions.txt
	# generate docs
	# javadoc -d docs-$name -sourcepath src/main/java -subpackages me.botsko.prism
fi

# Remove the files
rm versions.txt

# Send a notification to IRC.
pass=`cat pass.txt`
curl -Gd "build=$name&pass=$pass" "http://stuff.nasonfish.com/prism/build.php"

# Deploy to maven

echo "Setting Version: $nameNoV"
cp pom.xml ../pom-old.xml
mv pom.xml pom-edit.xml

# add in revision
sed -e "s/nightly/$nameNoV/g" pom-edit.xml > pom.xml
rm pom-edit.xml

# Build maven
mvn deploy

echo "BUILD COMPLETE"
