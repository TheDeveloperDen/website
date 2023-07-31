# TODO make sure js2e is installed
# This also doesn't work because js2e is broken lol. keeping it here for now

wget https://raw.githubusercontent.com/TheDeveloperDen/LearningResources/master/resources/resource.schema.json -O resource.schema.json
js2e resource.schema.json
cp -r js2e_output/src/Data src
rm -rf js2e_output
rm resource.schema.json
