const { configs } = require("./build")
const esbuild = require('esbuild')

for (const [package, config] of Object.entries(configs)) {
  console.info(`Watching ${package}...`);
  esbuild
    .build({
      ...config,
      minify: false,
      watch: true,
    })
    .then(result => [
      process.on('SIGINT', () => result.stop())
    ]);
}