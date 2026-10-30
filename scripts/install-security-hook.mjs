#!/usr/bin/env node
import fs from 'node:fs';import path from 'node:path';import {execFileSync} from 'node:child_process';
const root=execFileSync('git',['rev-parse','--show-toplevel'],{encoding:'utf8'}).trim();
const hook=path.resolve(root,execFileSync('git',['rev-parse','--git-path','hooks/pre-commit'],{cwd:root,encoding:'utf8'}).trim());
const marker='# aside-offline-secret-guard';
if(fs.existsSync(hook)){
 const old=fs.readFileSync(hook,'utf8');
 if(old.includes(marker)){console.log('Secret guard already installed.');process.exit(0)}
 console.error('Existing pre-commit hook preserved. Add this check manually before its exit: node scripts/check-secrets.mjs');process.exit(1);
}
fs.mkdirSync(path.dirname(hook),{recursive:true});fs.writeFileSync(hook,`#!/bin/sh\n${marker}\ncommand -v node >/dev/null 2>&1 || { echo 'Node.js is required for secret checks' >&2; exit 1; }\nnode scripts/check-secrets.mjs\n`,{mode:0o755});fs.chmodSync(hook,0o755);console.log('Installed offline secret guard. It checks the staged content before committing.');
