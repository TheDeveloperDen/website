import { defineConfig } from "vite";

export default {
  vite: defineConfig({}),
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/base.css" />
<script src="/theme.js"></script>
<script src="https://kit.fontawesome.com/9bc6b8da88.js"></script>
<meta name="generator" content="elm-pages v${context.cliVersion}" />
`;
  },
  preloadTagForFile(file) {
    return !file.endsWith(".css");
  },
};
