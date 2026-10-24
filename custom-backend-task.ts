import { mkdir, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { Resvg } from "@resvg/resvg-js";
import {
	type BundledLanguage,
	codeToTokens,
	createCssVariablesTheme,
	type ThemedToken,
} from "shiki";

const fontFiles = [
	"banners/fonts/CascadiaCode-SemiBold.ttf",
	"banners/fonts/Montserrat-Medium.ttf",
];

/** Converts an SVG to a PNG at `path` */
export async function writePng({
	path,
	svg,
}: {
	path: string;
	svg: string;
}): Promise<null> {
	const resvg = new Resvg(svg, {
		font: {
			fontFiles,
			loadSystemFonts: false,
			defaultFontFamily: "Montserrat",
		},
	});
	await mkdir(dirname(path), { recursive: true });
	await writeFile(path, resvg.render().asPng());
	return null;
}

const theme = createCssVariablesTheme({
	name: "den",
	variablePrefix: "--shiki-",
	fontStyle: true,
});

/** Syntax-highlights `code` with Shiki */
export async function highlight({
	code,
	lang,
}: {
	code: string;
	lang: string;
}): Promise<ThemedToken[][]> {
	const render = (lang: string) =>
		codeToTokens(code, { lang: lang as BundledLanguage, theme });
	const { tokens } = await render(lang).catch(() => render("text"));
	return tokens;
}
