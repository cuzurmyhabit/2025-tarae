#!/usr/bin/env node
// Offline staged-file guard. Reports paths and line numbers only, never values.
import {execFileSync} from 'node:child_process';
const git=(...args)=>execFileSync('git',args,{maxBuffer:64*1024*1024});
const args=process.argv.slice(2);let paths;
try{paths=git('diff','--cached','--name-only','--diff-filter=ACMR','-z').toString().split('\0').filter(Boolean)}catch{console.error('Run this checker inside a Git worktree.');process.exit(2)}
const patterns=[
 ['OpenAI key',/\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{24,}\b/g],
 ['Google API key',/\bAIza[0-9A-Za-z_-]{35}\b/g],
 ['GitHub token',/\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b/g],
 ['AWS access key',/\b(?:AKIA|ASIA)[A-Z0-9]{16}\b/g],
 ['Slack token',/\bxox[baprs]-[A-Za-z0-9-]{20,}\b/g],
 ['Stripe secret',/\b(?:sk|rk)_live_[A-Za-z0-9]{20,}\b/g],
 ['private key',/-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----/g],
 ['credential URL',/\b(?:postgres(?:ql)?|mysql|mongodb(?:\+srv)?|redis|amqps?):\/\/[^\s:@/]+:[^\s@/]+@[^\s"'`]+/g],
 ['JWT credential',/\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b/g],
 ['hardcoded secret',/\b(?:OPENAI_API_KEY|GEMINI_API_KEY|JWT_SECRET|DB_PASSWORD|ENCRYPTION_KEY)\b\s*[:=]\s*["']([^"'\r\n]{8,})["']/g],
];
let findings=0;
for(const file of paths){
 if(/(?:^|\/)\.env(?:$|\.)/.test(file)&&! /\.env\.(?:example|sample|template)$/.test(file)){console.error(`${file}: local .env files must not be committed`);findings++;continue}
 let buf;try{buf=git('show',`:${file}`)}catch{console.error(`${file}: could not read staged content`);findings++;continue}
 if(buf.includes(0))continue;
 if(buf.length>8*1024*1024){console.error(`${file}: text exceeds 8 MiB; inspect and split before committing`);findings++;continue}
 const text=buf.toString();
 for(const [label,re] of patterns){re.lastIndex=0;for(const match of text.matchAll(re)){
  const value=match[1]||match[0];
  if(label==='credential URL'&&/(?:user:pass(?:word)?|\$\{|<[^>]+>|example\.com)/i.test(value))continue;
  if(label==='hardcoded secret'&&/^(?:\$\{|your[_-]|replace[_-]|change[_-]|example|placeholder|test-only-|unit-test-|offline-test-|not-a-real-)/i.test(value))continue;
  const line=text.slice(0,match.index).split('\n').length;console.error(`${file}:${line}: possible ${label}; remove it and rotate real exposed credentials`);findings++;
 }}
}
if(findings){console.error(`Blocked: ${findings} potential secret(s). No secret values printed.`);process.exit(1)}
console.log(`Secret guard passed: ${paths.length} staged file(s). Pattern checks are not a complete security audit.`);
