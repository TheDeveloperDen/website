import {
	cpSync,
	existsSync,
	mkdirSync,
	readdirSync,
	rmSync,
	writeFileSync,
} from "node:fs";
import { extname, join } from "node:path";

// This script is responsible for turning the blog contents (stored in https://github.com/TheDeveloperDen/blog)
// into something that elm-pages can read.
// We either clone, or update an existing clone of the repo,
// check the `git log` to give each post a date (based on the date it was merged)
// and then copy the markdown and images into `public/` so that elm-pages can serve them.

/** Local directory where we store the blog's contents */
const BLOG_DIR = "content/blog";
/** Local directory where images get stored */
const IMAGE_OUT = "public/blog";

const BLOG_GITHUB_URL = "https://github.com/TheDeveloperDen/blog";

const IMAGE_EXTENSIONS = new Set([".png", ".jpg", ".webp"]);

console.log(`Preparing the blog!`);

if (!existsSync(BLOG_DIR)) {
	console.log(`No existing clone, cloning ${BLOG_GITHUB_URL} into ${BLOG_DIR}`);
	const clone = Bun.spawnSync(["git", "clone", BLOG_GITHUB_URL, BLOG_DIR], {
		stdio: ["inherit", "inherit", "inherit"],
	});
	if (clone.exitCode !== 0) {
		process.exit(clone.exitCode);
	}
} else {
	console.log(
		`Pulling from ${BLOG_GITHUB_URL} into existing clone in ${BLOG_DIR}`,
	);
	if (
		Bun.spawnSync(["git", "-C", BLOG_DIR, "pull", "--ff-only", "--no-rebase"])
			.exitCode !== 0
	) {
		console.warn(
			`could not update ${BLOG_DIR}, building with the posts already present`,
		);
	}
}

console.log(`Deleting old images folder ${IMAGE_OUT}`);
rmSync(IMAGE_OUT, { recursive: true, force: true });

const postsDir = join(BLOG_DIR, "posts");
if (existsSync(postsDir)) {
	console.log(`Processing posts in ${postsDir}`);
	for (const slug of readdirSync(postsDir)) {
		if (slug.startsWith("_")) {
			console.debug(`Skipping likely template post ${slug}`);
			continue;
		}

		const postDir = join(postsDir, slug);

		const postFolderContents = readdirSync(postDir, {
			withFileTypes: true,
		});
		const imagePublicDir = join(IMAGE_OUT, slug);
		for (const file of postFolderContents) {
			if (
				!file.isFile() ||
				!IMAGE_EXTENSIONS.has(extname(file.name).toLowerCase())
			) {
				console.warn(`Skipping invalid file ${file}`);
				continue;
			}
			mkdirSync(imagePublicDir, { recursive: true });
			cpSync(join(postDir, file.name), join(imagePublicDir, file.name));
			console.log(
				`Copied images from ${join(postDir, file.name)} to ${join(imagePublicDir, file.name)}`,
			);
		}
	}
} else {
	console.warn(`No posts found in ${postsDir}`);
}

const git = (...args: string[]): string => {
	const result = Bun.spawnSync(["git", "-C", BLOG_DIR, ...args]);
	if (result.exitCode !== 0)
		throw new Error(`git ${args.join(" ")} failed: ${result.stderr}`);
	return result.stdout.toString().trim();
};

// to get merge dates we need the full history. I don't see how this could happen (manual clone?) but just in case
if (git("rev-parse", "--is-shallow-repository") === "true")
	git("fetch", "--unshallow");

const published: Record<string, number> = {};
for (const slug of existsSync(postsDir) ? readdirSync(postsDir) : []) {
	// Extract a publication date for a post based on when it was merged into master
	const added = git(
		"log",
		"--first-parent", // keep merge commits rather than the PR's own commits
		"--diff-filter=A",
		"--format=%ct",
		"--",
		`posts/${slug}/index.md`,
	);
	const oldest = added.split("\n").filter(Boolean).pop(); // log is newest first
	if (oldest) {
		published[slug] = Number(oldest) * 1000; // epoch milliseconds
		console.log(
			`Marked ${slug}'s publication date as ${new Date(published[slug])}`,
		);
	} else {
		console.warn(
			`post "${slug}" isn't on the checked-out branch's history yet, so it has no publish date`,
		);
	}
}

writeFileSync("content/blog-dates.json", JSON.stringify(published, null, 2));
console.log("Preparation complete!");
