import {
    quicktype,
    InputData,
    JSONSchemaInput,
    FetchingJSONSchemaStore
} from "quicktype-core";
import path from "path";
import fs from "fs"
import { $ } from "bun";

const SCHEMA_URL = "https://cdn.jsdelivr.net/gh/TheDeveloperDen/LearningResources@master/openapi.schema.json";
const OUTPUT_DIR = path.join(__dirname, "./src");
const MODULE_NAME = "LearningResources";

async function generateElmTypes() {

    await $`bunx elm-open-api ${SCHEMA_URL} --output-dir ${OUTPUT_DIR} --module-name LearningResources`;

    // remove the generated Api.elm file since we only care about the types
    const apiFilePath = path.join(OUTPUT_DIR, "LearningResources/Api.elm");
    try {
        await fs.promises.unlink(apiFilePath);
    } catch (e) {
        // doesnt exist
    }

    console.log(`Successfully generated Elm types in ${OUTPUT_DIR}/${MODULE_NAME}`);
}

generateElmTypes().catch(error => {
    console.error("Generation failed:", error);
    process.exit(1);
});