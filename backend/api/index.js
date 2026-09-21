// Plain JS on purpose: Vercel bundles this file with esbuild, which cannot emit
// the decorator metadata NestJS depends on. The Nest code is compiled ahead of
// time by `nest build` (tsc) and loaded from dist/ here.
const express = require('express');
const { createApp } = require('../dist/bootstrap');

const server = express();
let ready = null;

function init() {
  if (!ready) {
    ready = createApp(server).then((app) => app.init());
  }
  return ready;
}

module.exports = async (req, res) => {
  await init();
  return server(req, res);
};
