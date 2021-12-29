const fs = require('fs')
const esbuild = require('esbuild')

const configs = {
  "client": {
    bundle: true,
    entryPoints: ["client/src/Index.mjs"],
    logLevel: "info",
    minify: true,
    outfile: "dist/bundle.js",
    sourcemap: true,
    treeShaking: true,
  },
}

// If we're run directly then we build.
if (require.main === module) {
  for (const [package, config] of Object.entries(configs)) {
    console.info(`Building ${package}...`);
    esbuild.buildSync(config);
  }
  console.info("Done")
}
else [
  module.exports = { configs }
]
