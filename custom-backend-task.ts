import { Resvg } from "@resvg/resvg-js";
import { mkdir, writeFile } from "node:fs/promises";
import { dirname } from "node:path";

const fontFiles = ["banners/fonts/CascadiaCode-SemiBold.ttf", "banners/fonts/Montserrat-Medium.ttf"];

/** Converts an SVG to a PNG at `path` */
export async function writePng({ path, svg }: { path: string; svg: string }): Promise<null> {
  const resvg = new Resvg(svg, {
    font: { fontFiles, loadSystemFonts: false, defaultFontFamily: "Montserrat" },
  });
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, resvg.render().asPng());
  return null;
}
