import { defineConfig } from "vite";

export default {
  vite: defineConfig({}),
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/base.css" />
<script src="/theme.js"></script>
<script src="https://kit.fontawesome.com/9bc6b8da88.js"></script>
<script defer src="https://analytics.developerden.org/script.js" data-website-id="ecfb11cd-1a98-4a0e-9cbe-f25dc855bfbd"></script>
<meta name="generator" content="elm-pages v${context.cliVersion}" />
`;
  },
  preloadTagForFile(file) {
    return !file.endsWith(".css");
  },
};
